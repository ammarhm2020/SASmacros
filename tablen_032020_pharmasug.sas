/*------------------------------------------------------------------*
| MACRO NAME  : tablen
| SHORT DESC  : Creates a descriptives table of multiple variables
*------------------------------------------------------------------*
| CREATED BY  : Meyers, Jeffrey                 (07/28/2016 3:00)
*------------------------------------------------------------------*
| VERSION UPDATES:
| 2.37 04/08/2020
|   Updated BORDERDISPLAY options for HTML output
|   Fixed several bugs with significant digits
| 2.36 03/23/2020
|   Removed LOG_REFERENCE since it was not used.  REFERENCE should be used
|   Updates for Windows SAS
| 2.35 03/4/2020
|   Added a debug option that will keep notes on and not delete temporary datasets
| 2.34 02/21/2020
|   Corrected issue with BORDERDISPLAY=4 in PDF destination
|   Made fix to not show . in separating columns when using COLBY in Windows
| 2.33 02/12/2020
|   Corrected footnote for likelihood-ratio p-value
    Corrected text in error message for logistic p-values
| 2.32 10/01/2019
|   Corrected an issue with continuous variables when the BY variable
        has a missing value.
| 2.31 07/26/2019
|   Corrected a nesting error when a larger number of variables
        of the same type are listed.
| 2.3 07/24/2019
|   Corrected an error when changing orientation that caused the macro
        to make a sasrtf.rtf file and not correctly change the orientation
        when using OUTDOC
|   Added ability to use different significant digits with each variable.
      can be used to distinguish between variable in each parameter.
| 2.2 05/13/2019
|   Added logic to avoid errors when only one level of BY variable
      has values for all continuous variables.
| 2.1 04/15/2019
|   Corrected issue with survival output not including TIMELIST values
| 2.0 04/06/2019
|   Updated process to improve efficiency
| 1.94 04/05/2019
|   Corrected issue with listing output
|   Corrected issue in survival section
| 1.93 11/12/2018
|   Corrected spaces causing issues for DIS_ORDER
|   Corrected SQL issue for Cochran-armitage p-value  
| 1.92 11/11/2018
|   Corrected ORIENTATION option
|   Corrected SQL issue for continuous ANOVA
| 1.91 10/23/2018
|   Added value 4 to BORDERDISPLAY to remove horizontal lines
       within each variable
| 1.9 09/19/2018
|   Fixed an issue where the label wouldn't show up for a continuous
|   variable when only one BY group has non-missing values.
| 1.8 08/02/2018
|   Added BORDERDISPLAY to turn on/off table cell borders
|   Added type=5 for univariate LOGISTIC regression
       Can display counts, events, odds ratios, p-values and binomial success rates
| 1.7 01/16/2018
|   Corrected missing p-values when using dis_order to only show 
      one level of discrete variable.
| 1.6 01/06/2018
|   Corrected missing labels when discrete variable only has one 
      level.
| 1.5 12/21/2017
|   Corrected line size calculations for printing to listing when
       using a BY variable
| 1.4 12/13/2017
|   Added MEDIAN_IQR to CONTDISPLAY and DATEDISPLAY.  
|   Changed references to NTABLE to TABLEN
| 1.3 11/30/2017
|   Corrected order of ROWBY
|   Changed missing values of ROWBY and COLBY to show as Missing group
      in table
| 1.2 11/27/2017
|   Restructured logic for completing tables to be printed for efficiency
|   Added extra programming for RTF location
|   Added new option for SHOWPVAL: 2.  Shows continuous variable p-values
       when no BY variable is specified
| 1.1 11/13/2017
|   Corrected multiple logic errors
|   Added parameter PFOOT to remove automatic p-value footnotes   
|   Changed ordering of BY, COLBY, ROWBY, and discrete variables to be 
      by internal values by default, and added a ORDER_FORMATTED parameter
      for each to determine if the order is by formatted or unformatted values.
|   Added additional coding to frozen headers in Excel documents.
|   Extended maximum label size for variables to be 1000 characters from 100      
| 1.0 09/24/2017: Initial Release
*------------------------------------------------------------------*
| PURPOSE
| Create a descriptives table of multiple variables (often called 
| Table 1 in a manuscript).  Continuous, Discrete and Survival variables are 
| handled differently.  Multiple subgroup options are available for 
| comparisons and different p-values are available for each variable
| type.
|    
| 1.0: REQUIRED PARAMETERS
|   DATA = Specifies the dataset to be used in the macro
|   VAR = A space delimited list of variables to compute distributions on
|   TYPE = A space delimited list of values that determines the type for
|          each variable in the VAR list.  Options are 1, 2, 3 and 4.  If
|          the user doesn't specify a TYPE for every VAR then the last listed
|          type is carried through.  The allowable types are as follows:
|              1 = Continuous variable.  Must be numeric
|              2 = Discrete variable.  Can be numeric or character
|              3 = Date variable.  Must be numeric
|              4 = Survival time variable.  Must be numeric.  See section 2.3.4
|              5 = Logistic event variable.  See section 2.3.5
| 2.0: OPTIONAL PARAMETERS
|   2.1: Subgroup Options
|     2.1.1: BY variable Options - Comparisons including p-values
|       BY = Determines a variable to separate VAR variables into groups for comparison.
|            Will create one column per level of BY (potentially including missing values)
|            and will enable p-value comparisons based on PVALS.
|       BYORDER = Determines the order that the levels of BY variable are shown.  Leaving this
|                 missing causes the values to be listed in the order determined by BYORDER_FORMATTED.
|                 Order should be determined by a space delimited numbered list where each
|                 number corresponds to the default order of the BY variable.  For example
|                 a GENDER character variable could have values of MALE and FEMALE.  Default would list
|                 these values in the order FEMALE then MALE.  Specifying BYORDER=2 1 would
|                 change this order to be MALE then FEMALE.  Missing values of BY will always
|                 show up as the far left column if enabled.
|       BYORDER_FORMATTED = Determines if default order of BY variable is the formatted 
|                         values.  Options are 0 (no) or 1 (yes).  Default is 0.
|       BYLABEL = Determines the label for the BY variable.  Default will pull from the dataset.
|       BY_INCMISS = Determines if missing values are considered a level for comparison in
|                    percentages and p-values.  Options are 0 (no) and 1 (yes).Default is 0.  
|       BY_PRINTMISS = Determines if missing values are printed in the table.  Options are:
|                         0 = Do not print unless BY_INCMISS=1 and missing values are present
|                         1 = Prints column if missing values are present or BY_INCMISS=1
|                         2 = Always prints column even if there are no missing values
|                      Default is 1.  
|     2.1.2: COLBY (Column By) variable Options - Comparisons not including p-values
|       COLBY = Determines a variable to repeat distributions within subgroups horizontally
|               in the table.  If COLBY has two levels, then 2 independent sets of distributions
|               are displayed in the table.  P-values are not calculated comparing the subgroups
|               created by this variable.
|       COLBYORDER = Determines the order that the levels of COLBY variable are shown.  Leaving this
|                    missing causes the values to be listed in the order determined by COLBYORDER_FORMATTED.
|                    See BYORDER for details on use.
|       COLBYORDER_FORMATTED = Determines if default order of COLBY variable is the formatted 
|                              values.  Options are 0 (no) or 1 (yes).  Default is 0.
|       COLBYLABEL = Determines the label for the COLBY variable.  Default will pull from the dataset.
|     2.1.3: ROWBY (Row By) variable Options - Comparisons not including p-values
|       ROWBY = Determines a variable to repeat distributions within subgroups horizontally
|               in the table.  If ROWBY has two levels, then 2 independent sets of distributions
|               are displayed in the table.  P-values are not calculated comparing the subgroups
|               created by this variable.
|       ROWBYORDER = Determines the order that the levels of ROWBY variable are shown.  Leaving this
|                    missing causes the values to be listed in the order determined by ROWBYORDER_FORMATTED.
|                    See BYORDER for details on use.
|       ROWBYORDER_FORMATTED = Determines if default order of ROWBY variable is the formatted 
|                              values.  Options are 0 (no) or 1 (yes).  Default is 0.
|       ROWBYLABEL = Determines the label for the ROWBY variable.  Default will pull from the dataset.
|     2.1.4: Subset input dataset
|       WHERE = Allows a where clause to subset the input dataset within the macro.  List exactly as
|               a where clause within a procedure.  Example: WHERE=arm='A'
|   2.2: P-value Options
|     PVALS = A space delimited list of values that determines the p-value for
|             each variable in the VAR list.  Options depend on the TYPE of variable.  If
|             the user doesn't specify a p-value for every VAR then the last listed
|             type is carried through.  The allowable types are as follows:
|               Continuous or Date Variables:
|                 If BY variable is present
|                   0 = No p-value
|                   1 = Kruskal-Wallis
|                   2 = Exact Kruskal-Wallis (long calculation times)
|                   3 = Wilcoxon rank sum
|                   4 = Exact Wilcoxon rank sum (long calculation times)
|                   5 = ANOVA F-test
|                   6 = Equal variance two sample t-test
|                   7 = Unequal variance two sample t-test
|                 If BY variable is not present
|                   0 = No p-value
|                   1 = Student T-Test
|                   2 = Sign Rank
|               Discrete Variables:
|                 If BY variable is present
|                   0 = No p-value
|                   1 = Chi-square
|                   2 = Fisher's exact
|                   3 = Cochran-Armitage trend test (Either BY or VAR must have 2 levels only)
|               Survival Variables:
|                 If BY variable is present
|                   0 = No p-value
|                   1 = Logrank
|                   2 = Wilcoxon
|                   3 = Cox model type-3 score
|                   4 = Cox model type-3 likelihood-ratio
|                   5 = Cox model type-3 Wald
|   2.3: Variable Display Options
|     2.3.1: Continuous Variables
|       CONTDISPLAY = Determines which descriptive statistics are calculated for numeric variables.
|                     Options are the following in a space delmited list.  Items are shown in the order they are listed.
|                       N = Number of non-missing records
|                       NMISS = Number of missing records
|                       N_NMISS = Combines N and NMISS as N (NMISS)
|                       MEAN = Mean of the distribution
|                       SD = Standard Deviation of the distribution
|                       MEAN_SD = Combines Mean and SD as MEAN (SD)
|                       MEDIAN = Median of the distribution
|                       RANGE = Range of the distribution as MIN, MAX
|                       IQR = Interquartile range of the distribution as Q1, Q3
|                       MEDIAN_RANGE = Combines Median and Range as MEDIAN (MIN, MAX)
|                       MEDIAN_IQR = Combines Median and IQR as MEDIAN (Q1, Q3)
|                     Default is N MEAN_SD MEDIAN RANGE.
|     2.3.2: Discrete Variables
|       DIS_DISPLAY = Determines which descriptive statistics are calculated for numeric variables.
|                     Options are the following:
|                       N = Number within that level
|                       PCT = Percentage within that level. Percentage depends on PCTDISPLAY
|                       N_PCT = Combines N and PCT as N (PCT)
|       DIS_ORDER = Determines the order that the discrete variable levels are shown.  Leaving this
|                   missing causes the values to be listed in the order determined by DIS_ORDER_FORMATTED.
|                   Order should be determined by a space delimited numbered list where each
|                   number corresponds to the alphabetical order of the BY variable.  For example
|                   a GENDER character variable could have values of MALE and FEMALE.  Default would list
|                   these values in the order FEMALE then MALE.  Specifying DIS_ORDER=2 1 would
|                   change this order to be MALE then FEMALE.
|
|                   If there are multiple discrete variables then each can be provided their own list by
|                   separting lists with the | (capital \) symbol.  For example, if there are two variables
|                   ARM and GENDER, the orders for each can be modified with DIS_ORDER=3 1 2|2 1.  Leave
|                   missing if alphabetical is desired (DIS_ORDER=3 1 2| ).
|
|                   DIS_ORDER knows to skip over other types so missing values do
|                   not need to be entered for TYPE 1, 3 or 4 variables.
|
|                   The user does not need to specify every level of the discrete variable.  If only certain
|                   levels are to be shown such as only showing the Yes values of a Yes/No variable then
|                   user can specify DIS_ORDER=2.  A warning will fire but this can be suppressed with DIS_ORDER_OVERRIDE
|       DIS_ORDER_FORMATTED = Determines if default order of discrete variables is the formatted 
|                             values.  Options are 0 (no) or 1 (yes).  Default is 0.
|       DIS_ORDER_OVERRIDE = Flag variable to override the warning that comes with DIS_ORDER when not specifying
|                            all values.  Options are 0 (no) and 1 (yes). Default is 0.
|       DIS_INCMISS = Flag variable to determine if missing is a valid level of the discrete variables for percentages
|                     and p-values.  Options are 0 (no) and 1 (yes). Default is 0.
|       DIS_PRINTMISS = Flag variable to determine if missing values are printed for discrete values.  Default is 1.
|                       0 = Do not print unless DIS_INCMISS=1 and missing values are present
|                       1 = Prints column if missing values are present or DIS_INCMISS=1
|                       2 = Always prints column even if there are no missing values
|       DIS_MISSORDER = Determines if missing values are printed before or after other levels of discrete variables.
|                       Options are FIRST and LAST.  Default is LAST.
|       DIS_SUFFIX = Determines a suffix that is applied to the end of the label for each discrete variable.  This is a
|                    text string that is literally concatenated to the label.  Default is AUTO.  when AUTO is specified,
|                    the following occurs:
|                      When DIS_DISPLAY=N_PCT then , n (%)
|                      When DIS_DISPLAY=N then , n
|                      When DIS_DISPLAY=PCT then , %
|       PCTDISPLAY = Determines if percentages are row based or column based.  Options are COL and ROW.  Default is COL.
|     2.3.3: Date Variables
|       DATEDISPLAY = Determines which descriptive statistics are calculated for date variables.
|                     Options are the following in a space delmited list.  Items are shown in the order they are listed.
|                       N = Number of non-missing records
|                       NMISS = Number of missing records
|                       N_NMISS = Combines N and NMISS as N (NMISS)
|                       MEAN = Mean of the distribution
|                       SD = Standard Deviation of the distribution
|                       MEAN_SD = Combines Mean and SD as MEAN (SD)
|                       MEDIAN = Median of the distribution
|                       RANGE = Range of the distribution as MIN, MAX
|                       IQR = Interquartile range of the distribution as Q1, Q3
|                       MEDIAN_RANGE = Combines Median and Range as MEDIAN (MIN, MAX)
|                       MEDIAN_IQR = Combines Median and IQR as MEDIAN (Q1, Q3)
|                     Default is N MEDIAN RANGE.
|       DATEFMT = Determines the format for the date values.  Default is MMDDYY10. 
|     2.3.4: Survival Variables
|       SURVDISPLAY = Determines which descriptive statistics are calculated for survival variables.
|                     Options are the following in a space delmited list.  Items are shown in the order they are listed.
|                       N = Number of patients
|                       EVENTS = Number of events
|                       EVENTS_N = Combines N and Events as EVENTS/N
|                       MEDIAN = Kaplan-Meier survival median and 95% CI
|                       HR = Cox model hazard ratio and 95% CI
|                       COXPVAL = Cox model Wald p-value comparing parameters
|                       TIMELIST = Kaplan-Meier time-point event-free rates and 95% CI
|                     Default is EVENTS_N MEDIAN TIMELIST HR COXPVAL.
|       SURV_STAT = A space delimited list of variables to containing the censoring values for each
|                   survival variable.  The first variable in this list will be matched to the first
|                   TYPE=4 variable in the VAR parameter and so on.
|       CEN_VL = A space delimited list of censor values.  If the user doesn't specify a value for every survival variable
|                then the last value is carried through. 
|       TIMELIST = A space delimited list of time-points to calculate Kaplan-Meier time-point event-free rates.  Separate
|                  time lists must be specified for each survival variable by using the | (capital \) symbol.
|                  example: survival variables FU_TIME and DFS_TIME.  Specify TIMELIST=0.5 2|3 5 7 to get the time-point
|                  estimates for FU_TIME at 0.5 and 2, and time-point estimates for DFS_TIME at 3, 5 and 7.
|       TIME_UNITS = Specifies a unit for the survival variables to be concatenated with the timelist estimates.
|                    Example: TIMELIST=1 and TIME_UNITS=years will make "1 year est (95% CI)" in the table.
|       TDIVISOR = Specifies a scalar value to multiply the survival variable time values by.  Separate values can be specified
|                  for each survival time variable with a space delimted list.  If no values are listed then the default is 1 (no change).
|       REFERENCE = Specifies a value of the BY variable to be used as a reference within a Cox model.  The
|                   reference should be the formatted value of the variable.  Reference value must exist within all levels
|                   of COLBY and ROWBY if specified.
|       CONFTYPE = Sets the confidence limit types for the Kaplan-Meier medians and time-point event-free rates.  Options are
|                  LOG, ASINSQRT, LOGLOG, LINEAR, and LOGIT.  Default is LOG.
|       TIMELISTFMT = Determines the format for the Kaplan-Meier time-point event-free rates.  Options are PPT (proportion) or PCT (Percent).
|                     Default is PPT.
|     2.3.5: Logistic Regression Variables
|       LOG_EVENT = The logistic regression event for the dependent variable specified in VAR.  Must match the formatted value exactly.
|       LOG_DISPLAY = Determines which descriptive statistics are calculated for logistic regression variables.
|                     Options are the following in a space delmited list.  Items are shown in the order they are listed.
|                       N = Number of patients
|                       EVENTS = Number of events
|                       EVENTS_N = Combines N and Events as EVENTS/N
|                       ODDSRATIO = logistic regression odds ratio of the BY variable
|                       WALDPVAL = logistic regression Wald p-value comparing parameters
|                       BINRATE = Binomial success rate and 95% CI
|                     Default is EVENTS_N BINRATE ODDSRATIO WALDPVAL.
|       LOG_CONFTYPE = Specifies the method used for the 95% CI of the binomial success rate.  Options are BIN (Binomial) or 
|                      BINEXACT (Binomial Exact).  Default is BIN.
|       LOG_BINFMT = Determines the format for the binomial success rates.  Options are PPT (proportion) or PCT (Percent).
|                    Default is PPT.
|     2.3.6: All Variables
|       LABELS = Sets the labels for the variables in the VAR parameter if the user wishes to override the labels
|                in the dataset.  Labels can be specified from variable to variable by using the | (capital \) symbol.
|                Entering a blank value results in the label being pulled from the dataset.
|   2.4: Table Display Options
|     2.4.0: Table borders
|       BORDERDISPLAY = Determines which borders are turned on for the table.  Options are:
|                           1 = Only horizontal borders in the header and footer
|                           2 = All cell borders are left on
|                           3 = All cell borders are left on except for titles and footnotes
|                           4 = Frames around each variable's sections but no horizontal lines within each variable's section
|                       Default is 1.
|     2.4.1: Disable Certain Columns or Labels
|       SHOWTOTAL = Determines if the total columns are displayed.  Options are 0 (no) and 1 (yes).  Default is 1.
|                   NOTE: this is ignored if there is no BY variable specified.
|       SHOWPVAL = Determines if the P-value columns are displayed.  Options are 0 (no), 1 (yes when BY is specified),
|                  and 2 (yes with or without BY).  Default is 1.
|       SHOWBYLABEL = Determines if the BY variable label is displayed.  Options are 0 (no) and 1 (yes).  Default is 1.
|       SHOWCOLLABEL = Determines if the COLBY label is displayed.  Options are 0 (no) and 1 (yes).  Default is 1.
|     2.4.2: Results Digit Rounding
|       2.4.2.1: Continuous Variables
|         MEANDIGITS = Determines the rounding of decimals for the mean of continuous variables. Can set different digits 
|                      for each variable with the | delimiter.
|         MEDIANDIGITS = Determines the rounding of decimals for the median of continuous variables. Can set different digits 
|                        for each variable with the | delimiter.
|         STDDIGITS = Determines the rounding of decimals for the standard deviation of continuous variables. Can set different digits 
|                     for each variable with the | delimiter.
|         IQRDIGITS = Determines the rounding of decimals for the interquartile range of continuous variables. Can set different digits 
|                     for each variable with the | delimiter.
|         RANGEDIGITS = Determines the rounding of decimals for the range of continuous variables. Can set different digits 
|                       for each variable with the | delimiter.
|       2.4.2.2: Discrete Variables
|         PCTDIGITS = Determines the rounding of decimals for the percentages of discrete variables. Can set different digits 
|                     for each variable with the | delimiter.
|       2.4.2.3: Survival Variables
|         SMEDIANDIGITS = Determines the rounding of decimals for the Kaplan-Meier median of time-to-event and
|                         confidence bounds for survival variables. Can set different digits 
|                         for each variable with the | delimiter.
|         HRDIGITS = Determines the rounding of decimals for the hazard ratio and confidence bounds of survival variables. Can set different digits 
|                    for each variable with the | delimiter.
|         TLDIGITS = Determines the rounding of decimals for the Kaplan-Meier time-point event-free rates and confidence bounds for
|                    survival variables. Can set different digits 
|                    for each variable with the | delimiter.
|       2.4.2.4: Logistic Variables
|         BINDIGITS = Determines the rounding of decimals for the Binomial Success rate and confidence bounds. Can set different digits 
|                     for each variable with the | delimiter.
|         ORDIGITS = Determines the rounding of decimals for the odds ratio and confidence bounds. Can set different digits 
|                    for each variable with the | delimiter.
|       2.4.2.5: P-values
|         PVALDIGITS = Determines the rounding of decimals for the p-values for all variables.
|     2.4.3: Shading
|       SHADING = Determines row shading for the table.  Default is 1.  Options are:
|         0 = No shading
|         1 = Alternating shading every row
|         2 = Alternating shading every variable
|     2.4.4: Titles/Footnotes
|       TITLE = Text string to be used as a title at the top of the table.  The ` will be used to manually create a line break.
|       TITLEALIGN = Determines how the TITLE is aligned. Options are LEFT, RIGHT, or CENTER.  Default is LEFT.
|       FOOTNOTE = Text string to be used as a footnote at the bottom of the table.  The ` will be used to manually create a line break.
|       FOOTNOTEALIGN = Determines how the FOOTNOTE is aligned. Options are LEFT, RIGHT, or CENTER.  Default is LEFT.
|     2.4.5: Separation of variables 
|       SPLIT = Determines how the table separates one variable from another.  Default is SPACE.  Options are:
|         SPACE = Adds a space when one variable ends and another begins
|         LINE = Adds a line when one variable ends and another begins
|         NONE = There is no line or space when one variable ends and another begins
|     2.4.6: Font Options
|       2.4.6.1: Font Size
|         HEADERSIZE = Determines the font size of the header section of the table.  Default is 10pt.
|         DATASIZE = Determines the font size of the data section of the table.  Default is 10pt.
|         TITLESIZE = Determines the font size of the title section of the table.  Default is 10pt.
|         FOOTNOTESIZE = Determines the font size of the footnote section of the table.  Default is 10pt.
|       2.4.6.2: Font Family
|         FONT = Determines the font for the table.  Default is Arial.
|       2.4.6.3: Font Weight
|         HEADERWEIGHT = Determines the weight of the font for the header section of the table.  Options are Medium (not bold) or BOLD.
|                        Default is MEDIUM.
|         DATAWEIGHT = Determines the weight of the font for the data section of the table.  Options are Medium (not bold) or BOLD.
|                        Default is MEDIUM.
|         TITLEWEIGHT = Determines the weight of the font for the title section of the table.  Options are Medium (not bold) or BOLD.
|                        Default is MEDIUM.
|         FOOTNOTEWEIGHT = Determines the weight of the font for the footnote section of the table.  Options are Medium (not bold) or BOLD.
|                        Default is MEDIUM.
|     2.4.7: Column Widths
|       SUBTITLEWIDTH = Determines the width of the subtitle/factor column.  Default is 2.25in.
|       DATAWIDTH = Determines the width of the DATA columns.  Default is 1.1in.
|       PVALWIDTH = Determines the width of the p-value columns.  Default is 0.75in.
|       ROWBYWIDTH = Determines the width of the ROWBY column.  Default is 2in.
|     2.4.8: Subtitle Header
|       SUBTITLEHEADER = Sets the column label for the subtitle/factor column.  Default is null (none).
|   2.5: Output options
|     2.5.1: Output Dataset
|       OUT = Identifies a dataset name to save out the report dataset.
|     2.5.2: Save to a document
|       OUTDOC = Identifies a file to directly save the table to.
|       DESTINATION = Identifies the ODS destination to use to save the OUTDOC file.  Options are RTF, PDF, EXCEL, POWERPOINT and HTML.
|                     Default is RTF.  POWERPOINT and EXCEL are only available in 9.4+.
|       ORIENTATION = Sets the page orientation of the file identified by OUTDOC.  Options are Portrait or Landscape.
|                     Default is PORTRAIT.
|       EXCEL_SHEETNAME = Sets the name of the sheet for the Excel destination.  Default is TABLEN.
|   2.6: Debugging options
|       DEBUG = Determines if notes are suppressed and temporary datasets cleaned up.  Options are:
|               0: notes are suppressed and temporary datasets are cleaned up
|               1: Notes are printed and temporary datasets are left behind.
|               Default is 0.
*------------------------------------------------------------------*
| OPERATING SYSTEM COMPATIBILITY
| SAS v9.2 or Higher: Yes
*------------------------------------------------------------------*
| MACRO CALL
|
| %tablen (
|            DATA=,
|            VAR=,
|            TYPE=
|          );
*------------------------------------------------------------------*
| EXAMPLES
|
| Neuralgia dataset for examples:
Data Neuralgia;
input Treatment $ Sex $ Age Duration Pain $ @@;
datalines;
P  F  68   1  No   B  M  74  16  No  P  F  67  30  No
P  M  66  26  Yes  B  F  67  28  No  B  F  77  16  No
A  F  71  12  No   B  F  72  50  No  B  F  76   9  Yes
A  M  71  17  Yes  A  F  63  27  No  A  F  69  18  Yes
B  F  66  12  No   A  M  62  42  No  P  F  64   1  Yes
A  F  64  17  No   P  M  74   4  No  A  F  72  25  No
P  M  70   1  Yes  B  M  66  19  No  B  M  59  29  No
A  F  64  30  No   A  M  70  28  No  A  M  69   1  No
B  F  78   1  No   P  M  83   1  Yes B  F  69  42  No
B  M  75  30  Yes  P  M  77  29  Yes P  F  79  20  Yes
A  M  70  12  No   A  F  69  12  No  B  F  65  14  No
B  M  70   1  No   B  M  67  23  No  A  M  76  25  Yes
P  M  78  12  Yes  B  M  77   1  Yes B  F  69  24  No
P  M  66   4  Yes  P  F  65  29  No  P  M  60  26  Yes
A  M  78  15  Yes  B  M  75  21  Yes A  F  67  11  No
P  F  72  27  No   P  F  70  13  Yes A  M  75   6  Yes
B  F  65   7  No   P  F  68  27  Yes P  M  68  11  Yes
P  M  67  17  Yes  B  M  70  22  No  A  M  65  15  No
P  F  67   1  Yes  A  M  67  10  No  P  F  72  11  Yes
A  F  74   1  No   B  M  80  21  Yes A  F  69   3  No
;
run;

| Example 1: Generic example
%tablen(
    DATA = NEURALGIA,
    VAR = TREATMENT SEX AGE DURATION PAIN,
    TYPE = 2 2 1 1 2);
|
| Example 2: Adding a BY variable
%tablen(
    DATA = NEURALGIA,
    VAR = SEX AGE DURATION PAIN,
    TYPE = 2 1 1 2,
    BY = TREATMENT);
|
| Example 3: Change discrete p-values to Fisher's exact
%tablen(
    DATA = NEURALGIA,
    VAR = SEX AGE DURATION PAIN,
    TYPE = 2 1 1 2,
    BY = TREATMENT,
    PVALS = 2 1 1 2);


proc format;
   value grpLabel 1='ALL' 2='AML low risk' 3='AML high risk';
run;

data BMT;
        input DIAGNOSIS Ftime Status Gender@@;
        label Ftime="Days";
        format Diagnosis grpLabel.;
datalines;
1       2081       0       1       1       1602    0       1
1       1496       0       1       1       1462    0       0
1       1433       0       1       1       1377    0       1
1       1330       0       1       1       996     0       1
1       226        0       0       1       1199    0       1
1       1111       0       1       1       530     0       1
1       1182       0       0       1       1167    0       0
1       418        2       1       1       383     1       1
1       276        2       0       1       104     1       1
1       609        1       1       1       172     2       0
1       487        2       1       1       662     1       1
1       194        2       0       1       230     1       0
1       526        2       1       1       122     2       1
1       129        1       0       1       74      1       1
1       122        1       0       1       86      2       1
1       466        2       1       1       192     1       1
1       109        1       1       1       55      1       0
1       1          2       1       1       107     2       1
1       110        1       0       1       332     2       1
2       2569       0       1       2       2506    0       1
2       2409       0       1       2       2218    0       1
2       1857       0       0       2       1829    0       1
2       1562       0       1       2       1470    0       1
2       1363       0       1       2       1030    0       0
2       860        0       0       2       1258    0       0
2       2246       0       0       2       1870    0       0
2       1799       0       1       2       1709    0       0
2       1674       0       1       2       1568    0       1
2       1527       0       0       2       1324    0       1
2       957        0       1       2       932     0       0
2       847        0       1       2       848     0       1
2       1850       0       0       2       1843    0       0
2       1535       0       0       2       1447    0       0
2       1384       0       0       2       414     2       1
2       2204       2       0       2       1063    2       1
2       481        2       1       2       105     2       1
2       641        2       1       2       390     2       1
2       288        2       1       2       421     1       1
2       79         2       0       2       748     1       1
2       486        1       0       2       48      2       0
2       272        1       0       2       1074    2       1
2       381        1       0       2       10      2       1
2       53         2       0       2       80      2       0
2       35         2       0       2       248     1       1
2       704        2       0       2       211     1       1
2       219        1       1       2       606     1       1
3       2640       0       1       3       2430    0       1
3       2252       0       1       3       2140    0       1
3       2133       0       0       3       1238    0       1
3       1631       0       1       3       2024    0       0
3       1345       0       1       3       1136    0       1
3       845        0       0       3       422     1       0
3       162        2       1       3       84      1       0
3       100        1       1       3       2       2       1
3       47         1       1       3       242     1       1
3       456        1       1       3       268     1       0
3       318        2       0       3       32      1       1
3       467        1       0       3       47      1       1
3       390        1       1       3       183     2       0
3       105        2       1       3       115     1       0
3       164        2       0       3       93      1       0
3       120        1       0       3       80      2       1
3       677        2       1       3       64      1       0
3       168        2       0       3       74      2       0
3       16         2       0       3       157     1       0
3       625        1       0       3       48      1       0
3       273        1       1       3       63      2       1
3       76         1       1       3       113     1       0
3       363        2       1
;
run;
|
| Example 4: Add in a survival variable
%tablen(
    DATA = BMT,
    VAR = GENDER STATUS FTIME,
    TYPE = 2 2 4,
    BY = DIAGNOSIS,
    SURV_STAT = STATUS,
    CEN_VL = 0);
|
| Example 4: Add time-point estimates and change time units
%tablen(
    DATA = BMT,
    VAR = GENDER STATUS FTIME,
    TYPE = 2 2 4,
    BY = DIAGNOSIS,
    SURV_STAT = STATUS,
    CEN_VL = 0,
    TDIVISOR = 365.25,
    TIMELIST = 1 2,
    TIME_UNITS = years);
*------------------------------------------------------------------*
| This program is free software; you can redistribute it and/or
| modify it under the terms of the GNU General Public License as
| published by the Free Software Foundation; either version 2 of
| the License, or (at your option) any later version.
|
| This program is distributed in the hope that it will be useful,
| but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
| General Public License for more details.
*------------------------------------------------------------------*/



%macro tablen(
    /*1.0: Required Parameters*/
    data=,var=,type=,
    /*2.0: Optional Parameters*/
        /*2.1: Subgroup Options*/
            /*2.1.1: BY variable Options - Comparisons including p-values*/
            by=,byorder=,byorder_formatted=0,bylabel=,by_incmiss=0,by_printmiss=1,
            /*2.1.2: COLBY (Column By) variable Options - Comparisons not including p-values*/
            colby=,colbyorder=,colbyorder_formatted=0,colbylabel=,
            /*2.1.3: ROWBY (Row By) variable Options - Comparisons not including p-values*/
            rowby=,rowbyorder=,rowbyorder_formatted=0,rowbylabel=,
            /*2.1.4: Subset input dataset*/
            where=,
        /*2.2: P-value Options*/
        pvals=1,pfoot=1,
        /*2.3: Variable Display Options*/
            /*2.3.1: Continuous Variables*/
            contdisplay=n mean_sd median range,
            /*2.3.2: Discrete Variables*/
            dis_display=n_pct,dis_order=,dis_order_formatted=0,dis_order_override=0,dis_incmiss=0,dis_printmiss=1,
            dis_missorder=last,pctdisplay=col,dis_suffix=AUTO,
            /*2.3.3: Date Variables*/
            datedisplay=n median range,datefmt=mmddyy10.,
            /*2.3.4: Survival Variables*/
            survdisplay=events_n median timelist hr coxpval,surv_stat=,cen_vl=,
            timelist=,time_units=,tdivisor=1,reference=,conftype=log,timelistfmt=ppt,
            /*2.3.5: Logistic Variables*/
            log_event=,log_display=events_n binrate oddsratio waldpval,log_conftype=bin,log_binfmt=ppt,
            /*2.3.6: All Variables*/
            labels=, 
        /*2.4: Table Display Options*/
            /*2.4.0: Table borders*/
            borderdisplay=1,
            /*2.4.1: Disable Certain Columns*/
            showtotal=1,showbylabel=1,showcollabel=1,showpval=1,
            /*2.4.2: Results Digit Rounding*/
                /*2.4.2.1: Continuous Variables*/
                meandigits=1,mediandigits=1,stddigits=2,iqrdigits=1,rangedigits=1,
                /*2.4.2.2: Discrete Variables*/
                pctdigits=1,
                /*2.4.2.3: Survival Variables*/
                smediandigits=2,hrdigits=2,tldigits=2,
                /*2.4.2.4: Logistic Variables*/
                ordigits=2,bindigits=2,
                /*2.4.2.5: P-values*/
                pvaldigits=4,
            /*2.4.3: Shading*/
            shading=1,
            /*2.4.4: Titles/Footnotes*/
            title=,titlealign=left,footnote=,footnotealign=left,
            /*2.4.5: Separation of variables*/    
            split=space,
            /*2.4.6: Font Options*/
                /*2.4.6.1: Font Size*/
                headersize=10pt,datasize=10pt,titlesize=10pt,footnotesize=10pt,
                /*2.4.6.2: Font Family*/
                font=Arial,
                /*2.4.6.3: Font Weight*/
                headerweight=medium,dataweight=medium,titleweight=medium,footnoteweight=medium,
            /*2.4.7: Column Widths*/
            subtitlewidth=2.25in,datawidth=1.1in,pvalwidth=0.75in,rowbywidth=2in,
            /*2.4.8: Subtitle Header*/
            subtitleheader=,
        /*2.5: Output options*/
            /*2.5.1: Output Dataset*/
            out=,
            /*2.5.2: Save to a document*/
            outdoc=,destination=RTF,orientation=portrait,
            excel_sheetname=TABLEN,
        /*2.6: Debuggin Options*/
            debug=0
            );
               
            
            
    /**Save current options to reset after macro runs**/
    %local _mergenoby _notes _qlm _odspath _starttime _listing _linesize _center _orientation _msglevel;
    %let _starttime=%sysfunc(time());
    %let _notes=%sysfunc(getoption(notes));
    %let _mergenoby=%sysfunc(getoption(mergenoby));
    %let _qlm=%sysfunc(getoption(quotelenmax)); 
    %let _linesize=%sysfunc(getoption(linesize));
    %let _center=%sysfunc(getoption(center));
    %let _orientation=%sysfunc(getoption(orientation));
    %let _msglevel=%sysfunc(getoption(msglevel));
    /**Turn off warnings for merging without a by and long quote lengths**/
    /**Turn off notes**/
    options mergenoby=NOWARN nonotes noquotelenmax msglevel=N;
    
    /*Don't send anything to output window, results window, and set escape character*/
    ods noresults escapechar='^';
    ods exclude all;
    %let _odspath=&sysodspath;
    
    /**Process Error Handling**/
    %if %sysfunc(exist(&data))=0 %then %do;
        %put ERROR: Dataset &data does not exist;
        %put ERROR: Please enter a valid dataset;
        %goto errhandl;
    %end;
    %else %if %sysevalf(%superq(data)=,boolean)=1 %then %do;
        %put ERROR: DATA parameter is required;
        %put ERROR: Please enter a valid dataset;
        %goto errhandl;
    %end;                       
    %local z nerror;
    %let nerror=0;  
      
    /**Error Handling on Global Parameters**/
    %macro _varcheck(parm,require,numeric,dataset=&data,nummsg=);
        %local _z _numcheck;
        /**Check if variable parameter is missing**/
        %if %sysevalf(%superq(&parm.)=,boolean)=0 %then %do;
            %if %sysfunc(notdigit(%superq(&parm.))) > 0 %then
                %do _z = 1 %to %sysfunc(countw(%superq(&parm.),%str( )));
                /**Check to make sure variable names are not just numbers**/    
                %local datid;
                /**Open up dataset to check for variables**/
                %let datid = %sysfunc(open(&dataset));
                /**Check if variable exists in dataset**/
                %if %sysfunc(varnum(&datid,%scan(%superq(&parm.),&_z,%str( )))) = 0 %then %do;
                    %put ERROR: (Global: %qupcase(&parm)) Variable %qupcase(%scan(%superq(&parm.),&_z,%str( ))) does not exist in dataset &dataset;
                    %local closedatid;
                    /**Close dataset**/
                    %let closedatid=%sysfunc(close(&datid));
                    %let nerror=%eval(&nerror+1);
                %end;
                %else %do;
                    %local closedatid;
                    %let closedatid=%sysfunc(close(&datid));
                    %if &numeric=1 %then %do;
                        data _null_;
                            set &dataset (obs=1);
                            call symput('_numcheck',strip(vtype(%qupcase(%scan(%superq(&parm.),&_z,%str( ))))));
                        run;
                        %if %sysevalf(%superq(_numcheck)^=N,boolean) %then %do;
                            %put ERROR: (Global: %qupcase(%scan(%superq(&parm.),&_z,%str( )))) variable must be numeric &nummsg;
                            %let nerror=%eval(&nerror+1);
                        %end;   
                    %end;                         
                %end;
            %end;
            %else %do;
                /**Give error message if variable name is number**/
                %put ERROR: (Global: %qupcase(&parm)) variable is not a valid SAS variable name (%superq(&parm.));
                %let nerror=%eval(&nerror+1);
            %end;
        %end;
        %else %if &require=1 %then %do;
            /**Give error if required variable is missing**/
            %put ERROR: (Global: %qupcase(&parm)) variable is a required variable but has no value;
            %let nerror=%eval(&nerror+1);
        %end;
    %mend;
    %macro _gparmcheck(parm, parmlist);          
        %local _test _z;
        /**Check if values are in approved list**/
        %do _z=1 %to %sysfunc(countw(&parmlist,|,m));
            %if %qupcase(%superq(&parm))=%qupcase(%scan(&parmlist,&_z,|,m)) %then %let _test=1;
        %end;
        %if &_test ^= 1 %then %do;
            /**If not then throw error**/
            %put ERROR: (Global: %qupcase(&parm)): %superq(&parm) is not a valid value;
            %put ERROR: (Global: %qupcase(&parm)): Possible values are &parmlist;
            %let nerror=%eval(&nerror+1);
        %end;
    %mend;
    /**Error Handling on Individual Model Numeric Variables**/
    %macro _gnumcheck(parm,min,contain,default);
        /**Check if missing**/
        %local z;
        %if %sysevalf(%superq(&parm.)=,boolean)=0 %then %do;
            %do z = 1 %to %sysfunc(countw(%superq(&parm),|,m));
                %if %sysevalf(%qscan(%superq(&parm.),&z,|,m)=,boolean) %then %do;
                    /**Check if value is not missing**/
                    %put ERROR: (Global: %qupcase(&parm) value &z) Cannot be missing and must be greater than &min.;
                    %let nerror=%eval(&nerror+1);                
                %end;
                %else %if %sysfunc(notdigit(%sysfunc(compress(%qscan(%superq(&parm.),&z,|,m),.)))) > 0 %then %do;
                    /**Check if character values are present**/
                    %put ERROR: (Global: %qupcase(&parm) value &z) Must be numeric.  %qupcase(%qscan(%superq(&parm.),&z,|,m)) is not valid.;
                    %let nerror=%eval(&nerror+1);
                %end;  
                %else %if %sysevalf(%superq(min)^=,boolean) %then %do;
                    %if %qscan(%superq(&parm.),&z,|,m) le &min and &contain=0 %then %do;
                        /**Check if value is below minimum threshold**/
                        %put ERROR: (Global: %qupcase(&parm) value &z) Must be greater than &min.  %qupcase(%qscan(%superq(&parm.),&z,|,m)) is not valid.;
                        %let nerror=%eval(&nerror+1);
                    %end;  
                    %else %if %qscan(%superq(&parm.),&z,|,m) lt &min and &contain=1 %then %do;
                        /**Check if value is below minimum threshold**/
                        %put ERROR: (Global: %qupcase(&parm) value &z) Must be greater than or equal to &min.  %qupcase(%qscan(%superq(&parm.),&z,|,m)) is not valid.;
                        %let nerror=%eval(&nerror+1);
                    %end; 
                %end;
            %end;
        %end;   
        %else %let &parm.=&default;      
    %mend;  
    /**Error Handling on Global Parameters Involving units**/
    %macro _gunitcheck(parm,allowmissing);
        %if %sysevalf(%superq(&parm)=,boolean)=1 %then %do;
                %if %sysevalf(&allowmissing^=1,boolean) %then %do;
                    /**Check if missing**/
                    %put ERROR: (Global: %qupcase(&parm)) Cannot be set to missing;
                    %let nerror=%eval(&nerror+1);
                %end;
        %end;
        %else %if %sysfunc(compress(%superq(&parm),ABCDEFGHIJKLMNOPQRSTUVWXYZ,i)) lt 0 %then %do;
            /**Throw error**/
            %put ERROR: (Global: %qupcase(&parm)) Cannot be less than zero (%qupcase(%superq(&parm)));
            %let nerror=%eval(&nerror+1);
        %end;
    %mend;
    /**Line Pattern Variables**/
    %macro _listcheck(var=,_patternlist=,lbl=,msg=);
        %local _z _z2 _test;
        %if %sysevalf(%superq(lbl)=,boolean) %then %let lbl=%qupcase(&var.);
        /**Check for missing values**/
        %if %sysevalf(%superq(&var.)=,boolean)=0 %then %do _z2=1 %to %sysfunc(countw(%superq(&var.),%str( )));
            %let _test=;
            /**Check if values are either in the approved list**/
            %do _z = 1 %to %sysfunc(countw(&_patternlist,|));
                %if %qupcase(%scan(%superq(&var.),&_z2,%str( )))=%scan(%qupcase(%sysfunc(compress(&_patternlist))),&_z,|,m) %then %let _test=1;
            %end;
            %if &_test ^= 1 %then %do;
                /**Throw error**/
                %put ERROR: (Global: &lbl): %qupcase(%scan(%superq(&var.),&_z2,%str( ))) is not in the list of valid values &msg;
                %put ERROR: (Global: &lbl): Possible values are %qupcase(&_patternlist);
                %let nerror=%eval(&nerror+1);
            %end;
        %end;
        %else %do;
            /**Throw error**/
            %put ERROR: (Global: &lbl): %qupcase(%superq(&var.)) is not in the list of valid values &msg;         
            %put ERROR: (Global: &lbl): Possible values are %qupcase(&_patternlist);
            %let nerror=%eval(&nerror+1);       
        %end;
    %mend;
    
    /**Check variables**/
    %_varcheck(var,1)
    %_varcheck(by,0)
    %_varcheck(rowby,0)
    %_varcheck(colby,0)
    %_varcheck(surv_stat,0,1)
    /**Check list parameters**/
    %_listcheck(var=type,_patternlist=1|2|3|4|5)
    %_listcheck(var=contdisplay,_patternlist=N|NMISS|N_NMISS|MEAN|SD|MEAN_SD|MEDIAN|RANGE|IQR|MEDIAN_RANGE|MEDIAN_IQR)
    %_listcheck(var=dis_display,_patternlist=N|PCT|N_PCT)
    %_listcheck(var=datedisplay,_patternlist=N|NMISS|N_NMISS|MEAN|SD|MEAN_SD|MEDIAN|RANGE|IQR|MEDIAN_RANGE|MEDIAN_IQR)
    %_listcheck(var=survdisplay,_patternlist=N|EVENTS|EVENTS_N|MEDIAN|HR|COXPVAL|TIMELIST)
    %_listcheck(var=log_display,_patternlist=N|EVENTS|EVENTS_N|ODDSRATIO|WALDPVAL|BINRATE)
    
    /**Parameter error checks**/
    %_gparmcheck(showtotal,0|1)
    %_gparmcheck(showbylabel,0|1)
    %_gparmcheck(showcollabel,0|1)
    %_gparmcheck(showpval,0|1|2)
    %_gparmcheck(pfoot,0|1)
    %_gparmcheck(shading,0|1|2)
    %_gparmcheck(titlealign,LEFT|CENTER|RIGHT)
    %_gparmcheck(footnotealign,LEFT|CENTER|RIGHT)
    %_gparmcheck(split,NONE|SPACE|LINE)
    %_gparmcheck(headerweight,MEDIUM|BOLD)
    %_gparmcheck(dataweight,MEDIUM|BOLD)
    %_gparmcheck(titleweight,MEDIUM|BOLD)
    %_gparmcheck(footnoteweight,MEDIUM|BOLD)
    %if &sysvlong >= 9.04.01M3P062415 %then %do;
        %_gparmcheck(destination,RTF|PDF|HTML|EXCEL|POWERPOINT)
    %end;
    %else %do;        
        %_gparmcheck(destination,RTF|PDF|HTML)
    %end;
    %_gparmcheck(orientation,PORTRAIT|LANDSCAPE)
    %_gparmcheck(dis_printmiss,0|1|2)
    %_gparmcheck(byorder_formatted,0|1)
    %_gparmcheck(rowbyorder_formatted,0|1)
    %_gparmcheck(colbyorder_formatted,0|1)
    %_gparmcheck(dis_order_formatted,0|1)
    %_gparmcheck(dis_missorder,FIRST|LAST)
    %_gparmcheck(dis_order_override,0|1)
    %_gparmcheck(dis_incmiss,0|1)
    %_gparmcheck(conftype,LOG|ASINSQRT|LOGLOG|LINEAR|LOGIT)
    %_gparmcheck(timelistfmt,PPT|PCT)
    %_gparmcheck(log_conftype,BIN|BINEXACT)
    %_gparmcheck(log_binfmt,PPT|PCT)
    %_gparmcheck(by_incmiss,0|1)
    %_gparmcheck(by_printmiss,0|1|2)
    %_gparmcheck(dis_incmiss,0|1)
    %_gparmcheck(dis_missorder,FIRST|LAST)
    %_gparmcheck(pctdisplay,COL|ROW)
    %_gparmcheck(borderdisplay,1|2|3|4)
    %_gparmcheck(debug,0|1)
    
    /**Number error checks**/
    %_gnumcheck(meandigits,0,1,1)
    %_gnumcheck(mediandigits,0,1,1)
    %_gnumcheck(stddigits,0,1,2)
    %_gnumcheck(iqrdigits,0,1,1)
    %_gnumcheck(rangedigits,0,1,1)
    %_gnumcheck(pctdigits,0,1,1)
    %_gnumcheck(smediandigits,0,1,2)
    %_gnumcheck(smediandigits,0,1,2)
    %_gnumcheck(pvaldigits,0,1,4)
    
    /*Numbers with units error checks**/
    %_gunitcheck(headersize,0)
    %_gunitcheck(datasize,0)
    %_gunitcheck(titlesize,0)
    %_gunitcheck(footnotesize,0)
    %_gunitcheck(subtitlewidth,0)
    %_gunitcheck(datawidth,0)
    %_gunitcheck(pvalwidth,0)
    %_gunitcheck(rowbywidth,0)
    
    %local nerror_run;
    %let nerror_run=0; 
    
    %if &nerror=0 %then %do;
        %local i j _nvar_ _numvars_ _nnumvars_ _ndisvars_ _nsurvvars_ _nlogvars_
            _lasttype_ _lastpval_ _lastcens_ _lastndisplay_ _lastddisplay_ _lastsdisplay_ _lastldisplay_
            _numpvals_ _dispvals_ _survpvals_ _logpvals_
            _numvars_ _numindex_ _numdisplay_ _numtype_ _meandigit_ _mediandigit_ _stddigit_ _iqrdigit_ _rangedigit_
            _disvars_ _disindex_  _disdisplay_ _pctdigit_
            _survvars_ _survindex_ _survstat_ _survcens_ _survtimelist_ _survntimelist_ _survunits_ _survdisplay_ _smediandigit_ _hrdigit_ _tldigit_
            _logvars_  _logindex_ _logdisplay_ _ordigit_ _bindigit_;
        /*Extend TYPE and PVALS to length of VAR*/
        %let _nvar_=%sysfunc(countw(%superq(var),%str( )));
        %do i = 1 %to &_nvar_;            
            %if %sysevalf(%qscan(&pvals,&i,%str( ))^=,boolean) %then %let _lastpval_=%scan(&pvals,&i,%str( ));
            %else %let pvals=&pvals &_lastpval_;
            %if %sysevalf(%qscan(&cen_vl,&i,%str( ))^=,boolean) %then %let _lastcens_=%scan(&cen_vl,&i,%str( ));
            %else %let cen_vl=&cen_vl &_lastcens_;
            %if %sysevalf(%qscan(&type,&i,%str( ))^=,boolean) %then %let _lasttype_=%scan(&type,&i,%str( ));
            %else %let type=&type &_lasttype_;
            
            %if %sysevalf(%qscan(&contdisplay,&i,|)^=,boolean) %then %let _lastndisplay_=%scan(&contdisplay,&i,|);
            %else %let contdisplay=&contdisplay|&_lastndisplay_;
            
            %if %sysevalf(%qscan(&datedisplay,&i,|)^=,boolean) %then %let _lastddisplay_=%scan(&datedisplay,&i,|);
            %else %let datedisplay=&datedisplay|&_lastddisplay_;
            
            %if %sysevalf(%qscan(&survdisplay,&i,|)^=,boolean) %then %let _lastsdisplay_=%scan(&survdisplay,&i,|);
            %else %let survdisplay=&survdisplay|&_lastsdisplay_;
            
            %if %sysevalf(%qscan(&log_display,&i,|)^=,boolean) %then %let _lastldisplay_=%scan(&log_display,&i,|);
            %else %let log_display=&log_display|&_lastldisplay_;
            
            %if %sysevalf(%qscan(&meandigits,&i,|)^=,boolean) %then %let _meandigit_=%scan(&meandigits,&i,|);
            %else %let meandigits=&meandigits|&_meandigit_;
            
            %if %sysevalf(%qscan(&mediandigits,&i,|)^=,boolean) %then %let _mediandigit_=%scan(&mediandigits,&i,|);
            %else %let mediandigits=&mediandigits|&_mediandigit_;
            
            %if %sysevalf(%qscan(&stddigits,&i,|)^=,boolean) %then %let _stddigit_=%scan(&stddigits,&i,|);
            %else %let stddigits=&stddigits|&_stddigit_;
            
            %if %sysevalf(%qscan(&rangedigits,&i,|)^=,boolean) %then %let _rangedigit_=%scan(&rangedigits,&i,|);
            %else %let rangedigits=&rangedigits|&_rangedigit_;
            
            %if %sysevalf(%qscan(&iqrdigits,&i,|)^=,boolean) %then %let _iqrdigit_=%scan(&iqrdigits,&i,|);
            %else %let iqrdigits=&iqrdigits|&_iqrdigit_;
            
            %if %sysevalf(%qscan(&pctdigits,&i,|)^=,boolean) %then %let _pctdigit_=%scan(&pctdigits,&i,|);
            %else %let pctdigits=&pctdigits|&_pctdigit_;
            
            %if %sysevalf(%qscan(&smediandigits,&i,|)^=,boolean) %then %let _smediandigit_=%scan(&smediandigits,&i,|);
            %else %let smediandigits=&smediandigits|&_smediandigit_;
            
            %if %sysevalf(%qscan(&hrdigits,&i,|)^=,boolean) %then %let _hrdigit_=%scan(&hrdigits,&i,|);
            %else %let hrdigits=&hrdigits|&_hrdigit_;
            
            %if %sysevalf(%qscan(&tldigits,&i,|)^=,boolean) %then %let _tldigit_=%scan(&tldigits,&i,|);
            %else %let tldigits=&tldigits|&_tldigit_;
            
            %if %sysevalf(%qscan(&ordigits,&i,|)^=,boolean) %then %let _ordigit_=%scan(&ordigits,&i,|);
            %else %let ordigits=&ordigits|&_ordigit_;
            
            %if %sysevalf(%qscan(&bindigits,&i,|)^=,boolean) %then %let _bindigit_=%scan(&bindigits,&i,|);
            %else %let bindigits=&bindigits|&_bindigit_;
            
        %end;
            
        /*Sort variables by type*/
        %do i = 1 %to %sysfunc(countw(%superq(var),%str( )));        
            %if %scan(%superq(type),&i,%str( ))=1 or %scan(%superq(type),&i,%str( ))=3 %then %do;
                %let _numvars_=&_numvars_ %scan(%superq(var),&i,%str( ));
                %let _numpvals_=&_numpvals_ %scan(%superq(pvals),&i,%str( ));
                %let _numindex_=&_numindex_ &i;
                %let _numtype_=&_numtype_ %scan(%superq(type),&i,%str( ));
            %end;
            %else %if %scan(%superq(type),&i,%str( ))=2 %then %do;
                %let _disvars_=&_disvars_ %scan(%superq(var),&i,%str( ));
                %let _dispvals_=&_dispvals_ %scan(%superq(pvals),&i,%str( ));
                %let _disindex_=&_disindex_ &i;
            %end;
            %else %if %scan(%superq(type),&i,%str( ))=4 %then %do;
                %let _survvars_=&_survvars_ %scan(%superq(var),&i,%str( ));
                %let _survpvals_=&_survpvals_ %scan(%superq(pvals),&i,%str( ));
                %let _survindex_=&_survindex_ &i;
            %end;
            %else %if %scan(%superq(type),&i,%str( ))=5 %then %do;
                %let _logvars_=&_logvars_ %scan(%superq(var),&i,%str( ));
                %let _logpvals_=&_logpvals_ %scan(%superq(pvals),&i,%str( ));
                %let _logindex_=&_logindex_ &i;
            %end;
        %end;
        
        /*Confirm Continuous variables are numeric*/
        %_varcheck(_numvars_,0,1,nummsg=when TYPE=1)
        /*Check for appropriate p-values*/
        %if %sysevalf(%superq(_numvars_)^=,boolean) %then %do;
            %if %sysevalf(%superq(by)^=,boolean) %then  %do;
                %_listcheck(var=_numpvals_,_patternlist=0|1|2|3|4|5|6|7,lbl=PVALS,msg=for continuous variables)
            %end;
            %else %do;
                %_listcheck(var=_numpvals_,_patternlist=0|1|2,lbl=PVALS,msg=for continuous variables with no BY variable)
            %end;
        %end;
        %if %sysevalf(%superq(_disvars_)^=,boolean) %then %do;
            %_listcheck(var=_dispvals_,_patternlist=0|1|2|3,lbl=PVALS,msg=for discrete variables)
        %end;
        %if %sysevalf(%superq(_survvars_)^=,boolean) %then %do;
            %_listcheck(var=_survpvals_,_patternlist=0|1|2|3|4|5,lbl=PVALS,msg=for survival variables)
        %end;
        %if %sysevalf(%superq(_logvars_)^=,boolean) %then %do;
            %_listcheck(var=_logpvals_,_patternlist=0|1|2|3,lbl=PVALS,msg=for logistic variables)
        %end;
        /*Calculate the number of each type of variable*/
        %let _nnumvars_=%sysfunc(countw(&_numvars_,%str( )));
        %let _ndisvars_=%sysfunc(countw(&_disvars_,%str( )));
        %let _nsurvvars_=%sysfunc(countw(&_survvars_,%str( )));
        %let _nlogvars_=%sysfunc(countw(&_logvars_,%str( )));
        
        /*Check for appropriate CEN_VL values*/
        %if &_nsurvvars_>0 and %sysevalf(%superq(cen_vl)^=,boolean) %then %do i = 1 %to &_nsurvvars_;
            %local _cen_vl&i;
            %let _cen_vl&i=%qscan(%superq(cen_vl),&i,|,m);
            %if %sysevalf(%superq(_cen_vl&i)^=,boolean) %then %do j = 1 %to %sysfunc(countw(%superq(_cen_vl&i),%str( )));
                %if %sysfunc(notdigit(%sysfunc(compress(%scan(%superq(_cen_vl&i),&j,%str( )),-.)))) > 0 %then %do;
                    /**Check if character values are present**/
                    %put ERROR: (Global: CEN_VL) Values must be numeric. %scan(%superq(_cen_vl&i),&j,%str( )) is not valid.;
                    %let nerror=%eval(&nerror+1);
                %end;  
            %end;
        %end;
        %else %if &_nsurvvars_>0 %then %do;
            /**Check if character values are present**/
            %put ERROR: (Global: CEN_VL) Values cannot be missing when specifying a TYPE=4 variable.;
            %let nerror=%eval(&nerror+1);
        %end; 
        /*Check for appropriate TDIVISOR values*/
        %if &_nsurvvars_>0 and %sysevalf(%superq(tdivisor)^=,boolean) %then %do i = 1 %to &_nsurvvars_;
            %local _tdivisor&i;
            %let _tdivisor&i=%qscan(%superq(tdivisor),&i,%str( ),m);
            %if %sysevalf(%superq(_tdivisor&i)^=,boolean) %then %do j = 1 %to %sysfunc(countw(%superq(_tdivisor&i),%str( )));
                %if %sysfunc(notdigit(%sysfunc(compress(%scan(%superq(_tdivisor&i),&j,%str( )),-.)))) > 0 %then %do;
                    /**Check if character values are present**/
                    %put ERROR: (Global: TDIVISOR) Values must be numeric. %scan(%superq(_tdivisor&i),&j,%str( )) is not valid.;
                    %let nerror=%eval(&nerror+1);
                %end;  
                %else %if %scan(%superq(_tdivisor&i),&j,%str( )) le 0 %then %do;
                    /**Check if character 0 or negative**/
                    %put ERROR: (Global: TDIVISOR) Values must be greater than or equal to 0 %scan(%superq(_tdivisor&i),&j,%str( )) is not valid.;
                    %let nerror=%eval(&nerror+1);
                %end;
            %end;
            %else %let _tdivisor&i=1;
        %end;
        %else %do i = 1 %to &_nsurvvars_;
            %let _tdivisor&i=1;
        %end; 
        /*Check for appropriate TIMELIST values*/
        %if &_nsurvvars_>0 and %sysevalf(%superq(timelist)^=,boolean) %then %do i = 1 %to &_nsurvvars_;
            %local _tl_&i;
            %let _tl_&i=%qscan(%superq(timelist),&i,|,m);
            %if %sysevalf(%superq(_tl_&i)^=,boolean) %then %do j = 1 %to %sysfunc(countw(%superq(_tl_&i),%str( )));
                %if %sysfunc(notdigit(%sysfunc(compress(%scan(%superq(_tl_&i),&j,%str( )),-.)))) > 0 %then %do;
                    /**Check if character values are present**/
                    %put ERROR: (Global: TIMELIST) Values must be numeric. %scan(%superq(_tl_&i),&j,%str( )) is not valid.;
                    %let nerror=%eval(&nerror+1);
                %end;  
                %else %if %superq(_tl_&i) lt 0 %then %do;
                    /**Check if value is below minimum threshold**/
                    %put ERROR: (Global: TIMELIST) Values must be greater than or equal to 0. %scan(%superq(_tl_&i),&j,%str( )) is not valid.;
                    %let nerror=%eval(&nerror+1);
                %end; 
            %end;
        %end;    
    %end;
    /*** If any errors exist, stop macro and send to end ***/
    %if &nerror > 0 %then %do;
        %put ERROR: &nerror pre-run errors listed;
        %put ERROR: Macro TABLEN will cease;
        %goto errhandl;
    %end;  
    %if &debug=1 %then %do;
        options notes mprint;
    %end;

    /*Make final macro variable updates*/
    %local dis_suffix_listing;
    %if %sysevalf(%qupcase(%superq(dis_suffix))=AUTO,boolean) %then %do;
        %if %sysevalf(%qupcase(%superq(dis_display))=N_PCT,boolean) %then %do;
            %let dis_suffix=^{style [fontweight=medium], n (%)};
            %let dis_suffix_listing=, n (%);
        %end;
        %else %if %sysevalf(%qupcase(%superq(dis_display))=N,boolean) %then %do;
            %let dis_suffix=^{style [fontweight=medium], n};
            %let dis_suffix_listing=, n;
        %end;
        %else %if %sysevalf(%qupcase(%superq(dis_display))=PCT,boolean) %then %do;
            %let dis_suffix=^{style [fontweight=medium], %};
            %let dis_suffix_listing=, %;
        %end;
    %end;
    /**Pull dataset information**/
    proc contents data=&data out=_temp noprint;
    run;

    /**See if the listing output is turned on**/
    proc sql noprint;
        select 1 into :_listing separated by '' from sashelp.vdest where upcase(destination)='LISTING';
    quit;
       
    /*Start analysis*/    
    /*Create subsetted temporary Dataset*/
    data _temp;
        set &data;
        where &where;
        %if %sysevalf(%superq(by)^=,boolean) %then %do;
            %if %sysevalf(%superq(bylabel)=,boolean) %then %do; call symput('bylabel',strip(vlabel(&by))); %end;
        %end;
        %if %sysevalf(%superq(rowby)^=,boolean) %then %do;
            %if %sysevalf(%superq(rowbylabel)=,boolean) %then %do; call symput('rowbylabel',strip(vlabel(&rowby))); %end;
        %end;
        %if %sysevalf(%superq(colby)^=,boolean) %then %do;
            %if %sysevalf(%superq(colbylabel)=,boolean) %then %do; call symput('colbylabel',strip(vlabel(&colby))); %end;
        %end;
    run;
    
    /**Row By variable Renaming**/
    %local nrowby _rowbylength _rowbylvls;
    %if %sysevalf(%superq(rowby)^=,boolean) %then %do;
        data _rowbyvar;
            set _temp (keep=&rowby rename=(&rowby=_rowby_orig_));
            length _rowby_ $300.;
            if strip(vvalue(_rowby_orig_))^='.' then _rowby_=strip(vvalue(_rowby_orig_));
            if missing(_rowby_) then _rowby_='Missing';
            _rowbylvl_=.;
        run;
        data _rowbyvar;
            set _rowbyvar;
            format _rowby_orig_;
        run; 
        proc sort data=_rowbyvar out=_rowbyvarlvls nodupkey;
            by _rowby_;
        run;
        %if %sysevalf(%superq(rowbyorder_formatted)=0,boolean) %then %do;
            proc sort data=_rowbyvarlvls;
                by _rowby_orig_;
            run;
        %end;
        proc sql noprint;
            select _rowby_ into :_rowbylvls separated by '|'   
                from _rowbyvarlvls;
            %let nrowby=%sysfunc(countw(%superq(_rowbylvls),|,m));
            select max(length(_rowby_)) into :_rowbylength separated by ''
                from _rowbyvar;
            alter table _rowbyvar
                modify _rowby_ char(&_rowbylength);
            %if %sysevalf(%superq(rowbyorder)^=,boolean) %then %do;
                update _rowbyvar
                    set _rowbylvl_=case(_rowby_)
                        %do i = 1 %to %sysfunc(countw(%superq(_rowbylvls),|,m));
                            when "%scan(%superq(_rowbylvls),%scan(%superq(rowbyorder),&i,%str( )),|,m)" then &i
                        %end;
                        else . end;                
            %end;
            %else %do;
                update _rowbyvar
                    set _rowbylvl_=case(_rowby_)
                        %do i = 1 %to %sysfunc(countw(%superq(_rowbylvls),|,m));
                            when "%scan(%superq(_rowbylvls),&i,|,m)" then &i
                        %end;
                        else . end;
            %end;
        quit;
        
        %if %sysevalf(%superq(rowbyorder)^=,boolean) %then %do;
            /**Pull largest value in order list**/
            %local _maxord;
            %let _maxord = %sysfunc(max(%sysfunc(tranwrd(%superq(rowbyorder),%str( ),%str(,)))));
            /**Pull number of items in order list**/
            %local _nord;
            %let _nord = %sysfunc(countw(%superq(rowbyorder),%str( )));
            /**Check if there are too many levels given**/
            %if &_nord ^= %sysfunc(countw(%superq(_rowbylvls),|)) %then %do;
                /**Throw errors**/
                %put ERROR: (Global: %qupcase(rowbyorder)): Number in order list (&_nord) does not equal the number of values for rowby variable %qupcase(%superq(rowby)) (%sysfunc(countw(%superq(_rowbylvls),|)));
                %let nerror_run=%eval(&nerror_run+1);
            %end;
            /**Check if the largest value is larger than the number of levels in the by variable**/
            %else %if &_maxord > %sysfunc(countw(%superq(_rowbylvls),|)) %then %do;
                /**Throw errors**/
                %put ERROR: (Global: %qupcase(rowbyorder)): Largest number in order list (&_maxord) is larger than the number of values for rowby variable %qupcase(%superq(rowby)) (%sysfunc(countw(%superq(_rowbylvls),|)));
                %let nerror_run=%eval(&nerror_run+1);
            %end;
            /**Check if all values from 1 to max are represented in the order list**/
            %else %do _z2=1 %to %sysfunc(countw(%superq(_rowbylvls),|));
                %local _test;
                %let _test=;
                %do z = 1 %to &_maxord;
                    %if %scan(%superq(rowbyorder),&z,%str( )) = &_z2 %then %let _test=1;
                %end;
                %if &_test ^=1 %then %do;
                    /**Throw errors**/
                    %put ERROR: (Global: %qupcase(rowbyorder)): Number &_z2 was not found in the rowbyorder list;
                    %put ERROR: (Global: %qupcase(rowbyorder)): Each number from 1 to maximum number of levels in rowby variable %qupcase(%superq(rowby)) (&_maxord) must be represented;
                    %let nerror_run=%eval(&nerror_run+1);
                %end;                                   
            %end;
            %if &nerror_run =0 %then %do;
                data _null_;  
                    call symput("_rowbylvls",
                        %do j = 1 %to %sysfunc(countw(%superq(rowbyorder),%str( )));
                            scan("%superq(_rowbylvls)",%scan(%superq(rowbyorder),&j,%str( )),'|') 
                                %if &j ^=%sysfunc(countw(%superq(rowbyorder),%str( ))) %then %do; ||'|'|| %end;
                        %end;);
                run;
            %end;
        %end;
    %end;
    %else %let nrowby=1;
    
    /**Col By variable Renaming**/
    %local ncolby _colbylength _colbylvls;
    %if %sysevalf(%superq(colby)^=,boolean) %then %do;
        data _colbyvar;
            set _temp (keep=&colby rename=(&colby=_colby_orig_));
            length _colby_ $300.;
            if strip(vvalue(_colby_orig_))^='.' then _colby_=strip(vvalue(_colby_orig_));
            if missing(_colby_) then _colby_='Missing';
            _colbylvl_=.;
        run;
        data _colbyvar;
            set _colbyvar;
            format _colby_orig_;
        run; 
        proc sort data=_colbyvar out=_colbyvarlvls nodupkey;
            by _colby_;
        run;
        %if %sysevalf(%superq(colbyorder_formatted)=0,boolean) %then %do;
            proc sort data=_colbyvarlvls;
                by _colby_orig_;
            run;
        %end;
        proc sql noprint;
            select _colby_ into :_colbylvls separated by '|'   
                from _colbyvarlvls;
            %let ncolby=%sysfunc(countw(%superq(_colbylvls),|,m));
            select max(length(_colby_)) into :_colbylength separated by ''
                from _colbyvar;
            alter table _colbyvar
                modify _colby_ char(&_colbylength);
            %if %sysevalf(%superq(colbyorder)^=,boolean) %then %do;
                update _colbyvar
                    set _colbylvl_=case(_colby_)
                        %do i = 1 %to %sysfunc(countw(%superq(_colbylvls),|,m));
                            when "%scan(%superq(_colbylvls),%scan(%superq(colbyorder),&i,%str( )),|,m)" then &i
                        %end;
                        else . end;                
            %end;
            %else %do;
                update _colbyvar
                    set _colbylvl_=case(_colby_)
                        %do i = 1 %to %sysfunc(countw(%superq(_colbylvls),|,m));
                            when "%scan(%superq(_colbylvls),&i,|,m)" then &i
                        %end;
                        else . end;
            %end;
        quit;
        
        %if %sysevalf(%superq(colbyorder)^=,boolean) %then %do;
            /**Pull largest value in order list**/
            %local _maxord;
            %let _maxord = %sysfunc(max(%sysfunc(tranwrd(%superq(colbyorder),%str( ),%str(,)))));
            /**Pull number of items in order list**/
            %local _nord;
            %let _nord = %sysfunc(countw(%superq(colbyorder),%str( )));
            /**Check if there are too many levels given**/
            %if &_nord ^= %sysfunc(countw(%superq(_colbylvls),|)) %then %do;
                /**Throw errors**/
                %put ERROR: (Global: %qupcase(colbyorder)): Number in order list (&_nord) does not equal the number of values for COLBY variable 
                    %qupcase(%superq(colby)) (%sysfunc(countw(%superq(_colbylvls),|)));
                %let nerror_run=%eval(&nerror_run+1);
            %end;
            /**Check if the largest value is larger than the number of levels in the by variable**/
            %else %if &_maxord > %sysfunc(countw(%superq(_colbylvls),|)) %then %do;
                /**Throw errors**/
                %put ERROR: (Global: %qupcase(colbyorder)): Largest number in order list (&_maxord) is larger than the number of values for COLBY variable 
                    %qupcase(%superq(colby)) (%sysfunc(countw(%superq(_colbylvls),|)));
                %let nerror_run=%eval(&nerror_run+1);
            %end;
            /**Check if all values from 1 to max are represented in the order list**/
            %else %do _z2=1 %to %sysfunc(countw(%superq(_colbylvls),|));
                %local _test;
                %let _test=;
                %do z = 1 %to &_maxord;
                    %if %scan(%superq(colbyorder),&z,%str( )) = &_z2 %then %let _test=1;
                %end;
                %if &_test ^=1 %then %do;
                    /**Throw errors**/
                    %put ERROR: (Global: %qupcase(colbyorder)): Number &_z2 was not found in the colbyorder list;
                    %put ERROR: (Global: %qupcase(colbyorder)): Each number from 1 to maximum number of levels in COLBY variable %qupcase(%superq(colby)) (&_maxord) must be represented;
                    %let nerror_run=%eval(&nerror_run+1);
                %end;                                   
            %end;
            %if &nerror_run =0 %then %do;
                data _null_;  
                    call symput("_colbylvls",
                        %do j = 1 %to %sysfunc(countw(%superq(colbyorder),%str( )));
                            scan("%superq(_colbylvls)",%scan(%superq(colbyorder),&j,%str( )),'|') 
                                %if &j ^=%sysfunc(countw(%superq(colbyorder),%str( ))) %then %do; ||'|'|| %end;
                        %end;);
                run;
            %end;
        %end;
    %end;
    %else %let ncolby=1;    
    
    /**By variable Renaming**/
    %local nby _bylength _bylvls;
    %if %sysevalf(%superq(by)^=,boolean) %then %do;
        data _byvar;
            set _temp (keep=&by rename=(&by=_by_orig_));
            length _by_ $300.;
            _by_=strip(vvalue(_by_orig_));
            _bylvl_=.;
        run;
        data _byvar;
            set _byvar;
            format _by_orig_;
        run;
        proc sort data=_byvar out=_byvarlvls nodupkey;
            by _by_;
            where ^missing(_by_);
        run;
        %if %sysevalf(%superq(byorder_formatted)=0,boolean) %then %do;
            proc sort data=_byvarlvls;
                by _by_orig_;
            run;
        %end;
        proc sql noprint;
            select _by_ into :_bylvls separated by '|'   
                from _byvarlvls;
            %let nby=%sysfunc(countw(%superq(_bylvls),|,m));
            select max(length(_by_)) into :_bylength separated by ''
                from _byvar;
            alter table _byvar
                modify _by_ char(&_bylength);
            %if %sysevalf(%superq(byorder)^=,boolean) %then %do;
                update _byvar
                    set _bylvl_=case(_by_)
                        %do i = 1 %to %sysfunc(countw(%superq(_bylvls),|,m));
                            when "%scan(%superq(_bylvls),%scan(%superq(byorder),&i,%str( )),|,m)" then &i
                        %end;
                        else %if %sysevalf(%superq(by_incmiss)=1,boolean) %then %do; 0 %end;
                             %else %do; .m %end; end;                
            %end;
            %else %do;
                update _byvar
                    set _bylvl_=case(_by_)
                        %do i = 1 %to %sysfunc(countw(%superq(_bylvls),|,m));
                            when "%scan(%superq(_bylvls),&i,|,m)" then &i
                        %end;
                        else %if %sysevalf(%superq(by_incmiss)=1,boolean) %then %do; 0 %end;
                             %else %do; .m %end; end;
            %end;
        quit;
        %if %sysevalf(%superq(byorder)^=,boolean) %then %do;
            /**Pull largest value in order list**/
            %local _maxord _minord;
            %let _maxord = %sysfunc(max(%sysfunc(tranwrd(%superq(byorder),%str( ),%str(,)))));
            %let _minord = %sysfunc(min(%sysfunc(tranwrd(%superq(byorder),%str( ),%str(,)))));
            /**Pull number of items in order list**/
            %local _nord;
            %let _nord = %sysfunc(countw(%superq(byorder),%str( )));
            /**Check if there are too many levels given**/
            %if &_nord ^= %sysfunc(countw(%superq(_bylvls),|,m)) %then %do;
                /**Throw errors**/
                %put ERROR: (Global: %qupcase(byorder)): Number in order list (&_nord) is not equal to the number of values for by variable %qupcase(%superq(by)) (%sysfunc(countw(%superq(_bylvls),|,m)));
                %let nerror_run=%eval(&nerror_run+1);
            %end;
            /**Check if the largest value is larger than the number of levels in the by variable**/
            %else %if &_maxord > %sysfunc(countw(%superq(_bylvls),|,m)) %then %do;
                /**Throw errors**/
                %put ERROR: (Global: %qupcase(byorder)): Largest number in order list (&_maxord) is larger than the number of values for by variable %qupcase(%superq(by)) (%sysfunc(countw(%superq(_bylvls),|,m)));
                %let nerror_run=%eval(&nerror_run+1);
            %end;
            /**Check if all values from 1 to max are represented in the order list**/
            %else %do _z2=1 %to %sysfunc(countw(%superq(_bylvls),|,m));
                %local _test;
                %let _test=;
                %do z = 1 %to &_maxord;
                    %if %scan(%superq(byorder),&z,%str( )) = &_z2 %then %let _test=1;
                %end;
                %if &_test ^=1 %then %do;
                    /**Throw errors**/
                    %put ERROR: (Global: %qupcase(byorder)): Number &_z2 was not found in the byorder list;
                    %put ERROR: (Global: %qupcase(byorder)): Each number from 1 to maximum number of levels in by variable %qupcase(%superq(by)) (&_maxord) must be represented;
                    %let nerror_run=%eval(&nerror_run+1);
                %end;                                   
            %end;
            %if &nerror_run =0 %then %do;
                data _null_;  
                    call symput("_bylvls",
                        %do j = 1 %to %sysfunc(countw(%superq(byorder),%str( )));
                            scan("%superq(_bylvls)",%scan(%superq(byorder),&j,%str( )),'|') 
                                %if &j ^=%sysfunc(countw(%superq(byorder),%str( ))) %then %do; ||'|'|| %end;
                        %end;);
                run;
            %end;
        %end;
    %end;
    %else %let nby=1;
    %local _nbymiss;
    proc sql noprint;
        %if %sysevalf(%superq(by)^=,boolean) %then %do;
            select sum((_bylvl_=0)) into :_nbymiss separated by '' from _byvar;
        %end;
        %else %let _nbymiss=0;
    quit;
    /**Change from Wilcoxon to Kruskal-Wallis**/
    %if (&nby>2 or (&nby=2 and &_nbymiss>0)) and %sysevalf(%superq(_numpvals_)^=,boolean) %then %do;
        %let _numpvals_=%sysfunc(tranwrd(&_numpvals_,3,1));
        %let _numpvals_=%sysfunc(tranwrd(&_numpvals_,4,2));
    %end;
    /*Rename Variables*/
    %do i = 1 %to &_nnumvars_;
        data _nvar&i;
            set _temp (keep=%scan(%superq(_numvars_),&i,%str( )) rename=(%scan(%superq(_numvars_),&i,%str( ))=_num_&i));
        run;
    %end;
    %do i = 1 %to &_ndisvars_;
        data _dvar&i;
            set _temp (keep=%scan(%superq(_disvars_),&i,%str( )) rename=(%scan(%superq(_disvars_),&i,%str( ))=_dis_orig_&i));
            length _dis_&i $300.;
            if strip(vvalue(_dis_orig_&i))^='.' then _dis_&i=strip(vvalue(_dis_orig_&i));
            _dis_&i._lvl=.;
        run;
        data _dvar&i;
            set _dvar&i;
            format _dis_orig_&i;
        run; 
        proc sort data=_dvar&i out=_dvarlvls&i nodupkey;
            by _dis_&i;
            where ^missing(_dis_&i);
        run;
        %if %sysevalf(%superq(dis_order_formatted)=0,boolean) %then %do;
            proc sort data=_dvarlvls&i;
                by _dis_orig_&i;
            run;
        %end;
    %end;
    %do i = 1 %to &_nsurvvars_;
        data _stime&i;
            set _temp (keep=%scan(%superq(_survvars_),&i,%str( ))  rename=(%scan(%superq(_survvars_),&i,%str( ))=_stime_&i));
            _stime_&i=_stime_&i/%superq(_tdivisor&i);
        run;
        data _sstat&i;
            set _temp (keep=%scan(%superq(surv_stat),&i,%str( ))  rename=(%scan(%superq(surv_stat),&i,%str( ))=_sstat_&i));
        run;
            
        data _svar&i;
            merge _stime&i _sstat&i;
        run;
        
        proc datasets nolist nodetails;
            %if &debug=0 %then %do;
                delete _stime&i _sstat&i;
            %end;
        quit;
    %end;
    %do i = 1 %to &_nlogvars_;
        data _lvar&i;
            set _temp (keep=%scan(%superq(_logvars_),&i,%str( ))  rename=(%scan(%superq(_logvars_),&i,%str( ))=_log_orig_&i));
            length _log_&i $300.;
            if strip(vvalue(_log_orig_&i))^='.' then _log_&i=strip(vvalue(_log_orig_&i));
            drop _log_orig_&i;
        run;
    %end;
            
    data _vars;
        merge %do i = 1 %to &_nnumvars_; _nvar&i %end;
              %do i = 1 %to &_ndisvars_; _dvar&i %end;
              %do i = 1 %to &_nsurvvars_; _svar&i %end;
              %do i = 1 %to &_nlogvars_; _lvar&i %end; ;
    run;
    %if %sysevalf(%superq(_disvars_)^=,boolean) %then %do;
        proc sql noprint;
            %do i = 1 %to &_ndisvars_;
                %local _dislength_&i _dislvls_&i _disorder_&i;
                select _dis_&i into :_dislvls_&i separated by '|'   
                    from _dvarlvls&i;
                select max(length(_dis_&i)) into :_dislength_&i separated by ''
                    from _vars;
                %let _disorder_&i=%sysfunc(strip(%qscan(%superq(dis_order),&i,|,m)));
            %end;
            alter table _vars
                modify 
                    %do i = 1 %to &_ndisvars_;
                        %if &i>1 %then %do; , %end;
                        _dis_&i char(&&_dislength_&i)
                    %end;;  
        quit;
        %do i = 1 %to &_ndisvars_;
            %if %sysevalf(%superq(_disorder_&i)^=,boolean) %then %do;
                /**Pull largest value in order list**/
                %local _maxord _minord _exlist&i;
                %let _exlist&i=%superq(_disorder_&i);
                %let _minord = %sysfunc(min(%sysfunc(tranwrd(%superq(_disorder_&i),%str( ),%str(,)))));
                %let _maxord = %sysfunc(max(%sysfunc(tranwrd(%superq(_disorder_&i),%str( ),%str(,)))));
                /**Pull number of items in order list**/
                %local _nord;
                %let _nord = %sysfunc(countw(%superq(_disorder_&i),%str( )));
                /**Check if there are too many levels given**/
                %if &_nord > %sysfunc(countw(%superq(_dislvls_&i),|)) %then %do;
                    /**Throw errors**/
                    %put ERROR: (Global: %qupcase(dis_order) variable &i): Number in order list (&_nord) greater than the number of values for %scan(&_disvars_,&i,%str( )) variable (%sysfunc(countw(%superq(_dislvls_&i),|)));
                    %let nerror_run=%eval(&nerror_run+1);
                %end;
                /**Check if the largest value is larger than the number of levels in the by variable**/
                %else %if &_maxord > %sysfunc(countw(%superq(_dislvls_&i),|)) %then %do;
                    /**Throw errors**/
                    %put ERROR: (Global: %qupcase(dis_order) variable &i): Largest number in order list (&_maxord) is larger than the number of values for %scan(&_disvars_,&i,%str( )) variable (%sysfunc(countw(%superq(_dislvls_&i),|)));
                    %let nerror_run=%eval(&nerror_run+1);
                %end;
                /**Check if the largest value is larger than the number of levels in the by variable**/
                %else %if &_minord < 1 %then %do;
                    /**Throw errors**/
                    %put ERROR: (Global: %qupcase(dis_order) variable &i): Smallest number in order list (&_minord) is less than 1 for %scan(&_disvars_,&i,%str( )) variable (%sysfunc(countw(%superq(_dislvls_&i),|)));
                    %let nerror_run=%eval(&nerror_run+1);
                %end;
                /**Check if all values from 1 to max are represented in the order list**/
                %else %do _z2=1 %to %sysfunc(countw(%superq(_dislvls_&i),|));
                    %local _test;
                    %let _test=;
                    %do z = 1 %to &_maxord;
                        %if %scan(%superq(_disorder_&i),&z,%str( )) = &_z2 %then %let _test=1;
                    %end;
                    %if &_test ^=1 %then %let _exlist&i=&&_exlist&i &_z2;
                    %if &_test ^=1 and &dis_order_override=0 %then %do;
                        /**Throw errors**/
                        %put WARNING: (GLOBAL: %qupcase(dis_order) variable &i): Number &_z2 was not found in the DIS_ORDER list;
                        %put WARNING: (GLOBAL: %qupcase(dis_order) variable &i): Not all values of %qupcase(%scan(&_disvars_,&i,%str( ))) accounted for;
                        %put WARNING: (GLOBAL: %qupcase(dis_order) variable &i): Set DIS_ORDER_OVERRIDE=1 to suppress this warning;
                        /*%let nerror_run=%eval(&nerror_run+1);*/
                    %end;                                   
                %end;
            %end;
        %end;
        %if &nerror_run =0 %then %do;
            proc sql noprint;
                update _vars
                    set 
                        %do i = 1 %to &_ndisvars_;
                            %if &i > 1 %then %do; , %end;  
                            _dis_&i._lvl=case(_dis_&i)
                                %do j = 1 %to %sysfunc(countw(%superq(_dislvls_&i),|,m));
                                    %if %sysevalf(%superq(_disorder_&i)^=,boolean) %then %do;
                                        %if %sysevalf(%scan(%superq(_disorder_&i),&j,%str( ))^=,boolean) %then %do;
                                            when "%scan(%superq(_dislvls_&i),%scan(%superq(_disorder_&i),&j,%str( )),|,m)" then &j
                                        %end;
                                        %else %if %sysevalf(%scan(%superq(_exlist&i),&j,%str( ))^=,boolean) %then %do;
                                            when "%scan(%superq(_dislvls_&i),%scan(%superq(_exlist&i),&j,%str( )),|,m)" then -&j
                                        %end;
                                    %end;
                                    %else %do;
                                        when "%scan(%superq(_dislvls_&i),&j,|,m)" then &j
                                    %end;
                                %end;
                                else %if %sysevalf(%superq(dis_incmiss)=1,boolean) %then %do; 0 %end;
                                     %else %do; .m %end; end
                        %end;
                        ;
            quit;
            data _null_;  
                %do i = 1 %to &_ndisvars_;
                    %local _ndislvl_pre&i;
                    %let _ndislvl_pre&i=%sysfunc(countw(%superq(_dislvls_&i),|,m));
                    %if %sysevalf(%superq(_disorder_&i)^=,boolean) %then %do;
                        call symput("_dislvls_&i",
                            %do j = 1 %to %sysfunc(countw(%superq(_disorder_&i),%str( )));
                                scan("%superq(_dislvls_&i)",%scan(%superq(_disorder_&i),&j,%str( )),'|') 
                                    %if &j ^=%sysfunc(countw(%superq(_disorder_&i),%str( ))) %then %do; ||'|'|| %end;
                            %end;);
                    %end;
                %end;
            run;
        %end;
    %end;
    
    /**Merge variables back together**/
    data _combined;
        merge _vars
            %if %sysevalf(%superq(by)^=,boolean) %then %do; _byvar %end;
            %if %sysevalf(%superq(rowby)^=,boolean) %then %do; _rowbyvar %end;
            %if %sysevalf(%superq(colby)^=,boolean) %then %do; _colbyvar %end;;
        
        %if %sysevalf(%superq(by)=,boolean) %then %do; _bylvl_=1; _by_='';%end;
        %if %sysevalf(%superq(rowby)=,boolean) %then %do; _rowbylvl_=1;_rowby_=''; %end;
        %if %sysevalf(%superq(colby)=,boolean) %then %do; _colbylvl_=1;_colby_='';%end;    
        
    run;
    
    /**Delete temporary variables**/
    proc datasets nolist nodetails;
        %if &debug=0 %then %do;
            delete _vars _byvar _rowbyvar _colbyvar _byvarlvls _rowbyvarlvls _colbyvarlvls
                %do i = 1 %to &_nnumvars_; _nvar&i %end;
                %do i = 1 %to &_ndisvars_; _dvar&i _dvarlvls&i %end;
                %do i = 1 %to &_nsurvvars_; _svar&i %end;
                %do i = 1 %to &_nlogvars_; _lvar&i %end;;
        %end;
    quit;

    /*Display variable values*/
    %local j _numindex _disindex _dateindex _survindex _logindex _timelistindex _anytimelist;
    %let _numindex=0;%let _disindex=0;%let _dateindex=0;%let _survindex=0;%let _timelistindex=0;%let _logindex=0;%let _anytimelist=0;
    %do i = 1 %to %sysfunc(countw(&var,%str( )));
        %local _displaylist_&i _ndisplay_&i;
        %if %scan(&type,&i,%str( ))=1 or %scan(&type,&i,%str( ))=3 %then %do;
            %if %scan(&type,&i,%str( ))=1 %then %do;
                %let _numindex=%sysevalf(&_numindex + 1);
                %let _displaylist_&i=%scan(%superq(contdisplay),&_numindex,|);
            %end;
            %else %if %scan(&type,&i,%str( ))=3 %then %do;
                %let _dateindex=%sysevalf(&_dateindex + 1);
                %let _displaylist_&i=%scan(%superq(datedisplay),&_dateindex,|);
            %end;
            %let _ndisplay_&i=%sysfunc(countw(&&_displaylist_&i,%str( )));
        
            %do j = 1 %to &&_ndisplay_&i;
                %local _display_&i._&j;
                %if %sysevalf(%qupcase(%scan(%superq(_displaylist_&i),&j,%str( )))=N) %then %let _display_&i._&j=N;
                %else %if %sysevalf(%qupcase(%scan(%superq(_displaylist_&i),&j,%str( )))=NMISS) %then %let _display_&i._&j=Missing;
                %else %if %sysevalf(%qupcase(%scan(%superq(_displaylist_&i),&j,%str( )))=N_NMISS) %then %let _display_&i._&j=N (Missing);
                %else %if %sysevalf(%qupcase(%scan(%superq(_displaylist_&i),&j,%str( )))=MEAN) %then %let _display_&i._&j=Mean;
                %else %if %sysevalf(%qupcase(%scan(%superq(_displaylist_&i),&j,%str( )))=SD) %then %let _display_&i._&j=SD;
                %else %if %sysevalf(%qupcase(%scan(%superq(_displaylist_&i),&j,%str( )))=MEAN_SD) %then %let _display_&i._&j=Mean (SD);
                %else %if %sysevalf(%qupcase(%scan(%superq(_displaylist_&i),&j,%str( )))=MEDIAN) %then %let _display_&i._&j=Median;
                %else %if %sysevalf(%qupcase(%scan(%superq(_displaylist_&i),&j,%str( )))=RANGE) %then %let _display_&i._&j=Range;
                %else %if %sysevalf(%qupcase(%scan(%superq(_displaylist_&i),&j,%str( )))=IQR) %then %let _display_&i._&j=IQR;
                %else %if %sysevalf(%qupcase(%scan(%superq(_displaylist_&i),&j,%str( )))=MEDIAN_RANGE) %then %let _display_&i._&j=Median (Range);
                %else %if %sysevalf(%qupcase(%scan(%superq(_displaylist_&i),&j,%str( )))=MEDIAN_IQR) %then %let _display_&i._&j=Median (IQR);
            %end;
        %end;
        %else %if %scan(&type,&i,%str( ))=2 %then %do;
            %let _disindex=%sysevalf(&_disindex + 1);
            %let _displaylist_&i=;
            %let _ndisplay_&i=%sysevalf(%sysfunc(countw(%superq(_dislvls_&_disindex),|))+1);

            %local k;
            %do j = 1 %to &&_ndisplay_&i;
                %local _display_&i._&j;
            %end;
            %if %sysevalf(%qupcase(&dis_missorder)=FIRST,boolean) %then %let _display_&i._1=Missing;
            %do j = 1 %to %sysfunc(countw(%superq(_dislvls_&_disindex),|));
                %let k=%sysevalf(&j + %sysevalf(%qupcase(&dis_missorder)=FIRST,boolean));
                %let _display_&i._&k=%qscan(%superq(_dislvls_&_disindex),&j,|);
            %end;
            %if %sysevalf(%qupcase(&dis_missorder)=LAST,boolean) %then %let _display_&i._&&_ndisplay_&i=Missing;
        %end;
        %else %if %scan(&type,&i,%str( ))=4 %then %do;
            %let _survindex=%sysevalf(&_survindex + 1);
            %let _timelistindex=0;
            %let _displaylist_&i=%scan(%superq(survdisplay),&_survindex,|);
            %let _ndisplay_&i=%sysfunc(countw(&&_displaylist_&i,%str( )));
            %if %sysfunc(find(&&_displaylist_&i,TIMELIST,i))>0 and %sysevalf(%scan(%superq(timelist),&_survindex,|)^=,boolean) %then %do;
                %let _anytimelist=1;
                %let _ndisplay_&i=%sysevalf(&&_ndisplay_&i + %sysfunc(countw(%scan(%superq(timelist),&_survindex,|),%str( ))) - 1);
                %let _displaylist_&i=%sysfunc(tranwrd(%qupcase(&&_displaylist_&i),TIMELIST,%sysfunc(repeat(%str(TIMELIST ),%sysfunc(countw(%scan(%superq(timelist),&_survindex,|),%str( )))-1))));
            %end;
            %else %if %sysfunc(find(&&_displaylist_&i,TIMELIST,i))>0 %then %do;
                %let _ndisplay_&i=%sysevalf(&&_ndisplay_&i - 1);
                %let _displaylist_&i=%sysfunc(tranwrd(%qupcase(&&_displaylist_&i),TIMELIST,%str()));
            %end;
            %do j = 1 %to &&_ndisplay_&i;
                %local _display_&i._&j;
                %if %sysevalf(%qupcase(%scan(%superq(_displaylist_&i),&j,%str( )))=N) %then %let _display_&i._&j=N;
                %else %if %sysevalf(%qupcase(%scan(%superq(_displaylist_&i),&j,%str( )))=EVENTS) %then %let _display_&i._&j=Events;
                %else %if %sysevalf(%qupcase(%scan(%superq(_displaylist_&i),&j,%str( )))=EVENTS_N) %then %let _display_&i._&j=Events/N;
                %else %if %sysevalf(%qupcase(%scan(%superq(_displaylist_&i),&j,%str( )))=MEDIAN) %then %let _display_&i._&j=Median (95% CI);
                %else %if %sysevalf(%qupcase(%scan(%superq(_displaylist_&i),&j,%str( )))=HR) %then %let _display_&i._&j=Hazard Ratio (95% CI);
                %else %if %sysevalf(%qupcase(%scan(%superq(_displaylist_&i),&j,%str( )))=COXPVAL) %then %let _display_&i._&j=Wald P-value;
                %else %if %sysevalf(%qupcase(%scan(%superq(_displaylist_&i),&j,%str( )))=TIMELIST) %then %do;
                    %let _timelistindex=%sysevalf(&_timelistindex+1);
                    %let _display_&i._&j=%sysfunc(compbl(%scan(%scan(%superq(timelist),&_survindex,|),&_timelistindex,%str( )) %superq(time_units) Est (95% CI)));
                %end;
            %end;
        %end;
        %else %if %scan(&type,&i,%str( ))=5 %then %do;
            %let _logindex=%sysevalf(&_logindex + 1);
            %let _displaylist_&i=%scan(%superq(log_display),&_logindex,|);
            %let _ndisplay_&i=%sysfunc(countw(&&_displaylist_&i,%str( )));
            
            %do j = 1 %to &&_ndisplay_&i;
                %local _display_&i._&j;
                %if %sysevalf(%qupcase(%scan(%superq(_displaylist_&i),&j,%str( )))=N) %then %let _display_&i._&j=N;
                %else %if %sysevalf(%qupcase(%scan(%superq(_displaylist_&i),&j,%str( )))=EVENTS) %then %let _display_&i._&j=Events;
                %else %if %sysevalf(%qupcase(%scan(%superq(_displaylist_&i),&j,%str( )))=EVENTS_N) %then %let _display_&i._&j=Events/N;
                %else %if %sysevalf(%qupcase(%scan(%superq(_displaylist_&i),&j,%str( )))=BINRATE) %then %let _display_&i._&j=Event Rate (95% CI);
                %else %if %sysevalf(%qupcase(%scan(%superq(_displaylist_&i),&j,%str( )))=ODDSRATIO) %then %let _display_&i._&j=Odds Ratio (95% CI);
                %else %if %sysevalf(%qupcase(%scan(%superq(_displaylist_&i),&j,%str( )))=WALDPVAL) %then %let _display_&i._&j=Wald P-value;
            %end;
        %end;
    %end;
    /**Check for reference values**/
    %local _cox _log;
    %if (&_nsurvvars_>0 or &_nlogvars_>0) and %sysevalf(%superq(by)^=,boolean) %then %do;    
        %if &nby lt 2 %then %do;
            %let _cox=0;
            %let _log=0;
        %end;
        %else %if %index(%qupcase(&survdisplay),HR) or %index(%qupcase(&survdisplay),COXPVAL) or
            %index(%qupcase(&log_display),ODDSRATIO) or %index(%qupcase(&log_display),WALDPVAL) or %index(%qupcase(&_logpvals_),1) or
            %index(%qupcase(&_survpvals_),3) or %index(%qupcase(&_survpvals_),4) or %index(%qupcase(&_survpvals_),5) %then %do;
            proc sql noprint;
                %local _test _test2;
                select %if %sysevalf(%superq(reference)^=,boolean) %then %do;min(test), %end;
                    ifn(max(nby)=min(nby),1,0) 
                    into %if %sysevalf(%superq(reference)^=,boolean) %then %do; :_test separated by '', %end; :_test2 separated by ''
                    from (select _rowbylvl_,_colbylvl_,
                            %if %sysevalf(%superq(reference)^=,boolean) %then %do; max(ifn(strip(_by_)="&reference",1,0)) as test, %end;
                            count(distinct _by_) as nby from _combined group by _rowbylvl_,_colbylvl_);
            quit;
            
            %if &_test = 0 and %sysevalf(%superq(reference)^=,boolean) %then %do;
                /**Throw errors**/
                %if %sysevalf(%superq(colby)^=,boolean) and %sysevalf(%superq(rowby)^=,boolean) %then   
                    %put ERROR: (Global: %qupcase(REFERENCE)): Specified reference (%superq(reference)) is not present in all combinations of ROWBY and COLBY;
                %else %if %sysevalf(%superq(colby)^=,boolean) %then   
                    %put ERROR: (Global: %qupcase(REFERENCE)): Specified reference (%superq(reference)) is not present in all levels of COLBY;
                %else %if %sysevalf(%superq(rowby)^=,boolean) %then   
                    %put ERROR: (Global: %qupcase(REFERENCE)): Specified reference (%superq(reference)) is not present in all levels of ROWBY;
                %else %put ERROR: (Global: %qupcase(REFERENCE)): Specified reference (%superq(reference)) is not present in the dataset;
                %put ERROR: (Global: %qupcase(REFERENCE)): Make sure to specify the formatted value of %superq(by) as a reference level;
                %let nerror_run=%eval(&nerror_run+1);
            %end;
            %else %if &_test2 =0 %then %do;
                /**Throw warnings**/
                %put WARNING: (Global: %qupcase(REFERENCE)): Different number of levels for %superq(by) across COLBY and/or ROWBY subgroups;
                %let _cox=1;
                %let _log=1;
            %end;
            %else %do;
                %let _cox=1;
                %let _log=1;
            %end;
        %end;
    %end;    
    %else %do;
        %let _cox=0;
        %let _log=0;
    %end;
    %local _refval;
    %if &_cox = 1 and %sysevalf(%superq(reference)^=,boolean) %then %do;
        %do i = 1 %to &nby;
            %if %sysevalf(%qscan(%superq(_bylvls),&i,|,m)=%superq(reference),boolean) %then %do;
                %let _refval=&i;
                %let i=&nby;
            %end;
        %end;
    %end;
    %else %let _refval=&nby;
    
    
    /*Check for 2 levels in each grouping combination*/
    %if &nerror_run=0 and &_nlogvars_>0 %then %do i = 1 %to &_nlogvars_;
        proc sql noprint;
            %local test1 test2 test3;
            select min(cnt),max(cnt) into :test1 separated by '',:test2 separated by ''
                from (select  _rowbylvl_,_colbylvl_,_bylvl_,count(distinct _log_&i) as cnt from _combined
                        group by _rowbylvl_,_colbylvl_,_bylvl_);
            select count(distinct _log_&i) into :test3 separated by '' from _combined;
        quit;
        %if &test3^=2 %then %do;
            %put ERROR: (Global: %qupcase(LOG_EVENT)): Variable %scan(%superq(_logvars_),&i,%str( )) does not have exactly 2 levels in dataset;
            %let nerror_run=%eval(&nerror_run+1);
        %end;            
        %else %if &test1 ^= 2 or &test2^=2 %then %do;
            %put ERROR: (Global: %qupcase(LOG_EVENT)): Variable %scan(%superq(_logvars_),&i,%str( )) does not have exactly 2 levels in all levels of ROWBY, COLBY, and BY variables;
            %let nerror_run=%eval(&nerror_run+1);
        %end;
        %if &nerror_run=0 %then %do;
            /*Check for appropriate LOG EVENT values*/
            %local _log_event&i;
            %if %sysevalf(%qscan(%superq(log_event),&i,|,m)^=,boolean) %then %do;
                %let _log_event&i=%qscan(%superq(log_event),&i,|,m);
                proc sql noprint;
                    %local test;
                    select min(cnt) into :test separated by ''
                        from (select _rowbylvl_,_colbylvl_,_bylvl_,max(ifn(_log_&i="%superq(_log_event&i)",1,0)) as cnt from _combined
                                group by _rowbylvl_,_colbylvl_,_bylvl_);
                quit;
                %if &test=0 %then %do;
                    %put ERROR: (Global: %qupcase(LOG_EVENT)): Specified event (%superq(_log_event&i)) for variable %scan(%superq(_logvars_),&i,%str( )) not found in all levels of ROWBY, COLBY, and BY variables;
                    %let nerror_run=%eval(&nerror_run+1);
                %end;
            %end;
            %else %do;
                proc sql noprint;
                    %local test;
                    select max(_log_&i) into :_log_event&i separated by '' from _combined;
                quit;
            %end;
        %end;
    %end;    
    /*** If any errors exist, stop macro and send to end ***/
    %if &nerror_run > 0 %then %goto errhandl2;
    /**Col By variable Renaming**/
    proc sort data=_combined;
        by _colbylvl_ _rowbylvl_ _bylvl_;
    run;

    /*Calculates N columns for table display*/
    %do c = 1 %to &ncolby;
        %do r = 1 %to &nrowby;
            %do b = 1 %to &nby;
                %local r&r._c&c._b&b._n;
            %end;
            %local r&r._c&c._n  r&r._c&c._miss_n;
        %end;
    %end;
    data _null_;
        set _combined end=last;
        by _colbylvl_ _rowbylvl_ _bylvl_;
        array _counts_ {&ncolby,&nrowby,%sysevalf(&nby+1)} (%sysevalf(&ncolby*&nrowby*(1+&nby))*0);
        array _counts2_ {&ncolby,&nrowby,2} (%sysevalf(&ncolby*&nrowby*2)*0);
        retain _counts_ _counts2_;
        _counts_(_colbylvl_,_rowbylvl_,ifn(_bylvl_ ^in(0 .m),_bylvl_,&nby+1))+1;
        if _bylvl_=0 then do;
            _counts2_(_colbylvl_,_rowbylvl_,1)+1;
            _counts2_(_colbylvl_,_rowbylvl_,2)+1;
        end;
        else _counts2_(_colbylvl_,_rowbylvl_,ifn(_bylvl_ ^in(.m),1,2))+1;
        
        if last then do;
            do i=1 to &ncolby;
                do j = 1 to &nrowby;
                    do k = 1 to &nby;
                        call symput(catt("r",j,"_c",i,"_b",k,"_n"),strip(put(_counts_(i,j,k),12.0)));
                    end;
                    call symput(catt("r",j,"_c",i,"_n"),strip(put(_counts2_(i,j,1),12.0)));
                    call symput(catt("r",j,"_c",i,"_miss_n"),strip(put(_counts2_(i,j,2),12.0)));
                end;
            end;
        end;
    run;
    proc sql noprint;  
        %do b = 1 %to &nby;  
            %local _b&b._colbylist;
            select distinct _colbylvl_ into :_b&b._colbylist separated by ' '
                from _combined where _bylvl_=&b;
        %end;
        %do c = 1 %to &ncolby;  
            %local _c&c._bylist;
            select distinct _bylvl_ into :_c&c._bylist separated by ' '
                from _combined where _colbylvl_=&c and _bylvl_ ^in(.m 0);
        %end;
        create table _out
            (rowby char(100),rowbylvl num,colby char(100),colbylvl num,indent num,
            vartype num,varnum num,varlevel num,header num,
            /*Meta-data for table*/
            meta num,nby num,ncolby num,nrowby num,title char(2000),footnote char(2000),pfoot char(1000),
            factor char(2000),
            %if %sysevalf(%superq(by)^=,boolean) %then %do j = 1 %to &nby;
                b&j._npct char(100),
            %end;
            m_npct char(100),
            t_npct char(100),
            pvaln num format=pvalue6.4,
            pvalfoot char(100),
            null num);
    quit;

    /**Assign Variable labels**/
    %do i = 1 %to %sysfunc(countw(&var,%str( )));
        /**If manual label not given, use variable's current label**/
        %if %sysevalf(%qscan(%superq(labels),&i,|,m)=,boolean) %then %do;
            data _null_;
                set &data (obs=1);
                call symput("label&i",strip(vlabel(%scan(&var,&i,%str( )))));
            run;
        %end;
        %else %let label&i=%qscan(%superq(labels),&i,|,m);
    %end;
    %local _rtf;
    proc sql noprint;
        select max(ifn(upcase(destination)='RTF',1,0))
            into :_rtf separated by '' from sashelp.vdest;
    quit;
    %if &_rtf=1 %then %do; 
        ODS RTF EXCLUDE ALL;
    %end;
    %if &_nnumvars_>0 %then %do;
    /*Distributions and p-values for numeric variables*/
        data _numeric;
            set _combined;
            array _num_ {&_nnumvars_};
            array _numtypes_ {&_nnumvars_} (%sysfunc(tranwrd(&_numtype_,%str( ),%str(,))));
            do i = 1 to dim(_num_);
                _numvar_=i;
                _numval_=_num_(i);
                _numtype_=_numtypes_(i);
                if scan("&_numpvals_",i,' ') in('2' '4') then exact=1;
                else exact=0;
                if scan("&_numpvals_",i,' ') in('6' '7') then ttest=1;
                output;
            end;
            drop i _numtypes_:;
        run;
        %local _nexact _nttest;
        proc sql noprint;
            select max(exact),max(ttest) into :_nexact separated by '',:_nttest separated by ''
                from _numeric;
        quit;
        proc sort data=_numeric;
            by _colbylvl_ _rowbylvl_ _numvar_ _bylvl_;
        run;
        /**Get statistics**/
        proc means data=_numeric noprint missing;
            by _colbylvl_ _rowbylvl_ _numvar_ _numtype_; 
            class _bylvl_;
            var _numval_;
            output out=_num_stat n=n nmiss=nmiss mean=mean stddev=stddev
                median=median min=min max=max q1=q1 q3=q3;
            where _bylvl_^=.m;
        run;
        proc means data=_numeric noprint missing;
            by _colbylvl_ _rowbylvl_ _numvar_ _numtype_; 
            class _bylvl_;
            var _numval_;
            output out=_num_statm n=n nmiss=nmiss mean=mean stddev=stddev
                median=median min=min max=max q1=q1 q3=q3;
            where _bylvl_=.m;
        run;
        data _num_stat;
            set _num_stat _num_statm (where=(_type_=1));
        proc sort data=_num_stat;
            by _colbylvl_ _rowbylvl_ _numvar_ _numtype_; 
        data _num_stat2;
            set _num_stat;
            by _colbylvl_ _rowbylvl_ _numvar_ _numtype_; 
            if first._colbylvl_ or first._rowbylvl_ then _conttype_=0;
            length factor n_pct $100.;
            if _numtype_=1 then do;
                if first._numvar_ then _conttype_+1;
                %do j = 1 %to &_nnumvars_;
                    %if &j>1 %then %do; else %end;
                    if _conttype_=&j then do;
                        factor='N';n_pct=ifc(n>0,strip(put(n,12.0)),'');output;
                        factor="Missing";n_pct=ifc(n>0,strip(put(nmiss,12.0)),'');output;
                        factor="N (Missing)";n_pct=ifc(n>0,strip(put(n,12.0))||' ('||strip(put(nmiss,12.0))||')','');output;
                        factor="Mean";n_pct=ifc(n>0,strip(put(mean,12.%scan(&meandigits,&j,|))),'');output;
                        factor="SD";n_pct=ifc(n>0,strip(put(stddev,12.%scan(&stddigits,&j,|))),'');output;
                        factor="Mean (SD)";n_pct=ifc(n>0,strip(put(mean,12.%scan(&meandigits,&j,|)))||' ('||strip(put(stddev,12.%scan(&stddigits,&j,|)))||')','');output;
                        factor="Median";n_pct=ifc(n>0,strip(put(median,12.%scan(&mediandigits,&j,|))),'');output;
                        factor="Range";n_pct=ifc(n>0,strip(put(min,12.%scan(&rangedigits,&j,|)))||', '||strip(put(max,12.%scan(&rangedigits,&j,|))),'');output;
                        factor="IQR";n_pct=ifc(n>0,strip(put(q1,12.%scan(&iqrdigits,&j,|)))||', '||strip(put(q3,12.%scan(&iqrdigits,&j,|))),'');output;
                        factor="Median (Range)";n_pct=ifc(n>0,strip(put(median,12.%scan(&mediandigits,&j,|))),'')||ifc(n>0,' ('||strip(put(min,12.%scan(&rangedigits,&j,|)))||', '||strip(put(max,12.%scan(&rangedigits,&j,|)))||')','');output;
                        factor="Median (IQR)";n_pct=ifc(n>0,strip(put(median,12.%scan(&mediandigits,&j,|))),'')||ifc(n>0,' ('||strip(put(q1,12.%scan(&iqrdigits,&j,|)))||', '||strip(put(q3,12.%scan(&iqrdigits,&j,|)))||')','');output;
                    end;
                %end;
            end;
            else if _numtype_=3 then do;
                factor='N';n_pct=ifc(n>0,strip(put(n,12.0)),'');output;
                factor="Missing";n_pct=ifc(n>0,strip(put(nmiss,12.0)),'');output;
                factor="N (Missing)";n_pct=ifc(n>0,strip(put(n,12.0))||' ('||strip(put(nmiss,12.0))||')','');output;
                factor="Mean";n_pct=ifc(n>0,strip(put(mean,&datefmt.)),'');output;
                factor="SD";n_pct=ifc(n>0,strip(put(stddev,&datefmt.))||' days','');output;
                factor="Mean (SD)";n_pct=ifc(n>0,strip(put(mean,&datefmt.))||' ('||strip(put(stddev,&datefmt.))||' days)','');output;
                factor="Median";n_pct=ifc(n>0,strip(put(median,&datefmt.)),'');output;
                factor="Range";n_pct=ifc(n>0,strip(put(min,&datefmt.))||', '||strip(put(max,&datefmt.)),'');output;
                factor="IQR";n_pct=ifc(n>0,strip(put(q1,&datefmt.))||', '||strip(put(q3,&datefmt.)),'');output;
                factor="Median (Range)";n_pct=ifc(n>0,strip(put(median,&datefmt.)),'')||ifc(n>0,' ('||strip(put(min,&datefmt.))||', '||strip(put(max,&datefmt.))||')','');output;
                factor="Median (IQR)";n_pct=ifc(n>0,strip(put(median,&datefmt.)),'')||ifc(n>0,' ('||strip(put(q1,&datefmt.))||', '||strip(put(q3,&datefmt.))||')','');output;
            end;
            keep _colbylvl_ _rowbylvl_ _numvar_ _numtype_ _bylvl_ factor n_pct;
        run;
        proc sort data=_num_stat2;
            by _colbylvl_ _rowbylvl_ _numvar_ _numtype_ factor;
        data _num_stat3;
            merge _num_stat2 (where=(_bylvl_=.) rename=(n_pct=t_npct))
                  _num_stat2 (where=(_bylvl_=ifn(&by_incmiss,0,.m)) rename=(n_pct=m_npct))
                  %if %sysevalf(%superq(by)^=,boolean) %then %do j = 1 %to &nby;
                      _num_stat2 (where=(_bylvl_=&j) rename=(n_pct=b&j._npct))
                  %end;;
            by _colbylvl_ _rowbylvl_ _numvar_ _numtype_ factor;
            drop _bylvl_;
        run;
        proc sql noprint;
            %local nby_num_nomiss;
            select count(distinct _bylvl_) into :nby_num_nomiss separated by '' from _numeric where ^missing(_numval_);
        quit;
        %if %sysevalf(%superq(nby)>1,boolean) and &nby_num_nomiss>1 %then %do;
            /**Get P-values**/
            proc npar1way data=_numeric noprint;
                by _colbylvl_ _rowbylvl_ _numvar_; 
                class _bylvl_;
                var _numval_;
                output out=_num_p1 wilcoxon anova;
            run;
            %if &_nexact=1 %then %do;
                proc npar1way data=_numeric noprint;
                    by _colbylvl_ _rowbylvl_ _numvar_; 
                    class _bylvl_;
                    var _numval_;
                    exact wilcoxon kw;
                    output out=_num_p1e wilcoxon anova;
                    where exact=1;
                run;
            %end;
            %if &nby =2 and &_nttest=1 %then %do;
                %if &_rtf=1 %then %do; 
                    ODS RTF EXCLUDE ALL;
                %end;
                proc ttest data=_numeric;
                    by _colbylvl_ _rowbylvl_ _numvar_; 
                    class _bylvl_;
                    var _numval_;
                    ods output TTests=_num_p2;
                run;
            %end;
        %end;
        %else %do;            
            proc univariate data=_numeric noprint;
                by _colbylvl_ _rowbylvl_ _numvar_; 
                var _numval_;
                output out=_num_p3 probt=probt probs=probs;
            run;
        %end;
    %end;
    /*Distributions and p-values for discrete variables*/
    %if &_ndisvars_>0 %then %do;
        data _discrete;
            set _combined;
            array _dis_ {&_ndisvars_} $300.;
            array _dis_lvl {&_ndisvars_} %do i = 1 %to &_ndisvars_; _dis_&i._lvl %end;;
            array _ndis_ {&_ndisvars_} 
                (%do i = 1 %to &_ndisvars_;
                    %if &i>1 %then %do; , %end;
                       %sysfunc(countw(%superq(_dislvls_&i),|,m))
                 %end;);
            length _disval_ $300.;
            do i = 1 to dim(_dis_);
                _disvar_=i;
                _dislvl_=_dis_lvl(i);
                _disval_=_dis_(i);
                if scan("&_dispvals_",i,' ') in('2') then exact=1;
                else exact=0;
                
                if scan("&_dispvals_",i,' ') in('3') and (&nby=2 or _ndis_(i)) then trend=1;
                else trend=0;
                
                output;
            end;
            drop i;
        run;
        
        %local _dtrend _dexact;
        proc sql noprint;
            select max(trend),max(exact) into :_dtrend separated by '',:_dexact separated by ''
                from _discrete;
        quit;
        proc sort data=_discrete;
            by _colbylvl_ _rowbylvl_ _disvar_ _bylvl_;
        run;
        /**Get Frequencies and first p-value**/
        proc freq data=_discrete noprint;
            by _colbylvl_ _rowbylvl_ _disvar_;
            table _dislvl_*_bylvl_ / 
                %if %sysevalf(%superq(by)^=,boolean) %then %do;chisq nowarn %end; outpct sparse out=_dis_stat;
            %if &nby>1 %then %do;output out=_dis_p1 chisq;%end;
        run;
        %if &nby=1 %then %do;
            data _dis_p1;
                do r=1 to &nrowby;
                    do c=1 to &ncolby;
                        _rowbylvl_=r;_colbylvl_=c;output;
                    end;
                end;
            run;
        %end;
        %if &_dexact=1 %then %do;
            proc freq data=_discrete noprint;
                by _colbylvl_ _rowbylvl_ _disvar_;
                table _dislvl_*_bylvl_ / %if %sysevalf(%superq(by)^=,boolean) %then %do;fisher nowarn %end;;
                %if &nby>1 %then %do;output out=_dis_p2 fisher;%end;
                where exact=1;
            run;
        %end;
        %if &_dtrend=1 %then %do;
            proc freq data=_discrete noprint;
                by _colbylvl_ _rowbylvl_ _disvar_;
                table _dislvl_*_bylvl_ / %if %sysevalf(%superq(by)^=,boolean) %then %do;trend nowarn %end;;
                %if &nby>1 %then %do;output out=_dis_p3 trend;%end;
                where trend=1 ;
            run;
        %end;
        
        data _dis_stat_missings;
            array _ndis_ {&_ndisvars_} 
                (%do i = 1 %to &_ndisvars_;
                    %if &i>1 %then %do; , %end;
                       %sysfunc(countw(%superq(_dislvls_&i),|,m))
                 %end;);
            do _rowbylvl_ = 1 to &nrowby;
                do _colbylvl_ = 1 to &ncolby;
                    do _bylvl_ = 1 to &nby;
                        do _disvar_ = 1 to &_ndisvars_;
                            _dislvl_ = ifn(%superq(dis_incmiss),0,.m);output;
                        end;
                    end;
                    _bylvl_=ifn(%superq(by_incmiss),0,.m);
                    do _disvar_ = 1 to &_ndisvars_;
                        do _dislvl_ = 1 to _ndis_(_disvar_);
                            output;
                        end;
                        _dislvl_ = ifn(%superq(dis_incmiss),0,.m);output;
                    end; 
                end;
            end;
            drop _ndis_:;
        run;
        proc sql noprint;
            insert into _dis_stat
                select _colbylvl_,_rowbylvl_,_disvar_,_dislvl_,_bylvl_,0 as count,0 as percent,0 as pct_col,0 as pct_row
                from _dis_stat_missings;
        quit;
        proc sort data=_dis_stat;
            by _colbylvl_ _rowbylvl_ _disvar_ _dislvl_ _bylvl_ count;
        run;
        
        data _dis_stat2;
            set _dis_stat;
            by _colbylvl_ _rowbylvl_ _disvar_ _dislvl_ _bylvl_;
            retain _tsum _tpct;
            length n_pct $100.;
            if first._dislvl_ then do;
                _tsum=0;_tpct=0;
            end;
            if count>=0 and _bylvl_^=.m then _tsum=_tsum+count;
            if percent>=0 and _bylvl_^=.m  then _tpct=_tpct+percent;
            %do j = 1 %to &_ndisvars_;
                %if &j>1 %then %do; else %end;
                if _disvar_=&j then do;
                    if upcase("%superq(dis_display)")='N_PCT' then n_pct=strip(put(count,12.0))||ifc(_dislvl_^=.m and _bylvl_^=.m,' ('||strip(put(pct_&pctdisplay,12.%scan(&pctdigits,&j,|)))||'%)','');
                    else if upcase("%superq(dis_display)")='N' then n_pct=strip(put(count,12.0));
                    else if upcase("%superq(dis_display)")='PCT' then n_pct=ifc(_dislvl_^=.m and _bylvl_^=.m,strip(put(pct_&pctdisplay,12.%scan(&pctdigits,&j,|))),strip(put(count,12.0)));
                end;
            %end;
            if ^last._dislvl_ and last._bylvl_ then output;
            else if last._dislvl_ then do;
                output;
                _bylvl_=.t;
                %do j = 1 %to &_ndisvars_;
                    %if &j>1 %then %do; else %end;
                    if _disvar_=&j then do;
                        if upcase("%superq(dis_display)")='N_PCT' then n_pct=strip(put(_tsum,12.0))||ifc(_dislvl_^=.m,' ('||strip(put(_tpct,12.%scan(&pctdigits,&j,|)))||'%)','');
                        else if upcase("%superq(dis_display)")='N' then n_pct=strip(put(_tsum,12.0));
                        else if upcase("%superq(dis_display)")='PCT' then n_pct=ifc(_dislvl_^=.m,strip(put(_tpct,12.%scan(&pctdigits,&j,|))),strip(put(_tsum,12.0)));
                        output;
                    end;
                %end;
            end;
            drop count percent pct_col pct_row _tsum _tpct;
        run;
        data _dis_stat3;
            merge _dis_stat2 (where=(_bylvl_=.t) rename=(n_pct=t_npct))
                  _dis_stat2 (where=(_bylvl_ in(0 .m)) rename=(n_pct=m_npct))
                  %if %sysevalf(%superq(by)^=,boolean) %then %do j = 1 %to &nby;
                      _dis_stat2 (where=(_bylvl_=&j) rename=(n_pct=b&j._npct))
                  %end;;
            by _colbylvl_ _rowbylvl_ _disvar_ _dislvl_;
            drop _bylvl_;
        run;
    %end;
    /*Distributions and p-values for survival variables*/
    %if &_nsurvvars_>0 %then %do;
         data _survival;
            set _combined;
            array _stime_ {&_nsurvvars_};
            array _sstat_ {&_nsurvvars_};
            array _cen_vl {&_nsurvvars_} (%do j = 1 %to &_nsurvvars_; %if &j>1 %then %do; , %end; %scan(%superq(cen_vl),&j,%str( )) %end;);
            do i = 1 to dim(_stime_);
                if _bylvl_=0 then _by_="*M*";
                _survvar_=i;
                _time_=_stime_(i);
                _stat_=_sstat_(i);
                _censor_=_cen_vl(i);
                if ^missing("&by") and _bylvl_^=.m then do;
                    _set_=1;
                    output;
                end;
                else if _bylvl_=.m then do;
                    _set_=2;
                    output;
                end;
            end;
            do i = 1 to dim(_stime_);
                _survvar_=i;
                _time_=_stime_(i);
                _stat_=_sstat_(i);
                _censor_=_cen_vl(i);
                _bylvl_=.;
                _by_='';
                _set_=3;
                output;
            end;
            drop i _stime_: _sstat_:;
        run;
        proc sort data=_survival;
            by _colbylvl_ _rowbylvl_ _survvar_ _set_ _bylvl_;
        run;
        /*Calculate how many unique censor values there are*/
        proc sql noprint;
            select distinct _censor_ into :_cenlist separated by ' ' from _survival;
        quit;
        %local k;
        %do k = 1 %to %sysfunc(countw(&_cenlist,%str( )));
            %if &_rtf=1 %then %do; 
                ODS RTF EXCLUDE ALL;
            %end;
            proc lifetest data=_survival missing
                %if &_anytimelist %then %do;
                    timelist=%do j = 1 %to %sysfunc(countw(%superq(timelist),|));
                                %scan(%superq(timelist),&j,|)
                             %end;
                    reduceout outs=_surv_stat3_&k
                %end; conftype=&conftype;
                by  _colbylvl_ _rowbylvl_ _survvar_ _set_;
                %if %sysevalf(%superq(by)^=,boolean) %then %do;
                    strata _bylvl_  / TEST=(LOGRANK WILCOXON);
                %end;
                time _time_*_stat_(%scan(%superq(_cenlist),&k,%str( )));
                ods output quartiles=_surv_stat2_&k (where=(percent=50)) censoredsummary=_surv_stat1_&k 
                    %if &nby>1 %then %do; homtests=_surv_p1_&k %end;;
                where _censor_=%scan(%superq(_cenlist),&k,%str( ));
            run;
            %if &_cox=1 %then %do;
                %if &_rtf=1 %then %do; 
                    ODS RTF EXCLUDE ALL;
                %end;
                proc phreg data=_survival;
                    by  _colbylvl_ _rowbylvl_ _survvar_ _set_;
                    class _bylvl_ %if %sysevalf(%superq(reference)^=,boolean) %then %do; (ref="&_refval") %end;;
                    model _time_*_stat_(%scan(%superq(_cenlist),&k,%str( ))) = _bylvl_ / rl type3(LR SCORE WALD);
                    ods output parameterestimates=_surv_stat4_&k 
                        %if %sysevalf(9.04.01M2P072314 > &sysvlong,boolean) %then %do;
                            type3=_surv_p2_&k 
                        %end;
                        %else %do;
                            modelanova=_surv_p2_&k
                        %end;;
                    where _censor_=%scan(%superq(_cenlist),&k,%str( )) and _set_=1;
                run; 
            %end; 
        %end;
        data _surv_stat1;
            set %do k = 1 %to %sysfunc(countw(&_cenlist,%str( )));  _surv_stat1_&k %end;;
        run; 
        data _surv_stat2;
            set %do k = 1 %to %sysfunc(countw(&_cenlist,%str( )));  _surv_stat2_&k %end;;
        run;
        %if %sysevalf(%superq(timelist)^=,boolean) %then %do;
            data _surv_stat3;
                set %do k = 1 %to %sysfunc(countw(&_cenlist,%str( )));  _surv_stat3_&k %end;;
            run;
        %end;
        %if &nby>1 %then %do;
            data _surv_p1;
                set %do k = 1 %to %sysfunc(countw(&_cenlist,%str( )));  _surv_p1_&k %end;;
            run;
            %if &_cox =1 %then %do;
                data _surv_stat4;
                    set %do k = 1 %to %sysfunc(countw(&_cenlist,%str( )));  _surv_stat4_&k %end;;
                run;
                data _surv_p2;
                    set %do k = 1 %to %sysfunc(countw(&_cenlist,%str( )));  _surv_p2_&k %end;;
                run;
            %end;
        %end;
        %else %if &nby=1 %then %do;
            data _surv_p1;
                do r=1 to &nrowby;
                    do c=1 to &ncolby;
                        _rowbylvl_=r;_colbylvl_=c;output;
                    end;
                end;
            run;
        %end;
        proc sql noprint;
            create table _surv_stat as
                select a._colbylvl_,a._rowbylvl_,a._survvar_,a._set_,
                        %if %sysevalf(%superq(by)^=,boolean) %then %do;
                            a._bylvl_,
                        %end;
                        %else %do;
                            . as _bylvl_,
                        %end;
                    strip(put(a.total,12.0)) as n,strip(put(a.failed,12.0)) as events,strip(put(a.failed,12.0))||'/'||strip(put(a.total,12.0)) as events_n,
                    case (a._survvar_)
                        %do i = 1 %to &_nsurvvars_;
                            when &i then 
                                ifc(^missing(b.estimate),strip(put(b.estimate,12.%scan(&smediandigits.,&i,|))),'NE')|| ' ('||
                                ifc(^missing(b.lowerlimit),strip(put(b.lowerlimit,12.%scan(&smediandigits.,&i,|))),'NE')||'A0'x||'-'||'A0'x||
                                ifc(^missing(b.upperlimit),strip(put(b.upperlimit,12.%scan(&smediandigits.,&i,|))),'NE')||')' 
                        %end; else '' end as median
                        %if &_cox =1 %then %do;
                            ,ifc(a._set_=1 and missing(c.hazardratio),'Reference',
                                ifc(a._set_ in(2 3),'',
                                    case (a._survvar_)
                                        %do i = 1 %to &_nsurvvars_;
                                            when &i then strip(put(hazardratio, 12.%scan(&hrdigits.,&i,|)))|| ' ('||
                                                         strip(put(hrlowercl,12.%scan(&hrdigits.,&i,|)))||'A0'x||'-'||'A0'x||
                                                         strip(put(hruppercl,12.%scan(&hrdigits.,&i,|)))
                                        %end;
                                    else '' end||')')) as hr,
                             ifc(a._set_=1 and missing(c.probchisq),'Reference',
                                ifc(a._set_ in(2 3),'',strip(put(c.probchisq,pvalue6.&pvaldigits.)))) as coxpval
                        %end;
                    from (select * from _surv_stat1 %if %sysevalf(%superq(by)^=,boolean) %then %do; where missing(control_var) %end;) a left join _surv_stat2 b 
                    on a._colbylvl_=b._colbylvl_ and a._rowbylvl_=b._rowbylvl_ and a._survvar_=b._survvar_ %if %sysevalf(%superq(by)^=,boolean) %then %do;  and a._bylvl_=b._bylvl_ %end;
                       and a._set_=b._set_
                    %if &_cox =1 %then %do; 
                        left join _surv_stat4 c
                        on a._colbylvl_=c._colbylvl_ and a._rowbylvl_=c._rowbylvl_ and a._survvar_=c._survvar_ and a._bylvl_=input(c.classval0,12.)
                    %end;
                    order by _colbylvl_,_rowbylvl_,_survvar_,_set_,_bylvl_;
            %if &_anytimelist=1 %then %do;
                create table _surv_stat_tl as
                    select a._colbylvl_,a._rowbylvl_,a._survvar_,a._set_,
                        %if %sysevalf(%superq(by)^=,boolean) %then %do;
                            a._bylvl_,
                        %end;
                        %else %do;
                            . as _bylvl_,
                        %end;
                    a.timelist,
                    case (a._survvar_)
                        %do i = 1 %to &_nsurvvars_;
                            when &i then 
                                ifc(^missing(survival),strip(put(survival*ifn(upcase("&timelistfmt")="PCT",100,1),12.%scan(&tldigits.,&i,|)))||ifc(upcase("&timelistfmt")="PCT",'%',''),'NE')||' ('||
                                ifc(^missing(sdf_lcl),strip(put(sdf_lcl*ifn(upcase("&timelistfmt")="PCT",100,1),12.%scan(&tldigits.,&i,|))),'NE')||'A0'x||'-'||'A0'x||
                                ifc(^missing(sdf_ucl),strip(put(sdf_ucl*ifn(upcase("&timelistfmt")="PCT",100,1),12.%scan(&tldigits.,&i,|))),'NE')||')' 
                        %end;
                    else '' end as tl
                    from _surv_stat3 a 
                    order by _colbylvl_,_rowbylvl_,_survvar_,_set_,_bylvl_;
            %end;
        quit;
        data _surv_stat_2;
            set _surv_stat;
            length factor n_pct $100.;
            factor='N';n_pct=n;output;
            factor='Events';n_pct=events;output;
            factor='Events/N';n_pct=events_n;output;
            factor='Median (95% CI)';n_pct=median;output;
            factor='Hazard Ratio (95% CI)';n_pct=hr;output;
            factor='Wald P-value';n_pct=coxpval;output;
            keep _colbylvl_ _rowbylvl_  _survvar_ factor n_pct _set_ _bylvl_;
        run;
        %if &_anytimelist=1 %then %do;
            data _surv_stat_tl2;
                set _surv_stat_tl;
                length factor n_pct $100.;
                factor=catx(' ',timelist,"%superq(time_units)",'Est (95% CI)');n_pct=tl;
                drop timelist tl;
            run;
        %end;
        data _surv_stat_3;
            set _surv_stat_2 %if &_anytimelist=1 %then %do; _surv_stat_tl2 %end;;
        run;
        proc sort data=_surv_stat_3;
            by _colbylvl_ _rowbylvl_  _survvar_ factor;
        data _surv_stat_4;
            merge _surv_stat_3 (where=(_bylvl_=. and _set_=3) rename=(n_pct=t_npct))
                  _surv_stat_3 (where=(_set_=ifn(&by_incmiss=0,2,1) %if &by_incmiss=1 %then %do; and _bylvl_=0 %end;) rename=(n_pct=m_npct))
                  %if %sysevalf(%superq(by)^=,boolean) %then %do j = 1 %to &nby;
                      _surv_stat_3 (where=(_bylvl_=&j and _set_=1) rename=(n_pct=b&j._npct))
                  %end;;
            by _colbylvl_ _rowbylvl_  _survvar_ factor;
            drop _bylvl_ _set_;
        run;
        proc datasets nolist nodetails;
            %if &debug=0 %then %do;
                delete %do k = 1 %to %sysfunc(countw(&_cenlist,%str( )));
                    _surv_stat1_&k _surv_stat1a_&k _surv_stat2_&k _surv_stat2a_&k _surv_stat3_&k _surv_stat3a_&k _surv_stat4_&k _surv_p1_&k _surv_p2_&k
                    _surv_stat1m_&k _surv_stat2m_&k _surv_stat3m_&k
                    %end;;
            %end;
        quit;
    %end;
    /*Distributions and p-values for logistic variables*/
    %if &_nlogvars_>0 %then %do;
         data _log;
            set _combined;
            array _log_ {&_nlogvars_} $300.;
            array _ev_vl {&_nlogvars_} $300. (%do j = 1 %to &_nlogvars_; %if &j>1 %then %do; , %end; "%superq(_log_event&j)" %end;);
            do i = 1 to dim(_log_);
                if scan("&_logpvals_",i,' ') in('3') then exact=1;
                else exact=0;
                if _bylvl_=0 then _by_="*M*";
                _logvar_=i;
                _event_=ifn(_log_(i)=_ev_vl(i),1,0);
                if &nby>1 and _bylvl_^=.m then do;
                    _set_=1;
                    output;
                end;
                else if _bylvl_=.m then do;
                    _set_=2;
                    output;
                end;
            end;
            do i = 1 to dim(_log_);
                if scan("&_logpvals_",i,' ') in('3') then exact=1;
                else exact=0;
                _logvar_=i;
                _logvar_=i;
                _event_=ifn(_log_(i)=_ev_vl(i),1,0);
                _bylvl_=.;
                _by_='';
                _set_=3;
                output;
            end;
            drop i _log_: _ev_vl:;
        run;
        
        %local _lexact;
        proc sql noprint;
            select max(exact) into :_lexact separated by ''
                from _log;
        quit;
        proc sort data=_log;
            by _colbylvl_ _rowbylvl_ _logvar_ _set_ _bylvl_;
        run;
        /*Counts/Events*/
        proc freq data=_log noprint;
            by _colbylvl_ _rowbylvl_ _logvar_ _set_ _bylvl_;
            table _event_ / bin(level='1');
            output out=_log_stat2 binomial;
        run;
        /*P-values*/
        %if &nby>1 %then %do;
            proc freq data=_log noprint;
                by _colbylvl_ _rowbylvl_ _logvar_ _set_ ;
                table _bylvl_*_event_ / chisq nowarn %if &_lexact=1 %then %do; fisher %end;;
                output out=_log_p3 chisq %if &_lexact=1 %then %do; fisher %end;;
            run;
        %end;
        /*Odds Ratios / P-values*/
        %if &_log=1 %then %do;
            %if &_rtf=1 %then %do; 
                ODS RTF EXCLUDE ALL;
            %end;
            proc logistic data=_log simple;
                by  _colbylvl_ _rowbylvl_ _logvar_ _set_;
                class _bylvl_ %if %sysevalf(%superq(reference)^=,boolean) %then %do; (ref="&_refval") %end;;
                model _event_(event='1') = _bylvl_ / clodds=wald;

                ods output parameterestimates=_log_p1 /*Covariate level p-values*/
                    cloddswald=_log_stat1 /*Odds ratios + CI*/
                    %if %sysevalf(9.04.01M2P072314 > &sysvlong,boolean) %then %do;/*Type 3 P-values*/
                        type3=_log_p2
                    %end;
                    %else %do;
                        modelanova=_log_p2
                    %end;;
                where _set_=1;
            run; 
        %end;
        %else %if &nby=1 %then %do;
            data _log_p1;
                do r=1 to &nrowby;
                    do c=1 to &ncolby;
                        _rowbylvl_=r;_colbylvl_=c;output;
                    end;
                end;
            run;
        %end;
        
        proc sql noprint;
            create table _log_stat as
                select a._colbylvl_,a._rowbylvl_,a._logvar_,a._set_,
                        %if %sysevalf(%superq(by)^=,boolean) %then %do;
                            a._bylvl_,
                        %end;
                        %else %do;
                            . as _bylvl_,
                        %end;
                    strip(put(a.n,12.0)) as n,strip(put(a.n*_bin_,12.0)) as events,strip(put(a.n*_bin_,12.0))||'/'||strip(put(a.n,12.0)) as events_n,
                    case (a._logvar_)
                        %do i = 1 %to &_nlogvars_;
                            when &i then
                                strip(strip(put(a._bin_*ifn(upcase("&log_binfmt")='PPT',1,100),12.%scan(&bindigits.,&i,|)))||ifc(upcase("&log_binfmt")='PPT',' (','% (')||
                                    %if %sysevalf(%qupcase(%superq(log_conftype))=BIN,boolean) %then %do;
                                        strip(put(a.l_bin*ifn(upcase("&log_binfmt")='PPT',1,100),12.%scan(&bindigits.,&i,|)))||'A0'x||'-'||'A0'x||
                                        strip(put(a.u_bin*ifn(upcase("&log_binfmt")='PPT',1,100),12.%scan(&bindigits.,&i,|)))||ifc(upcase("&log_binfmt")='PPT',')','%)')
                                    %end;
                                    %else %do;
                                        strip(put(a.xl_bin*ifn(upcase("&log_binfmt")='PPT',1,100),12.%scan(&bindigits.,&i,|)))||'A0'x||'-'||'A0'x||
                                        strip(put(a.xu_bin*ifn(upcase("&log_binfmt")='PPT',1,100),12.%scan(&bindigits.,&i,|)))||ifc(upcase("&log_binfmt")='PPT',')','%)')
                                    %end;)
                        %end; else '' end as BINRATE
                        %if &_log =1 %then %do;
                            ,case (a._logvar_)
                                %do i = 1 %to &_nlogvars_;
                                    when &i then
                                        ifc(a._set_=1 and missing(b.oddsratioest),'Reference',
                                            ifc(a._set_ in(2 3),'',strip(put(oddsratioest,12.%scan(&ordigits.,&i,|)))|| ' ('||
                                                                   strip(put(lowercl,12.%scan(&ordigits.,&i,|)))||'A0'x||'-'||'A0'x||
                                                                   strip(put(uppercl,12.%scan(&ordigits.,&i,|)))||')')) 
                                %end; else '' end as oddsratio,
                             ifc(a._set_=1 and missing(c.probchisq),'Reference',
                                ifc(a._set_ in(2 3),'',strip(put(c.probchisq,pvalue6.&pvaldigits.)))) as waldpval
                        %end;
                    from (select * from _log_stat2) a 
                    %if &_log =1 %then %do; 
                        left join _log_stat1 b
                        on a._colbylvl_=b._colbylvl_ and a._rowbylvl_=b._rowbylvl_ and a._logvar_=b._logvar_ and a._bylvl_=input(scan(b.effect,2,' '),12.)
                        left join _log_p1 c
                        on a._colbylvl_=c._colbylvl_ and a._rowbylvl_=c._rowbylvl_ and a._logvar_=c._logvar_ and a._bylvl_=input(c.classval0,12.)
                    %end;
                    order by _colbylvl_,_rowbylvl_,_logvar_,_set_,_bylvl_;
        quit;
        data _log_stat2;
            set _log_stat;
            length factor n_pct $100.;
            factor='N';n_pct=n;output;
            factor='Events';n_pct=events;output;
            factor='Events/N';n_pct=events_n;output;
            factor='Event Rate (95% CI)';n_pct=binrate;output;
            %if &_log=1 %then %do;
                factor='Odds Ratio (95% CI)';n_pct=oddsratio;output;
                factor='Wald P-value';n_pct=Waldpval;output;
            %end;
            keep _colbylvl_ _rowbylvl_  _logvar_ factor n_pct _bylvl_ _set_;
        run;
        proc sort data=_log_stat2;
            by _colbylvl_ _rowbylvl_  _logvar_ factor;
        data _log_stat3;
            merge _log_stat2 (where=(_bylvl_=. and _set_=3) rename=(n_pct=t_npct))
                  _log_stat2 (where=(_set_=ifn(&by_incmiss=0,2,1) %if &by_incmiss=1 %then %do; and _bylvl_=0 %end;) rename=(n_pct=m_npct))
                  %if %sysevalf(%superq(by)^=,boolean) %then %do j = 1 %to &nby;
                      _log_stat2 (where=(_bylvl_=&j and _set_=1) rename=(n_pct=b&j._npct))
                  %end;;
            by _colbylvl_ _rowbylvl_  _logvar_ factor;
            drop _bylvl_ _set_;
        run;
        proc datasets nolist nodetails;
            %if &debug=0 %then %do;
                delete _log _log_stat1 _log_stat2;
            %end;
        quit;
    %end;
    /**Insert statistics into output table**/
    %local _numindex _disindex _survindex _logindex k;
    %let _numindex=0;
    %let _disindex=0;
    %let _survindex=0;
    %let _logindex=0;
    %local k d;
    %let k=0;%let d=0;
    data _tester_;
        length rowby $100. rowbylvl 8. colby $100. colbylvl indent vartype vartypenum varnum varlevel header meta nby ncolby nrowby ptype 8.
            title footnote $2000. pfoot $1000. factor $2000.
            %if %sysevalf(%superq(by)^=,boolean) %then %do j = 1 %to &nby;
                b&j._npct 
            %end; 
            m_npct t_npct $100. pvaln 8. pvalfoot $100. null 8.;
        array _types_ {5} _temporary_;
        %do r = 1 %to &nrowby;
            %do c = 1 %to &ncolby;
                call missing(of _types_(*));
                factor=" ";
                rowbylvl=&r;
                rowby=put("%scan(%superq(_rowbylvls),&r,|,m)",$100.);
                indent=0;vartype=0;varnum=0;header=1;meta=0;varlevel=.r;ptype=.;
                colbylvl=&c;colby=put("%scan(%superq(_colbylvls),&c,|,m)",$100.);
                %if %sysevalf(%superq(by)^=,boolean) %then %do b = 1 %to %sysfunc(countw(%superq(_c&c._bylist)));
                    b%scan(%superq(_c&c._bylist),&b)_npct="(N=%superq(r&r._c&c._b%scan(%superq(_c&c._bylist),&b)_n))";
                %end;
                m_npct="(N=%superq(r&r._c&c._miss_n))";
                t_npct="(N=%superq(r&r._c&c._n))";
                if ^missing(rowby) then output _tester_;
                header=0;
                call missing(factor,m_npct,t_npct,pvaln,pvalfoot,null
                    %if %sysevalf(%superq(by)^=,boolean) %then %do j = 1 %to &nby;
                         ,b&j._npct
                    %end;);
                %let _logindex=0;
                %do i = 1 %to %sysfunc(countw(&var,%str( )));
                    %if %scan(&type,&i,%str( ))=5 %then %let _logindex=%sysevalf(&_logindex+1);
                    %if %sysevalf(%qscan(%superq(labels),&i,|,m)=,boolean) and %scan(&type,&i,%str( ))=5 %then %do;
                        factor="%superq(label&i) (Event=%superq(_log_event&_logindex))";
                    %end;
                    %else %do;
                        factor="%superq(label&i)"; 
                    %end;
                    varlevel=.l;varnum=&i;ptype=%scan(&pvals,&i,%str( ));vartype=%scan(&type,&i,%str( ));indent=0;
                    _types_(ifn(vartype in(1 3),1,vartype))+1;vartypenum=_types_(ifn(vartype in(1 3),1,vartype));
                    output _tester_;
                    ptype=.;indent=1;
                    %if %sysevalf(%scan(&type,&i,%str( ))^=2,boolean) %then %do;
                        %if &r=1 and &c=1 %then %do;
                           array _ndisplay_&i._ {&&_ndisplay_&i} $300. (
                             %do j = 1 %to &&_ndisplay_&i;
                                 %if &j>1 %then %do; , %end;
                                 "%superq(_display_&i._&j)"
                             %end;);
                        %end;
                        do i = 1 to dim(_ndisplay_&i._);         
                            factor=_ndisplay_&i._(i);varlevel=i;
                            
                            if ^(&nby=1 and ((vartype=4 and _ndisplay_&i._(i) in('Hazard Ratio (95% CI)' 'Wald P-value')) or
                                             (vartype=5 and _ndisplay_&i._(i) in('Odds Ratio (95% CI)' 'Wald P-value')))) then output _tester_;
                        end;
                        drop i _ndisplay_&i._:;
                    %end;
                    %else %if %sysevalf(%scan(&type,&i,%str( ))=2,boolean) %then %do;
                        %if &r=1 and &c=1 %then %do;
                          array _ndisplay_&i._ {&&_ndisplay_&i} $300. (
                             %do j = 1 %to &&_ndisplay_&i;
                                 %if &j>1 %then %do; , %end;
                                 "%superq(_display_&i._&j)"
                             %end;);
                        %end;
                        do i = 1 to dim(_ndisplay_&i._);         
                            factor=_ndisplay_&i._(i);
                            if i = 1 and upcase("&dis_missorder")='FIRST' then varlevel=0.5;
                            else if i=dim(_ndisplay_&i._) and upcase("&dis_missorder")='LAST' then varlevel=i-0.5;
                            else if upcase("&dis_missorder")='FIRST' then varlevel=i-1;
                            else varlevel=i;
                            output _tester_;
                        end;
                        drop i _ndisplay_&i._:;
                    %end;
                %end;
                call missing(rowby,rowbylvl,colby,colbylvl,indent,vartype,varnum,varlevel,header,
                    meta,nby,ncolby,nrowby,title,footnote,pfoot,factor,m_npct,t_npct,pvaln,pvalfoot,null
                    %if %sysevalf(%superq(by)^=,boolean) %then %do j = 1 %to &nby;
                         ,b&j._npct
                    %end;);
            %end;
        %end;
    run;
    proc sql noprint;
        create table _out as
          %if %sysevalf(%superq(rowby)^=,boolean) %then %do;
            select * from _tester_ where header=1
            outer union corr
          %end;
          %if %index(&type,1)>0 or %index(&type,3)>0 %then %do;
            select a.*,
                %if %sysevalf(%superq(by)^=,boolean) %then %do j = 1 %to &nby; b&j._npct, %end;
                m_npct, t_npct
            %if %sysevalf(%superq(nby)>1,boolean) and &nby_num_nomiss>1 %then %do;
                , case(a.ptype)
                     when 1 then p1.p_kw
                     %if &nby=2 and (&_nbymiss=0 or &by_incmiss=0) %then %do;
                         when 3 then p1.p2_wil
                     %end;
                     %if &_nexact=1 %then %do;
                         when 2 then p1e.p_kw
                         %if &nby=2 and &_nbymiss=0 %then %do;
                             when 4 then p1e.p2_wil
                         %end;
                     %end;
                     when 5 then p1.p_f
                     %if &nby =2 and &_nttest=1 %then %do;
                         when 6 then p2a.probt
                         when 7 then p2b.probt
                     %end;
                  else . end as pvaln
                , put(case(a.ptype)
                     when 1 then 'KW'
                     when 2 then 'EKW'
                     when 3 then 'W'
                     when 4 then 'EW'
                     when 5 then 'ANOVA'
                     when 6 then 'TE'
                     when 7 then 'TU'
                  else '' end,$100.) as pvalfoot
            %end;        
            %else %if %sysevalf(%superq(by)=,boolean) or &nby=1 %then %do;
                , case(a.ptype)
                     when 1 then p3.probt
                     when 2 then p3.probs
                  else . end as pvaln
                , put(case(a.ptype)
                     when 1 then 'ST'
                     when 2 then 'SR'
                  else '' end,$100.) as pvalfoot
            %end;
            from _tester_ (where=(varnum>0 and vartype in(1 3)) drop=%if %sysevalf(%superq(by)^=,boolean) %then %do j = 1 %to &nby; b&j._npct %end; m_npct t_npct pvaln pvalfoot null) a
                left join _num_stat3 b
                on a.colbylvl=b._colbylvl_ and a.rowbylvl=b._rowbylvl_ and a.vartypenum=b._numvar_ and a.factor=b.factor
                %if %sysevalf(%superq(nby)>1,boolean)  and &nby_num_nomiss>1 %then %do;
                    left join _num_p1 as p1 on a.colbylvl=p1._colbylvl_ and a.rowbylvl=p1._rowbylvl_ and a.vartypenum=p1._numvar_
                    %if &_nexact=1 %then %do;
                        left join _num_p1e as p1e on a.colbylvl=p1e._colbylvl_ and a.rowbylvl=p1e._rowbylvl_ and a.vartypenum=p1e._numvar_
                    %end;
                    %if &nby =2 and &_nttest=1 %then %do;
                        left join (select * from _num_p2 where variances='Equal') as p2a on a.colbylvl=p2a._colbylvl_ and a.rowbylvl=p2a._rowbylvl_ and a.vartypenum=p2a._numvar_
                        left join (select * from _num_p2 where variances='Unequal') as p2b on a.colbylvl=p2b._colbylvl_ and a.rowbylvl=p2b._rowbylvl_ and a.vartypenum=p2b._numvar_
                    %end;
                %end;
                %else %if %sysevalf(%superq(by)=,boolean) or &nby=1 %then %do;
                    left join _num_p3 as p3 on a.colbylvl=p3._colbylvl_ and a.rowbylvl=p3._rowbylvl_ and a.vartypenum=p3._numvar_
                %end;
             %if &_ndisvars_>0 or &_nsurvvars_>0 or &_nlogvars_>0 %then %do;
                 OUTER UNION CORR
             %end;
           %end;
           %if &_ndisvars_>0 %then %do;
            select a.*,
                %if %sysevalf(%superq(by)^=,boolean) %then %do j = 1 %to &nby; b.b&j._npct, %end;
                b.m_npct, b.t_npct
             %if %sysevalf(%superq(nby)>1,boolean) %then %do;
                , case(a.ptype)
                     when 1 then p1.p_pchi
                     %if &_dexact=1 %then %do;
                         when 2 then p2.xp2_fish
                     %end;
                     %if &_dtrend=1 %then %do;
                         when 3 then p3.p2_trend
                     %end;
                  else . end as pvaln
                , put(case(a.ptype)
                     when 1 then 'C'
                     %if &_dexact=1 %then %do;
                         when 2 then 'F'
                     %end;
                     %if &_dtrend=1 %then %do;
                         when 3 then 'CAT'
                     %end;
                  else '' end,$100.) as pvalfoot
            %end;       
            from _tester_ (where=(varnum>0 and vartype in(2)) drop=%if %sysevalf(%superq(by)^=,boolean) %then %do j = 1 %to &nby; b&j._npct %end; m_npct t_npct pvaln pvalfoot null) a
                left join _dis_stat3 b
                on a.colbylvl=b._colbylvl_ and a.rowbylvl=b._rowbylvl_ and a.vartypenum=b._disvar_ and ifn(a.varlevel^=int(a.varlevel) and a.varlevel>0,.m,a.varlevel)=ifn(b._dislvl_ in(.m 0),.m,b._dislvl_)
                %if %sysevalf(%superq(nby)>1,boolean) %then %do;
                    left join _dis_p1 as p1 on a.colbylvl=p1._colbylvl_ and a.rowbylvl=p1._rowbylvl_ and a.vartypenum=p1._disvar_
                    %if &_dexact=1 %then %do;
                        left join _dis_p2 as p2 on a.colbylvl=p2._colbylvl_ and a.rowbylvl=p2._rowbylvl_ and a.vartypenum=p2._disvar_
                    %end;
                    %if &_dtrend=1 %then %do;
                        left join _dis_p3 as p3 on a.colbylvl=p3._colbylvl_ and a.rowbylvl=p3._rowbylvl_ and a.vartypenum=p3._disvar_
                    %end;
                %end;
             %if &_nsurvvars_>0 or &_nlogvars_>0 %then %do;
                 OUTER UNION CORR
             %end;
           %end;
           %if &_nsurvvars_>0 %then %do;
            select a.*,
                %if %sysevalf(%superq(by)^=,boolean) %then %do j = 1 %to &nby; b.b&j._npct, %end;
                b.m_npct, b.t_npct
             %if %sysevalf(%superq(nby)>1,boolean) %then %do;
                , case(a.ptype)
                     when 1 then p1.probchisq
                     when 2 then p1b.probchisq
                     %if &_cox=1 %then %do;
                         when 3 then p2.probscorechisq
                         when 4 then p2.problrchisq
                         when 5 then p2.probchisq
                     %end;
                  else . end as pvaln
                , put(case(a.ptype)
                     when 1 then 'Logrank'
                     when 2 then 'Wilcoxon'
                     when 3 then 'Score'
                     when 4 then 'lr'
                     when 5 then 'Wald'
                  else '' end,$100.) as pvalfoot
            %end;       
            from _tester_ (where=(varnum>0 and vartype in(4)) drop=%if %sysevalf(%superq(by)^=,boolean) %then %do j = 1 %to &nby; b&j._npct %end; m_npct t_npct pvaln pvalfoot null) a
                left join _surv_stat_4 b
                on a.colbylvl=b._colbylvl_ and a.rowbylvl=b._rowbylvl_ and a.vartypenum=b._survvar_ and a.factor=b.factor
                %if %sysevalf(%superq(nby)>1,boolean) %then %do;
                    left join (select * from _surv_p1 where upcase(test)^="WILCOXON") as p1 on a.colbylvl=p1._colbylvl_ and a.rowbylvl=p1._rowbylvl_ and a.vartypenum=p1._survvar_
                    left join (select * from _surv_p1 where upcase(test)="WILCOXON") as p1b on a.colbylvl=p1b._colbylvl_ and a.rowbylvl=p1b._rowbylvl_ and a.vartypenum=p1b._survvar_
                    %if &_cox=1 %then %do;
                        left join _surv_p2 as p2 on a.colbylvl=p2._colbylvl_ and a.rowbylvl=p2._rowbylvl_ and a.vartypenum=p2._survvar_
                    %end;
                %end;
             %if &_nlogvars_>0 %then %do;
                 OUTER UNION CORR
             %end;
           %end;
           %if &_nlogvars_>0 %then %do;
            select a.*,
                %if %sysevalf(%superq(by)^=,boolean) %then %do j = 1 %to &nby; b.b&j._npct, %end;
                b.m_npct, b.t_npct
             %if %sysevalf(%superq(nby)>1,boolean) %then %do;
                , case(a.ptype)
                     %if &_log=1 %then %do;
                         when 1 then p2.probchisq
                     %end;
                     %else %do;
                         when 1 then p3.p_pchi
                         when 2 then p3.xp2_fish
                     %end;
                  else . end as pvaln
                , put(case(a.ptype)
                     %if &_log=1 %then %do;
                         when 1 then 'Wald'
                     %end;
                     %else %do;
                         when 1 then 'C'
                         when 2 then 'F'
                     %end;
                  else '' end,$100.) as pvalfoot
            %end;       
            from _tester_ (where=(varnum>0 and vartype in(5)) drop=%if %sysevalf(%superq(by)^=,boolean) %then %do j = 1 %to &nby; b&j._npct %end; m_npct t_npct pvaln pvalfoot null) a
                left join _log_stat3 b
                on a.colbylvl=b._colbylvl_ and a.rowbylvl=b._rowbylvl_ and a.vartypenum=b._logvar_ and a.factor=b.factor
                %if %sysevalf(%superq(nby)>1,boolean) %then %do;
                    left join _log_p3 as p3 on a.colbylvl=p3._colbylvl_ and a.rowbylvl=p3._rowbylvl_ and a.vartypenum=p3._logvar_
                    %if &_log=1 %then %do;
                        left join _log_p2 as p2 on a.colbylvl=p2._colbylvl_ and a.rowbylvl=p2._rowbylvl_ and a.vartypenum=p2._logvar_
                    %end;
                %end;
          %end;
             order by rowbylvl,colbylvl,varnum,varlevel;
    quit;    
    %do i = 1 %to 20;
        %local pfoot&i;
    %end;
    %local pfoot;
    %do c = 1 %to &ncolby;
        %do b = 1 %to &nby;
            %local c&c._b&b._switch;
        %end;
        %local c&c._m_switch c&c._t_switch;
    %end;
    %let npfoot=0;
    proc sort data=_out;
        by rowbylvl varnum varlevel colbylvl;
    run;

    data _out;
        set _out end=last;
        by rowbylvl varnum varlevel colbylvl;
        length factor_listing $2000.;
        %if %sysevalf(%superq(by)^=,boolean) %then %do b = 1 %to &nby;
            array _b&b._npct {&ncolby} $100. %do c = 1 %to &ncolby; c&c._b&b._npct %end;;
        %end;
        array _m_npct {&ncolby} $100. %do c = 1 %to &ncolby; c&c._m_npct %end;;
        array _t_npct {&ncolby} $100. %do c = 1 %to &ncolby; c&c._t_npct %end;;
        array plist (20) $20. _temporary_;
        array pvars (&ncolby) $100. %do i=1 %to &ncolby; c&i._pval %end;;
        array pvars_l (&ncolby) $100. %do i=1 %to &ncolby; c&i._pval_listing %end;;
        array ntotals (&ncolby) _temporary_;
        if first.varnum then call missing(of ntotals(*));
        
        retain %if %sysevalf(%superq(by)^=,boolean) %then %do b = 1 %to &nby;_b&b._npct %end;
            _m_npct _t_npct pvars pvars_l;
        
        if first.varlevel then 
            call missing(%if %sysevalf(%superq(by)^=,boolean) %then %do b = 1 %to &nby; of _b&b._npct(*), %end;
                         of _m_npct(*),of _t_npct(*),of pvars(*),of pvars_l(*));
                         
        %if %sysevalf(%superq(by)^=,boolean) %then %do b = 1 %to &nby;
            _b&b._npct(colbylvl)=b&b._npct;
        %end;
        _m_npct(colbylvl)=m_npct;
        _t_npct(colbylvl)=t_npct;
        if vartype=2 and varlevel=.l then do;
            if indent>0 then factor_listing=repeat('A0A0'x,indent-1)||strip(Factor)||"%superq(dis_suffix_listing)";
            else factor_listing=strip(factor)||"%superq(dis_suffix_listing)";
            factor=strip(factor)||"%superq(dis_suffix)";
        end;
        else do;
            if indent>0 then factor_listing=repeat('A0A0'x,indent-1)||strip(Factor);
            else factor_listing=strip(factor);
        end;
    
        if vartype=2 and ^missing(t_npct) then ntotals(colbylvl)=input(scan(compress(t_npct,'%'),1,' '),12.);
            
        if ^missing(pvaln) then do;
            if &pfoot then do;
                if ^missing(pvalfoot) then do j = 1 to dim(plist);
                    if missing(plist(j)) or pvalfoot = plist(j) then do;
                        if missing(plist(j)) then plist(j)=pvalfoot;
                        pvars(colbylvl)=strip(put(pvaln,pvalue6.&pvaldigits))||'^{super '||strip(put(j,12.0))||'}';
                        pvars_l(colbylvl)=strip(put(pvaln,pvalue6.&pvaldigits))||repeat('*',j-1);
                        j=dim(plist);
                    end;
                end;
            end;
            else do;
                pvars(colbylvl)=strip(put(pvaln,pvalue6.&pvaldigits));
                pvars_l(colbylvl)=strip(put(pvaln,pvalue6.&pvaldigits));
            end;
        end;
        if last.varlevel then do;
            if vartype=2 and nmiss(of ntotals(*)) < dim(ntotals) then do;
                /*If No missing and dis_printmiss ^=2 then should delete
                  If dis_incmiss=1 and No missing then delete
                  If dis_printmiss=0 and dis_incmiss=1 and No missing then delete*/
                if &dis_printmiss^=2 then do;
                    if sum(of ntotals(*))=0 and varlevel^=.l and int(varlevel)^=varlevel then del=1;
                    else if sum(of ntotals(*))>0 and &dis_printmiss=0 and &dis_incmiss=0 and varlevel^=.l and int(varlevel)^=varlevel then del=1;
                    else output;
                end;
                else output;
            end;
            else output;
            %if %sysevalf(%qupcase(%superq(split))=SPACE,boolean) %then %do;
                call missing(factor,factor_listing,
                            %if %sysevalf(%superq(by)^=,boolean) %then %do j = 1 %to &nby;of _b&j._npct(*), %end;
                            of _m_npct(*),of _t_npct(*),of pvars(*),of pvars_l(*));
                if ^last and varlevel^=.r and last.varnum and missing(rowby) then output;
            %end;
        end;
        if last then do;
            do i = 1 to dim(plist)-cmiss(of plist(*));
                call symput('pfoot'||strip(put(i,12.0)),strip(plist(i)));
            end;
            call symput('npfoot',strip(put(dim(plist)-cmiss(of plist(*)),12.0)));
            /*Meta-data for table*/
            call missing(factor,factor_listing,rowby,
                %if %sysevalf(%superq(by)^=,boolean) %then %do j = 1 %to &nby;of _b&j._npct(*), %end;
                of _m_npct(*),of _t_npct(*),of pvars(*),of pvars_l(*));
            rowbylvl=0;varnum=0;meta=1;nby=&nby;ncolby=&ncolby;nrowby=&nrowby;varlevel=0;indent=.;vartype=.;
            title=strip("&title");footnote="&footnote";
            %do c = 1 %to &ncolby;
                %if %sysevalf(%superq(by)^=,boolean) %then %do b = 1 %to &nby;
                    c&c._b&b._npct=ifc(max(%do r = 1 %to &nrowby; %superq(r&r._c&c._b&b._n), %end; 0)>0,'1','0');
                    call symput("c&c._b&b._switch",strip(c&c._b&b._npct));
                %end;
                c&c._m_npct=ifc(max(%do r = 1 %to &nrowby; %superq(r&r._c&c._miss_n), %end; 0)>0,'1','0');
                call symput("c&c._m_switch",strip(c&c._m_npct));
                c&c._t_npct=ifc(max(%do r = 1 %to &nrowby; %superq(r&r._c&c._n), %end; 0)>0,'1','0');
                call symput("c&c._t_switch",strip(c&c._t_npct));
            %end;
            output;
        end;
        keep rowby--factor factor_listing
            %do c = 1 %to &ncolby;
                %if %sysevalf(%superq(by)^=,boolean) %then %do b = 1 %to %sysfunc(countw(%superq(_c&c._bylist)));
                   c&c._b%scan(%superq(_c&c._bylist),&b)_npct
                %end;
                c&c._m_npct c&c._t_npct c&c._pval c&c._pval_listing
            %end;;
        drop colby colbylvl;
    run;   
    proc sql noprint;
        %local pfoot npfoot maxsublength;
        select max(length(factor)) into :maxsublength separated by ''
            from _out;
        alter table _out
            modify factor char(&maxsublength);
        /*Meta-data for table*/
        update _out
            set pfoot=catx(' ',
                    %do i = 1 %to &npfoot;
                       %if %sysevalf(%superq(pfoot&i)=KW,boolean) %then %do;
                           "^{super &i}Kruskal-Wallis p-value; ", 
                       %end;
                       %else %if %sysevalf(%superq(pfoot&i)=EKW,boolean) %then %do;
                           "^{super &i}Exact Kruskal-Wallis p-value; ", 
                       %end;
                       %else %if %sysevalf(%superq(pfoot&i)=W,boolean) %then %do;
                           "^{super &i}Wilcoxon rank sum p-value; ", 
                       %end;
                       %else %if %sysevalf(%superq(pfoot&i)=EW,boolean) %then %do;
                           "^{super &i}Exact Wilcoxon rank sum p-value; ", 
                       %end;
                       %else %if %sysevalf(%superq(pfoot&i)=ANOVA,boolean) %then %do;
                           "^{super &i}ANOVA F-test p-value; ", 
                       %end;
                       %else %if %sysevalf(%superq(pfoot&i)=TE,boolean) %then %do;
                           "^{super &i}Equal variance two sample t-test; ", 
                       %end;
                       %else %if %sysevalf(%superq(pfoot&i)=TU,boolean) %then %do;
                           "^{super &i}Unequal variance two sample t-test; ", 
                       %end;
                       %else %if %sysevalf(%superq(pfoot&i)=ST,boolean) %then %do;
                           "^{super &i}Student T-Test; ", 
                       %end;
                       %else %if %sysevalf(%superq(pfoot&i)=SR,boolean) %then %do;
                           "^{super &i}Sign Rank; ", 
                       %end;
                       %else %if %sysevalf(%superq(pfoot&i)=C,boolean) %then %do;
                           "^{super &i}Chi-Square p-value; ", 
                       %end;
                       %else %if %sysevalf(%superq(pfoot&i)=F,boolean) %then %do;
                           "^{super &i}Fisher Exact p-value; ", 
                       %end;
                       %else %if %sysevalf(%superq(pfoot&i)=CAT,boolean) %then %do;
                           "^{super &i}Cochran-Armitage trend test; ", 
                       %end;
                       %else %if %sysevalf(%qupcase(%superq(pfoot&i))=LOGRANK,boolean) %then %do;
                           "^{super &i}Logrank p-value; ", 
                       %end;
                       %else %if %sysevalf(%qupcase(%superq(pfoot&i))=WILCOXON,boolean) %then %do;
                           "^{super &i}Wilcoxon p-value; ", 
                       %end;
                       %else %if %sysevalf(%qupcase(%superq(pfoot&i))=SCORE,boolean) %then %do;
                           "^{super &i}Type-3 score p-value; ", 
                       %end;
                       %else %if %sysevalf(%qupcase(%superq(pfoot&i))=LR,boolean) %then %do;
                           "^{super &i}Type-3 likelihood-ratio p-value; ", 
                       %end;
                       %else %if %sysevalf(%qupcase(%superq(pfoot&i))=WALD,boolean) %then %do;
                           "^{super &i}Type-3 Wald p-value; ", 
                       %end;
                   %end;
                   " ")
           where meta=1;
        select pfoot
            into :pfoot separated by ''
            from _out where meta=1;
    quit;
    %if &_rtf=1 %then %do; 
        ODS RTF SELECT ALL;
        ODS SELECT NONE;
    %end;
    /**Run-time Errors are sent there to delete temporary datasets before being sent to 
    errhandl, which stops the macro**/
    %errhandl2:
    proc datasets nolist nodetails;
        %if &debug=0 %then %do;
            delete _num_stat _num_statm _num_stat2 _num_stat3 _dis_stat _dis_stat2 _dis_stat3 _combined _tester_ _numeric _discrete _dis_p1 _dis_p2 _dis_p3  _num_p1  _num_p2 _num_p3 _combined
                _surv_stat1 _surv_stat1a _surv_stat2 _surv_stat2a _surv_stat3 _surv_stat3a _surv_stat4 _surv_p1 _surv_p2 _survival
                _surv_stat1m _surv_stat2m _surv_stat3m _surv_stat _surv_stat_tl _surv_stat_2 _surv_stat_3 _surv_stat_4 _surv_stat_tl2
                _dis_stat_final _dis_stat_missings
                _log _log_stat _log_stat2 _log_stat3 _log_p1 _log_p2 _log_p3; 
        %end;
    quit;
    /**If errors occurred then throw message and end macro**/
    %if &nerror_run > 0 %then %do;
        %put ERROR: &nerror_run run-time errors listed;
        %put ERROR: Macro TABLEN will cease;           
        %goto errhandl;
    %end;
    
    options orientation=&orientation;
    ods path WORK.TEMPLAT(UPDATE) SASHELP.TMPLMST (READ);
    proc template;
        %if %superq(borderdisplay)=1 %then %do;
            define style _tablen;
                parent=styles.rtf;
                style Table /
                   color=black
                   cellpadding = 0
                   borderspacing = 0
                   cellspacing=0
                   frame = void
                   rules = groups
                   bordercollapse = separate
                   borderleftstyle = none
                   borderrightstyle = none
                   bordertopstyle = none
                   borderbottomstyle = none
                    fontfamily="&font" ;
                style Header /
                   color=black
                   backgroundcolor = white
                   bordercolor = white
                   borderstyle = none
                    fontfamily="&font" ;
                style Data /
                   color=black
                   backgroundcolor = white
                   bordercolor = white
                   borderstyle = none
                    fontfamily="&font" ;
                End;
            define style _tablenppt;
                parent=styles.powerpointlight;
                class Header / 
                    background=white 
                    fontsize=&headersize 
                    color=black 
                    fontfamily="&font" 
                    fontweight=&headerweight 
                    vjust=bottom 
                    borderstyle=solid 
                    bordercolor=black 
                    borderwidth=0.1 ;
                class Data / 
                    background=white 
                    fontsize=&datasize 
                    color=black 
                    fontfamily="&font" 
                    fontweight=&dataweight 
                    vjust=top
                    borderstyle=hidden;
                class linecontent / 
                    background=white 
                    fontsize=&datasize 
                    color=black 
                    fontfamily="&font" 
                    fontweight=&dataweight
                    borderstyle=solid 
                    bordercolor=black 
                    borderwidth=0.1;
                class Table / 
                    color=black 
                    cellpadding=0 
                    borderspacing=0 
                    cellspacing=0 
                    frame=void 
                    rules=rows 
                    borderstyle=solid 
                    bordercolor=black 
                    borderwidth=0.1pt;
            End;
        %end;
        %else %if %superq(borderdisplay)=2 %then %do;
            define style _tablen;
                parent=styles.rtf;
                style Table /
                   color=black
                   cellpadding = 0
                   borderspacing = 0
                   cellspacing=0
                   frame = box
                   rules = all
                   bordercollapse = separate
                   borderleftstyle = solid
                   borderrightstyle = solid
                   bordertopstyle = solid
                   borderbottomstyle = solid
                   fontfamily="&font"  
                   borderwidth=0.1
                   bordercolor=black;
                style Header /
                   color=black
                   backgroundcolor = white
                   bordercolor = white
                   borderstyle = solid  
                   borderwidth=0.1
                   bordercolor=black
                    fontfamily="&font" ;
                style Data /
                   color=black
                   backgroundcolor = white
                   bordercolor = white
                   borderstyle = solid  
                   borderwidth=0.1
                   bordercolor=black
                    fontfamily="&font" ;
            End;
            define style _tablenppt;
                parent=styles.powerpointlight;
                class Header / 
                    background=white 
                    fontsize=&headersize 
                    color=black 
                    fontfamily="&font" 
                    fontweight=&headerweight 
                    vjust=bottom 
                    borderstyle=solid 
                    bordercolor=black 
                    borderwidth=0.1 ;
                class Data / 
                    background=white 
                    fontsize=&datasize 
                    color=black 
                    fontfamily="&font" 
                    fontweight=&dataweight 
                    vjust=top
                    borderstyle=solid 
                    bordercolor=black 
                    borderwidth=0.1;
                class linecontent / 
                    background=white 
                    fontsize=&datasize 
                    color=black 
                    fontfamily="&font" 
                    fontweight=&dataweight
                    borderstyle=solid 
                    bordercolor=black 
                    borderwidth=0.1;
                class Table / 
                    color=black 
                    cellpadding=0 
                    borderspacing=0 
                    cellspacing=0 
                    frame=box 
                    rules=all 
                    borderstyle=solid 
                    bordercolor=black 
                    borderwidth=0.1pt;
            End;
        %end;
        %else %if %superq(borderdisplay)=3 or %superq(borderdisplay)=4 %then %do;
            define style _tablen;
                parent=styles.rtf;
                style Table /
                   color=black
                   cellpadding = 0
                   borderspacing = 0
                   cellspacing=0
                   frame = void
                   rules = all
                   bordercollapse = separate
                   borderleftstyle = solid
                   borderrightstyle = solid
                   bordertopstyle = none
                   borderbottomstyle = none
                   fontfamily="&font"  
                   borderwidth=0.1
                   bordercolor=black;
                style Header /
                   color=black
                   backgroundcolor = white
                   bordercolor = white
                   borderstyle = solid  
                   borderwidth=0.1
                   bordercolor=black
                   bordercollapse = separate
                   borderleftstyle = solid
                   borderrightstyle = solid
                   bordertopstyle = solid
                   borderbottomstyle = solid
                   borderwidth=0.1
                   bordertopwidth=0.1
                   borderbottomwidth=0.1
                   borderleftwidth=0.1
                   borderrightwidth=0.1
                   bordercolor=black
                   borderleftcolor=black
                   borderrightcolor=black
                   bordertopcolor=black
                   borderbottomcolor=black
                    fontfamily="&font" ;
                style Data /
                   color=black
                   backgroundcolor = white
                   bordercolor = white
                   borderstyle = solid  
                   bordercollapse = separate
                   borderleftstyle = solid
                   borderrightstyle = solid
                   bordertopstyle = solid
                   borderbottomstyle = solid
                   borderwidth=0.1
                   bordertopwidth=0.1
                   borderbottomwidth=0.1
                   borderleftwidth=0.1
                   borderrightwidth=0.1
                   bordercolor=black
                   borderleftcolor=black
                   borderrightcolor=black
                   bordertopcolor=black
                   borderbottomcolor=black
                    fontfamily="&font" ;
            End;
            define style _tablenppt;
                parent=styles.powerpointlight;
                class Header / 
                    background=white 
                    fontsize=&headersize 
                    color=black 
                    fontfamily="&font" 
                    fontweight=&headerweight 
                    vjust=bottom 
                    borderstyle=solid 
                    bordercolor=black 
                    borderwidth=0.1 ;
                class Data / 
                    background=white 
                    fontsize=&datasize 
                    color=black 
                    fontfamily="&font" 
                    fontweight=&dataweight 
                    vjust=top
                    borderstyle=solid 
                    bordercolor=black 
                    borderwidth=0.1;
                class linecontent / 
                    background=white 
                    fontsize=&datasize 
                    color=black 
                    fontfamily="&font" 
                    fontweight=&dataweight
                    borderstyle=solid 
                    bordercolor=black 
                    borderwidth=0.1;
                class Table / 
                    color=black 
                    cellpadding=0 
                    borderspacing=0 
                    cellspacing=0 
                    frame=box 
                    rules=all 
                    borderstyle=solid 
                    bordercolor=black 
                    borderwidth=0.1pt;
            End;
        %end;
    run;
    %if %sysevalf(%superq(outdoc)^=,boolean) %then %do;
        %if %qupcase(&destination)=HTML %then %do;
            ods &destination style=_tablen
                %if %upcase(&sysscpl)=LINUX or %upcase(&sysscpl)=UNIX %then %do;
                    path="%substr(&outdoc,1,%sysfunc(find(&outdoc,/,-%sysfunc(length(&outdoc)))))"
                    file="%scan(&outdoc,1,/,b)"
                %end;
                %else %do;
                    path="%substr(&outdoc,1,%sysfunc(find(&outdoc,\,-%sysfunc(length(&outdoc)))))"
                    file="%scan(&outdoc,1,\,b)"
                %end;;
        %end;
        %else %do;
            ods &destination file="&outdoc" style=_tablen;
        %end;
    %end;
    proc sql noprint;
        %local _listing _ppt _other _html _destinations _styles k pfoot_list _rtf _rtf2;
        %let _rtf2=_rtf;
        select max(ifn(upcase(destination)='LISTING',1,0)),
            max(ifn(upcase(destination) in('HTML'),1,0)),
            max(ifn(upcase(destination) ^in('LISTING' 'OUTPUT' 'POWERPOINT' 'RTF' 'HTML'),1,0)),
            max(ifn(upcase(destination) in('POWERPOINT'),1,0)),
            max(ifn(upcase(destination) in('RTF'),1,0))
            into :_listing separated by '',:_html separated by '',:_other separated by '',:_ppt separated by '',:_rtf separated by '' from sashelp.vdest;
        select upcase(destination),upcase(style) into :_destinations separated by '|',:_styles separated by '|'
            from sashelp.vdest
            where upcase(destination)^in('OUTPUT' 'LISTING');
        %do i = 1 %to &npfoot;
            %if &i=1 %then %let pfoot_list=%sysfunc(tranwrd(%qscan(%superq(pfoot),&i,%str(;)),^{super &i},%sysfunc(repeat(*,&i-1))));
            %else %let pfoot_list=&pfoot_list%str(;)%sysfunc(tranwrd(%qscan(%superq(pfoot),&i,%str(;)),^{super &i},%sysfunc(repeat(*,&i-1))));
        %end;
    quit;
    ods results;  
    ods select all;
    ods escapechar='^';
    %if &_listing = 1 %then %do;
        %do i = 1 %to %sysfunc(countw(%superq(_destinations),|));
            ods %scan(%superq(_destinations),&i,|) select none;
        %end;
        data _out_listing;
            set _out (where=(meta^=1));
            array _chars_ (*) $2000. _character_;      
            do i = 1 to dim(_chars_);
                _chars_(i)='A0A0A0'x||strip(_chars_(i));
            end;
            drop factor 
                %do c=1 %to &ncolby;
                    c&c._pval
                %end;;
            rename factor_listing=factor 
                %do c=1 %to &ncolby;
                    c&c._pval_listing=c&c._pval
                %end;;
        run;
        proc contents data=_out_listing noprint out=_outldict;
        run;
        
        proc sql noprint;
            %local _list_cvars;
            select upcase(name) into :_list_cvars separated by '|' from _outldict where type=2;
            %do i = 1 %to %sysfunc(countw(%superq(_list_cvars),|,m));
                %local _list_%scan(%superq(_list_cvars),&i,|,m);
            %end;
            select %do i = 1 %to %sysfunc(countw(%superq(_list_cvars),|,m)); 
                      %if &i>1 %then %do; , %end;
                      max(length(strip(%scan(%superq(_list_cvars),&i,|,m))))
                   %end;
                   into %do i = 1 %to %sysfunc(countw(%superq(_list_cvars),|,m)); 
                            %if &i>1 %then %do; , %end;
                            :_list_%scan(%superq(_list_cvars),&i,|,m) separated by ''
                        %end;
                   from _out_listing;
                   
            %local _list_totlength;
            %let _list_totlength=0;
            %do i = 1 %to &ncolby;
                %local _list_c&i._totlength;
                %if &i=1 %then %let _list_c&i._totlength=0;
                %if %sysevalf(%superq(by)^=,boolean) %then %do;
                    %do b = 1 %to %sysfunc(countw(%superq(_c&i._bylist),%str( )));
                        %let _list_c&i._b%scan(%superq(_c&i._bylist),&b)_npct=%sysfunc(max(%length(%qscan(%superq(_bylvls),%qscan(%superq(_c&i._bylist),&b),|,m))+2,
                            %length((N=%superq(r1_c&i._b%scan(%superq(_c&i._bylist),&b)_n)))+2,%superq(_list_c&i._b%scan(%superq(_c&i._bylist),&b)_npct)+2));
                        %if %sysevalf(%superq(c&i._b%scan(%superq(_c&i._bylist),&b)_switch)=1,boolean) %then
                            %let _list_c&i._totlength=%sysevalf(&&_list_c&i._totlength + %superq(_list_c&i._b%scan(%superq(_c&i._bylist),&b)_npct));
                    %end;
                    
                    %let _list_c&i._m_npct=%sysfunc(max(%length(Missing)+2,%length((N=%superq(r1_c&i._miss_n)))+2,%superq(_list_c&i._m_npct)+2));
                    %if &by_printmiss =2 or (%sysevalf(%superq(c&i._m_switch)=1,boolean) and (&by_incmiss=1 or &by_printmiss=1)) %then 
                        %let _list_c&i._totlength=%sysevalf(&&_list_c&i._totlength + %superq(_list_c&i._m_npct));
                %end;    
                
                %let _list_c&i._t_npct=%sysfunc(max(%length(Total)+2,%length((N=%superq(r1_c&i._n)))+2,%superq(_list_c&i._t_npct)+2));
                %if &showtotal=1 or %sysevalf(%superq(by)=,boolean) %then 
                    %let _list_c&i._totlength=%sysevalf(&&_list_c&i._totlength + %superq(_list_c&i._t_npct));
                       
                %let _list_c&i._pval=%sysfunc(max(%length(P-value)+2,%superq(_list_c&i._pval)+2));
                %if (&showpval=1 and &nby>1) or &showpval=2 %then 
                    %let _list_c&i._totlength=%sysevalf(&&_list_c&i._totlength + %superq(_list_c&i._pval));
                    
                %let _list_totlength=%sysevalf(&&_list_c&i._totlength + &_list_totlength); 
                %if &i ^= &ncolby %then %let _list_totlength=%sysevalf(&_list_totlength + 4); 
            %end;
            
            %if %sysevalf(%superq(rowby)^=,boolean) %then %do;
                %let _list_rowby=%sysfunc(max(%length(%superq(rowbylabel))+2,%superq(_list_rowby)+2));
                %let _list_totlength=%sysevalf(&_list_rowby + &_list_totlength);  
            %end;
            %let _list_factor=%sysevalf(&_list_factor+2);
            %let _list_totlength=%sysevalf(&_list_totlength + &_list_factor);
             
            alter table _out_listing
                modify %do i = 1 %to %sysfunc(countw(%superq(_list_cvars),|,m)); 
                            %if &i>1 %then %do; , %end;
                            %scan(%superq(_list_cvars),&i,|,m) char(%superq(_list_%scan(%superq(_list_cvars),&i,|,m)))
                        %end;;  
        quit;
        options linesize=%sysfunc(max(64,%sysfunc(min(256,&_list_totlength)))) nocenter;
        proc report data=_out_listing nowd split='~' spanrows spacing=0 missing;
            columns 
                /*Table Title*/
                ("%sysfunc(tranwrd(%superq(title),`,~))~%sysfunc(repeat(-,&_list_totlength-1))"
                     /*Variables for later*/
                    (rowby varnum varlevel header meta factor)
                    /*Start COLBY Label*/
                    %if %sysevalf(%superq(colby)^=,boolean) and %sysevalf(%superq(showcollabel)=1,boolean) %then %do;
                        ("&colbylabel"
                    %end;
                        %do c = 1 %to &ncolby;
                           /*Add a space between COLBY levels*/
                           %if &c>1 %then %do; 
                                (dummy&c) 
                           %end;
                           /*Add Column level headers*/
                           %if %sysevalf(%superq(colby)^=,boolean) %then %do;
                              ("%scan(%superq(_colbylvls),&c,|,m)~%sysfunc(repeat(-,&&_list_c&c._totlength-1))"
                           %end;   
                               /*Print BY variable headers*/
                               %if %sysevalf(%superq(by)^=,boolean) %then %do;
                                    %if %sysevalf(%superq(showbylabel)=1,boolean) %then %do; ("&bylabel" %end;
                                    c&c._m_npct 
                               %end;
                                   /*Print result variables*/
                                   %if %sysevalf(%superq(by)^=,boolean) %then %do b = 1 %to %sysfunc(countw(%superq(_c&c._bylist)));
                                       c&c._b%scan(%superq(_c&c._bylist),&b)_npct
                                   %end;
                                   %if %sysevalf(%superq(showbylabel)=1,boolean) and %sysevalf(%superq(by)^=,boolean) %then %do; ) %end;
                                   c&c._t_npct   
                               /*Print P-value and close By Header parenthasis*/  
                               %if (%sysevalf(%superq(by)^=,boolean)  and &nby>1) or &showpval=2 %then %do;
                                   c&c._pval
                               %end;      
                           /*Close COLBY header parenthases*/          
                           %if %sysevalf(%superq(colby)^=,boolean) %then %do;
                              )
                           %end;
                        /*End C loop*/     
                        %end;  
                    /*Close COLBY Label parenthases*/          
                    %if %sysevalf(%superq(colby)^=,boolean) and %sysevalf(%superq(showcollabel)=1,boolean) %then %do;
                        )
                    %end;
                /*Closes title parenthases*/    
                );
    
            /*Subtitle*/
            define factor / display "&subtitleheader~%sysfunc(repeat(-,&_list_factor-1))" id;
            /*Set up indent for compute block*/    
            define varnum / order order=data noprint;/*NOPRINT initializes variable without printing.  Can still refer to it*/
            compute before varnum;
                %if %qupcase(&split)=LINE %then %do;
                    x="%sysfunc(repeat(-,&_list_totlength-1))";
                    if varnum in(0 1) then len=0;
                    else len=length(x);
                    line @1 x $varying. len;
                %end;
                %if %sysevalf(%superq(rowby)^=,boolean) %then %do;
                    x="%sysfunc(repeat(-,&_list_totlength-1))";
                    if varnum ^=1 then len2=0;
                    else len2=length(x);
                    line @1 x $varying. len2;
                %end;
            endcomp;
            define varlevel / display noprint;/*NOPRINT initializes variable without printing.  Can still refer to it*/
            define header / display noprint;/*NOPRINT initializes variable without printing.  Can still refer to it*/
            define meta / display noprint;/*NOPRINT initializes variable without printing.  Can still refer to it*/
             
            /*Set up whether ROWBY is shown or not*/
            %if %sysevalf(%superq(rowby)^=,boolean) %then %do;
                define rowby / order order=data "&rowbylabel~%sysfunc(repeat(-,&_list_rowby-1))" missing id;
                compute before rowby;
                    line @1 "%sysfunc(repeat(-,&_list_totlength-1))";
                endcomp;
                %end;
            %else %do;
                define rowby / order order=data noprint missing;/*NOPRINT initializes variable without printing.  Can still refer to it*/
                %end;
            
            /*Print each Column Subgroup analysis*/
            %do c = 1 %to &ncolby; 
                /*If BY variable present, print all subgroup distributions*/
                %if %sysevalf(%superq(by)^=,boolean) %then %do b = 1 %to %sysfunc(countw(%superq(_c&c._bylist)));
                    define c&c._b%scan(%superq(_c&c._bylist),&b)_npct / display  center
                        %if %sysevalf(%superq(rowby)=,boolean) %then %do;
                            "%scan(%superq(_bylvls),%scan(%superq(_c&c._bylist),&b),|,m)~(N=%superq(r1_c&c._b%scan(%superq(_c&c._bylist),&b)_n))~%sysfunc(repeat(-,%superq(_list_c&c._b%scan(%superq(_c&c._bylist),&b)_npct)-1))" 
                        %end;
                        %else %do;
                            "%scan(%superq(_bylvls),%scan(%superq(_c&c._bylist),&b),|,m)~%sysfunc(repeat(-,%superq(_list_c&c._b%scan(%superq(_c&c._bylist),&b)_npct)-1))" 
                        %end;                    
                        %if %sysevalf(%superq(c&c._b%scan(%superq(_c&c._bylist),&b)_switch)=0,boolean) %then %do; noprint %end;;
                %end;         
                /*Print distribution across missing by group*/
                %if %sysevalf(%superq(by)^=,boolean) %then %do; 
                    define c&c._m_npct / display
                        %if %sysevalf(%superq(rowby)=,boolean) %then %do; 
                            "Missing~(N=%superq(r1_c&c._miss_n))~%sysfunc(repeat(-,&&_list_c&c._m_npct-1))" 
                        %end;
                        %else %do; 
                            "Missing~%sysfunc(repeat(-,&&_list_c&c._m_npct-1))" 
                        %end;                    
                        center 
                        %if &by_printmiss ^=2 %then %do;/*Value if 2 tells SAS to always print the missing column even if no values*/
                            %if %sysevalf(%superq(c&c._m_switch)=0,boolean) %then %do; noprint %end; /*No values in the missing column*/
                            %else %if &by_incmiss=0 and &by_printmiss=0 %then %do; noprint %end; /*If there are missing values, but requested to be suppressed and not included as a value of by*/
                        %end;;
                %end;
                /*Print distribution across all patients*/
                define c&c._t_npct / display
                    %if %sysevalf(%superq(rowby)=,boolean) %then %do; 
                        "Total~(N=%superq(r1_c&c._n))~%sysfunc(repeat(-,&&_list_c&c._t_npct-1))" 
                    %end;
                    %else %do; 
                        "Total~%sysfunc(repeat(-,&&_list_c&c._t_npct-1))" 
                    %end;                    
                    center
                    %if &showtotal=0 and %sysevalf(%superq(by)^=,boolean) %then %do; noprint %end;; /*Overrides SHOWTOTAL when no BY variable specified*/
                /*Print P-values if BY variable specified*/
                %if (%sysevalf(%superq(by)^=,boolean) and &nby>1) or &showpval=2 %then %do;
                    define c&c._pval / display "P-value~%sysfunc(repeat(-,&&_list_c&c._pval-1))" center style={cellwidth=&pvalwidth} 
                        %if &showpval=0 %then %do; noprint %end;;/*NOPRINT initializes variable without printing.  Can still refer to it*/
                %end;
                /*Sets up DUMMY variable to create space between column headers*/
                %if &c>1 %then %do;
                    define dummy&c / computed " ~%sysfunc(repeat(-,4-1))" width=4;
                %end;
            %end;
            /*Print p-values and footnotes after table*/
            compute after / style={just=l};
                line @1 "%sysfunc(repeat(-,&_list_totlength-1))";
               /*Prints p-value footnotes*/
               %if (&showpval=2 or (&showpval=1 and %sysevalf(%superq(by)^=,boolean))) and &npfoot>0 %then %do; 
                   line  @4 "&pfoot_list";
               %end;
               /*Print Footnotes*/
               %do i = 1 %to %sysfunc(max(1,%sysfunc(countw(%superq(footnote),`,m))));
                   line @4 "%scan(%superq(footnote),&i,`,m) ";
               %end;
           endcomp;
           where meta^=1;
        run;           
        options &_center;
        proc datasets nolist nodetails;
            %if &debug=0 %then %do;
                delete _outldict _out_listing ;
            %end;
        quit;
        ods select all;
    %end;
    %if &_other = 1 or &_ppt = 1 or &_rtf=1 or &_html=1 or %sysevalf(%superq(outdoc)^=,boolean) %then %do;
        %if &_listing=1 %then %do;
            ODS LISTING CLOSE;
        %end;
        %do k = 1 %to %sysfunc(countw(%superq(_destinations),|));
            %if %sysevalf(%qupcase(%qscan(%superq(_destinations),&k,|))=POWERPOINT,boolean) %then %do;
                ods powerpoint style=_tablenppt;
            %end;
            %else %if %sysevalf(%qupcase(%qscan(%superq(_destinations),&k,|))=EXCEL,boolean) %then %do;
                ods excel options(sheet_name="&excel_sheetname" frozen_rowheaders="%sysevalf(1+%sysevalf(%superq(rowby)^=,boolean))"
                    frozen_headers="%sysevalf(%sysevalf(%superq(colby)^=,boolean)*(1+&showcollabel) + 
                                              %sysevalf(%superq(by)^=,boolean)*(&showbylabel) + 2)") style=_tablen;
            %end;
            %else %if %sysevalf(%qupcase(%qscan(%superq(_destinations),&k,|))^=RTF,boolean) %then %do;
                ods %scan(%superq(_destinations),&k,|) style=_tablen;
            %end;
        %end;
        %local _rloop;
        %if &_other=1 %then %let _rloop=OTHER;
        %if &_ppt=1 and %sysevalf(%superq(_rloop)=,boolean) %then %let _rloop=PPT;
        %else %if &_ppt=1 %then %let _rloop=&_rloop|PPT;
        %if &_rtf=1 and %sysevalf(%superq(_rloop)=,boolean) %then %let _rloop=RTF;
        %else %if &_rtf=1 %then %let _rloop=&_rloop|RTF;
        %if &_HTML=1 and %sysevalf(%superq(_rloop)=,boolean) %then %let _rloop=HTML;
        %else %if &_HTML=1 %then %let _rloop=&_rloop|HTML;
        %do rloop = 1 %to %sysfunc(countw(&_rloop,|));
            %if %sysevalf(%scan(%superq(_rloop),&rloop,|)=OTHER,boolean) %then %do;
                %if &_ppt=1 %then %do;
                    ods POWERPOINT exclude all;
                %end;
                %if &_rtf=1 %then %do;
                    ods RTF exclude all;
                %end;
                %if &_html=1 %then %do;
                    ods HTML exclude all;
                %end;
            %end;
            %else %if %sysevalf(%scan(%superq(_rloop),&rloop,|)=RTF,boolean) %then %do;
                ods RTF select all;
                %if %sysevalf(%qupcase(&orientation)^=%qupcase(&_orientation),boolean) %then %do;
                    ods rtf;
                %end;
                %do k = 1 %to %sysfunc(countw(%superq(_destinations),|));
                    %if %sysevalf(%qupcase(%qscan(%superq(_destinations),&k,|))^=RTF,boolean) %then %do;
                        ods %scan(%superq(_destinations),&k,|) exclude all;
                    %end;
                %end;
            %end;
            %else %if %sysevalf(%scan(%superq(_rloop),&rloop,|)=HTML,boolean) %then %do;
                ods HTML select all;
                %do k = 1 %to %sysfunc(countw(%superq(_destinations),|));
                    %if %sysevalf(%qupcase(%qscan(%superq(_destinations),&k,|))^=HTML,boolean) %then %do;
                        ods %scan(%superq(_destinations),&k,|) exclude all;
                    %end;
                %end;
            %end;
            %else %do;
                ods POWERPOINT select all;
                ods POWERPOINT  style=_tablenppt;
                %do k = 1 %to %sysfunc(countw(%superq(_destinations),|));
                    %if %sysevalf(%qupcase(%qscan(%superq(_destinations),&k,|))^=POWERPOINT,boolean) %then %do;
                        ods %scan(%superq(_destinations),&k,|) exclude all;
                    %end;
                %end;
            %end;
            %local _hbtmbrd _htwidth;
            %if %sysevalf(%scan(%superq(_rloop),&rloop,|)=RTF,boolean) %then %let _hbtmbrd=^S={borderbottomstyle=solid borderbottomwidth=0.1 borderbottomcolor=black};
            %else %let _hbtmbrd=;
            %if %sysevalf(%scan(%superq(_rloop),&rloop,|)=HTML,boolean) %then %let _htwidth=1;
            %else %let _htwidth=0.1;
            proc report data=_out nowd split='~' spanrows missing
                %if %sysevalf(%scan(%superq(_rloop),&rloop,|)^=PPT,boolean) %then %do;
                    style(header)={%if %sysevalf(%scan(%superq(_rloop),&rloop,|)=HTML,boolean) %then %do; 
                                        borderstyle=none borderwidth=1 
                                        %if &borderdisplay>=2 %then %do; borderstyle=solid bordercolor=black %end; 
                                   %end;
                                   background=white fontsize=&headersize color=black fontfamily="&font" fontweight=&headerweight vjust=bottom}
                    style(column)={%if %sysevalf(%scan(%superq(_rloop),&rloop,|)=HTML,boolean) %then %do; 
                                        borderstyle=none borderwidth=1 
                                        %if &borderdisplay>=2 %then %do; borderstyle=solid bordercolor=black %end; 
                                   %end;
                                   background=white fontsize=&datasize color=black fontfamily="&font" fontweight=&dataweight vjust=top}
                    style(lines)={%if %sysevalf(%scan(%superq(_rloop),&rloop,|)=HTML,boolean) %then %do; 
                                        borderstyle=none borderwidth=1 
                                        %if &borderdisplay>=2 %then %do; borderstyle=solid bordercolor=black %end; 
                                   %end;
                                   background=white fontsize=&datasize color=black fontfamily="&font" fontweight=&dataweight}
                    style(report)={color=black
                                   %if %sysevalf(%scan(%superq(_rloop),&rloop,|)=RTF,boolean) and &borderdisplay=1 %then %do;
                                      cellspacing=0 rules=groups frame=void cellpadding=0 borderspacing=0
                                   %end;
                                   %else %if %sysevalf(%scan(%superq(_rloop),&rloop,|)=HTML,boolean) %then %do; 
                                            borderstyle=none borderwidth=1 
                                            %if &borderdisplay>=2 %then %do; borderstyle=solid bordercolor=black %end; 
                                   %end;}                                       
                %end;;
                
                columns 
                    
                         /*Variables for later*/
                        (rowby indent vartype varnum varlevel header meta factor)
                        /*Start COLBY Label*/
                        %if %sysevalf(%superq(colby)^=,boolean) and %sysevalf(%superq(showcollabel)=1,boolean) %then %do;
                            title=collabel, (
                        %end;
                            %do c = 1 %to &ncolby;
                               /*Add a space between COLBY levels*/
                               %if &c>1 %then %do; 
                                    %if %sysevalf(%superq(by)^=,boolean) and %sysevalf(%superq(showbylabel)=1,boolean) %then %do; 
                                        title=dummy_title&c, 
                                    %end; 
                                    (footnote=dummy&c) 
                               %end;
                               /*Add Column level headers*/
                               %if %sysevalf(%superq(colby)^=,boolean) %then %do;
                                  title=colval&c,(
                               %end;   
                                   /*Print BY variable headers*/
                                   %if %sysevalf(%superq(by)^=,boolean) %then %do;
                                        %if %sysevalf(%superq(showbylabel)=1,boolean) %then %do; ("&bylabel" %end;
                                        c&c._m_npct 
                                   %end;
                                       /*Print result variables*/
                                       %if %sysevalf(%superq(by)^=,boolean) %then %do b = 1 %to %sysfunc(countw(%superq(_c&c._bylist)));
                                           c&c._b%scan(%superq(_c&c._bylist),&b)_npct
                                       %end;
                                       %if %sysevalf(%superq(showbylabel)=1,boolean) and %sysevalf(%superq(by)^=,boolean) %then %do; ) %end;
                                    %if %sysevalf(%superq(by)^=,boolean) %then %do; ("A0"x %end;
                                        %if %sysevalf(%superq(colby)^=,boolean) %then %do; _dummy&c %end;
                                    c&c._t_npct   
                                   /*Print P-value and close By Header parenthasis*/  
                                   %if (%sysevalf(%superq(by)^=,boolean)  and &nby>1) or &showpval=2 %then %do;
                                       c&c._pval 
                                   %end;
                                   %if %sysevalf(%superq(by)^=,boolean) %then %do; ) %end;
                               /*Close COLBY header parenthases*/          
                               %if %sysevalf(%superq(colby)^=,boolean) %then %do;
                                  )
                               %end;
                            /*End C loop*/     
                            %end;  
                        /*Close COLBY Label parenthases*/          
                        %if %sysevalf(%superq(colby)^=,boolean) and %sysevalf(%superq(showcollabel)=1,boolean) %then %do;
                            )
                        %end;
                    /*Closes title parenthases*/    
                     _last_;
                
                /*Last is for compute block*/
                define _last_ / computed noprint;
                /*Subtitle*/
                define factor / display "&_hbtmbrd.&subtitleheader." id 
                    style(column)={cellwidth=&subtitlewidth leftmargin=0.05in} style(header)={just=left};
                /*Column By Headers*/
                %if %sysevalf(%superq(colby)^=,boolean) and %sysevalf(%superq(showcollabel)=1,boolean) %then %do;
                    define collabel / across missing "&colbylabel"
                        style(header)={%if &borderdisplay=1 %then %do; borderbottomstyle=none %end; just=center};
                %end;
                %if %sysevalf(%superq(colby)^=,boolean) %then %do c = 1 %to &ncolby;
                    define colval&c / across missing "%scan(%superq(_colbylvls),&c,|,m)"
                        style(header)={borderbottomstyle=solid borderbottomwidth=&_htwidth borderbottomcolor=black just=center} ;
                    %if &c>1 and %sysevalf(%superq(by)^=,boolean) and %sysevalf(%superq(showbylabel)=1,boolean) %then %do; 
                        define dummy_title&c / across missing 'A0'x
                            style(header)={%if &borderdisplay=1 %then %do; borderbottomstyle=none %end; borderbottomwidth=&_htwidth}; 
                    %end;
                %end;
                /*Set up indent for compute block*/    
                define indent / display noprint;/*NOPRINT initializes variable without printing.  Can still refer to it*/
                define vartype / display noprint;/*NOPRINT initializes variable without printing.  Can still refer to it*/
                define varnum / display noprint;/*NOPRINT initializes variable without printing.  Can still refer to it*/
                define varlevel / display noprint;/*NOPRINT initializes variable without printing.  Can still refer to it*/
                define header / display noprint;/*NOPRINT initializes variable without printing.  Can still refer to it*/
                define meta / display noprint;/*NOPRINT initializes variable without printing.  Can still refer to it*/
                 
                /*Set up whether ROWBY is shown or not*/
                %if %sysevalf(%superq(rowby)^=,boolean) %then %do;
                    define rowby / order order=data "&_hbtmbrd.&rowbylabel" style(column)={leftmargin=0.05in cellwidth=&rowbywidth} missing id;
                    %end;
                %else %do;
                    define rowby / order order=data noprint missing;/*NOPRINT initializes variable without printing.  Can still refer to it*/
                    %end;
                
                /*Print each Column Subgroup analysis*/
                %do c = 1 %to &ncolby; 
                    /*If BY variable present, print all subgroup distributions*/
                    %if %sysevalf(%superq(by)^=,boolean) %then %do b = 1 %to %sysfunc(countw(%superq(_c&c._bylist)));
                        define c&c._b%scan(%superq(_c&c._bylist),&b)_npct / display 
                            %if %sysevalf(%superq(rowby)=,boolean) %then %do;
                                "&_hbtmbrd.%scan(%superq(_bylvls),%scan(%superq(_c&c._bylist),&b),|,m)~(N=%superq(r1_c&c._b%scan(%superq(_c&c._bylist),&b)_n))" 
                            %end;
                            %else %do;
                                "&_hbtmbrd.%scan(%superq(_bylvls),%scan(%superq(_c&c._bylist),&b),|,m)" 
                            %end;                    
                            center style(column)={cellwidth=&datawidth}
                            %if %sysevalf(%superq(c&c._b%scan(%superq(_c&c._bylist),&b)_switch)=0,boolean) %then %do; noprint %end;;
                    %end;          
                    /*Print distribution across missing by group*/  
                    %if %sysevalf(%superq(by)^=,boolean) %then %do;
                        define c&c._m_npct / display
                            %if %sysevalf(%superq(rowby)=,boolean) %then %do; 
                                "&_hbtmbrd.Missing~(N=%superq(r1_c&c._miss_n))" 
                            %end;
                            %else %do; 
                                "&_hbtmbrd.Missing" 
                            %end;                    
                            center style(column)={cellwidth=&datawidth} 
                            %if &by_printmiss ^=2 %then %do;/*Value if 2 tells SAS to always print the missing column even if no values*/
                                %if %sysevalf(%superq(c&c._m_switch)=0,boolean) %then %do; noprint %end; /*No values in the missing column*/
                                %else %if &by_incmiss=0 and &by_printmiss=0 %then %do; noprint %end; /*If there are missing values, but requested to be suppressed and not included as a value of by*/
                            %end;;
                    %end;
                    /*Print distribution across all patients*/
                    define c&c._t_npct / display
                        %if %sysevalf(%superq(rowby)=,boolean) %then %do; 
                            "&_hbtmbrd.Total~(N=%superq(r1_c&c._n))" 
                        %end;
                        %else %do; 
                            "&_hbtmbrd.Total" 
                        %end;                    
                        center style(column)={cellwidth=&datawidth} 
                        %if &showtotal=0 and %sysevalf(%superq(by)^=,boolean) %then %do; noprint %end;; /*Overrides SHOWTOTAL when no BY variable specified*/
                    /*Print P-values if BY variable specified*/
                    %if (%sysevalf(%superq(by)^=,boolean) and &nby>1) or &showpval=2 %then %do;
                        define c&c._pval / display "&_hbtmbrd.P-value" center style(column)={cellwidth=&pvalwidth} 
                            %if &showpval=0 %then %do; noprint %end;;/*NOPRINT initializes variable without printing.  Can still refer to it*/
                    %end;
                    /*Sets up DUMMY variable to create space between column headers*/
                    %if %sysevalf(%superq(colby)^=,boolean) %then %do;
                        define _dummy&c / computed "&_hbtmbrd. " style(column)={cellwidth=0.1in } noprint;
                    %end;
                    %if &c>1 %then %do;
                        define dummy&c / display "&_hbtmbrd. " style(column)={cellwidth=0.1in};
                    %end;
                %end;
                /*Set up indents and shading with compute block*/
                compute _last_;
                    count+1;
                    %if &shading=1 %then %do;
                        shade+1;
                    %end;
                    %else %if &shading=2 %then %do;
                        if varlevel=.l then shade+1;
                    %end;
                    %else %do;
                        shade=1;
                    %end;
                    %if %qupcase(&split)=LINE %then %do;
                        if varlevel=.l then call define(_row_,"style/merge","style={bordertopstyle=solid bordertopwidth=&_htwidth bordertopcolor=black}");
                    %end;
                    if count=1 then call define(_row_,"style/merge","style={bordertopstyle=solid bordertopcolor=black bordertopwidth=&_htwidth}");
                    /*Indents when indent=1, otherwise bolds text for label*/
                    if indent=1 then call define("factor","style/merge","style={leftmargin=0.12in indent=0.12in}");
                    else call define("factor","style/merge","style={fontweight=bold}");

                    if mod(shade,2)=0 then call define(_row_,"style/merge","style={background=greyef}");
                    if ^missing(rowby) and "%qupcase(&split)"^="LINE" then do;
                        call define(_row_,"style/merge","style={bordertopstyle=solid bordertopwidth=&_htwidth bordertopcolor=black borderbottomstyle=solid borderbottomwidth=&_htwidth borderbottomcolor=black}");
                        call define("rowby","style/merge","style={borderbottomstyle=none borderbottomwidth=&_htwidth borderbottomcolor=black}");
                    end;

                    %if %superq(borderdisplay)=4 %then %do;
                        if varlevel ^=.l then do;
                            if mod(shade,2)=0 then call define(_row_,"style/merge","style={bordertopstyle=hidden borderbottomstyle=hidden bordertopwidth=0 borderbottomwidth=0 bordertopcolor=greyef borderbottomcolor=greyef}");
                            else call define(_row_,"style/merge","style={bordertopstyle=hidden borderbottomstyle=hidden bordertopwidth=0 borderbottomwidth=0 bordertopcolor=white borderbottomcolor=white}");
                        end;
                        else if varlevel=.l then do;
                            if mod(shade,2)=0 then call define(_row_,"style/merge","style={bordertopstyle=solid borderbottomstyle=hidden bordertopwidth=&_htwidth borderbottomwidth=0 bordertopcolor=black borderbottomcolor=greyef}");
                            else call define(_row_,"style/merge","style={bordertopstyle=solid borderbottomstyle=hidden bordertopwidth=&_htwidth borderbottomwidth=0 bordertopcolor=black borderbottomcolor=white}");
                        end;
                    %end;        
                    endcomp;
                /*Print title before table*/
                compute before _page_/ 
                    style={leftmargin=0.06in borderbottomwidth=&_htwidth borderbottomcolor=black borderbottomstyle=solid 
                           %if &borderdisplay=1 or &borderdisplay=3 or &borderdisplay=4 %then %do;
                               bordertopstyle=hidden borderleftstyle=hidden borderrightstyle=hidden
                               bordertopwidth=&_htwidth  borderleftwidth=&_htwidth  borderrightwidth=&_htwidth 
                               bordertopcolor=white borderleftcolor=white borderrightcolor=white
                           %end;
                           %else %if &borderdisplay=2 %then %do;
                               bordertopstyle=solid borderleftstyle=solid borderrightstyle=solid
                               bordertopwidth=&_htwidth  borderleftwidth=&_htwidth  borderrightwidth=&_htwidth 
                               bordertopcolor=black borderleftcolor=black borderrightcolor=black
                           %end;
                           vjust=bottom fontsize=&titlesize fontweight=&titleweight 
                           just=&titlealign color=black background=white};
                    %do i = 1 %to %sysfunc(max(1,%sysfunc(countw(%superq(title),`,m))));
                        line @1 "%scan(%superq(title),&i,`,m)";
                    %end;
                endcomp;
                /*Print p-values and footnotes after table*/
                compute after / style={leftmargin=0.06in bordertopstyle=solid bordertopwidth=&_htwidth bordertopcolor=black vjust=top 
                           %if &borderdisplay=1 or &borderdisplay=3 or &borderdisplay=4 %then %do;
                               borderbottomstyle=hidden borderleftstyle=hidden borderrightstyle=hidden
                               borderbottomwidth=&_htwidth  borderleftwidth=&_htwidth  borderrightwidth=&_htwidth 
                               borderbottomcolor=white borderleftcolor=white borderrightcolor=white
                           %end;
                           %else %if &borderdisplay=2 %then %do;
                               borderbottomstyle=solid borderleftstyle=solid borderrightstyle=solid
                               borderbottomwidth=&_htwidth  borderleftwidth=&_htwidth  borderrightwidth=&_htwidth
                               borderbottomcolor=black borderleftcolor=black borderrightcolor=black
                           %end;
                                       fontsize=&footnotesize fontfamily="&font" fontweight=&footnoteweight just=&footnotealign color=black};
                   /*Prints p-value footnotes*/
                   %if (&showpval=2 or (&showpval=1 and %sysevalf(%superq(by)^=,boolean))) and &npfoot>0 %then %do; 
                       line @1 "&pfoot";  
                   %end;
                   /*Print Footnotes*/
                   %if ^((&showpval=2 or (&showpval=1 and %sysevalf(%superq(by)^=,boolean))) and &npfoot>0) or
                       %sysevalf(%superq(footnote)^=,boolean) %then %do i = 1 %to %sysfunc(max(1,%sysfunc(countw(%superq(footnote),`,m))));
                       line "%scan(%superq(footnote),&i,`,m) ";
                   %end;
               endcomp;
               where meta^=1;
            run;  
        %end;          
        ods select all;
        %do k = 1 %to %sysfunc(countw(%superq(_destinations),|));
            ods %scan(%superq(_destinations),&k,|) style=%scan(%superq(_styles),&k,|);
        %end;
        %if %sysevalf(%superq(outdoc)^=,boolean) %then %do;
            ods &destination close;
        %end;
        %if &_listing=1 %then %do;
            ODS LISTING;
        %end;
        %else %if &_listing=0 %then %do;
            ODS LISTING CLOSE;
        %end;
    %end; 
    options nonotes orientation=&_orientation;
    %if &_rtf2=1 and %sysevalf(%qupcase(&orientation)^=%qupcase(&_orientation),boolean) %then %do;
        ods rtf;
    %end;
    /*Output report dataset*/
    %if %sysevalf(%superq(out)^=,boolean) %then %do;
        data &out;
            set _out;
        run;
    %end;
    
    %errhandl:
    proc datasets nolist nodetails;
        %if &debug=0 %then %do;
            delete _temp _combined _out;
        %end;
    quit;
    
    /**Reload previous Options**/ 
    ods path &_odspath;
    options mergenoby=&_mergenoby &_notes &_qlm linesize=&_linesize msglevel=&_msglevel;
    %put TABLEN has finished processing, runtime: %sysfunc(putn(%sysevalf(%sysfunc(TIME())-&_starttime.),mmss8.4)); 
    
    %mend;
