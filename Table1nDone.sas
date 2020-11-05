/*---------------------------------------------------------
Title: Table1nDone Macro
Date: 2019/10/02
Author: Martha Wetzel
Purpose: Run basic statistics by group
	Currently, categorical variables must be character type. 
	Macro parameters:
	Required:
		DATASET=,  Input data set 
		DRIVER=, File path and name for Excel driver file - no quotes
		OUTPATH=, File pathway for RTF output, no quotes 
		FNAME=,  File name for RTF output 
		CLASSVAR=, CAN ONLY TAKE ONE CLASS VARIABLE 
	Optional:
		OVERALL=Y, Request overall summary statistics 
		BYCLASS=Y, Request statistic by class variable 
		OUTLIB=WORK ,  Name of library to save out SAS data sets to 
		ODSGRAPHS=N,  Create or suppress ODS graphics (Y/N)
		ROUNDTO=0.01 Decimal place to round results to  
		DISPLAY_PVAL=Y,  Display p-values in RTF report (Y/N)
		DISPLAY_METRIC=Y,  Display metric names in RTF report (Y/N)
		DISPLAY_N =Y  Display variable N's in RTF report (Y/N)
		CLEARTEMP = Y, Delete all the temp files created by the macro. 
		EXCLUDEMISS=Y, Exclude observations with a missing BYCLASS value from the overall calculations. Only use if both 
			OVERALL = Y and BYCLASS = Y. 
	Input:
		Excel driver: The macro is operated using a Excel driver that includes a list of variable names,
		labels, types, and requested test. 
		In data: The macro requires an input SAS data set with categorical variables in character format.
	Output:  
		The macro outputs two SAS data sets and one RTF table. The SAS data sets 
		contain a variety of statistics of interest to the analyst, including 
		N's and results of alternative statistical tests and (for continuous variables) means, 
		medians, percentiles, min, max, mode, normality test statistics, and counts of missing values. The RTF output contains 
		a limited number of columns that can easily be used in a demographic table for a paper.
-----------------------------------------------------------*/


%MACRO Table1nDone(
	DATASET=, /* Input data set */
	DRIVER=, /* File path and name for Excel driver file - no quotes*/ 
	OVERALL=Y, /* Request overall summary statistics */
	BYCLASS=Y, /* Request statistic by class variable */
	EXCLUDEMISS=Y, /* Exclude observations with a missing BYCLASS value from the overall calculations */
	OUTLIB= WORK, /* Name of library to save out SAS data sets to */
	OUTPATH=, /* File pathway for RTF output, no quotes */
	FNAME=,  /* File name for RTF output */
	CLASSVAR=, /* CAN ONLY TAKE ONE CLASS VARIABLE */
	ODSGRAPHS=N, /* Create or suppress ODS graphics (Y/N) */
	ROUNDTO=0.01, /* Decimal place to round results to */ 
	DISPLAY_PVAL=Y, /* Display p-values in RTF report */
	DISPLAY_METRIC=Y, /* Display metric names in RTF report */
	DISPLAY_N =Y, /* Display variable N's in RTF report */
	CLEARTEMP = Y /* Delete temp files created by macro */
);  

	option label;

	/* Establish a temp directory for macro files */
	%let work_path=%sysfunc(pathname(work));
	options dlcreatedir;
	libname Table1 "&work_path.\Table1";

	/* Get rid of any existing files Table1 directory */
	proc datasets lib=Table1 nolist kill;
	run;
	quit;

	/* Set ODS graphics option */
	%if %sysfunc(upcase(&ODSGRAPHS.)) = Y %then %do;
		ods HTML;
		ods graphics;
		%put NOTE: ODS graphics are on;
	%end;
	
	/* Requested decimal format */
	%let deccnt = %length(%scan("&ROUNDTO.", 2, "."));

	/* Make sure driver file exists */
	%if %sysfunc(fileexist(&Driver.)) = 0 %then %do;
			%put ERROR: The driver file does not exist 
			Aborting analysis;
		%goto ExitNow;	
	%end;

 	proc import datafile = "&Driver." out = Table1.driver (where = (not missing(Variable_Name)))
		dbms = xlsx replace;
		sheet = "Variables";
	run;

	/* Driver prep work */
	data Table1.driverb;
		set Table1.driver (keep = Variable_name Label type);
		Order = _N_; /* Establish order for output */
		
		/* Create upcase version of original name */
		name_up = upcase(variable_name);
	run;

	/* Check counts of variables */
	data _null_;
		set Table1.driver;
		retain CatCount ContCount ;
		if _N_ = 1 then do;
			CatCount = 0;
			ContCount = 0;
		end;
		if upcase(Type) = "CATEGORICAL" then CatCount +1;
		if upcase(Type) = "CONTINUOUS" then ContCount +1;
		call symputx("CatCount", CatCount);
		call symputx("ContCount", ContCount);

	run;

	%put Note: There are &ContCount. continuous variables and  &CatCount. categorical variables;

	/* Set up variable lists */
	%if %eval(&CatCount. >= 1) %then %do;
		proc sql noprint;
			select Variable_Name, 
					upcase(strip(Variable_name))
			into :CATLIST separated by " ",
				:CatListQ separated by '" "'

			from Table1.driver
			where upcase(Type) = "CATEGORICAL";
		quit;
	%end;

	%else %do;
		%let catlist = ;
	%end;

	%if %eval(&ContCount. >= 1) %then %do; 
		/* List of continuous variables */
		proc sql noprint;
			select Variable_Name
			into :NLIST separated by " "
			from Table1.driver
			where upcase(Type) = "CONTINUOUS";

		quit;

	%end;

	%else %do;
		%let NLIST = ;
	%end;

	%put The following categorical variables will be included: &catlist.;
	%put The following numeric variables will be included: &nlist.;


	%if &ByClass = Y %then %do;
		/* Set up standardized naming scheme for class levels - needed for output following transpose */
		proc sort data = &dataset. out = Table1.insort ;
			by &classvar.;
		run;

		data Table1.indata;
			set Table1.insort;
			by &classvar.;

			%if %upcase(&EXCLUDEMISS.) = Y %then %do;
				where not missing(&classvar.);
			%end;

			if first.&classvar then ClassNum +1;

			length StandClass $10;

			StandClass = cats("Class_",ClassNum);

		run;

		/* Generate label statement */
		proc sql noprint;
			select distinct cats(StandClass, "='",&classvar.,"'"), /* For regular data set labeling */
				count(unique(StandClass)) /* count number of class levels */
		
			into :ClassLabel separated by " ",
				:ClassCount
			from Table1.indata;
		quit;

		proc format;
			value $ ClassFmt 
			&classlabel.;
		run;
			
		%put &Classlabel.;
		%put Number Classes = &ClassCount.;
	%end; /* End prep work for class-level analysis */

	%else %do; /* Don't prep class parts if it's only an overall analysis */
		data Table1.indata;
			set &dataset.;
		run;
	%end;

	/* Set up for determining which statistical tests to apply */
	data Table1.testfmt;
		format statistical_test Statistical_test2 $30. Metric metric_up $20.; 
 		set Table1.driver (keep = Variable_Name type Statistical_test Metric rename = (type=DataType));
		where not missing(Variable_name);
		format statistical_test Statistical_test2 $30. Metric metric_up $20.; 
		Start = upcase(strip(Variable_name));
		Type = "C";
		Fmtname = "Test";

		if missing(statistical_test) then statistical_test = "AUTO-SELECT";
		statistical_test2 = upcase(compress(statistical_test," ","p"));

		metric_up = upcase(compress(Metric," ","p"));
		if missing(compress(metric_up)) then metric_up = "AUTOSELECT";

		/* Error checks */
		%if &ByClass. = Y & &DISPLAY_PVAL. = Y %then %do;
			/* Check that statistical test is in list */
			if statistical_test2 not in ("AUTOSELECT", "CHISQUARE", "ANOVA", "KRUSKALWALLIS",
				"KOLMOGOROVSMIRNOV", "TTEST", "WILCOXONRANKSUMS") then do;
				put "WARNING: " Statistical_test "is not a valid option. Defaulting to AUTO-SELECT";
				statistical_test2 = "AUTOSELECT";
			end;
			
			/* Check that statistical test is valid for data type */
			else if (upcase(DataType) = "CONTINUOUS" and statistical_test2 = "CHISQUARE") or
				(upcase(DataType) = "CATEGORICAL" and statistical_test2 in ("ANOVA", "KRUSKALWALLIS",
				"KOLMOGOROVSMIRNOV", "TTEST", "WILCOXONRANKSUMS")) then do;
				put "WARNING: " Statistical_test " is not valid for " DataType " data. Defaulting to AUTO-SELECT.";
				statistical_test2 = "AUTOSELECT";
			end;

			/* Check that test is available for # groups */
			if (&ClassCount. = 2 & statistical_test2 in ("ANOVA", "KRUSKALWALLIS") ) or
				(&ClassCount. > 2 & statistical_test2 in ("TTEST", "WILCOXONRANKSUMS", "KOLMOGOROVSMIRNOV")) then do;
				put "WARNING: " Statistical_test "is not an option for analyses of &ClassCount. groups. Defaulting to AUTO-SELECT";
				statistical_test2 = "AUTOSELECT";
			end;
		%end;

		Label = upcase(Statistical_test2);

		/* Check that metric is valid */
		if ( upcase(DataType) = "CONTINUOUS" and metric_up not in ("MEDIAN", "MEAN", "AUTOSELECT")) or 
			(upcase(DataType) = "CATEGORICAL" and metric_up not in ("COUNT", "AUTOSELECT")) THEN DO;
				metric_up = "AUTOSELECT";
				put "WARNING: Metric for " Variable_name " is invalid. Defaulting to AUTO-SELECT.";
			end;
		fmtname_metric = "Metric";
	run;

	proc format cntlin = Table1.testfmt;
	run;

	proc format cntlin = Table1.testfmt (keep = fmtname_metric start type metric_up rename = (
		fmtname_metric=FMTNAME metric_up = label));
	run;


	/* Check that requested variables exist in the in data set */
	proc sql noprint;
		create table table1.badvars as
		select Variable_Name
		from table1.driver 
		where upcase(Variable_Name) not in (select upcase(name) from
			dictionary.columns where upcase(libname) = "TABLE1" and UPCASE(memname) = "INDATA");
	quit;

	/* Check to see if there are any bad variables (i.e., badvars has more than one row */
	%let dsnid = %sysfunc(open(table1.badvars));

	%if %sysfunc(attrn(&dsnid.,nlobs)) ~= 0 %then %do;
		proc sql noprint;
			select * into :dnelist
			from table1.badvars ;
		quit;

		/* Close the open data set */
		%let rc  =%sysfunc(close(&dsnid.));

		%put ERROR: The following requested variables do not exist in &dataset.: &dnelist.. 
			Aborting analysis;
		%goto ExitNow;	
	%end;

	/* Close the open data set */
	%let rc  =%sysfunc(close(&dsnid.));

	/* Check that the categorical variables are character format - abort if wrong */
	%if &CatCount. >= 1 %then %do;
		proc sql noprint;
			select 
				 sum(case when type = "num" then 1 else 0 end),
					cats(case when type = "num" then name end)
			into :BadVarCount,
				:BadVars separated by " "
			from dictionary.columns
			where upcase(libname) = "TABLE1" and UPCASE(memname) = "INDATA" and upcase(name) in ("&CatListQ.");
		quit;

		%if &BadVarCount. > 0 %then %do;
			%put ERROR: Categorical analysis requested for the following numeric variables: &BadVars.. 
				Convert these variables to character type for categorical analysis.
				Aborting analysis;
			%goto ExitNow;	
		%end;
	%end;

	/* Set up format for labeling and ordering variables */
	proc sort data = table1.driverb;
		by name_up;
	run;
	
	/* If no variable labels provided in Excel driver, pull from indata */
	data table1.extralabels (keep = name_up label );
		set  sashelp.vcolumn (keep = libname memname name label);
		where libname = "TABLE1" and memname = "INDATA";
		name_up = upcase(name);
	run;

	proc sort data = table1.extralabels;
		by name_up ;
	run;

	/* merge in existing labels */
	data Table1.labelfmt (drop = order);
		length name_up $32. label $200.;
		merge Table1.driverb (in=a keep = Variable_name name_up Label Order rename = (Label=DriverLabel) )
			table1.extralabels (rename = (label=existlabel));
		by name_up;
		if a;
		Start = upcase(strip(Variable_name));

		if not missing(DriverLabel) then Label = DriverLabel;
			else if not missing(existlabel) then label = existlabel;
			else label = variable_name;

		/* Label */
		Type = "C";
		Fmtname = "Varlab";
		output;
		/* Order */

		Label = input(Order, $200.);
		FmtName = "Order";
		output;

	run;

	proc sort data = Table1.labelfmt;
		by Fmtname;
	run;

	proc format cntlin = Table1.labelfmt;
	run;


	/* ------------------------------------------------------*/
	/*			Start Analysis: Numeric Variables			*/
	/* ------------------------------------------------------*/


    %IF &NLIST NE  %THEN %DO; 

   		/* Run overall stats, even if not requested, to pick up the N's */
			%put NOTE: Running overall statistics for continuous data;

	   		/* Calculate basic stats for all variables */
		   	proc univariate data = Table1.indata normal outtable = Table1.Overall_numsummary (keep =_VAR_  _NOBS_ _NMISS_ _SUM_ _MEAN_ _STD_ _MIN_ 
				_P1_ _P5_ _P10_ _P90_ _P95_ _P99_ _Q1_ _MEDIAN_ _Q3_ _MAX_ _RANGE_ _qRANGE_ _MODE_ _NORMAL_ _PROBN_
				) noprint;
				var &nlist.;
			run;

			data &outlib..AllStats_Numeric_overall (drop = i);
				set Table1.overall_numsummary (rename = (_VAR_ = Variable));

				/* Round */
				array unround (5) _Q1_ _MEDIAN_ _Q3_ _MEAN_ _STD_;
				array rounded (5) r_Q1_ r_MEDIAN_ r_Q3_ r_MEAN_ r_STD_;

				do i = 1 to 5;
					rounded(i) = round(unround(i),&ROUNDTO.);
				end;

				Overall_Result_Median = cat(strip(r_MEDIAN_), " (", strip(r_Q1_), ", ",strip(r_Q3_), ")");
				Overall_Result_Mean = cat(put(r_MEAN_, 10.&deccnt.), " (", strip(put(r_STD_, 10.&deccnt.)), ")");

			run;

			proc sort data = &outlib..AllStats_Numeric_overall ;
				by Variable;
			run;

	
		%if &byclass. = Y %then %do;
			/* Calculate basic stats for all variables */
		   	proc univariate data = Table1.indata normal outtable = Table1.numsummary (keep =_VAR_ StandClass _NOBS_ _NMISS_ _SUM_ _MEAN_ _STD_ _MIN_ 
				_Q1_ _MEDIAN_ _Q3_ _MAX_ _RANGE_ _qRANGE_ _MODE_ _NORMAL_ _PROBN_
				) noprint;
				var &nlist.;
				class StandClass;
				%if %upcase(&ODSGRAPHS.) = Y %then %do;
					histogram &nlist.;
				%end;
			run;

			/* All the tests are run for analyst review - only requested test is included in output table */
			/* Run non-parametric stats */
			proc npar1way data=Table1.indata wilcoxon edf;
				var &nlist.;
				class StandClass;
				output out = Table1.nonpar_tests ;
			run;

			data Table1.nonpar_tests2 (rename = (P_KSA = pvalue_np_uneqvar));
				set Table1.nonpar_tests;
				%if &ClassCount = 2 %then %do;
					rename P2_WIL = pvalue_np_eqvar;
				%end;
				%else %do;
					rename P_KW = pvalue_np_eqvar;
					P_KSA =.;
				%end;
			run;

			/* Run parametric stats */
			/* T-tests: only if class variable has 2 levels */
			%if &CLassCount = 2 %then %do;
				ods output Ttests = Table1.numttests equality = Table1.numeqvar;
				proc ttest data = Table1.indata ;
					var &nlist.;
					class StandClass;
				run;

				/* Choose correct ttest method based on variance */
				proc sort data = Table1.numttests;
					by Variable;
				run;

				proc sort data = Table1.numeqvar;
					by Variable;
				run;

				data Table1.Parm_tests (drop = DF  rename = (Method = TTestMethod Probt = Parm_pvalue
						ProbF = probf_variance));
					merge Table1.numttests Table1.numeqvar (keep = Variable ProbF) ;
					by Variable;
					if (ProbF < 0.05 and variances = "Unequal") or (ProbF > 0.05 and Variances = "Equal");
					ParmTest = "T test";
					label ProbF = "F Test for Equal Variance";
				run;
			%end;

			%else %if &ClassCount >= 3 %then %do;
			
				/*----	This section iterates through each  variable ----*/
				/* Create ANOVA driver data set */
				data Table1.driver_con;
					set Table1.driverb;
					where upcase(Type) = "CONTINUOUS" ;
					Counter +1;
					call symputx('totparm', Counter);
				run;

				%let parmsets = ; /* this will be a list of all the final data sets that need to be combined */

				%let a = 1;
				%do %while (&a. <= &totparm.);

					data _null_;
						set Table1.driver_con;
						where counter = &a.;

						/* Set up a short name so as to avoid issues with data set names being too long */
						if length(strip(Variable_name)) > 25 then ShortName = cats(substr(Variable_name, 1,15),&a.);
							else ShortName = Variable_name;

						call symputx("varcon", Variable_name);
						call symputx("varcon_s", ShortName);
					run;

					/* Run the ANOVA */
					ods table ModelANOVA   = Table1.Anova_&varcon_s. HOVFTest=Table1.ftest_&varcon_s.;
					proc glm data = Table1.indata;
						class &classvar.;
						model &varcon. = &classvar.;
						means &classvar. / hovtest ;
					run;
					quit;

					/* Merge variance test with ANOVA results */
					data Table1.Anova_&varcon_s.2 (drop = Source);
						merge Table1.Anova_&varcon_s. Table1.ftest_&varcon_s. (keep = dependent
							ProbF Source rename = (ProbF=probf_variance) where =(Source ne "Error" ));
						by dependent;
						label probf_variance = "Levene's Test P-Value";
					run;

					/* Add to list of data sets to stack at end */
					%let parmsets = &parmsets. Table1.Anova_&varcon_s.2;

					/* Iterate to next variable */
					%let a = %eval(&a. +1);

				%end; /* End variable loop for ANOVA  */

				/* Combine ANOVA output for all variables */
				data Table1.Parm_tests (drop = HypothesisType rename = (ProbF = Parm_pvalue Dependent = Variable));
					length Dependent $32.;
					set &parmsets.;
					if HypothesisType = 1; /* Doesn't matter which one b/c it's a one-way ANOVA */
					ParmTest = "ANOVA";
				run;

			%end; /* End ANOVA analysis */


			/* Merge stat test results to summary stats */
				proc sort data = Table1.numsummary;
					by _VAR_;
				run;

				proc sort data = Table1.nonpar_tests2;
					by _VAR_;
				run;
		
				proc sort data = Table1.Parm_tests;
					by Variable;
				run;

			/* Save detailed summary table */
			data &outlib..AllStats_Numeric_class (drop = parmtest);

				format StandClass2 $100. Variable $32. StandClass $100.;

				merge Table1.numsummary (rename = (_VAR_ = Variable)) 
					Table1.nonpar_tests2 (rename = (_VAR_ = Variable))
					Table1.Parm_tests;
				by Variable;

				label Parm_pvalue = "Parametric Test p-value";
				StandClass2 = put(StandClass, $Classfmt.);
				label StandClass2 = "&classvar.";
				format Parm_pvalue probf_variance pvalue6.3;

			run;

			%end; /* End class-specific calculations */

			/* Combine overall and by class analysis */
			/* Choose p-value */
			data Table1.numeric_combo ;
				format variable $32. 
					%if &BYCLASS = Y %then %do; StandClass2 $100. %end ;;
				merge 
					&outlib..AllStats_Numeric_overall  (keep = Variable _NOBS_
						Overall_Result_mean Overall_Result_median _PROBN_ rename = (_PROBN_=_PROBN_overall))
						
				%if &BYCLASS = Y %then %do;
					&outlib..AllStats_Numeric_class (drop = _NOBS_ _PROBN_ _NORMAL_  )
				%end;
					;
				by variable;
				format variable $32.;

				StatTest =  put(upcase(strip(Variable)), $test.);
				format Overall_Result $30. Metrics $30.;

				/* Determine which type of result to display */
				if put(upcase(variable), $metric.) = "MEAN" or 
					(put(upcase(variable), $metric.) = "AUTOSELECT" AND _PROBN_overall >= 0.05) then do;
					Overall_Result = strip(Overall_Result_Mean);
					%if &BYCLASS = Y %then %do; 
						Result = cat(strip(put(_MEAN_, 10.&deccnt.)), " (", strip(put(_STD_, 7.&deccnt.)), ")");
					%end;
					Metrics = "Mean (SD)";
				end;

				else do;
					Overall_Result = strip(Overall_Result_Median);
					%if &BYCLASS = Y %then %do; 
						/* Check if the median results need to be rounded */
						Decimals = length(scan(compress(_MEDIAN_), -1, "."));
						if Decimals > &deccnt. then Result = cat(strip(put(_MEDIAN_,10.&deccnt.))," (", strip(put(_Q1_, 10.&deccnt.)), ", ",strip(put(_Q3_, 10.&deccnt.)),")");	
							else Result = cat(strip(_MEDIAN_)," (", strip(_Q1_), ", ",strip(_Q3_),")");
					%end;
					Metrics = "Median (Q1, Q3)";
				end;

				%if %upcase(&BYCLASS) = Y & %upcase(&DISPLAY_PVAL.) = Y %then %do;
					format  AutoSelectTest FinalTest $50.;
					/* Auto-selection for most appropriate test */
					if _PROBN_overall >= 0.05 then do; /* Parametric test appropriate*/
						if &ClassCount = 2 then AutoSelectTest = "TTEST";
						else if &ClassCount. >2 and probf_variance >= 0.05 then AutoSelectTest = "ANOVA";
						else if &ClassCount. >2 and probf_variance < 0.05 then AutoSelectTest = "OUT OF SCOPE" ;
					end; /* end logic for normal distribution */
					else if _PROBN_overall < 0.05 then do; /* Non-Normal */
						if &ClassCount = 2 and probf_variance >= 0.05 then  AutoSelectTest = "WILCOXONRANKSUMS";
						else if &ClassCount = 2 and probf_variance < 0.05 then AutoSelectTest = "KOLMOGOROVSMIRNOV";
						else if &ClassCount > 2 and probf_variance >= 0.05 then  AutoSelectTest = "KRUSKALWALLIS";
						else if &ClassCount > 2 and probf_variance < 0.05 then AutoSelectTest ="OUT OF SCOPE" ;
					end; /* End logic for non-normal variables */

					/* Compare auto-selected test with user-requested test */
					if StatTest ne "AUTOSELECT" and (AutoSelectTest ne StatTest ) then do;
						put "WARNING: Consider " AutoSelectTest " for " Variable ;
					end;

					if StatTest = "AUTOSELECT" then FinalTest = AutoSelectTest;
						else FinalTest = StatTest;
			
					if FinalTest in ("TTEST", "ANOVA") then Final_pval = Parm_pvalue;
						else if FinalTest in ("KRUSKALWALLIS", "WILCOXONRANKSUMS") then Final_pval = pvalue_np_eqvar;
						%if &ClassCount. = 2 %then %do; 
							else if FinalTest = "KOLMOGOROVSMIRNOV" then Final_pval = pvalue_np_uneqvar;
						%end;
						else if FinalTest = "OUT OF SCOPE" then do;
							put "WARNING: Variable " Variable "requires an out-of-scope test. P-values suppressed";
						end; 
			
				%end;	
				%else %do;
					final_pval = .;
				%end;

			run;

			/* Transpose so class variables go across, if there is by-class analysis */
			%if &BYCLASS = Y %then %do;
				proc transpose data = table1.numeric_combo out = Table1.numeric_t (rename = (final_pval=pvalue));
					by Variable Overall_Result _NOBS_ final_pval Metrics;
					var  Result;
					id StandClass;
				run;
			%end;
			%else %do;
				data Table1.numeric_t;
					set table1.numeric_combo;
				run;
			%end;


	%end; /* End numeric variable analysis */

	/* ------------------------------------------------------*/
	/*					Categorical Variables				*/
	/* ------------------------------------------------------*/

	%if &catlist. ne %then %do;

		/*----	This section iterates through each categorical variable ----*/
		/* Create categorical driver data set that renumbers the categorical variables */
		data Table1.driver_cat;
			set Table1.testfmt (keep = Variable_Name DataType statistical_test2);
			where upcase(DataType) = "CATEGORICAL";
			Counter +1;
		run;

		/* Find number of variables */
		proc sql noprint;
			select max(counter) into :totcats
			from Table1.driver_cat;
		quit;

		%let list = ; /* this will be a list of all the final data sets that need to be combined */
		%let list_overall = ;

		%let c = 1;
		%do %while (&c. <= &totcats.);

			data _null_;
				set Table1.driver_cat;
				where counter = &c.;

				/* Set up a short name so as to avoid issues with data set names being too long */
				if length(strip(Variable_name)) >= 25 then ShortName = cats(substr(Variable_name, 1,15),&c.);
					else ShortName = Variable_name;

				call symputx("var", Variable_name);
				call symputx("varcat_s", ShortName);
			run;

			%put Note: Calculating &var. statistics;

			/* Run overall regardless of options to get overall N's by variable */
				proc freq data = Table1.indata (where = (not missing(&var.))) ;
					table &var. / out = Table1.ovfreq_&varcat_s. ;
				run;

				/* Manipulate frequency table */
				data Table1.ovfreq2_&varcat_s. (rename = (&var. = Category));
					retain Variable;
					set Table1.ovfreq_&varcat_s.;
					/* combine count and percent into single variable */
					Overall_Result = cat(count, " (",strip(put(PERCENT,7.&deccnt.)), "%)");
					Variable = "&var.";
				run;

				%let varlevels = &sysnobs.;

				%let list_overall = &list_overall. Table1.ovfreq2_&varcat_s.;

			/*---- Run by class statistics ----*/
			%if &byclass. = Y %then %do;

				/* Determine requested tests */
				data _NULL_;
					set Table1.driver_cat;
					where counter = &c.;
					call symputx('CATTEST', Statistical_Test2);
				run;

				/* Calculate stats */
				proc freq data = Table1.indata (where = (not missing(&var.))) ;
					table &var.*StandClass / out = Table1.freq_&varcat_s. outpct chisq warn = output;
					output out = Table1.chisq_&varcat_s. chisq N  ;
				run;

				%if %sysfunc(exist(Table1.chisq_&varcat_s.)) = 0 %then %do;

					/* Create blank table with initialized variables if the chisq output was not produced
					   due to lack of variation in response */
					data Table1.chisq_&varcat_s.2;
						WARN_PCHI = .;
						P_PCHI= .;
						pvalue =.;
					run;
				%end;

				%else %do;

					/* Determine if exact test is warranted */
					data _null_;
						set Table1.chisq_&varcat_s.;
						call symputx("NeedExact", WARN_PCHI);
					run;

					/* Run/Use Fisher's exact test */

					%if &NeedExact = 1 & &CATTEST. = AUTOSELECT & &DISPLAY_PVAL. = Y %then %do;
						proc freq data = Table1.indata (where = (not missing(&var.))) ;
							table &var.*StandClass / out = Table1.freq_&varcat_s. outpct chisq exact warn = output;
							output out = Table1.chisq_&varcat_s. chisq N fishers ;
						run;

						data Table1.chisq_&varcat_s.2;
							set Table1.chisq_&varcat_s.;
							format pvalue pvalue6.3;
							pvalue = XP2_FISH;
							FinalTest = "Fisher's Exact";
						run;

					%end;

					/* Use CHISQ */
					%else %do;
						%if &NeedExact = 1 & &CATTEST. = CHISQUARE & &DISPLAY_PVAL. = Y %then %do;
							%put WARNING: Chi square test inappropriate for data due to small cell scounts. To 
								run and use Fishers Exact test, set driver option to AUTO-SELECT;	
						%end; 

						data Table1.chisq_&varcat_s.2;
							set Table1.chisq_&varcat_s.;
							format pvalue pvalue6.3;
							pvalue = P_PCHI;
							FinalTest = "Chi Square";
						run;
					%end;


				%end;

				/* Manipulate frequency table */
				data Table1.freq2_&varcat_s. (rename = (&var. = Category));
					retain Variable;
					set Table1.freq_&varcat_s.;
					/* combine count and percent into single variable */
					NPercent = cat(count, " (",strip(put(PCT_COL,7.&deccnt.)), "%)");
					Variable = "&var.";
				run;

				proc transpose data = Table1.freq2_&varcat_s. out = Table1.freqt_&varcat_s. (drop = _NAME_);
					by Variable Category;
					var NPercent;
					id StandClass;
				run;

				/* Merge with stats */
				data Table1.chisq_&varcat_s.3;
					set Table1.chisq_&varcat_s.2;
					Variable = "&var.";
				run;

				data Table1.freq3_&varcat_s.;
					merge Table1.freqt_&varcat_s. Table1.chisq_&varcat_s.3;
					format pvalue pvalue8.3;

					by Variable;

				run;

				/* Add to list of data sets to stack at end */
				%let list = &list. Table1.freq3_&varcat_s.;

			%end; /* Closes "by class" segment */

			/* Iterate to next variable */
			%let c = %eval(&c. +1);

		%end; /* End categorical loop */


		/* Stack Overall data sets */
		data &outlib..allstats_cat_overall ;
			length Variable $32 Category $100 ;
			format Variable $32. Category $100. ;
			set &list_overall.;

			if missing(Overall_Result) then Overall_Result = "0 (0.00%)";
			Metrics = "N (%)";
		run;

		/* Counts of non-missing values */
		proc means data = &outlib..allstats_cat_overall noprint nway;
			output out = Table1.char_Ns
			sum(COUNT)=;
			class Variable;
		run;

		proc sort data = &outlib..allstats_cat_overall ;
			by Variable Category;
		run;


		/* Stack by class data sets */
		%if &byclass. = Y %then %do;
			/* Create single data set with all categorical information */
			data &outlib..allstats_cat_class ;
				length Variable $32 Category $100 FinalTest $40;
				format Variable $32. Category $100. FinalTest $40.;
				set &list.;

				Metrics = "N (%)";

				/* Fill in zero cells */
				array zerofill (*) class:;
				do i = 1 to hbound(zerofill);
					if missing(zerofill(i)) then zerofill(i) = "0 (0.00%)";
				end;

				label &classlabel.;

			run;

			proc sort data =  &outlib..allstats_cat_class;
				by Variable Category;
			run;

		%end;

		data Table1.Allcat_a;
			merge
			%if &overall. = Y %then %do;
				&outlib..allstats_cat_overall (keep = Variable Category Overall_Result Metrics)
			%end;
			%if &byclass. = Y %then %do;
				&outlib..allstats_cat_class (keep = Variable Category Metrics Class_: pvalue)
			%end;
			;
			by Variable Category;
		run;

		/* Add N's */
		data Table1.Allcat;
			merge Table1.allcat_a 	Table1.char_Ns (keep = variable count rename = (Count = _NOBS_));
			by variable;
		run;


   %end; /* End categorical analysis */


   /*---------------------------------------------------*/
   /*----		Print for Analyst Review			----*/
   /*---------------------------------------------------*/

   ods html;
	%IF &NLIST NE  %THEN %DO; 

		%if &byclass. = Y  %then %do;
		   proc print data = Table1.numeric_combo (keep = StandClass2 variable _NOBS_ _NMISS_ _MEAN_ _STD_ _MIN_
				_Q1_ _MEDIAN_ _Q3_ 	_MAX_ _MODE_ probf_variance %if &DISPLAY_PVAL. = Y %then %do; FinalTest %end;) label noobs;
				format StandClass2 $50. probf_variance pvalue8.3;
			run;
		%end;

		%if &overall. = Y %then %do;
		   proc print data = &outlib..AllStats_Numeric_overall (keep = variable _NOBS_ _NMISS_ _MEAN_ _STD_ _MIN_
				_Q1_ _MEDIAN_ _Q3_ 	_MAX_ _MODE_ _PROBN_) label noobs;
				format _PROBN_ pvalue8.3;
			run;
		%end;

	%end;


   /*---------------------------------------------------*/
   /*----			Prep for Output					----*/
   /*---------------------------------------------------*/

   	/* Generate label for proc report */
	%if &byclass. = Y %then %do;
		proc sql noprint;
			select 
				distinct cats(StandClass, "='",&classvar.,"~ N=", count(StandClass), "'")  /* For proc report column headers */
			into :ReportLabel separated by " "
			from Table1.indata
			group by &classvar.;
		quit;
	%end;

	/* Get the overall observation count */
	data _null_;
		set Table1.indata;
		call symputx('totalobs',_N_);
	run;

   /* Combine character and numeric results */
   data Table1.combo (drop = Variable rename = (Variable2=Variable));
   		format Variable2 $200. %if &CatCount. > 0 %then %do; Category %end; Class_: $100. Metrics $30.;
		%if &Byclass = Y %then %do;
			format pvalue pvalue8.3;
		%end;

   		set 
			%if &CatCount. > 0 %then %do;
				Table1.Allcat 
			%end;
			%if &ContCount. > 0 %then %do;
				Table1.numeric_t ;
			%end;
			;

		/* Add observation counts to header */
		label 
			/* Apply class labels */
			%if &byclass. = Y %then %do;
				&ReportLabel
			%end;
			
			%if &overall. = Y %then %do;
				Overall_Result = "Overall~N=&totalobs."
			%end;
			;
		Order = input(put(strip(upcase(Variable)), $order.), 8.);
		Variable2 = put(strip(upcase(Variable)),$varlab.); 

	run;

	proc sort data = Table1.combo;
		by Order;
	run;

	/*---------------------------------------------------*/
   /*----			Create RTF					----*/
   /*---------------------------------------------------*/

ODS PATH WORK.TEMPLAT(UPDATE)
   SASUSR.TEMPLAT(UPDATE) SASHELP.TMPLMST(READ);

   PROC TEMPLATE;
	   DEFINE STYLE STYLES.TABLES;
	   NOTES "MY TABLE STYLE"; 
	   PARENT=STYLES.MINIMAL;

	     STYLE SYSTEMTITLE /FONT_SIZE = 12pt     FONT_FACE = "TIMES NEW ROMAN";

	     STYLE HEADER /
	           FONT_FACE = "TIMES NEW ROMAN"
	            CELLPADDING=8
	            JUST=C
	            VJUST=C
	            FONT_SIZE = 10pt
	           FONT_WEIGHT = BOLD; 

	     STYLE TABLE /
	            FRAME=HSIDES            /* outside borders: void, box, above/below, vsides/hsides, lhs/rhs */
	            RULES=GROUP              /* internal borders: none, all, cols, rows, groups */
	            CELLPADDING=6            /* the space between table cell contents and the cell border */
	            CELLSPACING=6           /* the space between table cells, allows background to show */
	            JUST=C
	            FONT_SIZE = 10pt
	            BORDERWIDTH = 0.5pt;  /* the width of the borders and rules */

	     STYLE DATAEMPHASIS /
	           FONT_FACE = "TIMES NEW ROMAN"
	           FONT_SIZE = 10pt
	           FONT_WEIGHT = BOLD;

	     STYLE DATA /
	           FONT_FACE = "TIMES NEW ROMAN" 
	           FONT_SIZE = 10pt;

	     STYLE SYSTEMFOOTER /FONT_SIZE = 9pt FONT_FACE = "TIMES NEW ROMAN" JUST=C;
	   END;

   RUN; 

   *------- build the table -----;

   OPTIONS ORIENTATION=PORTRAIT MISSING = "-" NODATE;

     ODS RTF STYLE=tables FILE= "&OUTPATH.\&FNAME &SYSDATE..DOC"; 


	PROC REPORT DATA=Table1.combo HEADLINE HEADSKIP CENTER STYLE(REPORT)={JUST=CENTER} SPLIT='~' nowd 
	          SPANROWS LS=256;
	      COLUMNS order variable 

 			%if &CatCount. > 0 %then %do; category %end;
			%if &DISPLAY_N. = Y %then %do; _NOBS_ %end;
			%if &overall. = Y %then %do;
				Overall_Result
			%end;
			%if &byclass. = Y %then %do;
				Class: 
				%if &DISPLAY_PVAL = Y %then %do; pvalue %end;
			%end;
			%if &DISPLAY_METRIC = Y %then %do; metrics %end;

			;	

	      DEFINE order/order order=internal noprint;
	      DEFINE variable/ Order order=data  "Variable"  STYLE(COLUMN) = {JUST = L CellWidth=15%};

			%if &CatCount. > 0 %then %do;
				DEFINE category/ DISPLAY   "Level"   STYLE(COLUMN) = {JUST = L CellWidth=15%};
			%end;

			%if &DISPLAY_N. = Y %then %do; DEFINE _NOBS_ / "N" order style(Column) = {JUST = C }; %end;

			%if &overall. = Y %then %do;
				DEFINE Overall_Result / DISPLAY STYLE(COLUMN) = {JUST = C } ;
			%end;

			%if &byclass. = Y %then %do;
			  %let z = 1;
			  
			  %do %while (&z. <= &ClassCount.);
			  	DEFINE Class_&z. / DISPLAY STYLE(COLUMN) = {JUST = C } ;
		     	%let z = %eval(&z. +1);
			  %end;

			   %if &DISPLAY_PVAL. = Y %then %do;
			      /* Bold p-values under 0.05 */
			       DEFINE pvalue/ORDER MISSING "P-Value" STYLE(COLUMN)={JUST = C CellWidth=10%} ;

		         COMPUTE pvalue; 
		              IF . < pvalue <0.05 THEN 
		               CALL DEFINE("pvalue", "STYLE", "STYLE=[FONT_WEIGHT=BOLD]");
		         ENDCOMP; 
				%end; /* End p-value column stuff */

			%end; /* End Class Variable Columns */
	       
		%if &DISPLAY_METRIC. = Y %then %do; DEFINE Metrics/ DISPLAY    STYLE(COLUMN) = {JUST = C }; %end;

	     compute after variable; line ''; endcomp; /* Inserts a blank line after each variable */
	       
	   RUN; 

 
      ODS RTF CLOSE; 

	/* Get rid of temp files created by macro in Table1 directory */
	%if %upcase(&CLEARTEMP.) = Y %then %do;
		proc datasets lib=Table1 nolist  ;
			save combo;
		run;
		quit;
	%end;

	  %ExitNow:

%mend; 
