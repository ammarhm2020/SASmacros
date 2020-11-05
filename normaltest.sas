*****************************************************************************;
************************    Normality Test Macro:    ************************;
*****************************************************************************;
/*
notes/documentation

indata:		input dataset name

outdata:	name of dataset macro will produce containing output

var:		list of continuous variable names to perform test of normality on

by:			optional, if test of normality is to be done separately for the by-groups

test:		1=Shapiro Wilk, 2=Kolmogorov-Smirnov, 3=Cramer-von Mises, 4=Anderson-Darling, or 
			blank(output all 4 p-values)

WARNING: option 1, Shapiro-Wilk will NOT produce a test value if sample size is over 2000!

print:		by default=Y, automatically prints output, specifying a value other than Y
			supresses the output

*/
*---------------------------------Libraries---------------------------------*;


*---------------------------------------------------------------------------*;
********************************** Macros: **********************************;
*---------------------------------------------------------------------------*;

%macro normaltest(indata=, outdata=, var=, by=, test=, print=Y);
run; ods listing close; run;

*test=1: Shapiro-Wilk;
*test=2: Kolmogorov-Smirnov;
*test=3: Cramer-von Mises;
*test=4: Anderson-Darling;
*test=blank, unspecified, anything else, gives all 4;

*-------------------------------------------------------*;
*** Running proc univariate to perform normality test ***;
*optional sort*;
%if &by^=  %then %do;
proc sort data=&indata;
by &by;
%end;

proc univariate data=&indata normal;
by &by;
var &var;
ods output TestsForNormality=_tfn;
run;
*-------------------------------------------------------*;


*-----------------------------------------------------*;
*** Organizing output dataset, selecting which test ***;
data _tfn(keep= &by varname p_normal test psign_normal pvalue_normal);
set _tfn;
length p_normal $ 10;
p_normal=compress(psign,' ')||compress(round(pvalue,0.0001),' ');
rename psign=psign_normal pvalue=pvalue_normal;
label varname='Analysis variable';
run;

%if &test=1 %then %do;
data _tfn(drop= test);
set _tfn;
if test='Shapiro-Wilk';
label p_normal='Shapiro-Wilk p';
%end;

%if &test=2 %then %do;
data _tfn(drop= test);
set _tfn;
if test='Kolmogorov-Smirnov';
label p_normal='Kolmogorov-Smirnov p';
%end;

%if &test=3 %then %do;
data _tfn(drop= test);
set _tfn;
if test='Cramer-von Mises';
label p_normal='Cramer-von Mises p';
%end;

%if &test=4 %then %do;
data _tfn(drop= test);
set _tfn;
if test='Anderson-Darling';
label p_normal='Anderson-Darling p';
%end;

proc sort data=_tfn; by VarName; run;
proc transpose data=_tfn out=_tfn2(DROP=_NAME_) ;
    by VarName ;
    id test;
    var p_normal;
run;



data &outdata;
set _tfn2;
label psign_normal='non-numeric prefix to p-value' pvalue_normal='p-value(numeric only)';
*-----------------------------------------------------*;


run; ods listing; run;


*-----------------------------*;
*** Optional printed output ***;
%if &print=Y %then %do;
proc print data=&outdata noobs l;
run;
%end;
*-----------------------------*;


*--------------------------------------------*;
**delete temporary working datasets in macro**;
proc datasets library=work nolist nowarn;
delete _tfn;
delete _tfn2;
run;
quit;
*--------------------------------------------*;


%mend;

run;
*-------------------------------------------------------------------------------*;
*-------------------------------------------------------------------------------*;
*********************************************************************************;
