/* file: pyrsstep.sas */

/* authored by Klaus Rostgaard, klp@ssi.dk, 02AUGUST2013,           */
/* Department of Epidemiology Research, Statens Serum Institut,     */
/* Copenhagen, Denmark.                                             */

/* This file primarily contains a SAS macro for stratification and  */
/* aggregation of person-years and events called stratify.          */

/* This macro is an attempt to provide most of the functionality    */
/* you would ever need to stratify data by time-varying covariates  */
/* in survival regression analysis, especially Poisson regression,  */
/* Cox regression and SIR/SMR analyses.                             */

/* You can get an idea of its capabilities and way of working by    */
/* looking at the open-access online paper called EPI_REV3 below.   */
/* EPI_REV3 is: Rostgaard K. Methods for stratification of          */
/* person-time and events - a prerequisite for Poisson regression   */
/* and SIR estimation. Epidemiologic Perspectives and Innovations   */
/* 2008;5:7 available at:                                           */
/* http://www.epi-perspectives.com/content/5/1/7                    */

/* However, with this version of the macro, most of the             */
/* post-processing presented in EPI_REV3 can be avoided, so you     */
/* might as well look at the manual right away.                     */

/* The user interface of the stratify macro is very similar to a    */
/* SAS procedure. We have therefore provided an accompanying manual */
/* (stratifymanual.pdf) for the macro, loosely styled as the        */
/* documentation of SAS procedures by SAS Institute.                */

/* Included is also                                                 */
/*     - some sample program code                                   */
/*     - macros for converting dates to decimal-years               */

/* If you prefer to learn to use the stratify macro by applying it  */
/* in toy examples, we suggest you copy some of the examples at the */
/* bottom of this file into another file and then take this new     */
/* file as the starting point for experiments. You will of course   */
/* have to run the macro first, for example by executing this file  */
/* or running an include statement regarding this file.             */

/* If you find bugs in whatever is the latest version of these      */
/* macros, please let me know. This is an ongoing project which     */
/* continually creates and fixes bugs.                              */





%macro stratify (indstr,data,out,eventdat,outcomes,rates,eventvalues,
                 mode,complete,method,scale,birthdate,eventtime,time,
                 subject,value,valuec,expevent,eventtype,noeventvalue,
                 granularity,coxorigin,chunksize);

/* Do not be scared by the long list of positional parameters ...          */
/* you are not going to specify all that in that order. It is just part    */
/* of a technical fix of a SAS inconsistency.                              */

/*        data =            Data set containing the fundamental variables  */
                         /*    entry, exit and possibly needed             */
                         /*    constant characteristics of the given       */
                         /*    person within the interval [entry,exit),    */
                         /*    e.g. gender, birthday, race, ... This is a  */
                         /*    mandatory variable, defaulting to _last_.   */
                         /*    When using &expdat or &outcomes it also has */
                         /*    to contain &subject. It may also contain    */
                         /*    information on outcomes when &mode=s,c.     */
/*         out =            Where to put the result, defaults to &data.    */
/*     expdats =            A list of data sets containing exposure        */
                         /*    information in a particular format. It      */
                         /*    contains the variables &subject, &time,     */
                         /*    &expevent, &value, &valuec. If not used     */
                         /*    any of the latter two can be omitted from   */
                         /*    a given data set.                           */
/*    eventdat =            If used this data set contains one record for  */
                         /*    each outcome event in &out, containing the  */
                         /*    variables in &out and those specified by    */
                         /*    &eventID, with the values at the time of    */
                         /*    the event. Can be used to scrutinize or     */
                         /*    further characterise the outcome events.    */
                         /*    Defaults to be absent.                      */
/*    outcomes =            Data set containing outcome events. Mandatory  */
                         /*    using &mode=m. Otherwise outcomes may be    */
                         /*    situated in &data or be completely absent.  */
                         /*    &outcomes must contain &subject, &eventtime */
                         /*    and when &mode=c,m also &eventtype.         */
/* eventvalues =            Data set containing all and the only values    */
                         /*    of &eventtype in the variable &eventtype    */
                         /*    that will be considered outcome events. The */
                         /*    unique values will be extracted by the      */
                         /*    macro. Needed when &mode=i,c,m or &rates is */
                         /*    specified. Defaulting to &rates, then       */
                         /*    &outcomes, then &data.                      */
/*       rates =            Data set containing reference rates of         */
                         /*    occurrence for some values of &eventtype.   */
                         /*    When &complete=yes this is used to          */
                         /*    calculate expected occurrences of events    */
                         /*    place in the variable expected. If &method  */
                         /*    =NOAGG the relevant rate is assigned to     */
                        /*     each follow-up interval instead.The dataset */
                         /*    must contain the variables rate, &eventtype */
                         /*    and precisely those other variables used to */
                         /*    cross-classify rates and these variables    */
                         /*    must be retained or generated in the macro  */
                         /*    with the same names. In case of no match    */
                         /*    the relevant follow-up interval is dropped. */
                         /*    The variable rate should be scaled          */
                         /*    according to &scale. I.e. if entry/exit is  */
                         /*    in days, and &scale=365.25 then rate should */
                         /*    be events per year.                         */
/*   eventtime = eventtime  The variable holding the time of occurrence of */
                         /*    outcome events.                             */
/*     subject =            Identifies the variable in &data, &expdats and */
                         /*    &outcomes containing the identification of  */
                         /*    the study subjects. Needed when &expdats or */
                         /*    &outcomes are used.                         */
/*        time = time       Identifies the variable in &expdats providing  */
                         /*    the time of occurrence of exposure events.  */
/*    expevent = expevent   Identifies the character variable in &expdats  */
                         /*    containing the exposure events. The macro   */
                         /*    is insensitive to different lengths of      */
                         /*    &expevent in different data sets.           */
/*       value = value      Name of variable carrying numeric attributes   */
                         /*    in the &expdat data sets.                   */
/*      valuec = valuec     Name of variable carrying character attributes */
                         /*    in the &expdat data sets.                   */
/*   birthdate = birthdate  Identifies the variable in &data that should   */
                         /*    be used for calculating age at exposure     */
                         /*    event. Only needed when specifying v=a in   */
                         /*    some zrtf statement.                        */
/* granularity = 1          Specifies how finely the timing of exposures   */
                         /*    is known. Relevant when &mode=s,c,m where   */
                         /*    follow-up is terminated at &eventtime       */
                         /*    + &granularity.                             */
/*        mode = s          Determines the mode of follow-up. There are    */
                         /*    four possibilities with various             */
                         /*    abbreviations:                              */
                         /*    s(ing(le))                                  */
                         /*    m(ult(iple))                                */
                         /*    c(omp(eting))                               */
                         /*    i(ntens(ity))                               */
                         /*    Single is the default, where we are waiting */
                         /*    for a single outcome and follow-up is       */
                         /*    terminated thereafter by the macro.         */
                         /*    Competing is similar (for competing risks   */
                         /*    analysis) but here we also need to record   */
                         /*    the type of outcome event in &eventtype.    */
                         /*    Multiple allows the recording of the first  */
                         /*    occurrence of each of several outcomes,     */
                         /*    typed by &eventtype. Follow-up after the    */
                         /*    occurrence of an outcome event of type      */
                         /*    &eventtype produces records marked by       */
                         /*    &eventtype for each outcome event, so that  */
                         /*    these contributions may later be subtracted */
                         /*    from the relevant analysis. Finally         */
                         /*    &mode=intensity allows any number of        */
                         /*    outcome events typed by &eventtype and has  */
                         /*    no effect on follow-up.                     */
/*    complete = yes        Yes/no-variable designating the amount of      */
                         /*    post-processing performed by the macro.     */
                         /*    Setting it to no requires you to program    */
                         /*    the manipulation of &out into a useful form */
                         /*    but &out may be much smaller than it would  */
                         /*    otherwise be.                               */
/*   eventtype = eventtype  Name of the variable containing the type of    */
                         /*    outcomes. Used when &mode=c,m,i. Should be  */
                         /*    in the &outcomes data set, but can be in    */
                         /*    &data when &mode=c,i.                       */
/* noeventvalue=            The value assigned &eventtype to designate     */
                         /*    person-time contributions. Used when        */
                         /*    &mode=c,m,i. A hierarchy of defaults exist  */
                         /*    that will make it extremely unlikely that   */
                         /*    you need to specify this in order to avoid  */
                         /*    interference with your range of eventvalues */
/*      method = fst        Determines the method used for aggregation of  */
                         /*    the event-time table. Choices are: fst,     */
                         /*    arr, sum, chunk and noagg. In the latter    */
                         /*    case no aggregation occurs - no pyrs and    */
                         /*    events are counted and the variables entry  */
                         /*    and exit are kept. Records for events are   */
                         /*    signalled by exit=.   This type of output   */
                         /*    is easily adapted for Cox regression.       */
/*   chunksize = 5000       Used only with method=chunk. This method is a  */
                         /*    variant of the sum method which stratifies  */
                         /*    and aggregates data in chunks of input data */
                         /*    usually a little larger than &chunksize     */
                         /*    obs in order to avoid generating gigantic   */
                         /*    temporary data sets.                        */
/*       scale = 365.25     Scale relation between time units for time     */
                         /*    points and cutpoints/PYRS. E.g. scale       */
                         /*    should be 365.25 if time points (entry,     */
                         /*    exit, origins) are SAS dates, and cutpoints */
                         /*    are given as years from the origins.        */
                         /*    When using v=a in zrtf statements, this     */
                         /*    scaling is also used.                       */
/*   coxorigin =            Variable or constant denoting the origin of    */
                         /*    the primary time scale in a Cox-regression  */
                         /*    on the time scale of entry/exit. Only in    */
                         /*    effect with &method=noagg and &complete=yes */
                         /*    and can be unspecified if you are on the    */
                         /*    right time scale (unlikely).                */
/*     eventID =            Extra variable(s) identifying and/or           */
                         /*    characterising the event in &eventdat,      */
                         /*    defaults to be absent.                      */
/*        drop =            Variables that can be dropped in &out after    */
                         /*    calculation of expected. Only in effect     */
                         /*    when &rates are specified. With all         */
                         /*    &methods except noagg &out is aggregated    */
                         /*    over &dropvars.                             */
/*       class =            List of stratifying variables to appear in     */
                         /*    &out retained from &data.                   */
/*       zrtf1 =            See below for the specification of statements  */
                         /*    for generating zero-rate time factors.      */
/*       srtf1 =            See below for the specification of statements  */
                         /*    for generating simple-rate time factors.    */
/*       axis1 =            See below for the specification of statements  */
                         /*    for generating unity-rate/simple-rate time  */
                         /*    factors.                                    */

/* The format of a zrtf statement is:                                      */
/* zrtf variablename l=  v=  c=  n=  g=  m=  ;                             */
/* the variablename and values for v and c are mandatory if the statement  */
/* is used. The order of the components following zrtf variablename is     */
/* immaterial. When used the value of each of these are assigned to an     */
/* appropriate macro variable. We exemplify by zrtf1 below.                */
/* To make the code less cryptic some of these one-letter specifications   */
/* can be expanded: v=val=value, l=len=length, c=cond=condition, g=groups, */
/* m=miss=missing.                                                         */
/*         zrtf1 = ,        Variable to get the value from the calculation */
/*                             of the 1st zero-rate time factor.           */
/*       length1 = ,        Length of zrtf1.                               */
/*         cond1 = ,        The value of the character variable &expevent  */
/*                             that will trigger the (re-)evaluation of    */
/*                             &zrtf1. It must NOT contain any signs       */
/*                             (commas, parantheses,semi-colons..) that    */
/*                             might conflict with signs used in the       */
/*                             interface of this macro and must be placed  */
/*                             in double quotes. Case-sensitive.           */
/*            n1 = L,       Which occurrence of &cond1 that will trigger   */
/*                             the (re-)evaluation of &zrtf1. Possible     */
/*                             values are f,first,l,last or any integer>0, */
/*                             where 1 means first, 2 means second etc.    */
/*        value1 = ,        The value assigned to &zrtf1 before grouping.  */
/*                             Possible values are:                        */
/*                             v (value),                                  */
/*                             s (sum of value so far, initially 0),       */
/*                             i (indicator that &cond1 and &n1 has        */
/*                                happened),                               */
/*                             n (number of occurrences of &cond1)         */
/*                             cv (valuec),                                */
/*                             t (&time),                                  */
/*                             a (age at occurrence of &cond1 and &n1).    */
/*       groups1 = ,        For a numeric variable the specification is as */
/*                             for &cuts1 or a format. If missing or below */
/*                             the lowest cut point a missing value is     */
/*                             assigned. For a character variable it is a  */
/*                             format. If unspecified no grouping occurs.  */
/*         miss1 = ,        Value of zrtf1 when missing.                   */
/*                             Blanks and commas must not appear in the    */
/*                             text when specifying values for missing     */
/*                             text strings.                               */

/* The format of a srtf statement is:                                      */
/* srtf variablename t= v= s= c=  ;                                        */
/* the variablename and a value for s are mandatory if the statement is    */
/* used. The order of the components following srtf variablename is        */
/* immaterial. The macro uses the statement to specify the calculation     */
/* of a relevant origin in the data step before stratifying and            */
/* aggregating according to simple-rate and zero-rate time factors, and    */
/* then transforms the statement to the equivalent axis-statement.         */
/* The one-letter specifications can be expanded: t=time, v=val=value,     */
/* s=speed, c=cuts. What you specify is the value (v=...) of the           */
/* simple-rate time factor (variablename) at the last time (t=...) the     */
/* simple rate (s=...) changed. The simple-rate time factor shall be       */
/* stratified as specified by the cutpoints (c=...) as in an axis          */
/* statement. Typically the variables specifying t and v will be generated */
/* in zrtf statements. Unless saved by other means all the zrtf variables  */
/* that are used in srtf statements will not appear in the final output    */
/* - we assume they were only needed as intermediates. Unless both v and t */
/* are specified the macro assumes that the value of the srtf variable is  */
/* 0 in an individual until and including the time when s is first set.    */
/* In that case the value of the SRTF variable thereafter is incremented   */
/* according to the timing and value of s exclusively.                     */

/* The format of an axis statement is:                                     */
/* axis variablename o= c= s=  ;                                           */
/* the variablename and values for c and o are mandatory if the statement  */
/* is used. The order of the components following axis variablename is     */
/* immaterial. When used the value of each of the components are
/* assigned to an appropriate macro variable. We exemplify by axis1 below. */
/* To make the code less cryptic some of these one-letter specifications   */
/* can be expanded: o=origin, c=cuts, s=speed.                             */
/*       axis1 = ,          Variable to get left endpoints of cuts1        */
/*     origin1 = ,          Origin of the 1st time scale. A Mandatory      */
/*                             argument.                                   */
/*       cuts1 = ,          Specification of the cutpoints on the 1st time */
/*                             scale. Either X to Z by Y or X1 X2 X3 ..    */
/*                             A mandatory argument.                       */
/*      speed1 = 1,         Numeric variable or constant. If 0 axis1 is    */
/*                             set to value at entry.                      */


/* The following variables are mandatory in the input data (&data) with    */
/* the following meaning:                                                  */
/*         entry: entry time, start of follow-up.                          */
/*          exit: exit time, end of follow-up.                             */
/* The following variables are generated in output data with               */
/* the following meaning:                                                  */
/*        events: number of events in a cell/observation                   */
/*          pyrs: person-time at risk in a cell/observation                */
/*      expected: expected number of events in a cell/observation          */
/* If you use method=noagg another type of output occurs (see above).      */

/* All output data sets contains the following variables:                  */
/* &class {zrtfX (where valueX ne T and not used in a srtf statement)}     */
/* {axisX} {srtfX}. Plus some more:                                        */
/* &out: events, pyrs [when method=fst, arr, sum, chunk]                   */
/* &out: entry, exits [when method=noagg]
/* &out: expected [when &rates is specified]                               */
/* &eventdat: &eventID [when &eventdat is not null]                        */

/* Macro creates/overwrites the following variables:                       */
/* _yr, _next, _segment_, _entry, _exit, _schluss_, _qwertyuiopasdfghjkl_, */
/* asdfgjkdgfasgkfasd, _in_Eventtypeproposal_, _in_Eventtype_range_ ,      */
/* _noeventvalue_proposal_, _qwertyuiopasdfghjkl2_, _qwertyuiopasdfghjkl3_ */
/* _orig_{srtfname}, {srtfname}_vr, {srtfname}_tr, {srtfname}_sr,          */
/* _temp_{zrtfname}, &axis1, ..., &axisN, _origin1, ..., _originN,         */
/* _p1, ..., _pN, _d1, ..., _dN, where N is the number of executed axis    */
/* statements. _p1, ..., _pN are again used if you specify rates N         */
/* designating the number of variables-1 in &rates.                        */
/* _p0 is used if you have multiple outcomes and use &complete=y.          */
/* If you use &rates and &mode=s the variables _cumevents, _cumpyrs and    */
/* _cumexpected are generated. If you use &rates and method=noagg the      */
/* generated rates will be from your &rate dataset.                        */
/* If you use &complete=y and &method=noagg then variable censored is      */
/* generated.                                                              */

/* The following temporary data sets may be generated:                     */
/* Thank_you_for_using_XXX XXX=zrtfX, fstpyrs, arrpyrs, sumpyrs, noagg,    */
/* noaggX, chunkpyrs, valid_values, This_methodX,                          */
/* Thank_you_for_using_valueX, Thank_you_for_using_valid_values,           */
/* X=0,1,2,... _pyrso, _rindat                                             */

****** SEPARATING THE INPUT STATEMENT INTO THE BASIC TYPES ******;

%let lastdataset=&syslast ; * for later use ;
%let notes=%sysfunc(getoption(notes));
options nonotes;

data _null_; x=datetime(); call symput('timestratifystart',left(put(x,f20.0))); run;

* The first part terminating in defining indstr is a work around an inconsistent;
* SAS macro interface.                                                          ;

%if %length(&data        )>0 %then %let indstr=options data=&data ;
%if %length(&out         )>0 %then %let indstr=options out=&out ;
%if %length(&eventdat    )>0 %then %let indstr=options eventdat=&eventdat ;
%if %length(&outcomes    )>0 %then %let indstr=options outcomes=&outcomes ;
%if %length(&rates       )>0 %then %let indstr=options rates=&rates ;
%if %length(&mode        )>0 %then %let indstr=options mode=&mode ;
%if %length(&complete    )>0 %then %let indstr=options complete=&complete ;
%if %length(&method      )>0 %then %let indstr=options method=&method ;
%if %length(&scale       )>0 %then %let indstr=options scale=&scale ;
%if %length(&birthdate   )>0 %then %let indstr=options birthdate=&birthdate ;
%if %length(&eventtime   )>0 %then %let indstr=options eventtime=&eventtime ;
%if %length(&time        )>0 %then %let indstr=options time=&time ;
%if %length(&subject     )>0 %then %let indstr=options subject=&subject ;
%if %length(&value       )>0 %then %let indstr=options value=&value ;
%if %length(&valuec      )>0 %then %let indstr=options valuec=&valuec ;
%if %length(&expevent    )>0 %then %let indstr=options expevent=&expevent ;
%if %length(&eventtype   )>0 %then %let indstr=options eventtype=&eventtype ;
%if %length(&noeventvalue)>0 %then %let indstr=options noeventvalue=&noeventvalue ;
%if %length(&granularity )>0 %then %let indstr=options granularity=&granularity ;
%if %length(&chunksize   )>0 %then %let indstr=options chunksize=&chunksize ;
%if %length(&coxorigin   )>0 %then %let indstr=options coxorigin=&coxorigin;
%if %length(&eventvalues )>0 %then %let indstr=options eventvalues=&eventvalues ;

data _null_; length indstr tail first $32000; retain maxstrlength (0);
 indstr=symget('indstr');
 dimaxis=0;
 dimsrtf=0;
 dimzrtf=0;
 dimbad=0;
 i=1;
 tail=scan(indstr,i,';');
 l=length(tail);
 do while (tail ne '');
   if l>maxstrlength then maxstrlength=l;
   first=upcase(scan(tail,1,' '));
   if substr(first,1,1)='*' then first='*';
   if first='AXIS' then dimaxis=dimaxis+1;
   if first='SRTF' then dimsrtf=dimsrtf+1;
   if first='ZRTF' then dimzrtf=dimzrtf+1;
   if not (first in ('*','AXIS','SRTF','ZRTF','EXPDATS','EVENTID','CLASS','OPTIONS','DROP')) then dimbad=dimbad+1;
   if first='*' and i=1 then dimbad=dimbad+1;
   if first ne '*' and indexc(tail,'*')>0 then dimbad=dimbad+1;
   i=i+1;
   tail=scan(indstr,i,';');
   l=length(tail);
 end;
 call symput('no_of_strings',put(i-1,f5.));
 call symput('dno_of_strings',put(max(i-1,1),f5.));
 call symput('maxstrlength',put(maxstrlength,f5.));
 call symput('dimaxis',put(dimaxis,f5.));
 call symput('daxis',put(max(dimaxis,1),f5.));
 call symput('dimsrtf',put(dimsrtf,f5.));
 call symput('dsrtf',put(max(dimsrtf,1),f5.));
 call symput('dimzrtf',put(dimzrtf,f5.));
 call symput('dzrtf',put(max(dimzrtf,1),f5.));
 call symput('dimbad',put(dimbad,f5.));
 call symput('dbad',put(max(dimbad,1),f5.));
run;

data _null_;
 length indstr $32000;
 array _str (1:&no_of_strings) $ &maxstrlength;
 array _axis (1:&daxis) $ &maxstrlength;
 array _srtf (1:&dsrtf) $ &maxstrlength;
 array _zrtf (1:&dzrtf) $ &maxstrlength;
 array _bad  (1:&dno_of_strings) $ &maxstrlength;
 length options class eventid expdats dropvars str1 str2 $ &maxstrlength;
 indstr=symget('indstr');
 axis=0;
 srtf=0;
 zrtf=0;
 bad=0;
 class='';
 eventid='';
 expdats='';
 options='';
 do i=1 to &no_of_strings;
    str1=scan(indstr,i,';');
    str2=upcase(scan(str1,1,' '));
    if substr(str2,1,1)='*' then str2='*';
    if i=1 and str2='*' then str2='Schlecht';
    if str2 ne '*' and indexc(str1,'*')>0 then str2='Schlecht';
    pos=indexc(upcase(str1),'ACDEOSZ');
    select(str2);
       when('AXIS') do; axis=axis+1; _axis(axis)=substr(str1,pos+5); end;
       when('SRTF') do; srtf=srtf+1; _srtf(srtf)=substr(str1,pos+5); end;
       when('ZRTF') do; zrtf=zrtf+1; _zrtf(zrtf)=substr(str1,pos+5); end;
       when('EVENTID')  eventid=substr(str1,pos+8);
       when('DROP')     dropvars=substr(str1,pos+5);
       when('CLASS')    class=substr(str1,pos+6);
       when('EXPDATS')  expdats=substr(str1,pos+8);
       when('OPTIONS')  options=substr(str1,pos+8);
       when('*')  ;
       otherwise do; bad=bad+1; _bad(bad)=str1; end;
    end;
 end;
 call symput('bad',put(bad,f5.));
 call symput('class',class);
 call symput('eventid',eventid);
 call symput('dropvars',dropvars);
 call symput('expdats',expdats);
 call symput('options',options);
 %do i=1 %to &dimaxis; call symput("axis&i",_axis(&i)); %end;
 %do i=1 %to &dimsrtf; call symput("srtf&i",_srtf(&i)); %end;
 %do i=1 %to &dimzrtf; call symput("zrtf&i",_zrtf(&i)); %end;
 %do i=1 %to &dimbad ; call symput("bad&i",_bad(&i)); %end;
run;



******* PARSING THE OPTIONS *******;

data _null_;
 length options hlpstr data out eventdat outcomes mode method scale birthdate
        eventtime subject expevent value valuec time eventtype
        noeventvalue granularity chunksize str1 str2 str3 badoptions
        scalediv scalemul coxorigin eventvalues rates complete pyrsdata $ &maxstrlength;
 length badmode badmethod badchunksize badgranularity badscale badcomplete badeventvalues badsubject
        badcoxorigin $80 badmission $120
        pyrsdatasetname $32 complete_rates_agg_multi eventvaluesrates ratesmulti ratessingle $8;
 options=symget('options');
 i=1;
 str1=scan(options,i,' ');
 hlpstr=str1;
 do while (str1 ne '');
   i=i+1;
   str2=scan(options,i,' ');
   if (str1 ne '=' and str2='=') or (str1='=' and str2 ne '=') then hlpstr=trim(hlpstr)||str2;
      else hlpstr=trim(hlpstr)||' '||str2;
   str1=str2;
 end;
 i=1;
 str1=scan(hlpstr,i,' ');
 do while (str1 ne '');
    str2=upcase(scan(str1,1,'='));
    str3=scan(str1,2,'=');
    select (str2);
     when ('DATA') data=str3;
     when ('OUT') out=str3;
     when ('EVENTDAT') eventdat=str3;
     when ('OUTCOMES') outcomes=str3;
     when ('MODE') mode=str3;
     when ('METHOD') method=str3;
     when ('SCALE') scale=str3;
     when ('BIRTHDATE') birthdate=str3;
     when ('EVENTTIME') eventtime=str3;
     when ('TIME') time=str3;
     when ('SUBJECT') subject=str3;
     when ('VALUE') value=str3;
     when ('VALUEC') valuec=str3;
     when ('EXPEVENT') expevent=str3;
     when ('EVENTTYPE') eventtype=str3;
     when ('NOEVENTVALUE') noeventvalue=str3;
     when ('GRANULARITY') granularity=str3;
     when ('CHUNKSIZE') chunksize=str3;
     when ('COXORIGIN') coxorigin=str3;
     when ('EVENTVALUES') eventvalues=str3;
     when ('RATES') rates=str3;
     when ('COMPLETE') complete=str3;
     when ('OPTIONS') ;
     otherwise badoptions=trim(badoptions)||' '||trim(str1);
    end;
    i=i+1;
    str1=scan(hlpstr,i,' ');
 end;

 if data=''        then data=symget('lastdataset');
 if out=''         then out=data;
 if eventvalues='' then eventvalues=rates;
 if eventvalues='' then eventvalues=outcomes;
 if eventvalues='' then eventvalues=data;
 if eventtype=''   then eventtype='eventtype';
 if expevent=''    then expevent='expevent';
 if eventtime=''   then eventtime='eventtime';
 if value=''       then value='value';
 if valuec=''      then valuec='valuec';
 if birthdate=''   then birthdate='birthdate';
 if time=''        then time='time';

 if eventvalues='' and rates='' then eventvaluesrates='NN';
 if eventvalues ne '' and rates='' then eventvaluesrates='YN';
 if eventvalues='' and rates ne '' then eventvaluesrates='NY';
 if eventvalues ne '' and rates ne '' then eventvaluesrates='YY';

 if scale=''       then scale='365.25';
 if input(scale,f20.) le 0
    then do;
     badscale="Illegal value for option SCALE found. Default value (365.25) retained." ;
     scale='365.25';
    end;
 if input(scale,f20.) ne 1 then do;
    scalediv='/'||trim(scale);
    scalemul='*'||trim(scale);
 end;

 if granularity='' then granularity='1';
 if input(granularity,f20.) le 0
    then do;
     badgranularity="Illegal value for option GRANULARITY found. Default value (1) retained." ;
     granularity='1';
    end;

 if chunksize=''   then chunksize='5000';
 if not (input(chunksize,f20.)>0 and input(chunksize,f20.)=floor(input(chunksize,f20.)))
    then do;
     badchunk="Illegal value for option CHUNKSIZE found. Default value (5000) retained." ;
     chunksize='5000';
    end;

 if mode=''        then mode='S';
 if upcase(mode) in ('S','SING','SINGLE','M','MULT','MULTIPLE',
                     'I','INTENS','INTENSITY','C','COMP','COMPETING')
   then mode=upcase(substr(mode,1,1));
   else do;
     badmode="Illegal value for option MODE found. Default value (single) retained." ;
     mode='S';
   end;

 if method=''      then method='FST';
 if upcase(method) in ('FST','ARR','SUM','CHUNK','NOAGG') then method=upcase(method);
   else do;
     badmethod="Illegal value for option METHOD found. Default value (fst) retained." ;
     method='FST';
   end;
 pyrsdatasetname='Thank_you_for_using_'||trim(method)||'pyrs';
 if method='NOAGG' then pyrsdatasetname='Thank_you_for_using_NOAGG';

 if complete=''    then complete='Y';
 if upcase(complete) in ('YES','Y','NO','N') then complete=upcase(substr(complete,1,1));
   else do;
     badcomplete="Illegal value for option COMPLETE found. Default value (yes) retained.";
     complete='Y';
   end;

 if complete='Y' and method='NOAGG' and mode='I' then do;
   * badmission='Sorry, no built-in post-processing for this combination of MODE and METHOD. Option COMPLETE set to N.';
   * complete='N';
 end;

 if method='NOAGG' and complete='Y' and coxorigin='' then badcoxorigin='ERROR: A Value for option COXORIGIN is needed.';
 if not (method='NOAGG' and complete='Y') then coxorigin='';

 if complete='N' then rates='';

 needeventtype=1-(mode='S');
 if needeventtype=1 and eventvalues='' then badeventvalues="ERROR: A value for option EVENTVALUES is needed.";

 if rates='' then complete_rates_agg_multi=trim(complete)||'N';
             else complete_rates_agg_multi=trim(complete)||'Y';
 if method='NOAGG' then complete_rates_agg_multi=trim(complete_rates_agg_multi)||'N';
                   else complete_rates_agg_multi=trim(complete_rates_agg_multi)||'Y';
 if mode='S' then complete_rates_agg_multi=trim(complete_rates_agg_multi)||'N';
             else complete_rates_agg_multi=trim(complete_rates_agg_multi)||'Y';
 if complete_rates_agg_multi in ('NNYY','NNYN','NNNN','NNNY','YNYN') then do; pyrsdata=out; call symput('postprocess','N'); end;
    else do; pyrsdata=pyrsdatasetname; call symput('postprocess','Y'); end;

 if mode in ('I','C','M') and rates ne '' then ratesmulti='Y'; else ratesmulti='N';
 if mode in ('S') and rates ne '' then ratessingle='Y'; else ratessingle='N';
 if not (complete_rates_agg_multi in ('YYYY','YYYN')) then call symput('dropvars','');

 needsubject=((outcomes ne '') or (&dimzrtf gt 0) or (method='NOAGG'));
 if needsubject and subject='' then badsubject='ERROR: A value for option SUBJECT is needed.';

 call symput('needsubject',needsubject);
 call symput('badsubject',badsubject);
 call symput('pyrsdata',pyrsdata);
 call symput('pyrsdatasetname',pyrsdatasetname);
 call symput('badmode',badmode);
 call symput('badmethod',badmethod);
 call symput('badchunksize',badchunksize);
 call symput('badgranularity',badgranularity);
 call symput('badscale',badscale);
 call symput('badcomplete',badcomplete);
 call symput('data',data);
 call symput('out',out);
 call symput('eventdat',eventdat);
 call symput('outcomes',outcomes);
 call symput('mode',mode);
 call symput('method',method);
 call symput('scale',scale);
 call symput('birthdate',birthdate);
 call symput('eventtime',eventtime);
 call symput('time',time);
 call symput('subject',subject);
 call symput('value',value);
 call symput('valuec',valuec);
 call symput('expevent',expevent);
 call symput('eventtype',eventtype);
 call symput('noeventvalue',noeventvalue);
 call symput('granularity',granularity);
 call symput('chunksize',chunksize);
 call symput('badoptions',badoptions);
 call symput('scalediv',scalediv);
 call symput('scalemul',scalemul);
 call symput('coxorigin',coxorigin);
 call symput('complete',complete);
 call symput('eventvalues',eventvalues);
 call symput('rates',rates);
 call symput('needeventtype',put(needeventtype,f1.));
 call symput('badeventvalues',badeventvalues);
 call symput('badcoxorigin',badcoxorigin);
 call symput('complete_rates_agg_multi',complete_rates_agg_multi);
 call symput('eventvaluesrates',eventvaluesrates);
 call symput('ratesmulti',ratesmulti);
 call symput('ratessingle',ratessingle);
 call symput('badmission',badmission);
run;

%if &method=NOAGG %then %let class=&subject &class;

******* PARSING ZRTF, SRTF AND AXIS STATEMENTS *****;



data Thank_you_for_using_stratify0; length orgstr $ &maxstrlength stmtype $4;
%do i=1 %to &dimaxis; stmtype='axis'; dimtype=&i; orgstr=left(symget("axis&i")); output; %end;
%do i=1 %to &dimzrtf; stmtype='zrtf'; dimtype=&i; orgstr=left(symget("zrtf&i")); output; %end;
%do i=1 %to &dimsrtf; stmtype='srtf'; dimtype=&i; orgstr=left(symget("srtf&i")); output; %end;
run;

data Thank_you_for_using_stratify0(keep=cond);
 length hlpstr name origin cuts speed value time missing groups g4 n
        badaxis badsrtf badzrtf
        arg argname
        str1 str2 bingo $ &maxstrlength;
 length badcuts badsrtfcuts $31
        badsrtfspeed $32
        badvaluezrtf $45
        badlengthzrtf $56
        badmissingzrtf $47
        badcondzrtf $60
        badgroupszrtf $46
        badnzrtf $41
        badnameaxis badnamezrtf badnamesrtf $33 ;
 set Thank_you_for_using_stratify0;

 name=scan(orgstr,1,' ');
 namelength=length(name);
 orgstr=substr(orgstr,namelength+1);
 i=1;
 str1=scan(orgstr,i,' ');
 hlpstr=str1;
 do while (str1 ne '');
   i=i+1;
   str2=scan(orgstr,i,' ');
   lengthstr1=length(str1);
   if (str1 ne '=' and substr(str2,1,1)='=') or
      (substr(str1,lengthstr1,1)='=' and str2 ne '=') then hlpstr=trim(hlpstr)||str2;
      else hlpstr=trim(hlpstr)||' '||str2;
   str1=str2;
 end;
 * the above manipulations normalise 'a =   1 2  4 b=5    c=   6' into 'a=1 2 3 b=5 c=6' ;

 do while(hlpstr ne ''); **** ASSIGN THE ARGUMENTS IN EACH STATEMENT ****;
   argname=left(upcase(scan(hlpstr,1,'=')));
   l=index(hlpstr,'=');
   if l>0 then hlpstr=substr(hlpstr,l+1);
   l=index(hlpstr,'=');
   if l>0 then do;
      arg=substr(hlpstr,1,l-1);
      u=l-1;
      do while(substr(arg,u,1) ne ' ' and u>0); u=u-1; end;
      arg=substr(arg,1,u);
   end;
   else arg=hlpstr;

   if stmtype='axis' then do;
     select (argname);
       when ('ORIGIN') origin=arg;
       when ('ORIG') origin=arg;
       when ('O') origin=arg;
       when ('SPEED') speed=arg;
       when ('S') speed=arg;
       when ('CUTS') cuts=arg;
       when ('C') cuts=arg;
       otherwise badaxis=trim(badaxis)||' '||argname;
     end;
   end;
   if stmtype='srtf' then do;
     select (argname);
       when ('SPEED') speed=arg;
       when ('S') speed=arg;
       when ('CUTS') cuts=arg;
       when ('C') cuts=arg;
       when ('VALUE') value=arg;
       when ('VAL') value=arg;
       when ('V') value=arg;
       when ('TIME') time=arg;
       when ('T') time=arg;
       otherwise badsrtf=trim(badsrtf)||' '||argname;
     end;
   end;
   if stmtype='zrtf' then do;
     select(argname);
       when('VALUE') value=arg;
       when('VAL') value=arg;
       when('V') value=arg;
       when('CONDITION') cond=arg;
       when('COND') cond=arg;
       when('C') cond=arg;
       when('N') n=arg;
       when('MISSING') missing=arg;
       when('MISS') missing=arg;
       when('M') missing=arg;
       when('LENGTH') length=arg;
       when('LEN') length=arg;
       when('L') length=arg;
       when('GROUPS') groups=arg;
       when('G') groups=arg;
       otherwise badzrtf=trim(badzrtf)||' '||argname;
     end;
   end;

   hlpstr=substr(hlpstr,length(arg)+1);

 end; **** END ASSIGN THE ARGUMENTS IN EACH STATEMENT ****;


 if stmtype='axis' then do;
    if nvalid(name)=0
      then badnameaxis='ERROR: illegal AXIS variable name';
    if speed=''    then speed='1';
      * - ORIGIN is checked later ;
    if cuts=''
      then badcuts='ERROR: missing or bad AXIS cuts';
    type=0;
    if scan(upcase(cuts),2,' ')='TO' then type=1;
    if type=1 then do;
       if scan(upcase(cuts),4,' ') ne 'BY'
          then badcuts='ERROR: missing or bad AXIS cuts';
       if not ( .<input(scan(cuts,1,' '),f20.)<input(scan(cuts,3,' '),f20.))
          then badcuts='ERROR: missing or bad AXIS cuts';
       if input(scan(cuts,5,' '),f20.)<0
          then badcuts='ERROR: missing or bad AXIS cuts';
       if lengthn(scan(cuts,6,' '))>0
          then badcuts='ERROR: missing or bad AXIS cuts';
    end;
    if type=0 then do;
       prevelement=input(scan(cuts,1,' '),f20.);
       if prevelement=.
          then badcuts='ERROR: missing or bad AXIS cuts';
       i=2;
       do while(lengthn(scan(cuts,i,' '))>0);
          if input(scan(cuts,i,' '),f20.) le prevelement
             then badcuts='ERROR: missing or bad AXIS cuts';
          prevelement=input(scan(cuts,i,' '),f20.);
          i=i+1;
       end;
    end;
 end;
 if stmtype='srtf' then do;
    if nvalid(name)=0
      then badnamesrtf='ERROR: illegal SRTF variable name';
    if nvalid(speed)=0
      then badsrtfspeed='ERROR: missing or bad SRTF speed';
    if cuts=''
      then badsrtfcuts='ERROR: missing or bad SRTF cuts';
    type=0;
    if scan(upcase(cuts),2,' ')='TO' then type=1;
    if type=1 then do;
       if scan(upcase(cuts),4,' ') ne 'BY'
          then badsrtfcuts='ERROR: missing or bad SRTF cuts';
       if not ( .<input(scan(cuts,1,' '),f20.)<input(scan(cuts,3,' '),f20.))
          then badsrtfcuts='ERROR: missing or bad SRTF cuts';
       if input(scan(cuts,5,' '),f20.)<0
          then badsrtfcuts='ERROR: missing or bad SRTF cuts';
       if lengthn(scan(cuts,6,' '))>0
          then badsrtfcuts='ERROR: missing or bad SRTF cuts';
    end;
    if type=0 then do;
       prevelement=input(scan(cuts,1,' '),f20.);
       if prevelement=.
          then badsrtfcuts='ERROR: missing or bad SRTF cuts';
       i=2;
       do while(lengthn(scan(cuts,i,' '))>0);
          if input(scan(cuts,i,' '),f20.) le prevelement
             then badsrtfcuts='ERROR: missing or bad SRTF cuts';
          prevelement=input(scan(cuts,i,' '),f20.);
          i=i+1;
       end;
    end;
 end;
 if stmtype='zrtf' then do;
    if nvalid(name)=0
      then badnamezrtf='ERROR: illegal ZRTF variable name';
    if n='' then n='L';
    if n='l' then n='L';
    if upcase(n)='F' then n='1';
    if n ne 'L' and (input(n,f20.)<1 or (mod(input(n,f20.),1) ne 0))
      then badnzrtf='ERROR: illegal value for ZRTF n parameter';
    value=upcase(value);
    if not (value in ('I','N','S','T','V','CV','A'))
      then badvaluezrtf='ERROR: illegal value for ZRTF value parameter';
    if length ne '' then do;
       if value in ('I','N','S','T','V','A') then do;
          if not (input(length,f20.) ge 3 and mod(input(length,f20.),1)=0)
          then badlengthzrtf='WARNING: illegal value for ZRTF length parameter ignored';
       end;
       if value='CV' then do;
          if not (substr(length,1,1)='$' and
          input(substr(compress(length),2) ,f20.) ge 3
          and mod(input(substr(compress(length),2),f20.),1)=0)
          then badlengthzrtf='WARNING: illegal value for ZRTF length parameter ignored';
       end;
       if badlengthzrtf ne '' then length='';
    end;
    if missing ne '' then do;
      if value='CV' and not (lengthn(missing)>2 and substr(missing,1,1)='"'
                 and substr(missing,length(missing),1)='"' )
         then badmissingzrtf='ERROR: illegal value for ZRTF missing parameter';
    if value in ('I','N','S','T','V','A') then do;
       if not (input(missing,f20.)>. or missing='.' or missing='._' or
         (lengthn(missing)=2 and '.A' le upcase(missing) le '.Z') )
         then badmissingzrtf='ERROR: illegal value for ZRTF missing parameter';
       end;
    end;
    if not (lengthn(cond)>2 and substr(cond,1,1)='"'
                 and substr(cond,length(cond),1)='"' )
      then badcondzrtf='ERROR: missing or illegal value for ZRTF condition parameter';
    type=0;
    bingo=trim(scan(groups,1,' '));
    if length(bingo)=index(bingo,'.')>0 then type=1;
    if type=1 and substr(bingo,1,1)='$' then type=2;
    if type=0 and scan(upcase(groups),2,' ')='TO' then type=3;
    if type=0 and lengthn(bingo)>0 then do;
      type=4;
      i=2;
        do while (input(scan(groups,i,' '),f20.)>.);
          bingo=trim(bingo)||','||scan(groups,i,' ');
          i=i+1;
        end;
      g4=groups;
      groups=bingo;
    end;
    if type=3 then do;
       if scan(upcase(groups),4,' ') ne 'BY'
          then badgroupszrtf='ERROR: illegal value for ZRTF groups parameter';
       if not ( .<input(scan(groups,1,' '),f20.)<input(scan(groups,3,' '),f20.))
          then badgroupszrtf='ERROR: illegal value for ZRTF groups parameter';
       if input(scan(groups,5,' '),f20.)<0
          then badgroupszrtf='ERROR: illegal value for ZRTF groups parameter';
       if lengthn(scan(groups,6,' '))>0
          then badgroupszrtf='ERROR: illegal value for ZRTF groups parameter';
    end;
    if type=4 then do;
       prevelement=input(scan(g4,1,' '),f20.);
       if prevelement=.
          then badgroupszrtf='ERROR: illegal value for ZRTF groups parameter';
       i=2;
       do while(lengthn(scan(g4,i,' '))>0);
          if input(scan(g4,i,' '),f20.) le prevelement
          then badgroupszrtf='ERROR: illegal value for ZRTF groups parameter';
          prevelement=input(scan(g4,i,' '),f20.);
          i=i+1;
       end;
    end;
 end;


 %do i=1 %to &dimaxis;
  if dimtype=&i and stmtype='axis' then do;
     call symput("axis&i",name);
     call symput("origin&i",origin);
     call symput("cuts&i",cuts);
     call symput("speed&i",speed);
     call symput("badnameaxis&i",badnameaxis);
     call symput("badcuts&i",badcuts);
  end;
 %end;
 %do i=1 %to &dimsrtf;
  if dimtype=&i and stmtype='srtf' then do;
     call symput("srtf&i",name);
     call symput("srtfcuts&i",cuts);
     call symput("srtfspeed&i",speed);
     call symput("srtfvalue&i",value);
     call symput("t&i",time);
     call symput("badnamesrtf&i",badnamesrtf);
     call symput("badsrtfcuts&i",badsrtfcuts);
     call symput("badsrtfspeed&i",badsrtfspeed);
  end;
 %end;
 %do i=1 %to &dimzrtf;
  if dimtype=&i and stmtype='zrtf' then do;
     call symput("zrtf&i",name);
     call symput("n&i",n);
     call symput("cond&i",cond);
     call symput("groups&i",groups);
     call symput("gtype&i",put(type,f1.));
     call symput("value&i",value);
     call symput("miss&i",missing);
     call symput("length&i",length);
     call symput("badnamezrtf&i",badnamezrtf);
     call symput("badvaluezrtf&i",badvaluezrtf);
     call symput("badlengthzrtf&i",badlengthzrtf);
     call symput("badcondzrtf&i",badcondzrtf);
     call symput("badgroupszrtf&i",badgroupszrtf);
     call symput("badmissingzrtf&i",badmissingzrtf);
     call symput("badnzrtf&i",badnzrtf);
  end;
 %end;
 if stmtype='zrtf';
run;

%let maxlengthexpevent=8;
%let expeventvalues="a dummy";

%if %eval(&dimzrtf>0) %then %do;

proc sort nodupkey; by cond; run;

data _null_;
 length str $32000;
 retain str ('') len (1);
 set Thank_you_for_using_stratify0 end=flag;
 if _n_=1 then str=cond;
 if _n_>1 then str=trim(str)||','||cond;
 len=max(len,length(cond)-2);
 if flag then do;
    call symput("expeventvalues",str);
    len=8*ceil(len/8); * we assume it is wise to use a multiplum of 8;
    call symput("maxlengthexpevent",put(len,f20.));
 end;
run;

%end;



******* FINISH PARSE SRTF STATEMENTS ******;

%let orgdimaxis=&dimaxis;
%let startval=%eval(&dimaxis +1);
%let dimaxis=%eval(&dimaxis + &dimsrtf);
%let keepsimplesrtflist= ;


%do i=&startval %to &dimaxis;
  %let q=%eval(&i -&startval +1);
  %let name=&&srtf&q ;
  %let axis&i=&name;
  %let cuts&i=&&srtfcuts&q;
  %let origin&i=_orig_&name;
  %let srtforigin&q=_orig_&name;
  %let speed&i=&&srtfspeed&q;
  %let srtfflag&q=0;
  %if %length(&&srtfvalue&q)=0 or %length(&&t&q)=0 %then %let srtfflag&q=1;
  %if &&srtfflag&q=1  %then %do;
      %let thelp&q=&name._tr;
      %let srtfvaluehelp&q=&name._vr;
      %let srtfspeedhelp&q=&name._sr;
      %let keepsimplesrtflist=&keepsimplesrtflist &name._tr &name._vr;
  %end;
%end;



***** FINISH PARSE ZRTF STATEMENTS *****;

%let zrtfvars= ;
%let numzrtfvars= ;
%let zrtfvars_to_keep= ;
%do i=1 %to &dimzrtf;
  %let name=&&zrtf&i;
  %let zrtfvars=&zrtfvars &name ;
  %let hit=0;
  %if &&value&i=CV %then %let hit=1;
  %if &hit=0 %then %let numzrtfvars=&numzrtfvars &name;
  %let hit=0;
  %if &&value&i =T %then %let hit=1;
  %do q=1 %to &dimsrtf;
    %if %upcase(&&t&q)=%upcase(&name) %then %let hit=1;
    %if %upcase(&&srtfvalue&q)=%upcase(&name) %then %let hit=1;
    %if %upcase(&&srtfspeed&q)=%upcase(&name) %then %let hit=1;
    %if %upcase(&&srtforigin&q)=%upcase(&name) %then %let hit=1;
  %end;
  %if &hit=0 %then %let zrtfvars_to_keep=&zrtfvars_to_keep &name;
%end;

proc datasets nolist;
 contents data=&data out=Thank_you_for_using_stratify0 (keep=name type) noprint;
quit;

data _null_;
 length helpstr1 helpstr2 $32000 target1 target2 $50 badclass $200;
 retain helpstr1 helpstr2 ('','') badclass ('');
 set Thank_you_for_using_stratify0 end=endflag;
 if _n_=1 then helpstr1=symget('zrtfvars');
 helpstr1=trim(helpstr1)||' '||name;
 if endflag then do;
    helpstr2=symget('class');
    i=1;
    target2=upcase(scan(helpstr2,i,' '));
    found=0;
    do while ( target2 ne '');
      j=1;
      target1=upcase(scan(helpstr1,j,' '));
      do while (target1 ne '' and found=0);
         if target1=target2 then found=1;
         j=j+1;
         target1=upcase(scan(helpstr1,j,' '));
      end;
      if found=0 and j=2 and scan(helpstr1,1,' ')='' then found=1;
      if found=0 then badclass=trim(badclass)||' '||target2;
      i=i+1;
      target2=upcase(scan(helpstr2,i,' '));
      found=0;
    end;
    call symput("badclass",badclass);
 end;
run;


%if %length(&coxorigin)>0 %then %do;

data _null_;
 length helpstr1  $32000 target1 target2 target3 $50 badcoxorigin $200;
 retain helpstr1 ('') badcoxorigin ('');
 set Thank_you_for_using_stratify0 end=endflag;
 if _n_=1 then helpstr1=symget('numzrtfvars');
 if type=1 then helpstr1=trim(helpstr1)||' '||name;
 if endflag then do;
    target2=symget('coxorigin');
    target3=symget('data');
    found=2*(&coxorigin > .); * numeric constant;
    j=1;
    target1=upcase(scan(helpstr1,j,' '));
    do while (target1 ne '' and found=0);
      if target1=upcase(target2) then found=1;
      j=j+1;
      target1=upcase(scan(helpstr1,j,' '));
    end;
    if found=0 then badcoxorigin=
            'ERROR: COXORIGIN '||trim(target2)||' not numeric or not found in '||trim(target3)||' or ZRTF statement';
    call symput("badcoxorigin",badcoxorigin);
    call symput("addcoxorigin",put(found,f1.));
 end;
run;

%if &addcoxorigin=1 %then %let class=&class &coxorigin;

%end;




%if &orgdimaxis %then %do;

data _null_;
 length helpstr1 $32000 target target1 badorigin b1 b2 b3 $80;
 retain helpstr1 ('');
 set Thank_you_for_using_stratify0 end=endflag;
 if _n_=1 then helpstr1=symget('numzrtfvars');
 if type=1 then helpstr1=trim(helpstr1)||' '||name;
 if endflag then do;
   do i=1 to &orgdimaxis;
    target=left(upcase(symget('origin'||compress(put(i,f4.)))));
    j=1;
    target1=upcase(scan(helpstr1,j,' '));
    found=0;
    do while (target ne '' and target1 ne '' and found=0);
      if target=target1 then found=1;
      j=j+1;
      target1=upcase(scan(helpstr1,j,' '));
    end;
    if target='' then badorigin='ERROR: missing AXIS origin';
    if target ne '' and found=1 then badorigin='';
    if target ne '' and found=0 then badorigin='1';
    call symput('badorigin'||compress(put(i,f4.)),badorigin);
   end;
 end;
run;

%do i=1 %to &orgdimaxis;
%if &&badorigin&i=1 %then %let badorigin&i=%sysfunc(nmiss(&&origin&i));
%if &&badorigin&i=0 %then %let badorigin&i= ;
%if &&badorigin&i=1 %then %let badorigin&i=ERROR: bad AXIS origin ;
%if &&badorigin&i=. %then %let badorigin&i=ERROR: bad AXIS origin ;
%end;

%end;




proc sql; drop table Thank_you_for_using_stratify0; quit;










******** MISCELLANEOUS AND COMMUNICATION OF ERRORS ********;

%if &eventdat= %then %let eventID= ;
%let needvalue=0;
%let needvaluec=0;
%let needbirthdate=0;
%do i=1 %to &dimzrtf;
    %if %upcase(&&value&i)=V %then %let needvalue=1;
    %if %upcase(&&value&i)=S %then %let needvalue=1;
    %if %upcase(&&value&i)=CV %then %let needvaluec=1;
    %if %upcase(&&value&i)=A %then %let needbirthdate=1;
%end;
%if &rates= %then %let dropvars= ;

%let maxlengthvaluec=0;
%let expdatdroplist1= ;
%let expdatdroplist2= ;
%let numberofexpdats=0;
%let expdatvalueexists=0;
%let expdatvaluecexists=0;
%let charsubjectexists=0;
%let numsubjectexists=0;
%let j=1;
%let expdat=%scan(&expdats,&j,%str(' '));
%do %while (%length(&expdat)>0);  **** BEGIN WHILE EXPDAT NE NULL **** ;
  proc datasets nolist;
    contents data=&expdat out=Thank_you_for_using_stratify&j (keep=name type length) noprint;
  quit;

  data _null_; length junkstr $200 ;
   retain junkstr (',') maxlengthvaluec (&maxlengthvaluec)
          subjectOK timeOK expeventOK (0,0,0);
   set Thank_you_for_using_stratify&j end=flag;
   if upcase("&subject")=upcase(name) then do;
      junkstr=trim(junkstr)||', '||name; subjectOK=1;
      if type=1 then call symput('numsubjectexists','1');
      if type=2 then call symput('charsubjectexists','1');
   end;
   if upcase("&time")=upcase(name) then do;
     junkstr=trim(junkstr)||', '||name; if type=1 then timeOK=1;
   end;
   if upcase("&expevent")=upcase(name) then do;
         if type=2 then expeventOK=1;
         junkstr=trim(junkstr)||', '||name;
         maxlengthexpevent=max(maxlengthexpevent,length);
   end;
   if upcase("&value")=upcase(name) and &needvalue=1 then do;
     junkstr=trim(junkstr)||', '||name;
     call symput('expdatvalueexists','1');
   end;
   if upcase("&valuec")=upcase(name) and &needvaluec=1 then do;
     junkstr=trim(junkstr)||', '||name;
     maxlengthvaluec=max(maxlengthvaluec,length);
     call symput('expdatvaluecexists','1');
   end;
   if flag then do;
      call symput("badexpdat&j",' ');
      if min(subjectOK,timeOK,expeventOK)=0 then do;
        call symput("badexpdat&j",
         "ERROR: Missing or wrong type of SUBJECT TIME EXPEVENT variables in data set &expdat");
      end;
      call symput("expdatvarstr&j",substr(junkstr,3,198));
      call symput('maxlengthvaluec',put(maxlengthvaluec,f3.));
   end;
  run;

  %let expdatdroplist1=&expdatdroplist1 Thank_you_for_using_zrtf&j ;
  %let expdatdroplist2=&expdatdroplist2 Thank_you_for_using_stratify&j ;
  %let numberofexpdats=&j;
  %let j=%eval(&j+1);
  %let expdat=%scan(&expdats,&j,%str(' '));
%end; **** END WHILE EXPDAT NE NULL **** ;


%let badsubjectindata= ;
%let badsubjectinoutcomes= ;
%if &needsubject=1 %then %do;

%let vartypesubjectindata= ;
%let varnum1=0;
%let dsid1=%sysfunc(open(&data));
%if &dsid1>0 %then %let varnum1=%sysfunc(varnum(&dsid1,&subject));
%if &varnum1=0 %then %let badsubjectindata=ERROR: Variable SUBJECT (%trim(&subject)) is missing in data set %trim(&data). ;
%if &varnum1>0 %then %let vartypesubjectindata=%sysfunc(vartype(&dsid1,&varnum1));
%if &vartypesubjectindata=N %then %let numsubjectexists=1;
%if &vartypesubjectindata=C %then %let charsubjectexists=1;
%let rc=%sysfunc(close(&dsid1));

%if %length(&outcomes) %then %do;

%let vartypesubjectindata= ;
%let varnum1=0;
%let dsid1=%sysfunc(open(&outcomes));
%if &dsid1>0 %then %let varnum1=%sysfunc(varnum(&dsid1,&subject));
%if &varnum1=0 %then %let badsubjectinoutcomes=ERROR: Variable SUBJECT (%trim(&subject)) is missing in data set %trim(&outcomes). ;
%if &varnum1>0 %then %let vartypesubjectindata=%sysfunc(vartype(&dsid1,&varnum1));
%if &vartypesubjectindata=N %then %let numsubjectexists=1;
%if &vartypesubjectindata=C %then %let charsubjectexists=1;
%let rc=%sysfunc(close(&dsid1));

%end;

%end;

%let varyingsubjecttype= ;
%if &numsubjectexists=1 and &charsubjectexists=1 %then
  %let varyingsubjecttype=ERROR: Variable SUBJECT (%trim(&subject)) is of varying type in data sets used. ;


%if %length(&outcomes) %then %let eventtimedataset=&outcomes; %else %let eventtimedataset=&data;
%let badeventtime=;
%let eventtimetype=;
%let varnum1=0;
%let dsid1=%sysfunc(open(&eventtimedataset));
%if &dsid1=0 %then %let badeventtime=ERROR: DATA or OUTCOMES data set %trim(&eventtimedataset) requested, but not found. ;
%if &dsid1 %then %let varnum1=%sysfunc(varnum(&dsid1,&eventtime));
%if &varnum1=0 and &dsid1 %then %let badeventtime=ERROR: EVENTTIME (%trim(&eventtime)) not found in data set %trim(&eventtimedataset). ;
%if &varnum1 and &dsid1 %then %let eventtimetype=%sysfunc(vartype(&dsid1,&varnum1));
%if &eventtimetype=C %then %let badeventtime=ERROR: EVENTTIME (%trim(&eventtime)) not numeric. ;
%let rc=%sysfunc(close(&dsid1));



%let missingratesvars= ;
%let missingratesdataset= ;
%if %length(&rates) %then %do;
  %let dsid1=%sysfunc(open(&rates));
  %if &dsid1=0 %then %let missingratesdataset=ERROR: RATES data set %trim(&rates) specified, but not found. ;
  %let rc=%sysfunc(close(&dsid1));

%let generated_vars=&class &zrtfvars_to_keep &eventtype rate;
%do i=1 %to &dimaxis; %let generated_vars=&generated_vars &&axis&i; %end;

%if &dsid1 %then %do;
proc datasets nolist;
 contents data=&rates out=Thank_you_for_using_stratify0 (keep=name) noprint;
quit;

data _null_;
 length helpstr1 $32000 missingratesvars $400;
 retain helpstr1 helpstr2 ('','') missingratesvars ('');
 set Thank_you_for_using_stratify0 end=endflag;
 if _n_=1 then helpstr1=upcase(symget('generated_vars'));
 if indexw(helpstr1,upcase(name))=0 then missingratesvars=trim(missingratesvars)||' '||name;
 if endflag then call symput("missingratesvars",missingratesvars);
run;

proc sql; drop table Thank_you_for_using_stratify0; quit;
%end;
%end;



%let varnum1=0;
%let badentry=0;
%let badexit=0;
%let vartypeentry=N;
%let vartypeexit=N;
%let dsid1=%sysfunc(open(&data));
%if &dsid1>0 %then %let varnum1=%sysfunc(varnum(&dsid1,entry));
%if &varnum1=0 %then %let badentry=1;
%if &varnum1>0 %then %let vartypeentry=%sysfunc(vartype(&dsid1,&varnum1));
%if &vartypeentry=C %then %let badentry=1;
%if &dsid1>0 %then %let varnum1=%sysfunc(varnum(&dsid1,exit));
%if &varnum1=0 %then %let badexit=1;
%if &varnum1>0 %then %let vartypeexit=%sysfunc(vartype(&dsid1,&varnum1));
%if &vartypeexit=C %then %let badexit=1;
%let rc=%sysfunc(close(&dsid1));





%let stop_executing=0;
%if %eval(&dimbad>0) %then %do;
    %let stop_executing=1;
    %do i=1 %to &dimbad; %put Unrecognised statement: &&bad&i; %end;
%end;
%if %length(&badoptions)>0 %then %do;
    %let stop_executing=1;
    %put Unrecognised option(s): &badoptions;
%end;
%if %length(&badeventvalues)>0 %then %do;
    %let stop_executing=1;
    %put &badeventvalues;
%end;
%if %length(&badsubject)>0 %then %do;
    %let stop_executing=1;
    %put &badsubject;
%end;
%if %length(&badcoxorigin)>0 %then %do;
    %let stop_executing=1;
    %put &badcoxorigin;
%end;

%if %length(&badmode)>0 %then %put &badmode ; ;
%if %length(&badmethod)>0 %then %put &badmethod ; ;
%if %length(&badchunksize)>0 %then %put &badchunksize ; ;
%if %length(&badgranularity)>0 %then %put &badgranularity ; ;
%if %length(&badscale)>0 %then %put &badscale ; ;
%if %length(&badcomplete)>0 %then %put &badcomplete ; ;
%if %length(&badmission)>0 %then %put &badmission ; ;

%do i=1 %to &orgdimaxis;
  %if %length(&&badnameaxis&i)>0 %then %do;
    %let stop_executing=1;
    %put %trim(&&badnameaxis&i): %trim(&&axis&i) ;
  %end;
  %if %length(&&badorigin&i)>0 %then %do;
    %let stop_executing=1;
    %put %trim(&&badorigin&i) for %trim(&&axis&i) ;
  %end;
  %if %length(&&badcuts&i)>0 %then %do;
    %let stop_executing=1;
    %put %trim(&&badcuts&i) for %trim(&&axis&i) ;
  %end;
%end;

%do i=1 %to &dimsrtf;
  %if %length(&&badnamesrtf&i)>0 %then %do;
    %let stop_executing=1;
    %put &&badnamesrtf&i: &&srtf&i ;
  %end;
  %if %length(&&badsrtfcuts&i)>0 %then %do;
    %let stop_executing=1;
    %put &&badsrtfcuts&i for &&srtf&i ;
  %end;
  %if %length(&&badsrtfspeed&i)>0 %then %do;
    %let stop_executing=1;
    %put &&badsrtfspeed&i for &&srtf&i ;
  %end;
%end;

%do i=1 %to &dimzrtf;
  %if %length(&&badnamezrtf&i)>0 %then %do;
    %let stop_executing=1;
    %put %trim(&&badnamezrtf&i): &&zrtf&i ;
  %end;
  %if %length(&&badvaluezrtf&i)>0 %then %do;
    %let stop_executing=1;
    %put %trim(&&badvaluezrtf&i) for &&zrtf&i ;
  %end;
  %if %length(&&badnzrtf&i)>0 %then %do;
    %let stop_executing=1;
    %put %trim(&&badnzrtf&i) for &&zrtf&i ;
  %end;
  %if %length(&&badcondzrtf&i)>0 %then %do;
    %let stop_executing=1;
    %put %trim(&&badcondzrtf&i) for &&zrtf&i ;
  %end;
  %if %length(&&badgroupszrtf&i)>0 %then %do;
    %let stop_executing=1;
    %put %trim(&&badgroupszrtf&i) for &&zrtf&i ;
  %end;
  %if %length(&&badmissingzrtf&i)>0 %then %do;
    %let stop_executing=1;
    %put %trim(&&badmissingzrtf&i) for &&zrtf&i ;
  %end;
  %if %length(&&badlengthzrtf&i)>0 %then %do;
    %put %trim(&&badlengthzrtf&i) for &&zrtf&i ;
  %end;
%end;

%do i=1 %to &numberofexpdats;
  %if %length(&&badexpdat&i)>0 %then %do;
    %let stop_executing=1;
    %put %trim(&&badexpdat&i) ;
  %end;
%end;

%if %eval(&dimzrtf>0) and %length(&expdats)=0 %then %do;
    %let stop_executing=1;
%put ERROR: No EXPDATS for the ZRTF statements;
%end;

%if %eval(&expdatvalueexists=0) and %eval(&needvalue=1) %then %do;
    %let stop_executing=1;
%put ERROR: Variable %trim(&value) needed but not found in any EXPDATS datasets;
%end;

%if %eval(&expdatvaluecexists=0) and %eval(&needvaluec=1) %then %do;
    %let stop_executing=1;
%put ERROR: Variable %trim(&valuec) needed but not found in any EXPDATS datasets;
%end;

%if %length(&missingratesdataset) %then %do;
    %let stop_executing=1;
%put &missingratesdataset;
%end;

%if %length(&badsubjectindata) %then %do;
    %let stop_executing=1;
%put &badsubjectindata;
%end;

%if %length(&badsubjectinoutcomes) %then %do;
    %let stop_executing=1;
%put &badsubjectinoutcomes;
%end;

%if %length(&varyingsubjecttype) %then %do;
    %let stop_executing=1;
%put &varyingsubjecttype;
%end;

%if %length(&badeventtime) %then %do;
    %let stop_executing=1;
%put &badeventtime;
%end;

%if %length(&badclass)>0 %then %do;
    %let stop_executing=1;
%put ERROR: The following CLASS variable(s) not in %trim(&data) or ZRTF statement: %trim(&badclass). ;
%end;

%if %length(&missingratesvars)>0 %then %do;
    %let stop_executing=1;
%put ERROR: The following RATES variable(s) not produced in AXIS, CLASS, SRTF or ZRTF statements: %trim(&missingratesvars). ;
%end;




%if &badentry=1 %then %do;
    %let stop_executing=1;
%put ERROR: The variable entry is not in %trim(&data) or is not numeric ;
%end;

%if &badexit=1 %then %do;
    %let stop_executing=1;
%put ERROR: The variable exit is not in %trim(&data) or is not numeric ;
%end;






%if &stop_executing=1 %then %put
ERROR: Stratify macro not executed due to errors in user input. ;


%if &stop_executing=1 %then %do;
proc datasets lib=work nolist; delete &expdatdroplist2 ; quit;
%end;



**** EXTRA CHECK OF EVENTVALUES *****;
%if &stop_executing=0 %then %do; * A *;

%if &needeventtype=1 %then %do; * B *;

proc datasets nolist; delete Thank_you_for_using_valid_values; quit;

%let badeventvalues=Bad value for option EVENTVALUES or no common eventtype from EVENTVALUES and RATES;
proc sql;
 %if &eventvaluesrates=NY %then %do; create table Thank_you_for_using_valid_values as select unique &eventtype from &eventvalues; %end;
 %if &eventvaluesrates=YN %then %do; create table Thank_you_for_using_valid_values as select unique &eventtype from &eventvalues; %end;
 %if &eventvaluesrates=YY %then %do;
     create table Thank_you_for_using_valid_values as select unique p.&eventtype from &eventvalues p, &rates q
        where p.&eventtype=q.&eventtype; %end;
quit;

data _null_; set Thank_you_for_using_valid_values;
 if _n_>0 then call symput('badeventvalues','');
 call symput('n_valid_values',put(_n_,f5.));
run;

%if %length(&badeventvalues)>0 %then %let stop_executing=1;

%if &stop_executing=1 %then %do;
    %put &badeventvalues;
%put
ERROR: Stratify macro not executed due to errors in user input;
%end;

%if &stop_executing=0 %then %do; * C *;

%let dsid1=%sysfunc(open(Thank_you_for_using_valid_values));
%let d2=&outcomes;
%if &d2= %then %let d2=&data;
%let dsid2=%sysfunc(open(&d2));
%let varnum2=%sysfunc(varnum(&dsid2,&eventtype));
%let type1=%sysfunc(vartype(&dsid1,1));
%if %eval(&varnum2>0) %then %let type2=%sysfunc(vartype(&dsid2,&varnum2)); %else %let type2=x;
%if &type1 ^= &type2 %then %let stop_executing=1;
%let rc=%sysfunc(close(&dsid1));
%let rc=%sysfunc(close(&dsid2));

%if &stop_executing=1 %then %do;
%put Incompatible datatypes for EVENTTYPE in EVENTVALUES and DATA/OUTCOMES. ;
%put
ERROR: Stratify macro not executed due to errors in user input. ;
%end;

%end; * C *;
%end; * B *;
%end; * A *;





%if &stop_executing=0 %then %do;**** COVERS THE REST OF THE MACRO ****;





* Define NOEVENTVALUE if needed ;
%if %eval(&needeventtype=1) and %length(&noeventvalue)=0 %then %do;

proc sort data=Thank_you_for_using_valid_values; by &eventtype; run;

%if &type1=N %then %do;

data Thank_you_for_using_stratify0;
 set Thank_you_for_using_valid_values end=endflag;
   if endflag then do;
     do &eventtype = -9999,-999,-99,-9,0 ; output; end;
   end;
run;

proc sort; by &eventtype; run;

data Thank_you_for_using_stratify0;
 retain _noeventvalue_proposal_ (-99999);
 merge Thank_you_for_using_stratify0(in=_in_Eventtypeproposal_)
       Thank_you_for_using_valid_values(in=_in_Eventtype_range_) end=endflag;
 by &eventtype;
 if _in_Eventtypeproposal_ and _in_Eventtype_range_=0 then _noeventvalue_proposal_=&eventtype;
 if endflag then do;
   if _noeventvalue_proposal_=-99999 then _noeventvalue_proposal_=ceil(&eventtype + 1);
   call symput('noeventvalue',trim(put(_noeventvalue_proposal_,f20.)));
 end;
run;

%end;

%if &type1=C %then %do;

data Thank_you_for_using_stratify0;
 set Thank_you_for_using_valid_values end=endflag;
   if endflag then do;
     do &eventtype = 'p','py','pyr','pyrs' ; output; end;
   end;
run;

proc sort nodupkey; by &eventtype; run;

data Thank_you_for_using_stratify0;
 length _noeventvalue_proposal_ $200;
 retain _noeventvalue_proposal_ ('');
 merge Thank_you_for_using_stratify0(in=_in_Eventtypeproposal_)
       Thank_you_for_using_valid_values(in=_in_Eventtype_range_) end=endflag;
 by &eventtype;
 if _in_Eventtypeproposal_ and _in_Eventtype_range_=0 then _noeventvalue_proposal_=&eventtype;
 if endflag then do;
   if _noeventvalue_proposal_='' then _noeventvalue_proposal_=byte(rank(substr(&eventtype,1,1))+1);
   call symput('noeventvalue',trim(_noeventvalue_proposal_));
 end;
run;

%let noeventvalue="&noeventvalue";

%end;

proc sql; drop table Thank_you_for_using_stratify0; quit;

%end; * NOEVENTVALUE definition ;




%if %length(&expdats &outcomes)>0 %then %do;
%put If you link data you will receive warnings - just ignore them. ;
%end;

******* FIGURE OUT WHICH VARIABLES TO FETCH FROM WHERE ******* ;

%let junkstrlength=%eval(&dimaxis * 33 );
%if %eval(&junkstrlength=0) %then %let junkstrlength=32;

%let keepvars= ;
data _null_; length junkstr $ &junkstrlength punkstr $ &maxstrlength ;
 do i=1 to &dimaxis;
   punkstr=symget('origin'||compress(put(i,f4.)));
   if 'A' le upcase(substr(punkstr,1,1)) le 'Z' or upcase(substr(punkstr,1,1))='_' then do;
   * test whether the relevant origin is a SAS variable ;
      junkstr=trim(symget('keepvars'))||' '||punkstr;
      call symput('keepvars',junkstr);
   end;
   punkstr=symget('speed'||compress(put(i,f4.)));
   if 'A' le upcase(substr(punkstr,1,1)) le 'Z' or upcase(substr(punkstr,1,1))='_' then do;
   * test whether the relevant origin is a SAS variable ;
      junkstr=trim(symget('keepvars'))||' '||punkstr;
      call symput('keepvars',junkstr);
   end;
 end;
run;



%let eventidoutcomes= ;
%let eventiddata= ;

%if %length(&eventid)>0 %then %do; **** BEGIN EVENTID NE NULL ****;

proc datasets nolist;
    contents data=&data out=Thank_you_for_using_stratify0 (keep=name) noprint;
quit;

data _null_; length junkstr1 junkstr2 $2000 name_eventID $32 ;
   retain junkstr1 junkstr2 ('','');
   junkstr1=upcase(symget('eventid'));
   set Thank_you_for_using_stratify0 end=flag;
   i=1;
   name_eventID=scan(junkstr1,i,' ');
   do while (name_eventID ne '');
      if name_eventID=upcase(name) then junkstr2=trim(junkstr2)||' '||name;
      i=i+1;
      name_eventID=scan(junkstr1,i,' ');
   end;
   if flag then call symput('eventiddata',junkstr2);
run;

%if &outcomes ^= %then %do; **** BEGIN OUTCOMES NE NULL ****;

proc datasets nolist;
    contents data=&outcomes out=Thank_you_for_using_stratify0 (keep=name) noprint;
quit;

data _null_; length junkstr1 junkstr2 $2000 name_eventID $32 ;
   retain junkstr1 junkstr2 ('','');
   junkstr1=upcase(symget('eventid'));
   set Thank_you_for_using_stratify0 end=flag;
   i=1;
   name_eventID=scan(junkstr1,i,' ');
   do while (name_eventID ne '');
      if name_eventID=upcase(name) and name ne "&subject"
        then junkstr2=trim(junkstr2)||' '||name;
      i=i+1;
      name_eventID=scan(junkstr1,i,' ');
   end;
   if flag then call symput('eventidoutcomes',junkstr2);
run;

%end; **** END OUTCOMES NE NULL ****;

%end; **** END EVENTID NE NULL ****;



%let superlist=&class &keepvars &eventiddata ;

%let fetchvars=;
%let j=1;
%let tolist=%scan(%upcase(&superlist),1,%str(' '));
%do %while (%length(&tolist)>0);
 %let hit=0;
 %do i=1 %to &dimzrtf;
   %if %upcase(&&zrtf&i)=&tolist %then %let hit=1;
 %end;
 %do i=1 %to &dimsrtf;
   %if %upcase(&&srtforigin&i)=&tolist %then %let hit=1;
 %end;
 %if &hit=0 %then %let fetchvars=&fetchvars &tolist;
 %let j=%eval(&j+1);
 %let tolist=%scan(%upcase(&superlist),&j,%str(' '));
%end;

%let fetchvars0=entry exit &fetchvars &subject;
%if &needbirthdate=1 %then %let fetchvars0=&fetchvars0 &birthdate;
%if &needeventtype=1 %then %do;
  %if &outcomes= %then %let fetchvars0=&fetchvars0 &eventtype;
%end;
%if &outcomes= %then %let fetchvars0=&fetchvars0 &eventtime;
%let j=2;
%let hlpstr1=exit;
%let commafetchvars0=entry ;
%do %while (%length(&hlpstr1)>0);
   %let commafetchvars0=&commafetchvars0 , &hlpstr1 ;
   %let j=%eval(&j+1);
   %let hlpstr1=%scan(%upcase(&fetchvars0),&j,%str(' '));
%end;




proc sql;
  create table Thank_you_for_using_zrtf0 as select &commafetchvars0 from &data
   where .<entry<exit
   %if &subject ^= %then order by &subject ; ;
quit;

data Thank_you_for_using_zrtf0; set Thank_you_for_using_zrtf0; _segment_=_n_; run;




%do j=1 %to &numberofexpdats;

  proc sql;
    create table Thank_you_for_using_zrtf&j as select
      &&expdatvarstr&j from %scan(&expdats,&j,%str(' '))
      where &time>. and &expevent in (&expeventvalues) order by &subject , &time ;
  quit;

%end;

%let j=%eval(1+&numberofexpdats);

%if &expdats ^= %then %do; **** BEGIN MERGING DATA ****;

data Thank_you_for_using_zrtf&j;
 length &expevent $&maxlengthexpevent
  %if &needvaluec=1 %then &valuec $&maxlengthvaluec; %if &needvalue=1 %then &value 8; ;
 set &expdatdroplist1 ;
 by &subject &time;
run;

proc sql;
 create table Thank_you_for_using_zrtf0 as select * from
   Thank_you_for_using_zrtf0 p left join Thank_you_for_using_zrtf&j q
   on p.&subject=q.&subject and &time<exit
   order &subject, _segment_, &time;
quit;

proc datasets lib=work nolist;
 delete &expdatdroplist1 &expdatdroplist2 Thank_you_for_using_zrtf&j;
quit;

%end;  **** END MERGING DATA ****;



********* GENERATE ZRTFs ***********************;

%if &expdats ^= %then %do;
**** WE ONLY GENERATE ZRTFs this way when we have external exposure datasets ****;


%do i=1 %to &dimzrtf;
  %if &&value&i=CV %then %do;
    %if &&length&i= %then %let length&i=$&maxlengthvaluec ;
  %end;
%end;

data _null_;
 %do i=1 %to &dimzrtf;

   %if &&value&i=N %then %do;
     %if &&miss&i= %then %let miss&i=.; ;
     %if &&gtype&i=0 %then &&zrtf&i=0; ;
     %if &&gtype&i=1 %then &&zrtf&i=input(put(0,&&groups&i),f20.) ; ;
     %if &&gtype&i=3 %then %do;
       &&zrtf&i=  %scan(&&groups&i,1,%str(' ')) + %scan(&&groups&i,5,%str(' '))*
                 floor((min(0,%scan(&&groups&i,3,%str(' ')))
                            - %scan(&&groups&i,1,%str(' ')))
                    /%scan(&&groups&i,5,%str(' ')))   ;
       if &&zrtf&i <  %scan(&&groups&i,1,%str(' ')) then &&zrtf&i = &&miss&i ;
     %end;
     %if &&gtype&i=4 %then %do;
         _schluss_=.;
         do &&zrtf&i=&&groups&i;
           if &&zrtf&i le 0 then _schluss_=&&zrtf&i;
         end;
         &&zrtf&i=_schluss_;
         if &&zrtf&i=. then &&zrtf&i=&&miss&i;
     %end;
     call symput("initval&i",put(&&zrtf&i,f20.));
   %end;

   %if &&value&i=S %then %do;
     %if &&miss&i= %then %let miss&i=.; ;
     %if &&gtype&i=0 %then &&zrtf&i=0; ;
     %if &&gtype&i=1 %then &&zrtf&i=input(put(0,&&groups&i),f20.) ; ;
     %if &&gtype&i=3 %then %do;
       &&zrtf&i=  %scan(&&groups&i,1,%str(' ')) + %scan(&&groups&i,5,%str(' '))*
                 floor((min(0,%scan(&&groups&i,3,%str(' ')))
                            - %scan(&&groups&i,1,%str(' ')))
                    /%scan(&&groups&i,5,%str(' ')))   ;
       if &&zrtf&i <  %scan(&&groups&i,1,%str(' ')) then &&zrtf&i = &&miss&i ;
     %end;
     %if &&gtype&i=4 %then %do;
         _schluss_=.;
         do &&zrtf&i=&&groups&i;
           if &&zrtf&i le 0 then _schluss_=&&zrtf&i;
         end;
         &&zrtf&i=_schluss_;
         if &&zrtf&i=. then &&zrtf&i=&&miss&i;
     %end;
     call symput("initval&i",put(&&zrtf&i,f20.));
   %end;

 %end;
run;



data Thank_you_for_using_zrtf0;
 format entry exit;
 retain entry exit;
 set Thank_you_for_using_zrtf0(rename=(entry=_entry exit=_exit));
 by &subject _segment_;

 keep &fetchvars0 &zrtfvars _segment_ &keepsimplesrtflist ;


 %do i=1 %to &dimzrtf; **** BEGIN INITIALISATION LOOP ****;
   %if &&length&i ^= %then length &&zrtf&i &&length&i; ;

   %if &&value&i=I %then %do;
     retain _temp_&&zrtf&i &&zrtf&i  (0,0);
     if first._segment_ then &&zrtf&i=0;
     if first._segment_ then _temp_&&zrtf&i=0;
   %end;

   %if &&value&i=N %then %do;
     retain _temp_&&zrtf&i &&zrtf&i  (0,0);
     %if &&miss&i= %then %let miss&i=.;
     if first._segment_ then _temp_&&zrtf&i=0;
     if first._segment_ then &&zrtf&i=&&initval&i;
   %end;

   %if &&value&i=S %then %do;
     retain _temp_&&zrtf&i &&zrtf&i  (0,0);
     %if &&miss&i= %then %let miss&i=.;
     if first._segment_ then _temp_&&zrtf&i=0;
     if first._segment_ then &&zrtf&i=&&initval&i;
   %end;

   %if &&value&i=V %then %do;
     retain _temp_&&zrtf&i &&zrtf&i  (0,0);
     %if &&miss&i= %then %let miss&i=.;
     if first._segment_ then _temp_&&zrtf&i=0;
     if first._segment_ then &&zrtf&i=&&miss&i;
   %end;

   %if &&value&i=CV %then %do;
     retain _temp_&&zrtf&i (0) &&zrtf&i  ('');
     %if &&miss&i= %then %let miss&i='';
     if first._segment_ then _temp_&&zrtf&i=0;
     if first._segment_ then &&zrtf&i=&&miss&i;
   %end;

   %if &&value&i=T %then %do;
     retain _temp_&&zrtf&i &&zrtf&i  (0,0);
     if first._segment_ then _temp_&&zrtf&i=0;
     if first._segment_ then &&zrtf&i=.;
   %end;

   %if &&value&i=A %then %do;
     retain _temp_&&zrtf&i &&zrtf&i  (0,0);
     %if &&miss&i= %then %let miss&i=.;
     if first._segment_ then _temp_&&zrtf&i=0;
     if first._segment_ then &&zrtf&i=&&miss&i;
   %end;

 %end;  **** END INITIALISATION LOOP ****;


%do i=1 %to &dimsrtf;
  %if &&srtfflag&i=1 %then %do;
     retain &&thelp&i &&srtfvaluehelp&i &&srtfspeedhelp&i (0,0,1) ;
     if first._segment_ then do;
        &&srtfvaluehelp&i = 0;
        &&thelp&i = .;
        &&srtfspeedhelp&i=1;
     end;
  %end;
%end;




 if first._segment_ then entry=.;
 entry=max(entry,_entry);
 exit=min(&time,_exit);
 if entry<exit then output;


 **** START OF A MEGA LOOP ****;
 %do i=1 %to &dimzrtf;

   %if &&value&i=I %then %do;
     %if &&n&i=L %then %do;
       if &expevent=&&cond&i then &&zrtf&i=1;
     %end;
     %if &&n&i ^=L %then %do;
       if &expevent=&&cond&i then _temp_&&zrtf&i=_temp_&&zrtf&i + 1;
       if &expevent=&&cond&i and _temp_&&zrtf&i = &&n&i then &&zrtf&i=1;
     %end;
   %end;

   %if &&value&i=N %then %do;
     if &expevent=&&cond&i then _temp_&&zrtf&i=_temp_&&zrtf&i + 1;
     %if &&gtype&i=0 %then &&zrtf&i=_temp_&&zrtf&i; ;
     %if &&gtype&i=1 %then &&zrtf&i=input(put(_temp_&&zrtf&i,&&groups&i),f20.) ; ;
     %if &&gtype&i=3 %then %do;
       if _temp_&&zrtf&i <  %scan(&&groups&i,1,%str(' ')) then &&zrtf&i = &&miss&i ;
       else
       &&zrtf&i=  %scan(&&groups&i,1,%str(' ')) + %scan(&&groups&i,5,%str(' '))*
                 floor((min(_temp_&&zrtf&i,%scan(&&groups&i,3,%str(' ')))
                                   - %scan(&&groups&i,1,%str(' ')))
                    /%scan(&&groups&i,5,%str(' ')))   ;
     %end;
     %if &&gtype&i=4 %then %do;
         _schluss_=.;
         do &&zrtf&i=&&groups&i;
           if &&zrtf&i le _temp_&&zrtf&i then _schluss_=&&zrtf&i;
         end;
         &&zrtf&i=_schluss_;
         if &&zrtf&i=. then &&zrtf&i=&&miss&i;
     %end;
   %end;

   %if &&value&i=S %then %do;
     if &expevent=&&cond&i then _temp_&&zrtf&i=_temp_&&zrtf&i + &value;
     %if &&gtype&i=0 %then &&zrtf&i=_temp_&&zrtf&i; ;
     %if &&gtype&i=1 %then &&zrtf&i=input(put(_temp_&&zrtf&i,&&groups&i),f20.) ; ;
     %if &&gtype&i=3 %then %do;
       if _temp_&&zrtf&i <  %scan(&&groups&i,1,%str(' ')) then &&zrtf&i = &&miss&i ;
       else
       &&zrtf&i=  %scan(&&groups&i,1,%str(' ')) + %scan(&&groups&i,5,%str(' '))*
                 floor((min(_temp_&&zrtf&i,%scan(&&groups&i,3,%str(' ')))
                                   - %scan(&&groups&i,1,%str(' ')))
                    /%scan(&&groups&i,5,%str(' ')))   ;
     %end;
     %if &&gtype&i=4 %then %do;
         _schluss_=.;
         do &&zrtf&i=&&groups&i;
           if &&zrtf&i le _temp_&&zrtf&i then _schluss_=&&zrtf&i;
         end;
         &&zrtf&i=_schluss_;
         if &&zrtf&i=. then &&zrtf&i=&&miss&i;
     %end;
   %end;

   %if &&value&i=V %then %do;
     %if &&n&i=L %then %do;
       if &expevent=&&cond&i then do;
     %end;
     %if &&n&i ^=L %then %do;
       if &expevent=&&cond&i then _temp_&&zrtf&i=_temp_&&zrtf&i + 1;
       if &expevent=&&cond&i and _temp_&&zrtf&i = &&n&i then do;
     %end;
       %if &&gtype&i=0 %then &&zrtf&i=&value; ;
       %if &&gtype&i=1 %then %do;
           if &value>. then
           &&zrtf&i=input(put(&value,&&groups&i),f20.) ;
           else &&zrtf&i=&&miss&i;
       %end;
       %if &&gtype&i=3 %then %do;
         if &value <  %scan(&&groups&i,1,%str(' ')) then &&zrtf&i = &&miss&i ;
         else
         &&zrtf&i=  %scan(&&groups&i,1,%str(' ')) + %scan(&&groups&i,5,%str(' '))*
                   floor((min(&value,%scan(&&groups&i,3,%str(' ')))
                                     - %scan(&&groups&i,1,%str(' ')))
                      /%scan(&&groups&i,5,%str(' ')))   ;
       %end;
       %if &&gtype&i=4 %then %do;
         _schluss_=.;
         do &&zrtf&i=&&groups&i;
           if &&zrtf&i le &value then _schluss_=&&zrtf&i;
         end;
         &&zrtf&i=_schluss_;
         if &&zrtf&i=. then &&zrtf&i=&&miss&i;
       %end;
       end;
   %end;

   %if &&value&i=CV %then %do;
     %if &&n&i=L %then %do;
       if &expevent=&&cond&i then do;
     %end;
     %if &&n&i ^=L %then %do;
       if &expevent=&&cond&i then _temp_&&zrtf&i=_temp_&&zrtf&i + 1;
       if &expevent=&&cond&i and _temp_&&zrtf&i = &&n&i then do;
     %end;
     %if &&gtype&i=0 %then &&zrtf&i=valuec; ;
     %if &&gtype&i=2 %then &&zrtf&i=put(&valuec,&&groups&i); ;
     if &&zrtf&i='' then &&zrtf&i= &&miss&i;
     end;
   %end;

   %if &&value&i=T %then %do;
     %if &&n&i=L %then if &expevent=&&cond&i then &&zrtf&i=&time; ;
     %if &&n&i ^=L %then %do;
       if &expevent=&&cond&i then _temp_&&zrtf&i=_temp_&&zrtf&i + 1;
       if &expevent=&&cond&i and _temp_&&zrtf&i = &&n&i then &&zrtf&i=&time;
     %end;
   %end;

   %if &&value&i=A %then %do;
     %if &&n&i=L %then %do;
       if &expevent=&&cond&i then do;
     %end;
     %if &&n&i ^=L %then %do;
       if &expevent=&&cond&i then _temp_&&zrtf&i=_temp_&&zrtf&i + 1;
       if &expevent=&&cond&i and _temp_&&zrtf&i = &&n&i then do;
     %end;
         &&zrtf&i=(&time-&birthdate) &scalediv ;
         %if &&gtype&i=0 %then if &&zrtf&i=. then &&zrtf&i=&&miss&i; ;
         %if &&gtype&i=1 %then %do;
           if &&zrtf&i>. then
           &&zrtf&i=input(put(&&zrtf&i,&&groups&i),f20.) ;
           else &&zrtf&i = &&miss&i ;
         %end;
         %if &&gtype&i=3 %then %do;
           if &&zrtf&i <  %scan(&&groups&i,1,%str(' ')) then &&zrtf&i = &&miss&i ;
           else
           &&zrtf&i=  %scan(&&groups&i,1,%str(' ')) + %scan(&&groups&i,5,%str(' '))*
                     floor((min(&&zrtf&i,%scan(&&groups&i,3,%str(' ')))
                                       - %scan(&&groups&i,1,%str(' ')))
                        /%scan(&&groups&i,5,%str(' ')))   ;
         %end;
       %if &&gtype&i=4 %then %do;
         _schluss_=.;
         do &&zrtf&i=&&groups&i;
           if &&zrtf&i le ((&time-&birthdate) &scalediv) then _schluss_=&&zrtf&i;
         end;
         &&zrtf&i=_schluss_;
         if &&zrtf&i=. then &&zrtf&i=&&miss&i;
       %end;
       end;
   %end;

 %end;
 **** END OF A MEGA LOOP **** do i=1 to dimzrtf;


 %do i=1 %to &dimsrtf;
    %if &&srtfflag&i=1 %then %do;
       %let k=1;
       %do %while (%upcase(&&srtfspeed&i) ne %upcase(&&zrtf&k) and &k le &dimzrtf);
         %let k=%eval(&k+1);
       %end;
       %if %upcase(&&srtfspeed&i) = %upcase(&&zrtf&k) %then %do;
         if &expevent=&&cond&k then do;
            &&srtfvaluehelp&i=&&srtfvaluehelp&i + max(0,&time-&&thelp&i)*&&srtfspeedhelp&i;
            &&thelp&i=&time;
            &&srtfspeedhelp&i=&&srtfspeed&i;
         end;
       %end;
    %end;
 %end;

 entry=exit;
 if last._segment_ then do;
   exit=_exit; entry=max(_entry,entry); if entry<exit then output;
 end;

run;

%end; * if expdats ne null ;
**** WE ONLY GENERATE ZRTFs this way when we have external exposure datasets ****;



******* NOW WE TAKE CARE OF OUTCOME EVENTS AND CALCULATE ORIGINS OF SRTFs *****;

%do i=1 %to &dimsrtf;
  %if &&srtfflag&i=1 %then %do;
    %let t&i=&&thelp&i;
    %let srtfvalue&i=&&srtfvaluehelp&i;
  %end;
%end;

%if &outcomes ^= %then %do;
  %let outcomevars=&eventtime &eventIDoutcomes  ;
  %if &needeventtype=1 %then %let outcomevars=&outcomevars &eventtype;

  %let j=1;
  %let hlpstr1=&eventtime;
  %let commaoutcomevars= t.* ;
  %do %while (%length(&hlpstr1)>0);
     %if %upcase(&hlpstr1) ne %upcase(&subject) %then %do;
        %if %upcase(&hlpstr1)=%upcase(&eventtype) %then %let hlpstr1=o.&eventtype;
        %let commaoutcomevars=&commaoutcomevars , &hlpstr1 ;
     %end;
     %let j=%eval(&j+1);
     %let hlpstr1=%scan(%upcase(&outcomevars),&j,%str(' '));
  %end;
%end;

%let class=&class &zrtfvars_to_keep;
%let orgclass=&class;
%if &needeventtype=1 %then %let class=&eventtype &class;
%let keepvars=entry exit &keepvars &class &eventID;







****** MODE S ******** ;

%if &mode=S %then %do;

%if &outcomes ^= %then %do;

proc sql;
  create table Thank_you_for_using_this_outcome as select
    %substr(%bquote(&commaoutcomevars),6) , &subject from &outcomes where &eventtime > .
    order &subject , &eventtime ;
quit;

data Thank_you_for_using_this_outcome;
 set Thank_you_for_using_this_outcome;
 by &subject;
 if first.&subject;
run;

proc sql;
  create table Thank_you_for_using_zrtf0 as select &commaoutcomevars from
    Thank_you_for_using_zrtf0 t left join Thank_you_for_using_this_outcome o
    on t.&subject=o.&subject;
  drop table Thank_you_for_using_this_outcome;
quit;

%end;

data &pyrsdatasetname (keep= &keepvars);
 set Thank_you_for_using_zrtf0;
 exit=min(exit,&eventtime + &granularity);
 %do i=1 %to &dimsrtf;
    &&srtforigin&i=entry - &&srtfvalue&i - &&srtfspeed&i * (entry-&&t&i);
    %if &&srtfflag&i=1 %then %do;
      if &&srtforigin&i=. then do; &&srtforigin&i=entry; &&srtfspeed&i=0; end;
    %end;
 %end;
 if entry<exit then output;
 if entry le &eventtime < exit then do;
   entry=&eventtime;
   %do i=1 %to &dimsrtf;
    &&srtforigin&i=entry - &&srtfvalue&i - &&srtfspeed&i * (entry-&&t&i);
    %if &&srtfflag&i=1 %then %do;
      if &&srtforigin&i=. then do; &&srtforigin&i=entry; &&srtfspeed&i=0; end;
    %end;
   %end;
   exit=.;
   output;
 end;
run;

%end;

****** MODE C ******** ;

%if &mode=C %then %do;

%if &outcomes ^= %then %do;

proc sql;
  create table Thank_you_for_using_this_outcome as select
    %substr(%bquote(&commaoutcomevars),6) , &subject from &outcomes o, Thank_you_for_using_valid_values e
    where &eventtime > . and o.&eventtype=e.&eventtype
    order &subject, &eventtime, o.&eventtype;
quit;

data Thank_you_for_using_this_outcome;
 set Thank_you_for_using_this_outcome;
 by &subject;
 if first.&subject;
run;

proc sql;
  create table Thank_you_for_using_zrtf0 as select &commaoutcomevars from
    Thank_you_for_using_zrtf0 t left join Thank_you_for_using_this_outcome o
    on t.&subject=o.&subject;
  drop table Thank_you_for_using_this_outcome;
quit;

%end;

proc datasets nolist;
 contents data=Thank_you_for_using_zrtf0
          out=Thank_you_for_using_stratify0 (keep=name type length) noprint;
quit;

data _null_; length hlpstr1 hlpstr2 $50 ; set Thank_you_for_using_stratify0;
 if upcase(name)=upcase("&eventtype") then do;
    if type=1 then do; hlpstr1="length asdfgjkdgfasgkfasd 8"; hlpstr2=" "; end;
    if type=2 then do; hlpstr1="length asdfgjkdgfasgkfasd $"||trim(put(length,f6.)); hlpstr2="$"||trim(put(length,f6.)); end;
    call symput("hlpstr",hlpstr1);
    call symput("valid_values_length",hlpstr2);
 end;
run;

data Thank_you_for_using_stratify1; set Thank_you_for_using_zrtf0(obs=1)
 Thank_you_for_using_valid_values(in=Thank_you_for_using_valid_values);
 if Thank_you_for_using_valid_values;
run;

data &pyrsdatasetname (keep= &keepvars);
 &hlpstr ; ;
 array _valid_values (&n_valid_values) &valid_values_length _temporary_;
 set Thank_you_for_using_stratify1(in=Thank_you_for_using_valid_values) Thank_you_for_using_zrtf0;
 if Thank_you_for_using_valid_values then do; _valid_values(_n_)=&eventtype; end;
 if &eventtime>. then do;
    _deletovich_=1;
    _p1=1;
    do while (_p1 le &n_valid_values and _deletovich_=1);
      if _valid_values(_p1)=&eventtype then _deletovich_=0;
      _p1=_p1+1;
    end;
    if _deletovich_=1 then &eventtime=.;
 end;
 asdfgjkdgfasgkfasd=&eventtype;
 &eventtype=&noeventvalue ;
 exit=min(exit,&eventtime + &granularity);
 %do i=1 %to &dimsrtf;
    &&srtforigin&i=entry - &&srtfvalue&i - &&srtfspeed&i * (entry-&&t&i);
    %if &&srtfflag&i=1 %then %do;
      if &&srtforigin&i=. then do; &&srtforigin&i=entry; &&srtfspeed&i=0; end;
    %end;
 %end;
 if entry<exit then output;
 if entry le &eventtime < exit then do;
   entry=&eventtime;
   %do i=1 %to &dimsrtf;
      &&srtforigin&i=entry - &&srtfvalue&i - &&srtfspeed&i * (entry-&&t&i);
    %if &&srtfflag&i=1 %then %do;
      if &&srtforigin&i=. then do; &&srtforigin&i=entry; &&srtfspeed&i=0; end;
    %end;
   %end;
   &eventtype=asdfgjkdgfasgkfasd;
   exit=.;
   output;
 end;
run;


proc sql;
 drop table thank_you_for_using_stratify0;
 drop table thank_you_for_using_stratify1;
quit;

%end;



****** MODE M ******** ;

%if &mode=M %then %do;

proc sql;
  create table Thank_you_for_using_this_outcome as select
    %substr(%bquote(&commaoutcomevars),6) , &subject from &outcomes o, Thank_you_for_using_valid_values e
    where &eventtime > . and o.&eventtype=e.&eventtype
    order &subject, o.&eventtype, &eventtime ;
quit;

data Thank_you_for_using_this_outcome;
 set Thank_you_for_using_this_outcome;
 by &subject &eventtype;
 if first.&eventtype;
run;

proc sql;
  create table Thank_you_for_using_zrtfevents0 as select &commaoutcomevars from
    Thank_you_for_using_zrtf0 t, Thank_you_for_using_this_outcome o
    where t.&subject=o.&subject and &eventtime lt exit;
  drop table Thank_you_for_using_this_outcome;
quit;

data &pyrsdatasetname (keep= &keepvars);
 set Thank_you_for_using_zrtf0 (in=_Thank_you_for_using_stratify)
     Thank_you_for_using_zrtfevents0;
 if _Thank_you_for_using_stratify then do;
   &eventtype=&noeventvalue ;
   %do i=1 %to &dimsrtf;
       &&srtforigin&i=entry - &&srtfvalue&i - &&srtfspeed&i * (entry-&&t&i);
      %if &&srtfflag&i=1 %then %do;
        if &&srtforigin&i=. then do; &&srtforigin&i=entry; &&srtfspeed&i=0; end;
      %end;
   %end;
   if exit>entry then output;
 end;
 else do;
   _Thank_you_for_using_this_temp_=entry;
   entry=max(_Thank_you_for_using_this_temp_,&eventtime + &granularity);
   %do i=1 %to &dimsrtf;
       &&srtforigin&i=entry - &&srtfvalue&i - &&srtfspeed&i * (entry-&&t&i);
       %if &&srtfflag&i=1 %then %do;
         if &&srtforigin&i=. then do; &&srtforigin&i=entry; &&srtfspeed&i=0; end;
       %end;
   %end;
   if entry<exit then output;
   if _Thank_you_for_using_this_temp_ le &eventtime lt exit then do;
     entry=&eventtime ;
     exit=. ;
     %do i=1 %to &dimsrtf;
       &&srtforigin&i=entry - &&srtfvalue&i - &&srtfspeed&i * (entry-&&t&i);
       %if &&srtfflag&i=1 %then %do;
         if &&srtforigin&i=. then do; &&srtforigin&i=entry; &&srtfspeed&i=0; end;
       %end;
     %end;
     output;
   end;
 end;
run;

%end;



****** MODE I ******** ;

%if &mode=I %then %do;

%if &outcomes ^= %then %do;

proc sql;
  create table Thank_you_for_using_zrtfevents0 as select
    %substr(%bquote(&commaoutcomevars),6) , &subject from &outcomes o, Thank_you_for_using_valid_values e
    where &eventtime > . and o.&eventtype=e.&eventtype;
quit;

proc sort nodupkey; by &subject &eventtime &eventtype; run;

proc sql;
  create table Thank_you_for_using_zrtfevents0 as select &commaoutcomevars from
    Thank_you_for_using_zrtf0 t, Thank_you_for_using_zrtfevents0 o
    where t.&subject=o.&subject and entry le &eventtime lt exit;
quit;

data &pyrsdatasetname (keep= &keepvars);
 set Thank_you_for_using_zrtf0 (in=_Thank_you_for_using_stratify)
     Thank_you_for_using_zrtfevents0;
 if _Thank_you_for_using_stratify then &eventtype=&noeventvalue ;
   else do; exit=.; entry=&eventtime; end;
 %do i=1 %to &dimsrtf;
   &&srtforigin&i=entry - &&srtfvalue&i - &&srtfspeed&i * (entry-&&t&i);
   %if &&srtfflag&i=1 %then %do;
     if &&srtforigin&i=. then do; &&srtforigin&i=entry; &&srtfspeed&i=0; end;
   %end;
 %end;
run;

proc sql; drop table Thank_you_for_using_zrtfevents0; quit;

%end;

%if &outcomes = %then %do;

proc datasets nolist;
 contents data=Thank_you_for_using_valid_values
          out=Thank_you_for_using_stratify0 (keep=name type length) noprint;
quit;

data _null_; length hlpstr2 $50 ; set Thank_you_for_using_stratify0;
 if upcase(name)=upcase("&eventtype") then do;
    if type=1 then hlpstr2=" ";
    if type=2 then hlpstr2="$"||trim(put(length,f6.));
    call symput("valid_values_length",hlpstr2);
 end;
run;

data thank_you_for_using_stratify1; set Thank_you_for_using_zrtf0(obs=1)
 Thank_you_for_using_valid_values(in=Thank_you_for_using_valid_values);
 if Thank_you_for_using_valid_values;
run;

data &pyrsdatasetname (keep= &keepvars);
 array _valid_values(&n_valid_values) &valid_values_length _temporary_;
 set Thank_you_for_using_stratify1(in=Thank_you_for_using_valid_values) Thank_you_for_using_zrtf0;
 if Thank_you_for_using_valid_values then _valid_values(_n_)=&eventtype;
    _entry=entry; _exit=exit;
 if &eventtime>. then do;
    _deletovich_=1;
    _p1=1;
    do while (_p1 le &n_valid_values and _deletovich_=1);
      if _valid_values(_p1)=&eventtype then _deletovich_=0;
      _p1=_p1+1;
    end;
    if _deletovich_=1 then &eventtime=.;
 end;
 if entry le &eventtime lt exit then do;
    exit=.; entry=&eventtime;
    %do i=1 %to &dimsrtf;
       &&srtforigin&i=entry - &&srtfvalue&i - &&srtfspeed&i * (entry-&&t&i);
       %if &&srtfflag&i=1 %then %do;
         if &&srtforigin&i=. then do; &&srtforigin&i=entry; &&srtfspeed&i=0; end;
       %end;
    %end;
    output;
 end;
 entry=_entry; exit=_exit; &eventtype=&noeventvalue;
 %do i=1 %to &dimsrtf;
   &&srtforigin&i=entry - &&srtfvalue&i - &&srtfspeed&i * (entry-&&t&i);
       %if &&srtfflag&i=1 %then %do;
         if &&srtforigin&i=. then do; &&srtforigin&i=entry; &&srtfspeed&i=0; end;
       %end;
 %end;
 if entry<exit then output;
run;

proc sql;
 drop table thank_you_for_using_stratify0;
 drop table thank_you_for_using_stratify1;
quit;

%end;

%end;



******* START OF PYRS MACROS *******;


* A little cleaning-up first ;
%let hlpstr1=Thank_you_for_using_zrtf0 ;
%if &mode=M %then %let hlpstr1=&hlpstr1 Thank_you_for_using_zrtfevents0;
%if %length(&eventid)>0 %then %let hlpstr1=&hlpstr1 Thank_you_for_using_stratify0;
proc datasets lib=work nolist; delete &hlpstr1 ; quit;




%if &class ^= %then %do; proc sort data=&pyrsdatasetname; by &class; run; %end;


%let dim=&dimaxis;

* we generate various strings (macro variables) to be inserted in the main data step ;
%let i=1;
%do %while(%length(%scan(&class,%eval(&i+1),%str(' ')))>0); %let i=%eval(&i+1); %end;
%let last_fix=%scan(&class,&i,%str(' '));
%let totdim=1;%let maxdim=;%let axisvec=;%let pvec=;%let pveccsv=;%let min_ci=exit;
%do i=1 %to &dim;
  %if %nrbquote(%scan(%upcase(&&cuts&i),2,%str(' ')))=TO %then %do;
    %let _origo  =%scan(&&cuts&i,1,%str(' '));
    %let _step   =%scan(&&cuts&i,5,%str(' '));
    %let _cuts&i =&_origo + _p&i*&_step;
    data _null_; j=-1; do i=&&cuts&i ; j=j+1; end; call symput("_pmax&i",j); run;
  %end;
  %else %do;
    %let _cuts&i  =input(scan("&&cuts&i",_p&i +1,' '),f20.);
    %let _pmax&i  =-1;
    %do %while(%length(%scan(&&cuts&i,%eval(&&_pmax&i+2),%str(' ')))>0);
      %let _pmax&i=%eval(&&_pmax&i+1);
    %end;
  %end;
  %let totdim    =%eval(&totdim*%eval(&&_pmax&i +1));
  %let maxdim    =&maxdim 0:&&_pmax&i, ;
  %let pveccsv   =&pveccsv  _p&i , ;
  %let axisvec   =&axisvec &&axis&i ;
  %let min_ci    =&min_ci ,_d&i ;
%end;

%if &dimaxis  =0 %then %do;
 %let axis1   =_qwertyuiopasdfghjkl_;
 %let origin1 =entry;
 %let cuts1   =0;
 %let _cuts1  =0;
 %let speed1  =1;
 %let totdim  =2;
 %let maxdim  =0:2 , ;
 %let pveccsv =_p1 , ;
 %let min_ci  =exit,exit  ;
 %let dim     =1;
 %let _pmax1  =1;
%end;

options &notes;



**************** FSTPYRS ***********;

%if &method=FST %then %do;


data &pyrsdata.     (keep= &class &axisvec pyrs events)
%if &eventdat ^= %then &eventdat. (keep= &class &axisvec &eventID); ;


 array _capyarr(&maxdim 0:1)                           _temporary_;
 %do i=1 %to &dim; array _ci&i (0:%eval(&&_pmax&i +1)) _temporary_; %end;
 array _arrhits(0:&totdim,&dim)                        _temporary_;
 retain _no_of_hits (0);


 set &pyrsdatasetname %if &class = %then end=last_rec_flag; ;
 %if &class ^= %then by &class.; ;


  * initialisation of arrays ;
  if _n_=1 then do;
    %do i=1 %to &dim; do _p&i=0 to &&_pmax&i; %end;
      _capyarr(&pveccsv 0)=0;
      _capyarr(&pveccsv 1)=-1; * -1 signals the cells with coordinates &pveccsv are untouched ;
    %do i=1 %to &dim; end; %end;
    %do i=1 %to &dim;
      do _p&i=0 to &&_pmax&i; _ci&i(_p&i)=&&_cuts&i; end; _ci&i(&&_pmax&i +1)=. ;
    %end;
  end;


  * for each time scale find the pointer _p&i to the category for entry time;
%do i=1 %to &dim;
  _origin&i=&&origin&i ;
  _p&i     =&&_pmax&i;
  if _origin&i >. then do;
    _yr=(entry-_origin&i) &scalediv;
    %if %nrbquote(%scan(%upcase(&&cuts&i),2,%str(' ')))=TO %then %do;
      _p&i=min(_p&i,floor((_yr-_ci&i(0))/%scan(%upcase(&&cuts&i),5,%str(' '))));
        %end;
    %else %do;
       do while(_yr < _ci&i(_p&i)); _p&i=_p&i-1; end;
    %end;
  end;
  if &&speed&i = 0 then _origin&i =.;
  %let speeddiv&i= ;
  %let speedmove&i=1;
  %if &&speed&i ^=1 %then %let speeddiv&i= / &&speed&i ;
  %if &&speed&i ^=1 %then %let speedmove&i=(&&speed&i>0) ;
  %if &&speed&i ^=1 %then %do; if &&speed&i<0 and _yr=_ci&i(_p&i) then _p&i=_p&i-1; %end;
%end;


  * calculate person-time and event contributions from the record ;
  * output them for temporary storage in arrays                   ;
  _yr=entry;
  if exit=. then do;
    if _capyarr(&pveccsv 1)=-1 then do;
       _no_of_hits=_no_of_hits+1;
       %do i=1 %to &dim; _arrhits(_no_of_hits,&i)=_p&i; %end;
       _capyarr(&pveccsv 1)=0;
     end;
     _capyarr(&pveccsv 0)=1+_capyarr(&pveccsv 0);
  end;
  else do;
    %do i=1 %to &dim;
        _d&i=(_ci&i(_p&i+&&speedmove&i) &scalemul -entry+_origin&i) &&speeddiv&i +entry;
    %end;
    do while(_yr < exit);
      _next=min(&min_ci);
      if _capyarr(&pveccsv 1)=-1 then do;
         _no_of_hits=_no_of_hits+1;
         %do i=1 %to &dim; _arrhits(_no_of_hits,&i)=_p&i; %end;
         _capyarr(&pveccsv 1)=_next-_yr;
      end;
      else do;
         _capyarr(&pveccsv 1)=_next-_yr+_capyarr(&pveccsv 1);
      end;
      _yr=_next;
      %do i=1 %to &dim;
      if _yr=_d&i then do;
         _p&i=_p&i+sign(&&speed&i);
         %if &&speed&i ^=1 %then %do; if _yr=exit and &&speed&i<0 then _p&i=&&_pmax&i+1; %end;
        _d&i=(_ci&i(_p&i+&&speedmove&i) &scalemul -entry+_origin&i) &&speeddiv&i +entry;
      end;
      %end;
    end;
  end; * END else ;


  * if you want a closer look at events, &eventdat is generated here ;
%if &eventdat ^= %then %do;
  if exit=. then do;
    %do i=1 %to &dim; &&axis&i=_ci&i(_p&i); %end;
    output &eventdat ;
  end;
%end;


  * for each by-group determined by &class aggregated person-time and events ;
  * are provided with the values of the time-varying time factors and output ;
  * and the touched cells in the temporary storage array re-initialed.       ;
  %if &class  = %then if last_rec_flag  then do; ;
  %if &class ^= %then if last.&last_fix then do; ;
    do while(_no_of_hits>0);
      %do i=1 %to &dim; _p&i    =_arrhits(_no_of_hits,&i); %end;
      %do i=1 %to &dim; &&axis&i=_ci&i(_p&i); %end;
      events                    =_capyarr(&pveccsv 0);
      pyrs                      =_capyarr(&pveccsv 1) &scalediv;
      _capyarr(&pveccsv 0)      =0;
      _capyarr(&pveccsv 1)      =-1;
      output &pyrsdata ;
      _no_of_hits=_no_of_hits-1;
    end;
  end;


run;

options nonotes;
%if %upcase(&pyrsdata)=%upcase(&out) %then %do;
proc datasets nolist lib=work; delete &pyrsdatasetname; quit;
%end;
options &notes;

%end; * FSTPYRS ;



********************** ARRPYRS **********;

%if &method=ARR %then %do;



data &pyrsdata.     (keep= &class &axisvec pyrs events)
%if &eventdat ^= %then &eventdat. (keep= &class &axisvec &eventID); ;


 array _capyarr(&maxdim 0:1)                           _temporary_;
 %do i=1 %to &dim; array _ci&i (0:%eval(&&_pmax&i +1)) _temporary_; %end;


 set &pyrsdatasetname  %if &class = %then end=last_rec_flag; ;
 %if &class ^= %then by &class.; ;


  * initialisation of arrays ;
  if _n_=1 then do;
    %do i=1 %to &dim; do _p&i=0 to &&_pmax&i; %end;
      _capyarr(&pveccsv 0)=0;
      _capyarr(&pveccsv 1)=0;
    %do i=1 %to &dim; end; %end;
    %do i=1 %to &dim;
      do _p&i=0 to &&_pmax&i; _ci&i(_p&i)=&&_cuts&i; end; _ci&i(&&_pmax&i +1)=. ;
    %end;
  end;


  * for each time scale find the pointer _p&i to the category for entry time;
%do i=1 %to &dim;
  _origin&i=&&origin&i ;
  _p&i     =&&_pmax&i;
  if _origin&i >. then do;
    _yr=(entry-_origin&i) &scalediv;
    %if %nrbquote(%scan(%upcase(&&cuts&i),2,%str(' ')))=TO %then %do;
      _p&i=min(_p&i,floor((_yr-_ci&i(0))/%scan(%upcase(&&cuts&i),5,%str(' '))));
        %end;
    %else %do;
       do while(_yr < _ci&i(_p&i)); _p&i=_p&i-1; end;
    %end;
  end;
  if &&speed&i = 0 then _origin&i =.;
  %let speeddiv&i= ;
  %let speedmove&i=1;
  %if &&speed&i ^=1 %then %let speeddiv&i= / &&speed&i ;
  %if &&speed&i ^=1 %then %let speedmove&i=(&&speed&i>0) ;
  %if &&speed&i ^=1 %then %do; if &&speed&i<0 and _yr=_ci&i(_p&i) then _p&i=_p&i-1; %end;
%end;


  * calculate person-time and event contributions from the record ;
  * output them for temporary storage in arrays                   ;
  _yr=entry;
  if exit=. then _capyarr(&pveccsv 0)=1+_capyarr(&pveccsv 0);
  else do;
    %do i=1 %to &dim;
        _d&i=(_ci&i(_p&i+&&speedmove&i) &scalemul -entry+_origin&i) &&speeddiv&i +entry;
    %end;
    do while(_yr < exit);
      _next=min(&min_ci);
      _capyarr(&pveccsv 1)=_next-_yr+_capyarr(&pveccsv 1);
      _yr=_next;
      %do i=1 %to &dim;
      if _yr=_d&i then do;
         _p&i=_p&i+sign(&&speed&i);
         %if &&speed&i ^=1 %then %do; if _yr=exit and &&speed&i<0 then _p&i=&&_pmax&i+1; %end;
        _d&i=(_ci&i(_p&i+&&speedmove&i) &scalemul -entry+_origin&i) &&speeddiv&i +entry;
      end;
      %end;
    end;
  end; * END else ;


  * if you want a closer look at events, &eventdat is generated here ;
%if &eventdat ^= %then %do;
  if exit=. then do;
    %do i=1 %to &dim; &&axis&i=_ci&i(_p&i); %end;
    output &eventdat ;
  end;
%end;


  * for each by-group determined by &class aggregated person-time and events ;
  * are provided with the values of the time-varying time factors and output ;
  * and the touched cells in the temporary storage array re-initialed.       ;
  %if &class  = %then if last_rec_flag  then do; ;
  %if &class ^= %then if last.&last_fix then do; ;
      %do i=1 %to &dim; do _p&i =0 to &&_pmax&i; %end;
      %do i=1 %to &dim; &&axis&i=_ci&i(_p&i); %end;
      events                    =_capyarr(&pveccsv 0);
      pyrs                      =_capyarr(&pveccsv 1) &scalediv;
      if max(pyrs,events)>0 then do;
        _capyarr(&pveccsv 0)      =0;
        _capyarr(&pveccsv 1)      =0;
        output &pyrsdata ;
      end;
      %do i=1 %to &dim; end; %end;
  end;


run;

options nonotes;
%if %upcase(&pyrsdata)=%upcase(&out) %then %do;
proc datasets nolist lib=work; delete &pyrsdatasetname; quit;
%end;
options &notes;

%end;  * ARRPYRS ;



****************** SUMPYRS *********** ;

%if &method=SUM %then %do;

data &pyrsdatasetname  (keep= &class &axisvec pyrs events) ;
%if &eventdat ^= %then &eventdat. (keep= &class &axisvec &eventID); ;


 %do i=1 %to &dim; array _ci&i (0:%eval(&&_pmax&i +1)) _temporary_; %end;


 set &pyrsdatasetname %if &class = %then end=last_rec_flag; ;
 %if &class ^= %then by &class.; ;

  * initialisation of arrays ;
  if _n_=1 then do;
    %do i=1 %to &dim;
      do _p&i=0 to &&_pmax&i; _ci&i(_p&i)=&&_cuts&i; end; _ci&i(&&_pmax&i +1)=. ;
    %end;
  end;


  * for each time scale find the pointer _p&i to the category for entry time;
%do i=1 %to &dim;
  _origin&i=&&origin&i ;
  _p&i     =&&_pmax&i;
  if _origin&i >. then do;
    _yr=(entry-_origin&i) &scalediv;
    %if %nrbquote(%scan(%upcase(&&cuts&i),2,%str(' ')))=TO %then %do;
      _p&i=min(_p&i,floor((_yr-_ci&i(0))/%scan(%upcase(&&cuts&i),5,%str(' '))));
        %end;
    %else %do;
       do while(_yr < _ci&i(_p&i)); _p&i=_p&i-1; end;
    %end;
  end;
  if &&speed&i = 0 then _origin&i =.;
  %let speeddiv&i= ;
  %let speedmove&i=1;
  %if &&speed&i ^=1 %then %let speeddiv&i= / &&speed&i ;
  %if &&speed&i ^=1 %then %let speedmove&i=(&&speed&i>0) ;
  %if &&speed&i ^=1 %then %do; if &&speed&i<0 and _yr=_ci&i(_p&i) then _p&i=_p&i-1; %end;
%end;

  * calculate person-time and event contributions from the record ;
  * output them for temporary storage in a data set               ;
  _yr=entry;
  if exit=. then do;
    events=1;
    pyrs  =0;
    %do i=1 %to &dim; &&axis&i = _ci&i(_p&i); %end;
    output &pyrsdatasetname;
    end;
  else do;
    events=0;
    %do i=1 %to &dim;
        _d&i=(_ci&i(_p&i+&&speedmove&i) &scalemul -entry+_origin&i) &&speeddiv&i +entry;
    %end;
    do while(_yr < exit);
      _next=min(&min_ci);
      pyrs=(_next-_yr) &scalediv;
      %do i=1 %to &dim; &&axis&i = _ci&i(_p&i); %end;
      output &pyrsdatasetname;
      _yr=_next;
      %do i=1 %to &dim;
      if _yr=_d&i then do;
         _p&i=_p&i+sign(&&speed&i);
         %if &&speed&i ^=1 %then %do; if _yr=exit and &&speed&i<0 then _p&i=&&_pmax&i+1; %end;
        _d&i=(_ci&i(_p&i+&&speedmove&i) &scalemul -entry+_origin&i) &&speeddiv&i +entry;
      end;
      %end;
    end;
  end; * END else ;


  * if you want a closer look at events, &eventdat is generated here ;
%if &eventdat ^= %then %do;
  if exit=. then do;
    %do i=1 %to &dim; &&axis&i=_ci&i(_p&i); %end;
    output &eventdat ;
  end;
%end;


proc summary nway data=&pyrsdatasetname;
 class &axisvec;
%if &class ^= %then by &class;  ;
 var events pyrs;
 output out=&pyrsdata(drop=_freq_ _type_) sum=;
run;

options nonotes;
%if %upcase(&pyrsdata)=%upcase(&out) %then %do;
proc datasets nolist lib=work; delete &pyrsdatasetname; quit;
%end;
options &notes;

%end; * SUMPYRS ;



********************* CHUNKPYRS *********;

%if &method=CHUNK %then %do;

options nonotes;



proc datasets lib=work nolist;
 contents data=Thank_you_for_using_chunkpyrs
           out=Thank_you_for_using_chunkpyrs2(keep=nobs) noprint;
 delete &out;
 %if &eventdat ^= %then delete &eventdat; ;
quit;

%let obs_in_inputdat=;
data _null_; set Thank_you_for_using_chunkpyrs2(obs=1);
 call symput('obs_in_inputdat',nobs);
run;

%let start=1;
%let _xxx_=1;

%do %while (&start<&obs_in_inputdat ) ;

data Thank_you_for_using_chunkpyrs2;
 set Thank_you_for_using_chunkpyrs(firstobs=&start);
 %if &class ^= %then by &class.; ;
 if (_n_ ge &chunksize %if &class ^= %then and first.&last_fix =1;) then do;
     call symput('_xxx_',_n_);
     STOP;
 end;
 if _n_=&obs_in_inputdat then call symput('_xxx_',_n_);
run;

%let start=%eval(&start + &_xxx_);

data Thank_you_for_using_chunkpyrs2  (keep= &class &axisvec pyrs events)
%if &eventdat ^= %then Thank_you_for_using_chunkpyrs3 (keep= &class &axisvec &eventID); ;


 %do i=1 %to &dim; array _ci&i (0:%eval(&&_pmax&i +1)) _temporary_; %end;


 set Thank_you_for_using_chunkpyrs2 %if &class = %then end=last_rec_flag; ;
 %if &class ^= %then by &class.; ;

  * initialisation of arrays ;
  if _n_=1 then do;
    %do i=1 %to &dim;
      do _p&i=0 to &&_pmax&i; _ci&i(_p&i)=&&_cuts&i; end; _ci&i(&&_pmax&i +1)=. ;
    %end;
  end;


  * for each time scale find the pointer _p&i to the category for entry time;
%do i=1 %to &dim;
  _origin&i=&&origin&i ;
  _p&i     =&&_pmax&i;
  if _origin&i >. then do;
    _yr=(entry-_origin&i) &scalediv;
    %if %nrbquote(%scan(%upcase(&&cuts&i),2,%str(' ')))=TO %then %do;
      _p&i=min(_p&i,floor((_yr-_ci&i(0))/%scan(%upcase(&&cuts&i),5,%str(' '))));
        %end;
    %else %do;
       do while(_yr < _ci&i(_p&i)); _p&i=_p&i-1; end;
    %end;
  end;
  if &&speed&i = 0 then _origin&i =.;
  %let speeddiv&i= ;
  %let speedmove&i=1;
  %if &&speed&i ^=1 %then %let speeddiv&i= / &&speed&i ;
  %if &&speed&i ^=1 %then %let speedmove&i=(&&speed&i>0) ;
  %if &&speed&i ^=1 %then %do; if &&speed&i<0 and _yr=_ci&i(_p&i) then _p&i=_p&i-1; %end;
%end;


  * calculate person-time and event contributions from the record ;
  * output them for temporary storage in a data set               ;
  _yr=entry;
  if exit=. then do;
    events=1;
    pyrs  =0;
    %do i=1 %to &dim; &&axis&i = _ci&i(_p&i); %end;
    output Thank_you_for_using_chunkpyrs2;
    end;
  else do;
    events=0;
    %do i=1 %to &dim;
        _d&i=(_ci&i(_p&i+&&speedmove&i) &scalemul -entry+_origin&i) &&speeddiv&i +entry;
    %end;
    do while(_yr < exit);
      _next=min(&min_ci);
      pyrs=(_next-_yr) &scalediv;
      %do i=1 %to &dim; &&axis&i = _ci&i(_p&i); %end;
      output Thank_you_for_using_chunkpyrs2;
      _yr=_next;
      %do i=1 %to &dim;
      if _yr=_d&i then do;
         _p&i=_p&i+sign(&&speed&i);
         %if &&speed&i ^=1 %then %do; if _yr=exit and &&speed&i<0 then _p&i=&&_pmax&i+1; %end;
        _d&i=(_ci&i(_p&i+&&speedmove&i) &scalemul -entry+_origin&i) &&speeddiv&i +entry;
      end;
      %end;
    end;
  end; * END else ;


  * if you want a closer look at events, &eventdat is generated here ;
%if &eventdat ^= %then %do;
  if exit=. then do;
    %do i=1 %to &dim; &&axis&i=_ci&i(_p&i); %end;
    output Thank_you_for_using_chunkpyrs3 ;
  end;
%end;


proc summary nway data=Thank_you_for_using_chunkpyrs2;
 class &axisvec;
%if &class ^= %then by &class;  ;
 var events pyrs;
 output out=Thank_you_for_using_chunkpyrs2(drop=_freq_ _type_) sum=;
run;

proc datasets nolist lib=work;
   append base=&pyrsdata data=Thank_you_for_using_chunkpyrs2;
%if &eventdat ^= %then append base=&eventdat data=Thank_you_for_using_chunkpyrs3;  ;
quit;

%end;

proc datasets nolist lib=work;
   delete Thank_you_for_using_chunkpyrs
          Thank_you_for_using_chunkpyrs2;
   %if &eventdat ^= %then delete Thank_you_for_using_chunkpyrs3;  ;
quit;


%if &class = %then %do;
proc summary nway data=&pyrsdata;
 class &axisvec;
 var events pyrs;
 output out=&pyrsdata(drop=_freq_ _type_) sum=;
run;
%end;

%end; * CHUNKPYRS ;



******************* NOAGG **********;

%if &method=NOAGG %then %do;



data &pyrsdata  (keep= &class &axisvec _yr _next rename=(_yr=entry _next=exit))
%if &eventdat ^= %then &eventdat. (keep= &class &axisvec &eventID); ;


 %do i=1 %to &dim; array _ci&i (0:%eval(&&_pmax&i +1)) _temporary_; %end;


 set &pyrsdatasetname;

  * initialisation of arrays ;
  if _n_=1 then do;
    %do i=1 %to &dim;
      do _p&i=0 to &&_pmax&i; _ci&i(_p&i)=&&_cuts&i; end; _ci&i(&&_pmax&i +1)=. ;
      &&axis&i = _ci&i(_p&i); * for aesthetical reasons ;
    %end;
  end;


  * for each time scale find the pointer _p&i to the category for entry time;
%do i=1 %to &dim;
  _origin&i=&&origin&i ;
  _p&i     =&&_pmax&i;
  if _origin&i >. then do;
    _yr=(entry-_origin&i) &scalediv;
    %if %nrbquote(%scan(%upcase(&&cuts&i),2,%str(' ')))=TO %then %do;
      _p&i=min(_p&i,floor((_yr-_ci&i(0))/%scan(%upcase(&&cuts&i),5,%str(' '))));
        %end;
    %else %do;
       do while(_yr < _ci&i(_p&i)); _p&i=_p&i-1; end;
    %end;
  end;
  if &&speed&i = 0 then _origin&i =.;
  %let speeddiv&i= ;
  %let speedmove&i=1;
  %if &&speed&i ^=1 %then %let speeddiv&i= / &&speed&i ;
  %if &&speed&i ^=1 %then %let speedmove&i=(&&speed&i>0) ;
  %if &&speed&i ^=1 %then %do; if &&speed&i<0 and _yr=_ci&i(_p&i) then _p&i=_p&i-1; %end;
%end;


  _yr=entry;
  if exit=. then do;
    %do i=1 %to &dim; &&axis&i = _ci&i(_p&i); %end;
    output &pyrsdata;
    end;
  else do;
    %do i=1 %to &dim;
        _d&i=(_ci&i(_p&i+&&speedmove&i) &scalemul -entry+_origin&i) &&speeddiv&i +entry;
    %end;
    do while(_yr < exit);
      %do i=1 %to &dim; &&axis&i = _ci&i(_p&i); %end;
      _next=min(&min_ci);
      output &pyrsdata;
      _yr=_next;
      %do i=1 %to &dim;
      if _yr=_d&i then do;
         _p&i=_p&i+sign(&&speed&i);
         %if &&speed&i ^=1 %then %do; if _yr=exit and &&speed&i<0 then _p&i=&&_pmax&i+1; %end;
        _d&i=(_ci&i(_p&i+&&speedmove&i) &scalemul -entry+_origin&i) &&speeddiv&i +entry;
      end;
      %end;
    end;
  end; * END else ;


  * if you want a closer look at events, &eventdat is generated here ;
%if &eventdat ^= %then %do;
  if exit=. then do;
    %do i=1 %to &dim; &&axis&i=_ci&i(_p&i); %end;
    output &eventdat ;
  end;
%end;

run;


%if %upcase(&pyrsdata)=%upcase(&out) %then %do;
proc datasets nolist lib=work; delete &pyrsdatasetname; quit;
%end;

%end; * NOAGG ;





****** START OF POST-PROCESSING ******;

%if &complete=Y %then %do;

****** first some common things ******;

options nonotes;

%let byvars=&orgclass &axisvec;

data _null_; length junkstr1 junkstr2 junkstr3 junkstr4 $32000 target dropvar $32 ;
   junkstr1=upcase(symget('byvars'));
   junkstr2=upcase(symget('dropvars'));
   junkstr3='';
   junkstr4='';
   i=1;
   target=scan(junkstr1,i,' ');
   do while (target ne '');
      drop_this_thing=0;
      j=1;
      dropvar=scan(junkstr2,j,' ');
      do while (dropvar ne '' and drop_this_thing=0);
        if (target=dropvar) then drop_this_thing=1;
        j=j+1;
        dropvar=scan(junkstr2,j,' ');
      end;
      if drop_this_thing=0 then junkstr3=trim(junkstr3)||' '||trim(target);
      if drop_this_thing=0 then junkstr4=trim(junkstr4)||','||trim(target);
      i=i+1;
      target=scan(junkstr1,i,' ');
   end;
   call symput('byvars',junkstr3);
   call symput('commabyvars',substr(junkstr4,3));
run;

%let _nvars_=0;
%let _intvar=%scan(&byvars,1,%str(' '));
%do %while(%length(&_intvar)>0);
%let _nvars_=%eval(&_nvars_+1);
%let _intvar=%scan(&byvars,&_nvars_+1,%str(' '));
%end;
%let last_fix=;
%if &_nvars_>0 %then %let last_fix=%scan(&byvars,&_nvars_,%str(' '));



%if %substr(&complete_rates_agg_multi,4)=Y %then %do;

data Thank_you_for_using_valid_values;
 set Thank_you_for_using_valid_values end=_endflag_;
 _p0=_n_; output;
 if _endflag_ then do; _p0=0; &eventtype=&noeventvalue; output; end;
run;

proc datasets lib=work nolist;
  contents data=Thank_you_for_using_valid_values out=Thank_you_for_using_stratify0 (keep=name type length) noprint;
quit;

data _null_; length hlpstr $50 ; set Thank_you_for_using_stratify0;
 if upcase(name)=upcase("&eventtype") then do;
    if type=1 then hlpstr=" ";
    if type=2 then hlpstr="$"||trim(put(length,f6.));
    call symput("valid_values_length",hlpstr);
 end;
run;

%put When you use MODE=i,c,m and COMPLETE=y you will receive warnings - just ignore them. ;

proc sql;
  create table &pyrsdata (drop=&eventtype) as select *
    from &pyrsdata p, Thank_you_for_using_valid_values t
    where p.&eventtype=t.&eventtype
    %if %length(&commabyvars)>0 %then %do; order &commabyvars; %end; ;
  drop table Thank_you_for_using_stratify0;
quit;
%end;



%if &postprocess=Y %then %do;
%let nobyvars=0;
%if &byvars= %then %do;
  %let nobyvars=1;
  %let byvars=_qwertyuiopasdfghjkl_;
  %let last_fix=&byvars;
  data &pyrsdata; set &pyrsdata; _qwertyuiopasdfghjkl_=1; run;
%end;
%end;





%if &ratesmulti=Y %then %do;

proc sql;
  create table _rindat(drop=&eventtype) as select * from &rates r, Thank_you_for_using_valid_values t where r.&eventtype=t.&eventtype;
quit;

proc datasets nolist;
 contents data=_rindat out=Thank_you_for_using_stratify0(keep=name) noprint;
quit;

data _null_;
 length str1 str2 $32000;
 retain str1 str2 (' ',' ');
 set Thank_you_for_using_stratify0 end=endflag;
 if _n_=1 then do; str1=''; str2=''; end;
 if not (upcase(name)='RATE' or upcase(name)="_P0") then do;
      str1=trim(str1)||' '||name;
      str2=trim(str2)||' and p.'||name||'=q.'||name;
 end;
 if endflag then do;
     call symput('adjvars',trim(str1));
     call symput('whereadjvars',trim(substr(str2,6)));
 end;
run;

proc sql;
  create table Thank_you_for_using_stratify0 as select unique * from _rindat(drop=rate _p0);
quit;

data Thank_you_for_using_stratify0;
 set Thank_you_for_using_stratify0 end=endflag;
 _p1=_n_-1;
 if endflag then call symput('_p1max',put(_p1,f10.));
run;

proc sql;
  create table _rindat as select * from _rindat p, Thank_you_for_using_stratify0 q
    where &whereadjvars ;
  create table _pyrso as select p.*, q._p1, 1 as _This_is_the_real_data_ from &pyrsdata p, Thank_you_for_using_stratify0 q
    where &whereadjvars
    %if %length(&commabyvars)>0 %then %do; order &commabyvars; %end; ;
  drop table Thank_you_for_using_stratify0;
quit;

%let varstr=&adjvars ;

data _rindat; set _pyrso(obs=1) _rindat(in=r); if r; _This_is_the_real_data_=0; run;
proc sort; by &byvars; run;

%end; * end RATESMULTI=Y ;



%if &ratessingle=Y %then %do;

%put When you use RATES you will receive warnings - just ignore them. ;

proc sql; create table _rindat as select * from &rates; quit;

proc datasets nolist;
 contents data=_rindat out=Thank_you_for_using_stratify0(keep=name) noprint;
quit;

data _null_;
 length str1 str2 $32000;
 retain str1 str2 (' ',' ');
 set Thank_you_for_using_stratify0 end=endflag;
 if _n_=1 then do; str1=''; str2=''; end;
 if not (upcase(name)='RATE') then do;
      str1=trim(str1)||' '||name;
      str2=trim(str2)||' and p.'||name||'=q.'||name;
 end;
 if endflag then do;
     call symput('adjvars',trim(str1));
     call symput('whereadjvars',trim(substr(str2,6)));
 end;
run;

proc sql;
  create table Thank_you_for_using_stratify0 as select unique * from _rindat(drop=rate);
quit;

data Thank_you_for_using_stratify0;
 set Thank_you_for_using_stratify0 end=endflag;
 _p1=_n_-1;
 if endflag then call symput('_p1max',put(_p1,f10.));
run;

proc sql;
  create table _rindat as select * from _rindat p, Thank_you_for_using_stratify0 q
    where &whereadjvars ;
  create table _pyrso as select p.*, q._p1, 1 as _This_is_the_real_data_ from &pyrsdata p, Thank_you_for_using_stratify0 q
    where &whereadjvars
    %if %length(&commabyvars)>0 %then %do; order &commabyvars; %end; ;
  drop table Thank_you_for_using_stratify0;
  drop table &pyrsdata;
quit;

%let varstr=&adjvars ;

data _rindat; set _pyrso(obs=1) _rindat(in=r); if r; _This_is_the_real_data_=0; run;
proc sort; by &byvars; run;

%end; * end RATESSINGLE=Y ;






****** then the variants ******;




%if &complete_rates_agg_multi=YNYY %then %do;

data
%do i=1 %to &n_valid_values; Thank_you_for_using_value&i (drop=_px) %end;  ;
 array _cumpyrs (&n_valid_values) _temporary_;
 array _cumevents (&n_valid_values) _temporary_;
 set &pyrsdata;
 by &byvars;
 if first.&last_fix then do;
   do _px=1 to &n_valid_values; _cumpyrs(_px)=0; _cumevents(_px)=0; end;
 end;
 if _p0>0 then do; _cumevents(_p0)=_cumevents(_p0)+events; _cumpyrs(_p0)=_cumpyrs(_p0)-pyrs; end;
 if _p0=0 then do; do _px=1 to &n_valid_values; _cumpyrs(_px)=_cumpyrs(_px)+pyrs; end; end;
 if last.&last_fix then do;
   %do i=1 %to &n_valid_values;
     if _cumpyrs(&i)>10e-15 then do;
          pyrs=_cumpyrs(&i); events=_cumevents(&i); _p0=&i; output Thank_you_for_using_value&i ;
     end;
   %end;
 end;
run;

%end; * YNYY ;





%if &complete_rates_agg_multi=YYYY %then %do;

data
%do i=1 %to &n_valid_values; Thank_you_for_using_value&i (keep=&byvars _p0 events pyrs expected) %end;  ;
 array _cumpyrs (&n_valid_values) _temporary_;
 array _cumevents (&n_valid_values) _temporary_;
 array _cumexpected (&n_valid_values) _temporary_;
 array _rate(0:&n_valid_values,0:&_p1max) _temporary_;
 set _rindat _pyrso ;
 by _This_is_the_real_data_ &byvars;
 if  _This_is_the_real_data_=0 then _rate(_p0,_p1) = rate;
 if first.&last_fix then do;
   do _px=1 to &n_valid_values; _cumpyrs(_px)=0; _cumevents(_px)=0; _cumexpected(_px)=0; end;
 end;
 if _p0>0 then do;
   _cumevents(_p0)=_cumevents(_p0)+events*(_rate(_p0,_p1)>.);
   _cumpyrs(_p0)=_cumpyrs(_p0)-pyrs*(_rate(_p0,_p1)>.);
   _cumexpected(_p0)=_cumexpected(_p0)-pyrs*max(0,_rate(_p0,_p1));
end;
 if _p0=0 then do;
   do _px=1 to &n_valid_values;
     _cumpyrs(_px)=_cumpyrs(_px)+pyrs*(_rate(_px,_p1)>.);
     _cumexpected(_px)=_cumexpected(_px)+pyrs*max(0,_rate(_px,_p1));
   end;
 end;
 if last.&last_fix then do;
   %do i=1 %to &n_valid_values;
     if _cumpyrs(&i)>10e-15 then do;
          pyrs=_cumpyrs(&i); events=_cumevents(&i); expected=_cumexpected(&i); _p0=&i; output Thank_you_for_using_value&i ;
     end;
   %end;
 end;
run;

proc sql; drop table _rindat; drop table _pyrso; quit;

%end; * YYYY ;



%if &complete_rates_agg_multi=YYYN %then %do;

data &out (keep=&byvars events pyrs expected)  ;
 retain _cumevents _cumpyrs _cumexpected (0,0,0);
 array _rate(0:&_p1max) _temporary_;
 set _rindat _pyrso ;
 by _This_is_the_real_data_ &byvars;
 if  _This_is_the_real_data_=0 then _rate(_p1) = rate;
 if first.&last_fix then do; _cumevents=0; _cumpyrs=0; _cumexpected=0; end;
 _cumevents=_cumevents+events;
 _cumpyrs=_cumpyrs+pyrs;
 _cumexpected=_cumexpected+pyrs*max(0,_rate(_p1));
 if last.&last_fix and _cumpyrs>10e-15 then do; pyrs=_cumpyrs; events=_cumevents; expected=_cumexpected; output; end;
run;

proc sql; drop table _rindat; drop table _pyrso; quit;

%end; * YYYN ;



%if &complete_rates_agg_multi=YNNN %then %do;

proc sql;
 create table Thank_you_for_using_noagg2 as select unique &subject, entry as _qwertyuiopasdfghjkl2_ from &pyrsdata where exit=.;
 create table &pyrsdata as select *
   from &pyrsdata p left join Thank_you_for_using_noagg2 q on p.&subject=q.&subject order p.&subject, p.entry;
quit;

data &out; set &pyrsdata;
 if _qwertyuiopasdfghjkl2_>. then exit=min(exit,_qwertyuiopasdfghjkl2_);
 if entry<exit;
 censored=1-(_qwertyuiopasdfghjkl2_=exit);
 entry=(entry-&coxorigin) &scalediv;
 exit =(exit -&coxorigin) &scalediv;
 drop _qwertyuiopasdfghjkl2_;
  %if &nobyvars=1 %then %do; drop _qwertyuiopasdfghjkl_; %end;
run;

proc sql; drop table &pyrsdata; drop table Thank_you_for_using_noagg2; quit;

%end; * YNNN ;




%if &complete_rates_agg_multi=YNNY %then %do;

%if &mode=C %then %do;

proc sql;
 create table Thank_you_for_using_noagg2 as select unique
   &subject, entry as _qwertyuiopasdfghjkl2_, _p0 as _qwertyuiopasdfghjkl3_ from &pyrsdata where exit=.;
 create table &pyrsdata as select *
   from &pyrsdata p left join Thank_you_for_using_noagg2 q on p.&subject=q.&subject;
quit;

data
%do i=1 %to &n_valid_values; Thank_you_for_using_value&i (keep=&byvars _p0 entry exit censored) %end;   ;
 set &pyrsdata;
 if _qwertyuiopasdfghjkl2_>. then exit=min(exit,_qwertyuiopasdfghjkl2_);
 if entry<exit;
 _qwertyuiopasdfghjkl2_=(exit=_qwertyuiopasdfghjkl2_);
 entry=(entry-&coxorigin) &scalediv;
 exit =(exit -&coxorigin) &scalediv;
 %do i=1 %to &n_valid_values;
   _p0=&i;
   censored=1-_qwertyuiopasdfghjkl2_*(_p0=_qwertyuiopasdfghjkl3_);
   output Thank_you_for_using_value&i;
 %end;
run;

proc sql; drop table &pyrsdata; drop table Thank_you_for_using_noagg2; quit;

%end; * mode=C ;


%if &mode=M %then %do;

data Thank_you_for_using_stratify0 (keep=&subject _p0 entry)
     Thank_you_for_using_stratify1 (keep=&byvars _p0 entry exit)  ;
 set &pyrsdata;
 entry=(entry-&coxorigin) &scalediv;
 exit =(exit -&coxorigin) &scalediv;
 if exit=. then output Thank_you_for_using_stratify0;
 if _p0=0 then do;
   do _p0=1 to &n_valid_values; output Thank_you_for_using_stratify1; end;
 end;
run;

proc sort data=Thank_you_for_using_stratify1; by _p0 &subject; run;

proc sql;
  create table Thank_you_for_using_stratify0 as select _p0, &subject, min(entry) as _fullstop
         from  Thank_you_for_using_stratify0 group _p0, &subject ;
quit;

data
%do i=1 %to &n_valid_values; Thank_you_for_using_value&i (keep=&byvars _p0 entry exit censored) %end;  ;
 merge Thank_you_for_using_stratify1 Thank_you_for_using_stratify0; by _p0 &subject;
 if _fullstop>. then exit=min(exit,_fullstop);
 if entry<exit;
 censored=1-(_fullstop=exit);
 %do i=1 %to &n_valid_values; if _p0=&i then output Thank_you_for_using_value&i ; %end;
run;

proc sql;
 drop table Thank_you_for_using_stratify0;
 drop table Thank_you_for_using_stratify1;
quit;

%end; * mode=M ;


%if &mode=I %then %do;

data Thank_you_for_using_stratify0 (keep=&subject _p0 entry rename=(entry=_qwertyuiopasdfghjkl2_))
     Thank_you_for_using_stratify1 (keep=&byvars _p0 entry exit)  ;
 set &pyrsdata;
 entry=(entry-&coxorigin) &scalediv;
 exit =(exit -&coxorigin) &scalediv;
 if exit=. then output Thank_you_for_using_stratify0;
 if _p0=0 then do;
   do _p0=1 to &n_valid_values; output Thank_you_for_using_stratify1; end;
 end;
run;

proc sql;
 create table Thank_you_for_using_stratify0 as select unique * from Thank_you_for_using_stratify0;
 create table Thank_you_for_using_stratify1 as select * from
  Thank_you_for_using_stratify1 p left join Thank_you_for_using_stratify0 q on
  p.&subject=q.&subject and p.exit=q._qwertyuiopasdfghjkl2_ and p._p0=q._p0;
quit;

data
%do i=1 %to &n_valid_values; Thank_you_for_using_value&i (keep=&byvars _p0 entry exit censored) %end;  ;
 set Thank_you_for_using_stratify1;
 censored=1-(_qwertyuiopasdfghjkl2_=exit);
 %do i=1 %to &n_valid_values; if _p0=&i then output Thank_you_for_using_value&i ; %end;
run;

proc sql;
 drop table Thank_you_for_using_stratify0;
 drop table Thank_you_for_using_stratify1;
quit;

%end; * mode=I ;

%end; * YNNY ;


%if &complete_rates_agg_multi=YYNN %then %do;

data &pyrsdata (keep=&byvars entry exit rate)
     Thank_you_for_using_noagg2(keep=&subject entry) ;
 array _rate(0:&_p1max) _temporary_;
 set _rindat _pyrso ;
 if  _This_is_the_real_data_=0 then _rate(_p1) = rate;
 if  _This_is_the_real_data_ then do;
   rate=_rate(_p1);
   if exit>. and rate>. then output &pyrsdata;
     else output Thank_you_for_using_noagg2;
 end;
run;

proc sql; drop table _rindat; drop table _pyrso; quit;

proc sql;
 create table Thank_you_for_using_noagg2 as select unique &subject, entry as _qwertyuiopasdfghjkl2_
   from Thank_you_for_using_noagg2;
 create table &pyrsdata as select *
   from &pyrsdata p left join Thank_you_for_using_noagg2 q on p.&subject=q.&subject order p.&subject, p.entry;
quit;

data &out; set &pyrsdata;
 if _qwertyuiopasdfghjkl2_>. then exit=min(exit,_qwertyuiopasdfghjkl2_);
 if entry<exit;
 censored=1-(_qwertyuiopasdfghjkl2_=exit);
 entry=(entry-&coxorigin) &scalediv;
 exit =(exit -&coxorigin) &scalediv;
 drop _qwertyuiopasdfghjkl2_;
run;

proc sql; drop table &pyrsdata; drop table Thank_you_for_using_noagg2; quit;


%end; * YYNN ;



%if &complete_rates_agg_multi=YYNY %then %do;

%if &mode=C %then %do;

proc sql;
 create table Thank_you_for_using_noagg2 as select unique
   &subject, entry as _qwertyuiopasdfghjkl2_, _p0 as _qwertyuiopasdfghjkl3_ from _pyrso where exit=.;
 create table _pyrso as select *
   from _pyrso p left join Thank_you_for_using_noagg2 q on p.&subject=q.&subject;
quit;

data
%do i=1 %to &n_valid_values; Thank_you_for_using_value&i (keep=&byvars _p0 entry exit censored rate) %end;  ;
 array _rate(0:&n_valid_values,0:&_p1max) _temporary_;
 set _rindat _pyrso ;
 if _This_is_the_real_data_=0 then _rate(_p0,_p1) = rate;
 if _This_is_the_real_data_ then do;
   if _qwertyuiopasdfghjkl2_>. then exit=min(exit,_qwertyuiopasdfghjkl2_);
   if entry<exit;
   _qwertyuiopasdfghjkl2_=(exit=_qwertyuiopasdfghjkl2_);
   entry=(entry-&coxorigin) &scalediv;
   exit =(exit -&coxorigin) &scalediv;
   %do i=1 %to &n_valid_values;
     _p0=&i;
     censored=1-_qwertyuiopasdfghjkl2_*(_p0=_qwertyuiopasdfghjkl3_);
     rate=_rate(_p0,_p1);
     if rate>. then output Thank_you_for_using_value&i;
   %end;
 end;
run;

%end; * mode=C ;



%if &mode=M %then %do;

data Thank_you_for_using_stratify0 (keep=&subject _p0  entry)
     Thank_you_for_using_stratify1 (keep=&byvars _p0 _p1 entry exit _This_is_the_real_data_)  ;
 set _pyrso;
 entry=(entry-&coxorigin) &scalediv;
 exit =(exit -&coxorigin) &scalediv;
 if exit=. then output Thank_you_for_using_stratify0;
 if _p0=0 then do;
   do _p0=1 to &n_valid_values; output Thank_you_for_using_stratify1; end;
 end;
run;

proc sort data=Thank_you_for_using_stratify1; by _p0 &subject; run;

proc sql;
  create table Thank_you_for_using_stratify0 as select _p0, &subject, min(entry) as _fullstop
         from  Thank_you_for_using_stratify0 group _p0, &subject ;
quit;

data
 Thank_you_for_using_stratify2 (keep=&byvars _p0 _p1 entry exit censored _This_is_the_real_data_) ;
 merge Thank_you_for_using_stratify1 Thank_you_for_using_stratify0; by _p0 &subject;
 if _fullstop>. then exit=min(exit,_fullstop);
 if entry<exit;
 censored=1-(_fullstop=exit);
run;

data
%do i=1 %to &n_valid_values; Thank_you_for_using_value&i (keep=&byvars _p0 entry exit censored rate) %end;  ;
 array _rate(0:&n_valid_values,0:&_p1max) _temporary_;
 set _rindat  Thank_you_for_using_stratify2;
 if _This_is_the_real_data_=0 then _rate(_p0,_p1) = rate;
 if _This_is_the_real_data_ then do;
   %do i=1 %to &n_valid_values; if _p0=&i then do; rate=_rate(_p0,_p1); if rate>. then output Thank_you_for_using_value&i ; end; %end;
 end;
run;

proc sql;
 drop table Thank_you_for_using_stratify0;
 drop table Thank_you_for_using_stratify1;
 drop table Thank_you_for_using_stratify2;
quit;

%end; * mode=M ;


%if &mode=I %then %do;

data Thank_you_for_using_stratify0 (keep=&subject _p0  entry rename=(entry=_qwertyuiopasdfghjkl2_))
     Thank_you_for_using_stratify1 (keep=&byvars _p0 _p1 entry exit _This_is_the_real_data_)  ;
 set _pyrso;
 entry=(entry-&coxorigin) &scalediv;
 exit =(exit -&coxorigin) &scalediv;
 if exit=. then output Thank_you_for_using_stratify0;
 if _p0=0 then do;
   do _p0=1 to &n_valid_values; output Thank_you_for_using_stratify1; end;
 end;
run;

proc sql;
  create table Thank_you_for_using_stratify0 as select unique * from Thank_you_for_using_stratify0;
  create table Thank_you_for_using_stratify1 as select * from
   Thank_you_for_using_stratify1 p left join Thank_you_for_using_stratify0 q on
   p.&subject=q.&subject and p._p0=q._p0 and p.exit=q._qwertyuiopasdfghjkl2_;
quit;

data
%do i=1 %to &n_valid_values; Thank_you_for_using_value&i (keep=&byvars _p0 entry exit censored rate) %end;  ;
 array _rate(0:&n_valid_values,0:&_p1max) _temporary_;
 set _rindat  Thank_you_for_using_stratify1;
 if _This_is_the_real_data_=0 then _rate(_p0,_p1) = rate;
 if _This_is_the_real_data_ then do;
   censored=1-(exit=_qwertyuiopasdfghjkl2_);
   %do i=1 %to &n_valid_values; if _p0=&i then do; rate=_rate(_p0,_p1); if rate>. then output Thank_you_for_using_value&i ; end; %end;
 end;
run;

proc sql;
 drop table Thank_you_for_using_stratify0;
 drop table Thank_you_for_using_stratify1;
quit;

%end; * mode=I ;


proc sql; drop table _rindat; drop table _pyrso; quit;

%end; * YYNY ;





****** FINISHING POST-PROCESSING ******;

%if %substr(&complete_rates_agg_multi,4)=Y %then %do;

data &out (drop=_p0 %if &nobyvars=1 %then _qwertyuiopasdfghjkl_; );
 array _valid_values (0:&n_valid_values) &valid_values_length _temporary_;
 set Thank_you_for_using_valid_values(in=Thank_you_for_using_valid_values)
 %do i=1 %to &n_valid_values; Thank_you_for_using_value&i  %end;  ;
 if Thank_you_for_using_valid_values then _valid_values(_p0)=&eventtype;
 if Thank_you_for_using_valid_values=0 then do; &eventtype=_valid_values(_p0); output; end;
run;

proc datasets lib=work nolist;
  delete Thank_you_for_using_valid_values &pyrsdata
 %do i=1 %to &n_valid_values; Thank_you_for_using_value&i  %end;  ;
quit;

%end;


%if %substr(&complete_rates_agg_multi,3,2)=NY %then %do;

proc sort data=&out; by &eventtype &subject entry; run;

%end;


%end; **** IF COMPLETE=Y       ***** ;


%end; **** IF STOP_EXECUTING=0 ***** ;

proc datasets nolist; delete Thank_you_for_using_valid_values; quit;

data _null_;
 length resultstr $30;
 x=datetime();
 y=symget('timestratifystart');
 t=x-y;
 resultstr=left(put(t,f10.)||' seconds.');
 /*
 hours=floor(t/3600);
 t=mod(t,3600);
 minutes=floor(t/60);
 seconds=mod(t,60);
 if hours>0 then resultstr='real time'||put(hours,f10.)||':'||put(minutes,z2.)||':'||put(seconds,z2.)||'.0';
 if hours=0 and minutes>0 then resultstr='real time'||put(minutes,f10.)||':'||put(seconds,z2.)||'.0';
 if hours=0 and minutes=0 then resultstr='real time'||put(seconds,f10.)||'.0';
 */
 call symput('timestratifyduration',resultstr);
run;

options &notes;
%put NOTE: The stratify macro used: &timestratifyduration ;


%mend;





%macro decyear(date,decyear);
%* Converts a date to a decimal year,                 ;
%* actually time from start of year to start of date  ;
%* E.g. 01JAN1997=1997.00000 , 31DEC1997=1997.99726   ;
  &decyear=year(&date)
    +(mod(juldate(&date),1000)-1)/mod(juldate(mdy(12,31,year(&date))),1000);
%mend decyear;





%macro dtarray(from,to);
%* Creates an array of decimal years, indexed by SAS dates;
 array _dt[%sysevalf(&from.):%sysevalf(&to.)] _temporary_;
 do _i=&from. to &to.; %decyear(_i,_dt[_i]); end;
%mend dtarray;





/*
options nocenter nodate ls=80;

data studybase;
 input idnr sex birthdate entry exit;
 datalines;
 1 1 1935 2000 2008
 ;
run;

data disease;
 input idnr disease eventtime;
 datalines;
 1 1 2003.5
 1 2 2005.5
 ;
run;

data ev; do disease=1 to 2; output; end; run;

data births;
 length expevent $10;
 input idnr date expevent value;
 datalines;
 1 1978.3 birth 3700
 1 1984.3 birth 3500
 ;
run;

data cv;
 length  expevent valuec $10;
 input idnr date expevent valuec;
 datalines;
 1 1999 cv gfgdfg
 1 2002 cv kkk
 ;
run;

data rates;
  do disease=1 to 3;
    do sex=1 to 2;
      do period=2000 to 2010;
         do age=60 to 75;
            rate=0.1+0.1*mod(period,2); output;
         end;
      end;
    end;
  end;
run;

data srates;
    do sex=1 to 2;
      do period=2000 to 2010;
         do age=60 to 75;
            rate=0.1+0.1*mod(period,2); output;
         end;
      end;
    end;
run;






%let setup= data=studybase outcomes=disease out=output
            eventtype=disease EVENTVALUES=ev
            subject=idnr scale=1 granularity=0.001 ;

%stratify(&setup MODE=SINGLE);
title 'Follow-up for a single outcome';
proc print noobs; run;

%stratify(&setup MODE=MULTIPLE);
title 'Simultaneous follow-up for many single outcomes';
proc print noobs; run;

%stratify(&setup MODE=COMPETING); run;
title 'Follow-up for many outcomes to the occurrence of the first (Competing Risks)';
proc print noobs; run;

%stratify(&setup MODE=INTENSITY); run;
title 'Follow-up for many outcomes ignoring prevalent cases';
proc print noobs; run;





%let setup= data=studybase outcomes=disease out=output
            eventtype=disease
            METHOD=NOAGG COXORIGIN=BIRTHDATE
            subject=idnr scale=1 granularity=0.001 ;

%stratify(&setup MODE=SINGLE);
title 'Follow-up for a single outcome';
proc print noobs; run;

%stratify(&setup MODE=MULTIPLE);
title 'Simultaneous follow-up for many single outcomes';
proc print noobs; run;

%stratify(&setup MODE=COMPETING); run;
title 'Follow-up for many outcomes to the occurrence of the first (Competing Risks)';
proc print noobs; run;





%let setup= data=studybase outcomes=disease out=output
            eventtype=disease
            subject=idnr scale=1 granularity=0.001 ;

%stratify(&setup MODE=m  RATES=rates;
 class sex ;
 axis period o=0 c=2000 to 2008 by 1;
 axis age o=birthdate c=0 to 100 by 1;
 drop age period);
title 'Data for SIR analysis with a single outcome';
proc print noobs; run;

%stratify(&setup MODE=m RATES=rates ;
 class sex  birthdate    ;
 axis period o=0 c=2000 to 2008 by 1;
 axis age o=birthdate c=0 to 100 by 1;
 drop age period);
title 'Data for SIR analysis with a multiple outcome';
proc print noobs; run;





%stratify(&setup MODE=MULTIPLE EVENTVALUES=EV COMPLETE=NO);

data output; set output;
 if disease ne 0 then do; pyrs=-pyrs; output; end;
 if disease=0 then do; do disease=1,2; output; end; end;
run;

proc summary nway; class disease; var events pyrs;
 output out=output(drop=_freq_ _type_ where=(pyrs>0)) sum= ;
run;

title 'Simultaneous follow-up for many single outcomes';
proc print noobs; run;

%stratify(&setup MODE=COMPETING EVENTVALUES=EV COMPLETE=NO); run;

data output; set output;
 if disease ne 0 then do; output; end;
 if disease=0 then do; do disease=1,2; output; end; end;
run;

proc summary nway; class disease; var events pyrs;
 output out=output(drop=_freq_ _type_ where=(pyrs>0)) sum= ;
run;

title 'Follow-up for many outcomes to the occurrence of the first (Competing Risks)';
proc print noobs; run;

%stratify(&setup MODE=INTENSITY EVENTVALUES=EV COMPLETE=NO); run;

data output; set output;
 if disease ne 0 then do; output; end;
 if disease=0 then do; do disease=1,2; output; end; end;
run;

proc summary nway; class disease; var events pyrs;
 output out=output(drop=_freq_ _type_ where=(pyrs>0)) sum= ;
run;

title 'Follow-up for many outcomes ignoring prevalent cases';
proc print noobs; run;





data slopes;
 length  expevent $8;
 input idnr date expevent value;
 datalines;
 1 1999 slope -1
 1 2002 slope 2
 1 2009 slope 2
 ;
run;

%let setup= data=studybase outcomes=disease out=output
            eventtype=disease rates=srates
            subject=idnr scale=1 granularity=0.001 ;

%stratify(&setup time=date ;
  expdats slopes;
  class sex ;
  zrtf s c="slope" v=v;
  srtf varying s=s c=-10 to 10 by 1;
  axis period o=0 c=2000 to 2008 by 1);

title 'mode eq s ';
proc print data=output; run;
*/





/*
**** EXAMPLE 1 **** basis for fig. 2 in EPI_REV3;
data studybase; format idnr f8. sex f3. birthdate entry exit deathdate date9.;
 idnr=1; sex=1; birthdate='01jan1935'D; entry='01jan2000'D; exit='01JAN2008'D; deathdate='01JAN2005'D; output;
 idnr=2; sex=2; birthdate='01jan1940'D; entry='01jan2000'D; exit='01JAN2008'D; deathdate=.;output;
run;

title 'DATA: studybase';
proc print noobs; run;

%stratify(data=studybase out=py
 scale=365.25 mode=single eventtime=deathdate;
 class sex;
 axis yr   o="01JAN2000"D cuts=0 to 8 by 1;
 axis age  o=birthdate    cuts=0 50 60 65 70);

proc sort; by sex yr age; run;

title 'DATA: py - (re-)ordered to facilitate reading';
proc print noobs data=py; run;

* POST-PROCESSING ;
data py; set py;
 logpyrs=log(pyrs);
 yr=yr+2000;
run;

* ANALYSES ;
proc genmod;
 class sex age yr;
 model events=sex age yr
     /d=poisson offset=logpyrs;
run;



**** EXAMPLE2 **** basis for fig. 3 in EPI_REV3;

* The data set perm.rates below should have the same format as      ;
* the rates data set below: i.e. contain the variables mentioned    ;
* in the OBSEXP macro in adjvars=...., categorised as these         ;
* variables have been categorised by the STRATIFY macro and contain ;
* only one observation for each combination of values of these      ;
* variables. Each of these observations should contain the variable ;
* RATE, which should have be a non-negative numeric value. The      ;
* order of variables and observations in this data set has no       ;
* consequences.                                                     ;
* Just substitute rates for perm.rates to run the second half       ;
* of the example.                                                   ;

data rates;
 do sex=1 to 2;
   do yr=2000 to 2008;
      do age=0 to 90 by 5;
         do disease=1 to 2;
            rate=exp(ranuni(545345)-5);
            output;
         end;
      end;
   end;
 end;
run;

data ytsi;
 idnr=1; disease=1;eventtime=2003.5; output;
 idnr=2; disease=2;eventtime=2005.5; output;
run;

data studybase; format idnr f8. sex f3. birthdate entry exit f6.1;
 idnr=1; sex=1; birthdate=1983.0; entry=2000.0; exit=2008.0; output;
 idnr=2; sex=2; birthdate=1983.0; entry=2000.0; exit=2008.0; output;
run;

* PRE-PROCESSING provides ;
title 'DATA: studybase';
proc print data=studybase noobs; run;

title 'DATA: ytsi';
proc print data=ytsi noobs; run;

%stratify(data=studybase outcomes=ytsi out=yt
 eventtime=eventtime eventtype=disease complete=no
 mode=i noeventvalue=0 subject=idnr scale=1;
 class sex;
 axis age o=birthdate c=0 to 90 by 5;
 axis yr  o=0         c=2000 to 2008 by 2);

proc sort; by sex yr age; run;

title 'DATA: yt - (re-)ordered to facilitate reading';
proc print noobs data=yt; run;

* POST-PROCESSING ;
* now obsolete ... see examples in the manual ;
%obsexp(data=yt,ratedat=rates,out=sirdata,
 eventtype=disease,noeventvalue=0,
 byvars=sex, adjvars=sex age yr);

data a; set sirdata; logexp=log(expected); run;

* ANALYSIS ;
proc genmod;
 model events= /d=p offset=logexp lrci;
 by disease sex;
run;


**** EXAMPLE3 **** basis for fig. 4 in EPI_REV3;

* This is an example of competing risks analysis - in full generality.        ;
* It is not restricted to the situation where the outcomes are physically     ;
* absorbing states that logically preclude any further events from happening. ;
* Rather we are analysing competing risks for the occurrence of the           ;
* first outcome event.                                                        ;

data c;
 idnr=1; disease=1;cancerdate=2003.5; icd7=2009;output;
 idnr=1; disease=2;cancerdate=2005.5; icd7=1437;output;
run;

data studybase; format idnr f8. sex f3. birthdate entry exit f6.1;
 idnr=1; sex=1; birthdate=1983.0; entry=2000.0; exit=2008.0; exposed=1; output;
run;

title 'DATA: studybase';
proc print data=studybase noobs; run;

title 'DATA: c';
proc print data=c noobs; run;

* STRATIFICATION AND AGGREGATION ;
%stratify(data=studybase out=b
 outcomes=c eventdat=closelook
 mode=c eventtype=disease noeventvalue=0
 eventtime=cancerdate subject=idnr
 scale=1 granularity=0.001;
 eventid idnr icd7 cancerdate complete=no;
 class sex exposed;
 axis age o=birthdate c=0 to 90 by 5);

title 'DATA: b';
proc print data=b noobs; run;

title 'DATA: closelook';
proc print data=closelook noobs; run;


* POST-PROCESSING ;
data b; set b;
 if disease ne 0 then output;
 if disease=0 then do;
    do disease=1,2; output; end;
 end;
run;

title 'DATA: b';
proc print data=b noobs; run;

proc summary nway;
 class disease sex age exposed;
 var events pyrs;
 output out=comp(drop=_freq_ _type_) sum= ;
run;

title 'DATA: comp';
proc print data=comp noobs; run;

data comp; set comp; logpyrs=log(pyrs); run;

* ANALYSIS ;
proc genmod;
 class sex age exposed disease;
 model events=disease disease*sex disease*age
    exposed disease*exposed
   /d=p offset=logpyrs type1;
run;


**** EXAMPLE4 **** basis for fig. 5 in EPI_REV3;
data cancer;
 idnr=1; disease=1;cancerdate=2003.5; output;
 idnr=1; disease=2;cancerdate=2005.5; output;
run;

data studybase; format idnr f8. sex f3. birthdate entry exit f6.1;
 idnr=1; sex=1; birthdate=1980.0; entry=2000.0; exit=2008.0;  output;
run;

title 'DATA: studybase';
proc print data=studybase noobs; run;

proc sort data=cancer out=c;
 by idnr disease cancerdate ;

data c; set c; by idnr disease;
 if first.disease;
run;

title 'DATA: c';
proc print data=c noobs; run;

* STRATIFICATION AND AGGREGATION ;
%stratify(data=studybase out=b outcomes=c
 scale=1 granularity=0.001
 mode=m eventtype=disease noeventvalue=0
 eventtime=cancerdate subject=idnr complete=no;
 class sex;
 axis age o=birthdate c=0 20 23 26 29);


title 'DATA: b';
proc print data=b noobs; run;


* POST-PROCESSING ;
data b; set b;
 if disease ne 0 then do;
    pyrs=-pyrs; output;
 end;
 if disease=0 then do;
    do disease=1,2; output; end;
 end;
run;

title 'DATA: b';
proc print data=b noobs; run;

proc summary nway data=b;
 class disease sex age;
 var events pyrs;
 output out=multi
   (drop=_freq_ _type_ where=(pyrs>0)) sum= ;
run;

title 'DATA: multiple';
proc print data=multi noobs; run;

data multi; set multi; logpyrs=log(pyrs); run;

* ANALYSIS ;
proc genmod;
 class sex age;
 model events=sex age /d=p offset=logpyrs;
 by disease;
run;





**** EXAMPLE5 **** basis for fig. 6 in EPI_REV3;
* PRE-PROCESSING provides;

data studybase; format idnr f8. sex f3. birthdate entry exit f6.1;
 idnr=2; sex=2; birthdate=1983.0; entry=2000.0; exit=2008.0; output;
run;

data work;
 keep idnr d e;
 idnr=2;
 d=2001.0; e=1; output;
 d=2002.5; e=0; output;
 d=2003.0; e=1; output;
 d=2004.5; e=0; output;
run;

proc sort; by idnr d e; run;

data work1;
 retain cum_hired lastdate sw (0,0,0);
 set work(rename=(d=date e=employed)); by idnr;
 if first.idnr then do; cum_hired=0; sw=0;lastdate=date; end;
 cum_hired=cum_hired+(date-lastdate)*sw;
 lastdate=date;
 sw=employed;
 drop lastdate sw;
run;

data workout;
 length expevent $15;
 set work1;
 if employed=1 then do; expevent='new_job'; value=.; output; end;
 expevent='employed'; value=employed; output;
 expevent='cum_employed'; value=cum_hired; output;
run;

data residence;
 length expevent $15 valuec $2; format date f6.1;
 idnr=2; expevent='residence'; date=2001.0; valuec='MA'; output;
 idnr=2; expevent='residence'; date=2004.5; valuec='CA'; output;
run;

*60********************************************************;
*47********************************************;
* STRATIFICATION AND AGGREGATION ;


proc format ; value $state 'CA'='Cx' 'MA'='Ma'; run;


%stratify(data=studybase out=output
 subject=idnr time=date scale=1
 granularity=0.0001 eventtime=exit complete=no;
 expdats workout residence;
 class sex;
 zrtf ws         v=v  c="employed"    ;
 zrtf wc         v=v  c="cum_employed";
 zrtf wc_at      v=t  c="cum_employed";
 zrtf age_job1   v=a  c="new_job" n=1
             groups=15 to 30 by 1 missing=99;
 zrtf jobs       v=n  c="new_job";
 zrtf ever_hired v=i  c="new_job";
 zrtf state      v=cv c="residence";
 srtf cum_work time=wc_at speed=ws value=wc
                             cuts=0 2 4 6 99 ;
 axis period o=0 c=2000 to 2008 by 1);

title 'DATA: studybase';
proc print data=studybase noobs; run;
title 'DATA: residence';
proc print data=residence noobs; run;
title 'DATA: workout';
proc print data=workout(drop=employed) noobs; run;

title 'DATA: output - (re-)sorted to facilitate reading';
proc sort data=output; by sex period cum_work state; run;
proc print data=output noobs; run;



**** EXAMPLE 6 **** basis for fig. 7 in EPI_REV3;
data studybase; format idnr f8. sex f3. birthdate entry exit deathdate date9.;
 idnr=1; sex=1; birthdate='01jan1935'D; entry='01jan2000'D; exit='01JAN2008'D; deathdate='01JAN2005'D; output;
 idnr=2; sex=2; birthdate='01jan1940'D; entry='01jan2000'D; exit='01JAN2008'D; deathdate=.;output;
run;

title 'DATA: studybase';
proc print noobs; run;


* STRATIFICATION ;
%stratify(data=studybase out=cox complete=no
 scale=365.25 method=noagg eventtime=deathdate;
 class sex birthdate;
 axis  yr    o="01JAN2000"D c=0 to 8 by 1);

data cox; set cox;
 entry=(entry-birthdate)/365.25;
 exit=(exit-birthdate)/365.25;
 censor=1;
 if exit=. then do;
     exit=entry+0.0001;
     censor=0;
 end;
run;

proc sort; by sex yr; run;

title 'DATA: cox - (re-)ordered to facilitate reading';
proc print noobs data=cox; run;

* ANALYSIS ;
proc tphreg data=cox;
 class yr sex;
 model (entry,exit)*censor(1)=sex yr ;
run;




**** EXAMPLE8 ****;
* PRE-PROCESSING provides;

data studybase; format idnr f8. sex f3. birthdate entry exit f6.1;
 idnr=2; sex=2; birthdate=1983.0; entry=2000.0; exit=2008.0; output;
run;

data workout; length expevent $10; idnr=2; expevent='hiredfired';
 expevent='hiredfired'; date=2001.0; value=1; output;
 expevent='hiredfired'; date=2002.5; value=0; output;
 expevent='hiredfired'; date=2003.0; value=1; output;
 expevent='hiredfired'; date=2005.0; value=0; output;
 expevent='goatwork'  ; date=2004.0; value=1; output;
 expevent='goatwork'  ; date=2006.0; value=0; output;
 expevent='goatwork'  ; date=2007.0; value=1; output;
run;

proc sort; by idnr date; run;


%stratify(data=studybase out=output
 subject=idnr time=date scale=1
 granularity=0.0001 eventtime=exit;
 expdats workout;
 class sex;
 zrtf ws         v=v  c="hiredfired";
 zrtf gs         v=v  c="goatwork";
 srtf cum_work  speed=ws cuts=0 2 4 6  99;
 srtf goat_work speed=gs  cuts=0 2 4 6 99;
 axis period o=0 c=2000 to 2008 by 1);

title 'DATA: studybase';
proc print data=studybase noobs; run;
title 'DATA: workout';
proc print data=workout noobs; run;

title 'DATA: output - (re-)sorted to facilitate reading';
proc sort data=output; by period cum_work ; run;
proc print data=output noobs; run;
*/
