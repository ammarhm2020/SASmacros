/*------------------------------------------------------------------*
| MACRO NAME  : mvmodels
| SHORT DESC  : Creates a forest plot and/or a table of one or more 
|               analysis models involving Kaplan-Meier, Cox models, 
|               or binary logisticmethods.
*------------------------------------------------------------------*
| CREATED BY  : Meyers, Jeffrey                 (8/28/2018 12:00)
*------------------------------------------------------------------*
| VERSION UPDATES:
| 1.1 10/23/2018
|   Changed PFOOT to put the footnote marker on the header instead
       of each p-value when only one type of p-value is present.
|   Added the value 5 to CAT_DISPLAY which is the same as 1 but
       doesn't group 2 level covariates with the header
|   Added MODEL_TITLE_OWNROW parameter to force the model title
       to be in its own row with univariate models
|   General logic corrections
| 1.0 08/28/2018 (New Release)
*------------------------------------------------------------------*
| PURPOSE
|
| This macro is designed to generate a forest plot or table.  The macro can calculate two
| types of models: survival and logistic.  From the survival methodology, the macro 
| can calculate hazard ratios, Kaplan-Meier time-point event-free rates, Kaplan-Meier
| median time-to-event, concordance indexes, p-values, and number of patients/events.
| From the logistic methodology, the macro can calculate odds ratios, binomial success
| rates, concordance indexes, p-values, and sample size/successes.
| All covariates in a model can be displayed or only 
| specific ones can be shown.  There are many customizations for displaying the
| forest plot, and there are statistics such as N, events, and p-values that are
| also computed and shown.
|
| The plot can be exported into a number of different image formats such as tiff,
| emf, png, and jpeg, and the attributes of the images are customizable.  Scalable
| vector graphics are also possible.  Images can be saved as direct image files, or 
| into RTF, PDF or HTML documents.
|
| Multiple models can be displayed in the output.  Options for customization 
| between models are separated by | (pipe) characters.  For example, to specify two
| different time variables for two models, the line would be TIME=timevar1|timevar2.
| The number of models run is set by NMODELS.  If only one value is specified for an 
| option, then that value is used for all models.
|
| Models can be subset with different types of variables including a BY, GROUPBY, 
| COLBY, or ROWBY.  The BY variables run the same model within each level of the BY
| variable and display them in different ways within the graph/table.
|
|
| 1.0: Required Parameters
|   DATA = dataset that contains the variables for analysis.  This dataset will
|          not be modified by the macro.
|   NMODELS = Sets the number of models computed within the macro. Default=1.
|   METHOD = Determines which method is used to build the forest plot. The options 
|            are SURVIVAL and LOGISTIC. Survival method can calculate and plot hazard ratios,
|            Kaplan-Meier event-free rates, and median time-to-events.  Logistic method can 
|            calculate and plot ods ratios and binomial success rates.  Both methods can 
|            calculate and plot concordance indexes.
|   PLOT_DISPLAY = Determines which statistics are displayed in the plot.  Items are listed
|             separated by spaces and will show in the order they are listed.  Default=STANDARD.
|             Options vary by METHOD and are: 
|             All Methods: STANDARD TOTAL EVENTS EV_T PCT EV_T_PCT PVAL AIC BIC LOGLIKELIHOOD
|             SURVIVAL: HR_ESTIMATE HR_EST_RANGE HR_RANGE HR_PLOT
|                       C_ESTIMATE C_EST_RANGE C_RANGE C_PLOT 
|                       MED_ESTIMATE MED_EST_RANGE MED_RANGE MED_PLOT
|                       KM_ESTIMATE# KM_EST_RANGE# KM_RANGE# KM_PLOT#
|                       REF_MED_ESTIMATE REF_MED_EST_RANGE REF_MED_RANGE
|                       REF_KM_ESTIMATE# REF_KM_EST_RANGE# REF_KM_RANGE#
|                       REF_TOTAL REF_EVENTS REF_EV_T PCT REF_EV_T_PCT   
|                       NOTE: C_ statisics are not available when SURV_METHOD=CIF              
|             LOGISTIC: OR_ESTIMATE OR_EST_RANGE OR_RANGE OR_PLOT
|                       BIN_ESTIMATE BIN_EST_RANGE BIN_RANGE BIN_PLOT
|                       REF_BIN_ESTIMATE REF_BIN_EST_RANGE REF_BIN_RANGE
|                       C_ESTIMATE C_EST_RANGE C_RANGE C_PLOT
|                       NOTE: C_ statisics are not available from stratified logistic models
|
|             Items stand for:
|             STANDARD: Changes depending on method and parameters:
|             Prefixes:
|                 HR: Hazard Ratio
|                 KM: Kaplan-Meier Event-free rates
|                 MED: Kaplan-Meier median time-to-event
|                 C: Concordance index
|                 OR: Odds Ratio
|                 BIN: Binary frequency of success
|                 REF: Displays the stat for the reference value of a categorical variable.  Only available
|                      when COVARIATES is not missing and a categorical variable is specified.
|             SUFFIXES
|                 ESTIMATE: Refers to the primary estimate (hazard ratio, odds ratio, concordance index, event-free rate)
|                 EST_RANGE: Displays the primary estimate and lower/upper confidence limits in the format of x.xx (LCL-UCL)
|                 RANGE: Displays the lower to upper estimate for the primary estimate in the format LCL-UCL
|                 PLOT: Displays the plot of the specified pre-fix
|             Other Items:
|                 SUBTITLE: Displays the row headers values.  For example, the values of the CATCOV, CONTCOV, or BY variables
|                 TOTAL: Displays the total number of patients column
|                 EVENTS: Displays the number of events
|                 EV_T: Displays the number of events and number of patients in the format EEE/NNN
|                 PCT: Displays the number of percentage of patients that had an event in the format NN.N%
|                 EV_T_PCT: Displays the number of events and number of patients  with percentage in the format EEE/NNN (NN.N%)
|                 PVAL: Displays the p-values specified by the BYPVAL, MODPVAL, T3PVAL, and COVPVAL parameters
|   TABLE_DISPLAY = Determines which statistics are displayed in the table.  The options are the same as
|                   PLOT_DISPLAY without the SUBTITLE and _PLOT options.
| 2.0: Optional Parameters
|   2.1: Model Variables Options
|     2.1.1: Model Covariates
|       2.1.1.1: General Options
|         COVARIATES = A list of variables to be used in the model.  The first variable is considered the
|                      covariate of interest of the model and will always be displayed.  Any other
|                      covariates will only be shown if SHOW_ADJCOVARIATES=1.  The covariates will be
|                      displayed in the plot/table in the same order they are listed here.  Different covariates
|                      can be set for each model by using the | delimiter.  The TYPE parameter determines whether
|                      a covariate is continuous or categorical.
|                      NOTE: Any covariate in the list that is the same as a variable listed in BY, COLBY, ROWBY,
|                            or GROUPBY is removed from the model.
|                      NOTE 2: No covariates are required to get certain statistics.
|         TYPE = Determines the type of variables listed in the COVARIATES parameter. A value of 1 indicates
|                a continuous covariate and a value of 2 indicates a discrete covariate. Each nth listed value
|                coordinates to the ntch covariate.  The last listed value carries over to any remaining
|                covariates.  Different lists can be specified for different models with the | delimiter.
|         LABELS = Determines the labels for each covariate.  Distinguish between covariates with the ` delmiter.
|                  If no label is specified then the variable's label in the inputted dataset is used.
|                  Different lists can be specified for different models with the | delimiter.
|       2.1.1.2: Continuous Options
|         CONT_STEP = Determines the step sized used to calculating the estimates and ratios for the continuous
|                     covariates.  Must be a numeric value greater than 0, default is 1. Different step sizes can be
|                     specified for each continuous variable by separating values in a space delimted list. The last
|                     listed value is carried forward for any other continuous covariates.
|                     Different lists can be specified for different models with the | delimiter.
|         CONT_DISPLAY = Determines how the continuous covariates are displayed in the plot window.  Options are 1, 2, and 3.
|                        Default is 1.
|                        1: Displays values and step size on same row as covariate label
|                        2: Displays values without step size on same row as covariate label.
|                        3: Displays values and step size on different row than covariate label
|                         Different values can be specified for different models with the | delimiter.
|       2.1.1.3: Categorical Options
|         CAT_DISPLAY = Determines how the categorical covariates are displayed in the plot window.  Options are 1, 2, 3, 4.  Default is 1.
|              1: Displays categorical level vs Reference for each categorical level except the reference.  If only two levels exist
|                 (including the reference) then they are grouped into the same row as the label.
|              2: Displays the reference value after the label and shows the categorical levels without reference values.
|              3: Displays the categorical levels without reference values.
|              4: Displays all values, including reference, in their own row.  Ratios are shown as Reference in statistical table.
|              5: Displays categorical level vs Reference for each categorical level except the reference.
|              NOTE: Statistics such as total, events, and Kaplan-Meier estimates are only shown for each categorical level
|                    when CAT_DISPLAY=4 unless SHOW_MODELSTATS=2.
|         CAT_ORDER = Determines the order that the Categorical variable levels are shown in the plot by using a list of numbers (e.g. 1 2 3 4) where each
|                     number corresponds to the order the variable levels. If multiple categorical variables are called, then 
|                     use the ` (lowercase tilde) as a delimiter between labels.
|         CAT_ORDER_FORMATTED = Determines if categorical variable levels are shown in formatted alphabetical order (1) or
|                               by internal unformatted values (0).  Default is 0.
|         CAT_REF = Determines the reference value for the categorical covariates. If not specified then first value in the data set is used.  Multiple 
|                   covariates are labeled by listing them with the ` delimiter.  Must be formatted value.  If BY,
|                   COLBY, ROWBY, or GROUPBY variables are specified then the specified reference value must exist across all
|                   levels of the subgroup variables.
|     2.1.2: Subgroup Options
|       2.1.2.1: BY variable Options
|         BY = Determines a list of variables to perform subset analyses within.  Specifying a list of multiple
|              variables will run subset analysis sequentially through the list of variables and plot each one.
|              Model output will be repeated for every level of the BY variable and listed in the same graph cell.
|              Different lists of BY variables can be set for each model with the | delimiter.
|         BYLABEL = Determines the label for each BY variable listed.  If multiple BY variables are called, then 
|                   use the ` (lowercase tilde) as a delimiter between labels.  If left blank, will default to variable
|                   label from input data set.
|         BYLABELON = Determines if the label is shown for the BY variable. Options are 1 (Yes) and 0 (No).  Default is 1.
|         BYORDER = Determines the order that the BY variable levels are shown in the plot by using a list of numbers (e.g. 1 2 3 4) where each
|                   number corresponds to the order the variable levels would be alphabetically. If multiple BY variables are called, then 
|                   use the ` (lowercase tilde) as a delimiter between labels.  If left blank, will show levels in alphabetical order. 
|         BYORDER_FORMATTED = Determines if the BYORDER option sorts by alphabetical formatted values (1) or by
|                             unformatted values (0).  Default is 0.  
|       2.1.2.2: COLBY (Column By) variable Options 
|         COLBY = Indicates a variable to do subset analyses with.  Any values listed in the PLOT_DISPLAY or TABLE_DISPLAY are repeated
|                 in the plot/table for each level of the COLBY variable except SUBTITLE.  Only one variable can be specified for COLBY.
|         COLBYLABEL = Determines the label to be displayed for the COLBY variable. If blank then variable's label will be used.
|         COLBYORDER = Determines the order that the COLBY variable levels are shown in the plot by using a list of numbers (e.g. 1 2 3 4) where each
|                      number corresponds to the order the variable levels. 
|         COLBYORDER_FORMATTED = Determines if the COLBYORDER option sorts by alphabetical formatted values (1) or by
|                               unformatted values (0).  Default is 0.  
|         COLBYLABELON = Determines if the label is shown for the COLBY variable.  Options are 1 (Yes) and 0 (No).  Default is 1.
|       2.1.2.3: ROWBY (Row By) variable Options 
|         ROWBY = Indicates a variable to do subset analyses with.  Any models and BY variables are repeated across each row.
|                 Only one variable can be specified for ROWBY.
|         ROWBYLABEL = Determines the label to be displayed for the ROWBY variable. If blank then variable's label will be used.
|         ROWBYORDER = Determines the order that the ROWBY variable levels are shown in the plot by using a list of numbers (e.g. 1 2 3 4) where each
|                      number corresponds to the order the variable levels. 
|         ROWBYORDER_FORMATTED = Determines if the ROWBYORDER option sorts by alphabetical formatted values (1) or by
|                               unformatted values (0).  Default is 0.  
|         ROWBYLABELON = Determines if the label is shown for the ROWBY variable.  Options are 1 (Yes) and 0 (No).  Default is 1.
|         ROWBYTABLE_DISPLAY = Determines if ROWBY levels are displayed in a grouped rows or as subheaders within the table.
|                              Options are SPAN or SUBHEADERS. Default is SPAN.
|       2.1.2.4: GROUPBY (Group By) variable Options 
|         GROUPBY = Indicates a variable to do subset analyses with.  Each BY variable and COVARIATE is displayd normally with each value of the GROUPBY
|                   variable is shown within that row.  Each value of GROUPBY has different colors or symbols and a legend is created.
|                   Only one variable can be specified for GROUPBY.
|         GROUPBYLABEL = Determines the label to be displayed for the GROUPBY variable. If blank then variable's label will be used.
|         GROUPBYORDER = Determines the order that the GROUPBY variable levels are shown in the plot by using a list of numbers (e.g. 1 2 3 4) where each
|                        number corresponds to the order the variable levels. 
|         GROUPBYORDER_FORMATTED = Determines if the GROUPBYORDER option sorts by alphabetical formatted values (1) or by
|                                  unformatted values (0).  Default is 0.  
|         GROUPBYLABELON = Determines if the label is shown for the GROUPBY variable.  Options are 1 (Yes) and 0 (No).  Default is 1.
|         GROUPBY_COLORTEXT = Determines if statistics are colored to match group by levels.  Options are 1 (Yes) and 0 (No).  Default is 1.
|       2.1.2.5: Subset input dataset
|         WHERE = Gives a where clause to subset the DATA dataset down.  Type exactly as would be in a procedure step.  
|                 Example: where=age>70
|     2.1.3: Survival Models
|       2.1.3.1: Time and Censor Variables
|         TIME = Variable containing time to event information.  Different variables can be used for each model with the | delimiter.
|         CENS = Numeric variable containing event.  Different variables can be used for each model with the | delimiter.
|         CEN_VL = Numeric constant representing value of a non-event in CENS.  Different values can be used for each model with the | delimiter.
|                  Default = 0.
|         LANDMARK = Gives either a variable or a number to landmark the TIME variable by for the analysis.  Number must be greater than 0.
|                    Different numbers or variables can be specified for each model with the | delimiter.
|       2.1.3.2: Methods Options
|         SURV_METHOD = Method used for survival. Options are KM for Kaplan-Meier, 1-KM for 1-Kaplan-Meier, and CIF for Cumulative Incidence Function.
|                       Default is KM.
|                       NOTE: CIF is only available in SAS 9.4 M3+
|         TIES = Determines the method for dealing with ties in the PROC PHREG model statement.  Default is BRESLOW.
|                Options are: BRESLOW, DISCRETE, EFRON, and EXACT.
|       2.1.3.3: Time-point Estimates Options
|         TIMELIST = A space delimited list of numeric time-points to collect Kaplan-Meier survival
|                estimates w/confidence intervals. Time-points should match the TRANSFORMED time-scale of time variable if 
|                TDIVISOR is used.
|         TDIVISOR = A numeric scalar value to divide the TIME variable by.  Transforms from one unit to another (e.g. 365.25 to 
|                    transform from days to years).
|     2.1.4: Logistic Models
|       EVENTCOV = Specifies the variable containing the binary covariate for logistic regression or the variable
|                  containing the 2 level binary covariate for Binomial analysis.  Different variables can be specified
|                  for each model by using the | delmiter.
|       EVENT = Specifies the event for the EVENTCOV variable.  Must match formatted value. For Binomial analysis, this
|               refers to the Success value. Different values can be specified for each model by using the | delmiter.  
|     2.1.5: Binomial and Time-point estimate Display Options
|       CONFTYPE = Method of computing confidence intervals.  Options differ by METHOD option:
|                  SURVIVAL: Default is LOG, options are: LOG, ASINSQRT, LOGLOG, LINEAR, LOGIT.
|                  LOGISTIC: Default is PB, options are PB (Binomial) and PE (Binomial Exact).
|       ESTFMT = Determines whether the Kaplan-Meier estimates are displayed as either a percentage (PCT) or proportion (PPT).
|                Options are PCT or PPT.  Default is PPT.
|     2.1.6: Model Options
|       STRATA = A list of stratification variables to run stratfied analyses with.  Within the KM method, will produce stratified p-values.
|                 Can be different per model with the | delimiter.
|       SHOW_ADJCOVARIATES = Determines if the adjusting covariates in the COVARIATES parameter are shown.  Options are
|                            1 (yes) and 0 (no).  Default is 1. Can be different per model with the | delimiter.
|       SHOW_MODELSTATS = Determines if model level statistics such as number of total events are shown with the model title.
|                         Options are 1 (yes), 2 (yes*), and 0 (no).  Default is 1.  Can be different per model with the | delimiter.
|                         *A value of 2 will cause model statistics to be shown with categorical variables even when CAT_DISPLAY is not equal to 4.
|       MODEL_TITLE = Allows the user to specify a title for each model. Separate titles can be specified with the | delimiter. 
|       MODEL_TITLE_OWNROW = Forces the MODEL_TITLE to be in its own row even if there are no BY variables and there is only one covariate.
|                            Options are 1 (yes) and 0 (no).  Default is 0.
|       ADDSPACES = Adds lines of space at the end of a model in the graph/table. Can be an integer greater than or equal to 0.  Default is 0.
|     2.1.7 P-value Options 
|       PVAL_COVARIATES = Determines if a p-value is computed for individual covariate levels within a model.  Options are:
|                         0: No p-value is calculated
|                         1: Wald p-value is calculated
|                         Default is 1.
|       PVAL_TYPE3 = Determines if a type-3 level p-value is computed for each individual covariate within a model.  Options are:
|                    0: No p-value is calculated
|                    1: Wald p-value is calculated
|                    2: Score p-value is calculated (Note: Survival Only)
|                    3: Likelihood-Ratio p-value is calculated (Note: Survival Only)
|                    Default is 1.
|       PVAL_BY = Determines if a p-value is computed comparing the levels of the BY variable.  Note that this does not use the
|                 models determined by COVARIATES in its calculations.  Options are:
|                 0: No p-value is calculated
|                 Survival Methods:
|                   1: Logrank p-value is calculated
|                   2: Wilcoxon p-value is calculated 
|                 Logistic Methods:
|                   1: Chi-square p-value is calculated
|                   2: Fisher's exact p-value is calculated   
|       PVAL_PRIORITY = Determines which p-value takes priority to be displayed when a covariate is merged into the same
|                       same row as its label.  Options are COVARIATE and TYPE3.  Default is COVARIATE.
|       PFOOT = Determines if footnotes are automatically generated for p-values and displayed in the plot/table.
|               Options are 1 (yes) and 0 (no).  Default is 1.
|   2.2: Output Display Options
|     2.2.1: General Options
|       2.2.1.1: Display Options
|         SHADING = Indicates the shading scheme used in the plot and table.  Options are 0, 1, 2, 3 and 4.  Default=1.
|              0: No shading
|              1: Alternating shading each row
|              2: Alternating shading for each by group.  First level of by variable will always be shaded.
|              3: Alternating shading for each by variable.  
|              4: Shade everything except for By variable labels and model titles. 
|         PCTDIGITS = Determines the number of decimals displayed with the percentages. Default is 1.
|         PVALDIGITS = Determines the number of decimals displayed with the p-values. Default is 4.
|         HRDIGITS = Determines the number of decimals displayed with the hazard ratios. Default is 2.
|         ORDIGITS = Determines the number of decimals displayed with the odds ratios. Default is 2.
|         CDIGITS = Determines the number of decimals displayed with the concordance index. Default is 2.
|         MEDIANDIGITS = Determines the number of decimals displayed with the Kaplan-Meier median time-to-event. Default is 1.
|         KMDIGITS = Determines the number of decimals displayed with the Kaplan-Meier time-point event-free rates. Default is AUTO.
|                    AUTO changes the value depending on ESTFMT:
|                       When ESTFMT = PPT then default is 2
|                       When ESTFMT = PCT then default is 1
|         BINDIGITS = Determines the number of decimals displayed with the binary success rate frequencies. Default is AUTO.
|                    AUTO changes the value depending on ESTFMT:
|                       When ESTFMT = PPT then default is 2
|                       When ESTFMT = PCT then default is 1
|         AICDIGITS = Determines the number of decimals displayed with the AIC statistic. Default is 3.
|         BICDIGITS = Determines the number of decimals displayed with the BIC statistic. Default is 3.
|         LLDIGITS = Determines the number of decimals displayed with the Log-likelihood statistic. Default is 3.
|         MODELLINES = Determines whether a line is drawn between models.  Options are 1 (yes) and 0 (no).  Default is 0.
|       2.2.1.2: Column Heading Options
|          SUBHEADERALIGN = Determines where the SUBHEADER is aligned.  Options are LEFT, CENTER, and RIGHT.  Default is LEFT.
|          PLOT_HEADER = Gives the header above the plot window.  Separate multiple plots with the | symbol.  Default=nothing
|          Display Item Headers: Each item in PLOT_DISPLAY and TABLE_DISPLAY can have the header modified with the following syntax:
|                                displayitemHeader =
|                                See PLOT_DISPLAY and TABLE_DISPLAY for potential prefixes.  Each header has its own default text.
|       2.2.1.3: Subtitle specific options
|         2.2.1.3.1: Indentation
|           INDENT_BY_LABEL = Determines the number of indents for the BY variable labels.  Options are . or an integer greater than or equal to 0.  
|                             Default is ., which automatically calculates depending on BY variables.
|           INDENT_BY_VALUE = Determines the number of indents for the BY variable level text.  Options are . or an integer greater than or equal to 0.  
|                             Default is ., which automatically calculates depending on BY variables.
|           INDENT_COV_LABEL =  Determines the number of indents for the covariate labels.  Options are . or an integer greater than or equal to 0.  
|                               Default is ., which automatically calculates depending on BY variables.
|           INDENT_COV_VALUE = Determines the number of indents for the covariate values.  Options are . or an integer greater than or equal to 0.  
|                              Default is ., which automatically calculates depending on BY variables.
|           INDENT_MODEL_TITLE= Determines the number of indents for the Model Title.  Options are . or an integer greater than or equal to 0.  
|                               Default is ., which automatically calculates depending on BY variables.
|         2.2.1.3.2: Font Weight
|           BOLD_BY_LABEL = Determines if the label text for the BY variable is bold or not bold.  Options are . (auto), 1 (bold) and 0 (not bold). Default is .
|           BOLD_BY_VALUE = Determines if the level text for the BY variable is bold or not bold.  Options are . (auto), 1 (bold) and 0 (not bold).  Default is .
|           BOLD_COV_LABEL = Determines whether the covariate labels are bold or not.  Options are . (auto), 1 (bold) or 0 (not bold). Default is .
|           BOLD_COV_VALUE = Determines whether the covariate values are bold or not.  Options are . (auto), 1 (bold) or 0 (not bold). Default is .
|           BOLD_MODEL_TITLE = Determines if the Model Title is bold or not bold.  Options are . (auto), 1 (bold) and 0 (not bold).  Default is .
|         2.2.1.3.3: Font Size
|           SUBSIZE = Determines the font size for the subheader labels.  Default=10PT
|         2.2.1.3.4: Alignment with Column By Variable
|            COLSUBTITLES = Determines if the SUBTITLES are listed at the start or end when a COLBY variable is present.
|                           Options are START and END.  Default is START.
|       2.2.1.4: Titles and Footnotes options 
|         TITLE = Designates a title to be above the plot and table.  Multiple lines can be specified with the ` delimiter.
|         TITLEALIGN = Determines the horizontal alignment of the title.  Options are LEFT, CENTER, or RIGHT. Default=CENTER
|         FOOTNOTE = Designates a footnote to be below the plot and table.  Multiple lines can be specified with the ` delimiter.
|         FNALIGN = Determines the horizontal alignment of the footnote.  Options are LEFT, CENTER, or RIGHT. Default=LEFT
|     2.2.2: Table Display Options
|       SHOW_TABLE = Determines if the table is displayed in the output.  Options are 1 (yes) and 0 (no).  Default is 1.
|       2.2.2.1: Font Options 
|         2.2.2.1.1: DATA options.  These will change the fonts within the COLUMNS section of the PROC REPORT.  This is the output between the headers and footnotes.
|           TABLEDATAFAMILY = Determines the font for the area between the headers and footnotes. Default is Arial.
|           TABLEDATASIZE = Determines the font size for the area between the headers and footnotes. Default is 9pt.
|           TABLEDATAWEIGHT = Determines the font weight for the area between the headers and footnotes. Default is medium. Options are medium and bold.
|         2.2.2.1.1: FOOTNOTE options.  These will change the fonts within the footnotes section of the PROC REPORT.  
|           TABLEFOOTNOTEFAMILY = Determines the font for the footnotes. Default is Arial.
|           TABLEFOOTNOTESIZE = Determines the font size for the footnotes. Default is 10pt.
|           TABLEFOOTNOTEWEIGHT = Determines the font weight for the footnotes. Default is medium. Options are medium and bold.
|         2.2.2.1.1: FOOTNOTE options.  These will change the fonts within the HEADERS section of the PROC REPORT.  This includes column headers and titles. 
|           TABLEHEADERFAMILY = Determines the font for the headers. Default is Arial.
|           TABLEHEADERSIZE = Determines the font size for the headers. Default is 10pt.
|           TABLEHEADERWEIGHT = Determines the font weight for the headers. Default is bold. Options are medium and bold. 
|       2.2.2.2: Column Width Options 
|          Display Item Column Widths: Each item in TABLE_DISPLAY can have the column width modified with the following syntax:
|                                displayitemwidth =
|                                See TABLE_DISPLAY for potential prefixes.  Each header has its own default width.
|          DUMMYWIDTH = Determines the width of the gap between COLBY values when COLBY is specified.
|          GROUPBYWIDTH = Determines the width of the column showing the GROUPBY values when GROUPBY is specified.
|          ROWBYWIDTH = Determines the width of the column showing the ROWBY values when ROWBY is specified and ROWBYTABLE_DISPLAY=SPAN.
|     2.2.3: Plot Display Options
|       2.2.3.1: General Options
|         SHOW_PLOT = Determines if the table is displayed in the output.  Options are 1 (yes) and 0 (no).  Default is 1.
|         PLOT_COLUMWEIGHTS = Controls the amount of plot space given to each components: subtitles, graph and each summary statistic.
|                             Must be the same number of columns as there are items in DISPLAY (except for STANDARD).  Values must
|                             be between 0 and 1 and sum to 1.  If left missing then macro will attempt to calculate weights on its own.  Default=missing.
|       2.2.3.2: Error Bars and Symbol options
|         2.2.3.2.1: Error Bars
|           ERRORBARS = A flag variable to turn the error bars on or off.  Options are 1 (on) or 0 (off).  Default=1.
|                       A list, separated by | delimiters, can be used to change the option by model.
|           LINECAP =  Determines if the error bars have a cap on them or not.  Options are 1 (on) or 0 (off).  Default=1.
|           LINECOLOR = Determines the color of the error bars.  Default=BLACK
|                       A list of colors, separated by | delimiters, can be used to create different colors for each model when GROUPBY is missing.
|                       A list of colors, separated by | delimiters, can be used to create different colors for each value of GROUPBY when GROUPBY is not missing.
|           LINESIZE = Determines the thickness of the error bars.  Default=2pt.
|                      A list of thicknesses, separated by | delimiters, can be used to create different thicknesses for each model.
|         2.2.3.2.2: Symbols
|           SYMBOL = Determines the symbols used in the forest plot scatterplot.  Default is CIRCLEFILLED.  Options are:
|                    ARROWDOWN, ASTERISK, CIRCLE, DIAMOND, GREATERTHAN, HASH, HOMEDOWN, IBEAM, PLUS, SQUARE, STAR, TACK, TILDE, TRIANGLE,
|                    UNION, X, Y, Z, CIRCLEFILLED, DIAMONDFILLED, HOMEDOWNFILLED, SQUAREFILLED, STARFILLED, TRIANGLEFILLED.
|                    A list of symbols, separated by | delimiters, can be used to create different symbols for each model.
|           SYMBOLCOLOR = Determines the color of the symbols for the frest plot scatterplot.  Default is BLACK.
|                         A list of colors, separated by | delimiters, can be used to create different colors for each model when GROUPBY is missing.
|                         A list of colors, separated by | delimiters, can be used to create different colors for each value of GROUPBY when GROUPBY is notmissing.
|           SYMBOLSIZE = Determines the size of the symbols for the frest plot scatterplot.  Default is 10pt.
|                        A list of sizes, separated by | delimiters, can be used to create different sizes for each model.
|       2.2.3.3: Axes options
|         2.2.3.3.1: Type options
|           XAXISTYPE = Determines the X-axis type.  Options are LOG or LINEAR.  Default=LINEAR.
|                       Different plots can be set to different types with the | delimiter.
|           XAXISCOLOR = Determines the X-axis color.  Default=black.
|           LOGBASE = Determines the base for LOG axes.  Options are e, 10, and 2.  Default=10.
|                       Different plots can be set to different bases with the | delimiter.
|           LOGMINOR = Flag variable to turn the minor tick marks of the X-axis on or off.  Only valid when XAXISTYPE=LOG
|                      and LOGBASE=10 and LOGTICKSTYLE=LOGEXPAND or LOGEXPONENT.  Options are TRUE or FALSE. Default=FALSE.
|                       Different plots can be set to different options with the | delimiter.
|           LOGTICKSTYLE = Determines how the tick marks are displayed when XAXISTYPE=LOG.  Options are: AUTO, LOGEXPAND, LOGEXPONENT, and LINEAR.
|                          Default is LOGEXPAND.
|                          AUTO: Automatically selects Tick Style based on data
|                          LOGEXPAND: Major ticks are placed at uniform intervals at integer powers of the base. 
|                          LOGEXPONENT: Major ticks are placed at uniform intervals at integer powers of the base. The tick values are only the 
|                                       integer exponents for all bases.
|                          LINEAR: Major tick marks are placed at non-uniform intervals that cover the range of the data.
|                          Different plots can be set to different options with the | delimiter.
|         2.2.3.3.2: Min, max and incrementation      
|           TICKVALUES = Determines the tick values for the X-axis.  This option overrides the INCREMENT option.  Must be a space delmited list of numbers.
|                        Different plots can be set to different options with the | delimiter.
|           INCREMENT = Determines the incrementation value for the X-axis.  This option only works when XAXISTYPE=LINEAR.  If left missing,
|                       X-axis will be split into 5 increments based on MIN and MAX. This is ignored if TICKVALUES is specified.  
|                       Different plots can be set to different options with the | delimiter.
|           MAX = Determines the maximum for the X-axis.  When XAXISTYPE=LOG, the next highest value of the log base is used.  If left missing,
|                 MAX is calculated from the data.
|                 Different plots can be set to different options with the | delimiter.
|           MIN = Determines the minimum for the X-axis.  When XAXISTYPE=LOG, the next lowest value of the log base is used.  If left missing,
|                 MIN is calculated from the data. 
|                 Different plots can be set to different options with the | delimiter.   
|         2.2.3.3.3: Label Options
|           XAXISLABEL = Determines the X-axis label.  Will be automatically generated based on outcome if nothing is entered.
|                        Different plots can be set to different options with the | delimiter.  
|           XAXISLABELON = Determines if label is displayed or not.  Options are 1 (on) or 0 (off).  Default is 1.
|                          Different plots can be set to different options with the | delimiter.  
|           LCOLOR = Determines the color of the X-axis label.  Default=BLACK
|           LSIZE = Determines the Size of the X-axis label.  Default=10pt
|           LWEIGHT = Determines the font weight of the X-axis label.  Options are NORMAL or BOLD. Default=BOLD
|         2.2.3.3.4: Axis line style Options    
|           XLINESIZE = Determines the thickness of the X-axis.  Default=0.5PT   
|         2.2.3.3.5: Axis tick values style Options 
|           XTICKVALUESIZE = Determines the font size of the tick values.  Default=10PT
|           XTICKVALUEWEIGHT = Determines the font weight of the tick values.  Options are BOLD and NORMAL.  Default=NORMAL
|         2.2.3.3.6: Titles and Footnotes options 
|           TITLESIZE = Determines the font size of the plot title.  Default=10PT
|           TITLEWEIGHT = Determines the font size of the plot title.  Default=BOLD
|           FNSIZE = Determines the font size of the plot footnote.  Default=10PT
|           FNWEIGHT = Determines the font size of the plot footnote.  Default=NORMAL
|       2.2.3.4: Reference Lines
|         2.2.3.4.1: First Reference Line
|           REFLINE = Specifies a place on the X-axis to draw a vertical reference line. 
|                     Different plots can be set to different options with the | delimiter.  
|           REFLINEPATTERN= Determines the line pattern for the vertical reference line.  Default=1.  Options are
|                           numbers 1 to 46 or: SOLID, SHORTDASH, MEDIUMDASH, LONGDASH,
|                           MEDIUMDASHSHORTDASH, DASHDASHDOT, DASHDOTDOT, DASH, LONGDASHSHORTDASH,
|                           DOT, THINDOT, SHORTDASHDOT, and MEDIUMDASHDOTDOT. 
|                           Different plots can be set to different options with the | delimiter.  
|           REFLINECOLOR = Determines the line color for the vertical reference line.  Default=BLACK
|                          Different plots can be set to different options with the | delimiter.
|         2.2.3.4.2: Second Reference Line
|           SREFLINE = Specifies a place on the X-axis to draw a second vertical reference line. 
|                      Different plots can be set to different options with the | delimiter.  
|           SREFLINEPATTERN= Determines the line pattern for the vertical reference line.  Default=1.  Options are
|                            numbers 1 to 46 or: SOLID, SHORTDASH, MEDIUMDASH, LONGDASH,
|                            MEDIUMDASHSHORTDASH, DASHDASHDOT, DASHDOTDOT, DASH, LONGDASHSHORTDASH,
|                            DOT, THINDOT, SHORTDASHDOT, and MEDIUMDASHDOTDOT. 
|                            Different plots can be set to different options with the | delimiter.  
|           SREFLINECOLOR = Determines the line color for the vertical reference line.  Default=BLACK
|                           Different plots can be set to different options with the | delimiter.
|         2.2.3.4.3: Reference Guides
|           REFGUIDELOWER = Text to be displayed on the X-axis between the minimum and reference line. Line breaks can be specified with the ` delimiter.
|                           Different plots can be set to different options with the | delimiter.
|           REFGUIDEUPPER = Text to be displayed on the X-axis between the maximum and reference line. Line breaks can be specified with the ` delimiter.
|                           Different plots can be set to different options with the | delimiter.
|           REFGUIDEHALIGN = Determines if the reference guide's horizontal position within the graph space.  Options are
|                            IN (aligned towards reference lines) and CENTER (centered in horizontal space).  Default is IN. 
|           REFGUIDEVALIGN = Determines if the reference guide's vertical position within the graph space.  Options are
|                            TOP and BOTTOM.  Default is BOTTOM. 
|           REFGUIDESPACE = Allocates space for the reference guides and arrows.  Must be a number between 0 and 1.
|                           Default is 0.04.
|           REFGUIDEWEIGHT = Determines the font weight for the reference guides.  Options are BOLD and NORMAL.  Default=NORMAL.
|           REFGUIDECOLOR = Determines the font color for the reference guides.  Default is black.
|           REFGUIDESIZE = Determines the font size for the reference guides.  Default is 10pt.
|           REFGUIDELINECOLOR = Determines the color of the reference guide arrows. Default is black
|           REFGUIDELINEARROW = Determines the type of arrow used on the end of the reference guide.  Options are OPEN, CLOSED, FILLED, and BARBED.
|                               Default is FILLED.
|           REFGUIDELINEPATTERN = Determines the pattern for the reference guide line arrows.  Default=1.  Options are
|                                 numbers 1 to 46 or: SOLID, SHORTDASH, MEDIUMDASH, LONGDASH,
|                                 MEDIUMDASHSHORTDASH, DASHDASHDOT, DASHDOTDOT, DASH, LONGDASHSHORTDASH,
|                                 DOT, THINDOT, SHORTDASHDOT, and MEDIUMDASHDOTDOT. 
|           REFGUIDELINESIZE = Determines the thickness of the reference guide arrows.  Default is 1pt.
|       2.2.3.5: Plot Walls
|         SHOWWALLS = Determines if the left and right walls are drawn in the graph space.  Options are 1 (Yes) or 0 (No).  Default=0
|                     Different plots can be set to different options with the | delimiter.
|         WALLPATTERN = Determines the pattern of the walls.  Default is 1.  Options are
|                       numbers 1 to 46 or: SOLID, SHORTDASH, MEDIUMDASH, LONGDASH,
|                       MEDIUMDASHSHORTDASH, DASHDASHDOT, DASHDOTDOT, DASH, LONGDASHSHORTDASH,
|                       DOT, THINDOT, SHORTDASHDOT, and MEDIUMDASHDOTDOT. 
|                       Different plots can be set to different options with the | delimiter.
|         WALLCOLOR = Determines the color of the walls.  Default is BLACK.
|                     Different plots can be set to different options with the | delimiter.
|         COLLINE = Determines if lines separate the different levels of the COLBY variable in the plot.  Options are 1 (Yes) and 0 (No).  Default is 1.
|         COLLINESIZE = Determines the thickness of the COLUMN lines.  Default is 0.5pt.
|         COLLINEPATTERN = Determines the pattern of the COLUMN lines.  Default is 1.  Options are
|                          numbers 1 to 46 or: SOLID, SHORTDASH, MEDIUMDASH, LONGDASH,
|                          MEDIUMDASHSHORTDASH, DASHDASHDOT, DASHDOTDOT, DASH, LONGDASHSHORTDASH,
|                          DOT, THINDOT, SHORTDASHDOT, and MEDIUMDASHDOTDOT.
|         COLUMNGUTTER = Adds space between each column in the graph.  Must be a number greater than or equal to 0.  Default is 0.
|         ROWLINE = Determines if lines separate the different levels of the ROWBY variable in the plot.  Options are 1 (Yes) and 0 (No).  Default is 1.
|         ROWLINESIZE = Determines the thickness of the ROW lines.  Default is 0.5pt.
|         ROWLINEPATTERN = Determines the pattern of the ROW lines.  Default is 1.  Options are
|                          numbers 1 to 46 or: SOLID, SHORTDASH, MEDIUMDASH, LONGDASH,
|                          MEDIUMDASHSHORTDASH, DASHDASHDOT, DASHDOTDOT, DASH, LONGDASHSHORTDASH,
|                          DOT, THINDOT, SHORTDASHDOT, and MEDIUMDASHDOTDOT. 
|         ROWGUTTER = Adds space between each value of ROWBY in the graph.  Must be a number greater than or equal to 0.  Default is 0.
|       2.2.3.6: Legend
|         2.2.3.6.1: General Options
|           SHOW_LEGEND = Determines if the legend will be displayed.  Options are 1 (Yes) or 0 (No).  Default is 1.
|         2.2.3.6.2: Alignment
|           LEGENDALIGN = Determines where the legend will be drawn.  Options are TOP, BOTTOM, LEFT, or RIGHT.
|           LEGENDNACROSS = Determines how many values will be displayed horizontally in the legend.  Default is 6.
|           LEGENDNDOWN = Determines how many values will be displayed vertically in the legend.  Default is 1.
|         2.2.3.6.3: Font Styles
|           2.2.3.6.3.1: Values
|             LEGENDVALWEIGHT = Determines the weight of the legend values.  Options are BOLD and NORMAL.  Default is NORMAL.
|             LEGENDVALSIZE = Determines the font size of the legend values.  Default=10pt.
|           2.2.3.6.3.2: Titles
|             LEGENDTITLEWEIGHT = Determines the weight of the legend values.  Options are BOLD and NORMAL.  Default is BOLD.
|             LEGENDTITLESIZE = Determines the font size of the legend values.  Default=10pt.
|       2.2.3.7: Statistical Columns 
|         2.2.3.7.1: Font Style 
|           SUMSIZE = Determines the font size for the summary statistics section.  Default=10PT
|           SUMWEIGHT = Determines the font weight for the summary statistics section.  Options are BOLD or NORMAL. Default=NORMAL
|         2.2.3.7.2: Column Headers  
|           UNDERLINEHEADERS = Determines if the column headers will be underlined.  Options are 1 (Yes) or 0 (No). Default is 0. 
|   2.3: Output options
|     2.3.1: Image File Output Settings
|       ANTIALIASMAX = Maximum threshold to keep line smoothing activated.  Set to
|                      arbitrarily large number if large file.
|       AXISCOLOR = Determines the color of the axis lines.  Default is black.
|       BGCOLOR = Sets the background color behind the plot.  Default is WHITE
|       BORDER = Turns the black border in the plot image on (TRUE) or off (FALSE).  Options are
|                TRUE or FALSE, default is TRUE. 
|       BORDERCOLOR = Sets the border color for the entire plot image.  Default is BLACK
|       DPI = Determines the dots per inch of the image file.  Default=200.
|       FONTCOLOR = Determines the color of the text within the graph.  Default is black.
|       GPATH = Determines the path that the image is saved to.  Defaults to the path 
|               the SAS session is opened to.
|       HEIGHT = Sets the height of plot window.  Default is 6in.  Set by a
|                numeric constant followed by px or in.
|       PLOTNAME = Names the image file.  Plot will be saved per the GPATH parameter.  
|                  Default is _forest.
|       PLOTTYPE = Determines the image type of the plot.  Default is png, options
|                  are png, tiff, jpeg, emf, gif.  
|                  NOTE: There is special code added for TIFF plots in order to make 
|                        appropriately sized image files.  If DPI settings are too high
|                        depending on operating system and SAS version, this may not work.
|                  NOTE2: Special code is made for SAS 9.4 for EMF files.  This is due to SAS
|                         changing the default drivers for EMF files in 9.4, but this change
|                         causes the EMF files to not build properly when trying to convert to
|                         Windows objects.  Code given by Martin Mincey to add registry keys
|                         is used to temporarily add registry keys, then these are removed at
|                         the end of the macro.  This only occurs when making EMF files in SAS 9.4
|       SVG = Turns scalable vector graphics on or off.  Only compatible with SAS 9.3 or later.
|             Possible Scalable Vector Graphics formats are EMF within or not within RTF, 
|             PDF, and HTML.  In order to activate the scalable vector graphics, the 
|             DESTINATION must be used in conjunction with the SVG parameter.  To create
|             SVG EMF files use DESTINATION=RTF and PLOTTYPE=EMF.  To create SVG PDF files
|             use DESTINATION=PDF.  To create SVG HTML files use DESTINATION=HTML.
|             Default is 0 (off).  options are 1 or 0
|       TRANSPARENT = Determines if the background is transparent.  Must be SAS 9.4M3+ to use this 
|                     option.  Options are 1 (yes) and 0 (no).  Default is 0.
|       WIDTH = Sets the width of plot window.  Default is 8in.  Set by a
|               numeric constant followed by px or in.
|     2.3.2: Output Dataset
|       OUT_PLOT = Outputs the dataset used to make the plot.
|       OUT_TABLE = Outputs the dataset used to make the table.
|     2.3.3: Save to a document
|       DESTINATION = Type of ODS output when creating a document. 
|                     Default is RTF, options are RTF, PDF, HTML, EXCEL, and POWERPOINT.
|                     NOTE: EXCEL and POWERPOINT are only available in SAS 9.4+.
|       OUTDOC = Filepath with name at end to send the output.
|                Example: ~/ibm/example.doc
|       EXCEL_SHEETNAME = The worksheet name if the destination is EXCEL.
*------------------------------------------------------------------*
| OPERATING SYSTEM COMPATIBILITY
| SAS v9.2 or lower : NO
| UNIX SAS v9.3   :   YES
| UNIX SAS v9.4   :   YES
| PC SAS v9.3     :   YES
| PC SAS v9.4     :   YES
*------------------------------------------------------------------*
| MACRO CALL
| METHOD=SURVIVAL:
| %mvmodels (
|            DATA=,
|            METHOD=SURVIVAL,
|            NMODELS=,
|            TIME=,
|            CENS=,
|            CEN_VL=,
|            COVARIATES= /If running a Cox model/,
|            TYPE= /If running a Cox model/
|          );
| METHOD=LOGISTIC:
| %mvmodels (
|            DATA=,
|            METHOD=LOGISTIC,
|            NMODELS=,
|            EVENTCOV=,
|            EVENT=,
|            COVARIATES= /If running a logistic model/,
|            TYPE= /If running a logistic model/
|          );
*------------------------------------------------------------------*
| EXAMPLES 
| Dataset for SURVIVAL Examples (Taken from SAS website):
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
|Survival Example 1: 
%mvmodels (DATA=bmt,METHOD=SURVIVAL,NMODELS=1,
    TIME=ftime,CENS=status,BY=diagnosis);  
|
|Survival Example 2: 
%mvmodels (DATA=bmt,METHOD=SURVIVAL,NMODELS=1,
    TIME=ftime,CENS=status,TIMELIST=1000,BY=diagnosis);  
|
|Survival Example 3: 
%mvmodels (DATA=bmt,METHOD=SURVIVAL,NMODELS=1,
    TIME=ftime,CENS=status,COVARIATES=diagnosis gender,TYPE=2);  
|
|Survival Example 4: 
%mvmodels (DATA=bmt,METHOD=SURVIVAL,NMODELS=1,
    TIME=ftime,CENS=status,COVARIATES=gender,TYPE=2,BY=diagnosis,
    TIMELIST=1000,CAT_DISPLAY=4,SHOW_MODELSTATS=0,
    PLOT_DISPLAY=subtitle hr_plot hr_est_range km_est_range1,PLOT_COLUMNWEIGHTS=0.2 0.3 0.25 0.25);  
|
|Survival Example 5: 
%mvmodels (DATA=bmt,METHOD=SURVIVAL,NMODELS=1,
    TIME=ftime,CENS=status,COVARIATES=diagnosis,TYPE=2,COLBY=gender,SHOWWALLS=0,UNDERLINEHEADERS=1,
    TIMELIST=1000,CAT_DISPLAY=4,SHOW_MODELSTATS=0,
    PLOT_DISPLAY=subtitle hr_plot hr_est_range km_est_range1,PLOT_COLUMNWEIGHTS=0.25 0.3 0.225 0.225,
    width=10in);  
|
|Survival Example 6: 
%mvmodels (DATA=bmt,METHOD=SURVIVAL,NMODELS=1,
    TIME=ftime,CENS=status,COVARIATES=diagnosis,TYPE=2,ROWBY=gender,
    TIMELIST=1000,CAT_DISPLAY=4,SHOW_MODELSTATS=0,
    PLOT_DISPLAY=subtitle hr_plot hr_est_range km_est_range1,PLOT_COLUMNWEIGHTS=0.25 0.3 0.225 0.225,
    width=10in);  
|
|Survival Example 7: 
%mvmodels (DATA=bmt,METHOD=SURVIVAL,NMODELS=1,
    TIME=ftime,CENS=status,COVARIATES=diagnosis,TYPE=2,GROUPBY=gender,
    TIMELIST=1000,CAT_DISPLAY=4,SHOW_MODELSTATS=0,
    PLOT_DISPLAY=subtitle hr_plot hr_est_range km_est_range1,PLOT_COLUMNWEIGHTS=0.25 0.3 0.225 0.225,
    width=10in); 
|
|Survival Example 8: 
%mvmodels (DATA=bmt,METHOD=SURVIVAL,NMODELS=2,
    TIME=ftime,CENS=status,COVARIATES=gender,TYPE=2,BY=diagnosis|,
    CAT_DISPLAY=2,SHOW_MODELSTATS=1,INDENT_BY_VALUE=1,BOLD_BY_VALUE=0,
    PLOT_DISPLAY=subtitle ev_t hr_plot hr_est_range med_est_range,PLOT_COLUMNWEIGHTS=0.2 0.1 0.3 0.2 0.2,
    SYMBOLSIZE=10pt|18pt,SYMBOLCOLOR=black|red,SYMBOL=circlefilled|diamondfilled,
    ERRORBARS=1|0,SHOWWALLS=0,REFLINE=1);  
|
| Dataset for LOGISTIC Examples (Taken from SAS website):
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
|Logistic Example 1: 
%mvmodels (DATA=neuralgia,METHOD=LOGISTIC,NMODELS=1,
    EVENTCOV=pain,EVENT=Yes,COVARIATES=treatment sex age,TYPE=2 2 1);
|
|Logistic Example 2: 
%mvmodels (DATA=neuralgia,METHOD=LOGISTIC,NMODELS=1,
    EVENTCOV=pain,EVENT=Yes,COVARIATES=treatment sex age,TYPE=2 2 1,
    CAT_DISPLAY=2,XAXISTYPE=log,XAXISLABEL=Odds Ratios,SYMBOLSIZE=8pt);
|
|Logistic Example 3: 
%mvmodels (DATA=neuralgia,METHOD=LOGISTIC,NMODELS=1,
    EVENTCOV=pain,EVENT=Yes,COVARIATES=sex age,TYPE=2 1,
    CAT_DISPLAY=2,XAXISTYPE=log,XAXISLABEL=Odds Ratios,BY=TREATMENT)
|
|Logistic Example 4: 
%mvmodels (DATA=neuralgia,METHOD=LOGISTIC,NMODELS=1,
    EVENTCOV=pain,EVENT=Yes,COVARIATES=sex age,TYPE=2 1,
    CAT_DISPLAY=2,XAXISTYPE=log,XAXISLABEL=Odds Ratios,
    BY=TREATMENT,
    PVAL_TYPE3=1,PLOT_DISPLAY=subtitle or_plot ev_t or_est_range pval,PLOT_COLUMNWEIGHTS=0.2 0.3 0.15 0.2 0.15);
|
|Logistic Example 5: 
%mvmodels (DATA=neuralgia,METHOD=LOGISTIC,NMODELS=1,
    EVENTCOV=pain,EVENT=Yes,COVARIATES=sex age,TYPE=2 1,
    CAT_DISPLAY=2,XAXISTYPE=log,XAXISLABEL=Odds Ratios,
    BY=TREATMENT,BYORDER=3 2 1,
    PVAL_TYPE3=1,PLOT_DISPLAY=subtitle or_plot ev_t or_est_range pval,PLOT_COLUMNWEIGHTS=0.2 0.3 0.15 0.2 0.15);
|
|Logistic Example 6: 
%mvmodels (DATA=neuralgia,METHOD=LOGISTIC,NMODELS=1,
    EVENTCOV=pain,EVENT=Yes,COVARIATES=treatment sex age,TYPE=2 2 1,CATREF=P`M,
    CAT_DISPLAY=4,XAXISTYPE=log,XAXISLABEL=Odds Ratios,
    PVAL_TYPE3=1,PLOT_DISPLAY=subtitle or_plot ev_t or_est_range pval,PLOT_COLUMNWEIGHTS=0.2 0.3 0.15 0.2 0.15);
*------------------------------------------------------------------*
| References
| Methods for calculating concordance index and standard error in logistic 
| regression taken from:
| cNeil BJ: The meaning and use of the area under a receiver
| operating characteristic (ROC) curve. Radiology 143:29-36, 1982.  
| Methods for calculating concordance index and standard error in Cox 
| proportional hazards regression taken from:
| Therneau T (2014). _A Package for Survival Analysis in S_. R package
| version 2.37-7, <URL: http://CRAN.R-project.org/package=survival>.
|
| Terry M. Therneau and Patricia M. Grambsch (2000). _Modeling Survival
| Data: Extending the Cox Model_. Springer, New York. ISBN
| 0-387-98784-3.
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
  


%macro mvmodels(
    /*1.0: Required Parameters*/
        data=,nmodels=1,method=,
        plot_display=standard,
        table_display=standard,
    /*2.0: Optional Parameters*/
      /*2.1: Model Variables Options*/
        /*2.1.1: Model Covariates*/
          /*2.1.1.1: General Options*/
            covariates=,type=,labels=,
          /*2.1.1.2: Continuous Options*/
            cont_step=1,cont_display=1,
          /*2.1.1.3: Categorical Options*/
            cat_order=,cat_order_formatted=0,
            cat_ref=,
            cat_display=1,                
        /*2.1.2: Subgroup Options*/
            /*2.1.2.1: BY variable Options*/
              by=,byorder=,byorder_formatted=0,bylabel=,bylabelon=1,
            /*2.1.2.2: COLBY (Column By) variable Options*/
              colby=,colbyorder=,colbyorder_formatted=0,colbylabel=,colbylabelon=1,
            /*2.1.2.3: ROWBY (Row By) variable Options*/
              rowby=,rowbyorder=,rowbyorder_formatted=0,rowbylabel=,rowbylabelon=1,rowbytable_display=span,
            /*2.1.2.4: GROUPBY (Group By) variable Options*/
              groupby=,groupbyorder=,groupbyorder_formatted=0,groupbylabel=,groupbylabelon=1,groupby_colortext=1,
            /*2.1.2.5: Subset input dataset*/
              where=,
        /*2.1.3: Survival Options*/
            /*2.1.3.1: Time and Censor Variables*/
              time=,cens=,cen_vl=0,ev_vl=,landmark=,
            /*2.1.3.2: Methods Options*/
              surv_method=KM,ties=breslow,
            /*2.1.3.3: Time-point Estimates Options*/
              timelist=,tdivisor=1,
        /*2.1.4: Logistic Options*/
          event=,eventcov=,
        /*2.1.5: Binomial and Time-point estimate Display Options*/
          estfmt=ppt,conftype=auto,
        /*2.1.6: Model Options*/
          strata=,show_adjcovariates=1,show_modelstats=1,model_title=,model_title_ownrow=0,addspaces=0,
        /*2.1.7: P-value Options*/
          pval_covariates=1,pval_type3=1,pval_by=0,pval_priority=covariate,pfoot=1,
      /*2.2: Output Display Options*/
        /*2.2.1: Output Display Options*/
          /*2.2.1.1: Display Options*/
            shading=1,
            pvaldigits=4,hrdigits=2,mediandigits=1,kmdigits=auto,pctdigits=1,
            cdigits=2,ordigits=2,bindigits=auto,AICdigits=3,bicdigits=3,lldigits=3,
            modellines=0,
          /*2.2.1.2: Column Heading Options*/
            subtitleheader=,subheaderalign=left,plot_header=,
            totalheader=Total,eventsheader=Events,
            ev_theader=Events/Total,pctheader=% Events,ev_t_pctheader=Events/Total (%),
            ref_totalheader=Reference`Total,ref_eventsheader=Reference`Events,
            ref_ev_theader=Reference`Events/Total,ref_pctheader=Reference`% Events,ref_ev_t_pctheader=Reference`Events/Total (%),
            pvalheader=P-value,
            hr_estimateheader=Hazard Ratio,hr_est_rangeheader=Hazard Ratio`(95% CI),hr_rangeheader=Hazard Ratio 95% CI,
            
            med_estimateheader=Median,med_est_rangeheader=Median`(95% CI),med_rangeheader=Median 95% CI,
            ref_med_estimateheader=Reference`Median,ref_med_est_rangeheader=Reference`Median`(95% CI),ref_med_rangeheader=Reference`Median 95% CI,
            
            km_estimateheader=Event-free Rate,km_est_rangeheader=Event-free Rate`(95% CI),km_rangeheader=Event-free Rate 95% CI,
            ref_km_estimateheader=Reference`Event-free Rate,ref_km_est_rangeheader=Reference`Event-free Rate`(95% CI),ref_km_rangeheader=Reference`Event-free Rate 95% CI,
            
            or_estimateheader=Odds Ratio,or_est_rangeheader=Odds Ratio`(95% CI),or_rangeheader=Odds Ratio 95% CI,
            
            bin_estimateheader=Binary Rate,bin_est_rangeheader=Binary Rate`(95% CI),bin_rangeheader=Binary Rate 95% CI,
            ref_bin_estimateheader=Reference`Binary Rate,ref_bin_est_rangeheader=Reference`Binary Rate`(95% CI),ref_bin_rangeheader=Reference`Binary Rate 95% CI,
            
            c_estimateheader=C-Index,c_est_rangeheader=C-Index`(95% CI),c_rangeheader=C-Index 95% CI,
            
            AICheader=AIC,bicheader=BIC,loglikelihoodheader=-2 Log L,
                
          /*2.2.1.3: Subtitle specific options*/  
            /*2.2.1.3.1: Indentation*/
              bold_cov_label=.,bold_cov_value=.,bold_by_label=.,bold_by_value=.,bold_model_title=.,
            /*2.2.1.3.2: Font Weight*/
              indent_cov_label=.,indent_cov_value=.,indent_by_label=.,indent_by_value=.,indent_model_title=.,
            /*2.2.1.3.3: Font Size*/
              subsize=10pt,
            /*2.2.1.3.4: Alignment with Column By Variable*/
              colsubtitles=start,
          /*2.2.1.4: Titles and Footnotes Options*/
              title=,titlealign=center,footnote=,fnalign=left,    
        /*2.2.2: Table Display Options*/
          show_table=1,
          /*2.2.2.1: Font Options*/
            /*2.2.2.1.1: Data options*/
            tabledatafamily=Arial,tabledatasize=9pt,tabledataweight=medium,
            /*2.2.2.1.2: Footnote options*/
            tablefootnotefamily=Arial,tablefootnotesize=10pt,tablefootnoteweight=medium,
            /*2.2.2.1.3: Header options*/
            tableheaderfamily=Arial,tableheadersize=10pt,tableheaderweight=bold,
          /*2.2.2.2: Column Width Options */
            subtitlewidth=2in,rowbywidth=1in,Groupbywidth=1in,
            totalwidth=0.5in,eventswidth=0.5in,
            ev_twidth=1in,pctwidth=0.5in,ev_t_pctwidth=1.25in,
            ref_totalwidth=0.5in,ref_eventswidth=0.5in,
            ref_ev_twidth=1in,ref_pctwidth=0.5in,ref_ev_t_pctwidth=1.25in,
            pvalwidth=0.7in,
            hr_estimatewidth=0.5in,hr_est_rangewidth=1.1in,hr_rangewidth=1in,
            
            med_estimatewidth=0.7in,med_est_rangewidth=1.3in,med_rangewidth=1.1in,
            ref_med_estimatewidth=0.7in,ref_med_est_rangewidth=1.3in,ref_med_rangewidth=1.1in,
            
            km_estimatewidth=0.5in,km_est_rangewidth=1.1in,km_rangewidth=1.0in,
            ref_km_estimatewidth=0.5in,ref_km_est_rangewidth=1.1in,ref_km_rangewidth=1.0in,
            
            or_estimatewidth=0.5in,or_est_rangewidth=1.1in,or_rangewidth=1.0in,
            
            bin_estimatewidth=0.5in,bin_est_rangewidth=1.1in,bin_rangewidth=1.0in,
            ref_bin_estimatewidth=0.5in,ref_bin_est_rangewidth=1.1in,ref_bin_rangewidth=1.0in,
            
            c_estimatewidth=0.5in,c_est_rangewidth=1.1in,c_rangewidth=1.0in,
            
            dummywidth=0.1in,
            AICwidth=0.7in,bicwidth=0.7in,log_likelihoodwidth=0.7in,
        /*2.2.3: Plot Display Options*/
          /*2.2.3.1: General Options*/
            show_plot=1,plot_columnweights=,
          /*2.2.3.2: Error Bars and Symbol options*/
            /*2.2.3.2.1: Error Bars*/ 
              errorbars=1,linecap=1,linecolor=black,linesize=2pt,
            /*2.2.3.2.2: Symbols*/ 
              symbol=circlefilled,symbolcolor=black,symbolsize=10pt,
          /*2.2.3.3: Axes options*/
            /*2.2.3.3.1: Type options*/ 
              xaxistype=linear,logbase=10,logminor=false,logtickstyle=logexpand,            
            /*2.2.3.3.2: Min, max and incrementation*/             
              tickvalues=,increment=,min=,max=,            
            /*2.2.3.3.3: Label Options*/ 
              xaxislabel=,lsize=10pt,lweight=normal,xaxislabelon=1,        
            /*2.2.3.3.4: Axis line style Options*/                 
              xlinesize=0.5pt,
            /*2.2.3.3.5: Axis tick values style Options*/   
              xtickvaluesize=10pt,xtickvalueweight=normal,
            /*2.2.3.3.6: Titles and Footnotes options*/ 
              titlesize=10pt,titleweight=bold,
              fnsize=10pt,fnweight=normal, 
          /*2.2.3.4: Reference Lines*/ 
            /*2.2.3.4.1: First Reference Line*/
              refline=,reflinepattern=1,reflinecolor=black,
            /*2.2.3.4.2: Second Reference Line*/
              srefline=,sreflinepattern=1,sreflinecolor=black,
            /*2.2.3.4.3: Reference Guides*/
              refguidelower=,refguideupper=,refguidevalign=bottom,refguidehalign=in,
              refguideweight=normal,refguidecolor=black,refguidesize=10pt,
              refguidelinecolor=black,refguidelinepattern=1,refguidelinesize=1pt,refguidespace=0.04,
              refguidelinearrow=filled,
          /*2.2.3.5: Plot Walls*/ 
            showwalls=0,wallpattern=1,wallcolor=black,
            rowline=1,rowlinesize=0.5pt,rowlinepattern=1,rowgutter=0,
            colline=1,collinesize=0.5pt,collinepattern=1,columngutter=0,
          /*2.2.3.6: Legend*/
            /*2.2.3.6.1: Turn Legend on or off*/
              show_legend=1,
            /*2.2.3.6.2: Alignment*/ 
              legendalign=bottom,legendnacross=6,legendndown=1,
            /*2.2.3.6.3: Font Styles*/
              /*2.2.3.6.3.1: Values*/
                legendvalweight=normal,legendvalsize=10pt,
              /*2.2.3.6.3.2: Titles*/
                  legendtitleweight=normal,legendtitlesize=10pt,
          /*2.2.3.7: Statistical Columns*/ 
            /*2.2.3.7.1: Font Style*/ 
              sumsize=10pt,sumweight=normal,
            /*2.2.3.7.2: Column Headers*/          
              underlineheaders=0,    
      /*2.5: Output options*/
        /*2.05: Image File Output Settings*/
          antialiasmax=1000,axiscolor=black,bgcolor=white,border=false,
          bordercolor=black,dpi=200,fontcolor=black,gpath=,height=6in,plotname=_mvmodels,
          plottype=static,svg=0,transparent=0,width=8in,
        /*2.5.1: Output Dataset*/
            out_plot=,out_table=,
        /*2.5.2: Save to a document*/
          outdoc=,destination=RTF,
          excel_sheetname=MVMODELS,           
      /*2.6: Debug options*/
        debug=0);
            
            
            
    /**Save current options to reset after macro runs**/
    %local _mergenoby _notes _qlm _odspath _starttime _listing _linesize _center _msglevel;
    %let _starttime=%sysfunc(time());
    %let _notes=%sysfunc(getoption(notes));
    %let _mergenoby=%sysfunc(getoption(mergenoby));
    %let _qlm=%sysfunc(getoption(quotelenmax)); 
    %let _linesize=%sysfunc(getoption(linesize));
    %let _center=%sysfunc(getoption(center));
    %let _msglevel=%sysfunc(getoption(msglevel));
    /**Turn off warnings for merging without a by and long quote lengths**/
    /**Turn off notes**/
    options mergenoby=NOWARN nonotes noquotelenmax msglevel=N;
    /*Don't send anything to output window, results window, and set escape character*/
    ods noresults escapechar='^';
    ods exclude all;
    %let _odspath=&sysodspath;
    %local _data;
    
    /**Process Error Handling**/
    %if &sysver < 9.3 %then %do;
        %put ERROR: SAS must be version 9.3 or later;
        %goto errhandl;
    %end;  
    %else %if %sysevalf(%superq(data)=,boolean)=1 %then %do;
        %put ERROR: DATA parameter is required;
        %put ERROR: Please enter a valid dataset;
        %goto errhandl;
    %end;   
    %else %if %sysfunc(exist(&data))=0 %then %do;
        %put ERROR: Dataset &data does not exist;
        %put ERROR: Please enter a valid dataset;
        %goto errhandl;
    %end;  
    %else %do;
        %let _data=%sysfunc(open(&data));
    %end;
          
    %local z nerror;
    %let nerror=0;  
    /**See if the listing output is turned on**/
    proc sql noprint;
        select 1 into :_listing separated by '' from sashelp.vdest where upcase(destination)='LISTING';
    quit;
    
    /**Section 1: Error Handling**/
    /**Section 1.1: Initialize Error Handling Macros**/ 
    %local _z _z2 z nerror _test i j k l m n o p;
    /*Section 1.1.1: Error Handling on Variables*/
        /*Section 1.1.1.1: Individual Model Variables*/
        /**Error Handling on Individual Model Variables**/
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
                        %put ERROR: (Model &i: %qupcase(&parm)) Variable %qupcase(%scan(%superq(&parm.),&_z,%str( ))) does not exist in dataset &dataset;
                        %local closedatid;
                        /**Close dataset**/
                        %let closedatid=%sysfunc(close(&datid));
                        %let nerror=%eval(&nerror+1);
                    %end;
                    %else %do;
                        %local closedatid;
                        %let closedatid=%sysfunc(close(&datid));
                        %if &numeric=1 %then %do;
                            %if %sysfunc(vartype(&_data,%sysfunc(varnum(&_data,%superq(&parm.)))))^=N %then %do;
                                %put ERROR: (Model &i: %qupcase(%scan(%superq(&parm.),&_z,%str( )))) variable must be numeric &nummsg;
                                %let nerror=%eval(&nerror+1);
                            %end;   
                        %end;                         
                    %end;
                %end;
                %else %do;
                    /**Give error message if variable name is number**/
                    %put ERROR: (Model &i: %qupcase(&parm)) variable is not a valid SAS variable name (%superq(&parm.));
                    %let nerror=%eval(&nerror+1);
                %end;
            %end;
            %else %if &require=1 %then %do;
                /**Give error if required variable is missing**/
                %put ERROR: (Model &i: %qupcase(&parm)) variable is a required variable but has no value;
                %let nerror=%eval(&nerror+1);
            %end;
        %mend;
        /*Section 1.1.1.2: Global Variables*/
        %macro _gvarcheck(var,require);
            %local _z;
            /**Check if variable parameter is missing**/
            %if %sysevalf(%superq(&var)=,boolean)=0 %then %do;
                %if %sysfunc(notdigit(%superq(&var))) > 0 %then
                    %do _z = 1 %to %sysfunc(countw(%superq(&var),%str( )));
                    /**Check to make sure variable names are not just numbers**/    
                    %local datid;
                    /**Open up dataset to check for variables**/
                    %let datid = %sysfunc(open(&data));
                    /**Check if variable exists in dataset**/
                    %if %sysfunc(varnum(&datid,%scan(%superq(&var),&_z,%str( )))) = 0 %then %do;
                        %put ERROR: (Global: %qupcase(&var)) Variable %qupcase(%scan(%superq(&var),&_z,%str( ))) does not exist in dataset &data;
                        %local closedatid;
                        /**Close dataset**/
                        %let closedatid=%sysfunc(close(&datid));
                        %let nerror=%eval(&nerror+1);
                    %end;
                    %else %do;
                        %local closedatid;
                        %let closedatid=%sysfunc(close(&datid));
                    %end;
                %end;
                %else %do;
                    /**Give error message if variable name is number**/
                    %put ERROR: (Global: %qupcase(&var)) Variable is not a valid SAS variable name (%superq(&var));
                    %let nerror=%eval(&nerror+1);
                %end;
            %end;
            %else %if &require=1 %then %do;
                /**Give error if required variable is missing**/
                %put ERROR: (Global: %qupcase(&var)) Variable is a required variable but has no value;
                %let nerror=%eval(&nerror+1);
            %end;
        %mend;
    /*Section 1.1.2: Error Handling on Parameters Involving units*/
        /*Section 1.1.2.1: Individual Model Parameters*/
        %macro _unitcheck(parm);
            %if %sysevalf(%superq(&parm.&i)=,boolean)=1 %then %do;
                /**Check for missingness**/
                %put ERROR: (Model &i: %qupcase(&parm)) Cannot be set to missing;
                %let nerror=%eval(&nerror+1);
            %end;
            %else %if %sysfunc(compress(%superq(&parm.&i),ABCDEFGHIJKLMNOPQRSTUVWXYZ,i)) lt 0 %then %do;
                /**Check if value is less than zero**/
                %put ERROR: (Model &i: %qupcase(&parm)) Cannot be less than zero (%qupcase(%superq(&parm.&i)));
                %let nerror=%eval(&nerror+1);
            %end;
        %mend;
        /*Section 1.1.2.2: Plot Parameters*/
        %macro _punitcheck(parm,loopmax);
            %local z;
            %do z = 1 %to &loopmax;
                %if %sysevalf(%superq(&parm.&z)=,boolean)=1 %then %do;
                    /**Check for missingness**/
                    %put ERROR: (Plot &z: %qupcase(&parm)) Cannot be set to missing;
                    %let nerror=%eval(&nerror+1);
                %end;
                %else %if %sysfunc(compress(%superq(&parm.&z),ABCDEFGHIJKLMNOPQRSTUVWXYZ,i)) lt 0 %then %do;
                    /**Check if value is less than zero**/
                    %put ERROR: (Plot &z: %qupcase(&parm)) Cannot be less than zero (%qupcase(%superq(&parm.&z)));
                    %let nerror=%eval(&nerror+1);
                %end;
            %end;
        %mend;
        /*Section 1.1.2.3: Global Parameters*/
        %macro _gunitcheck(parm);
            %if %sysevalf(%superq(&parm)=,boolean)=1 %then %do;
                /**Check if missing**/
                %put ERROR: (Global: %qupcase(&parm)) Cannot be set to missing;
                %let nerror=%eval(&nerror+1);
            %end;
            %else %if %sysfunc(compress(%superq(&parm),ABCDEFGHIJKLMNOPQRSTUVWXYZ,i)) lt 0 %then %do;
                /**Throw error**/
                %put ERROR: (Global: %qupcase(&parm)) Cannot be less than zero (%qupcase(%superq(&parm)));
                %let nerror=%eval(&nerror+1);
            %end;
        %mend;
    /*Section 1.1.3: Error Handling on Model Numeric Variables*/
        /*Section 1.1.3.1: Individual Model Numeric Variables*/
        %macro _numcheck(parm,min,contain,default,maxvals=1);
            /**Check if missing**/
            %local j;
            %if %sysevalf(%superq(&parm.&i)=,boolean)=0 %then %do;
                %if %sysfunc(countw(%superq(&parm.&i),%str( )))>&maxvals %then %do;
                    %put ERROR: (Model &i: %qupcase(&parm)) Cannot be more values listed than &maxvals;
                    %let nerror=%eval(&nerror+1);
                %end;
                %else %if &maxvals=1 %then %do;
                    %if %sysfunc(notdigit(%sysfunc(compress(%superq(&parm.&i),-.)))) > 0 %then %do;
                        /**Check if character values are present**/
                        %put ERROR: (Model &i: %qupcase(&parm)) Must be numeric.  %qupcase(%superq(&parm.&i)) is not valid.;
                        %let nerror=%eval(&nerror+1);
                    %end;  
                    %else %if %superq(&parm.&i) le &min and &contain=0 %then %do;
                        /**Check if value is below minimum threshold**/
                        %put ERROR: (Model &i: %qupcase(&parm)) Must be greater than &min.  %qupcase(%superq(&parm.&i)) is not valid.;
                        %let nerror=%eval(&nerror+1);
                    %end;  
                    %else %if %superq(&parm.&i) lt &min and &contain=1 %then %do;
                        /**Check if value is below minimum threshold**/
                        %put ERROR: (Model &i: %qupcase(&parm)) Must be greater than or equal to &min.  %qupcase(%superq(&parm.&i)) is not valid.;
                        %let nerror=%eval(&nerror+1);
                    %end; 
                %end;
                %else %do j = 1 %to %sysfunc(countw(%superq(&parm.&i),%str( )));
                    %if %sysfunc(notdigit(%sysfunc(compress(%scan(%superq(&parm.&i),&j,%str( )),-.)))) > 0 %then %do;
                        /**Check if character values are present**/
                        %put ERROR: (Model &i: %qupcase(&parm)) All listed values must be numeric.  %qupcase(%scan(%superq(&parm.&i),&j,%str( ))) is not valid.;
                        %let nerror=%eval(&nerror+1);
                    %end;  
                    %else %if %scan(%superq(&parm.&i),&j,%str( )) le &min and &contain=0 %then %do;
                        /**Check if value is below minimum threshold**/
                        %put ERROR: (Model &i: %qupcase(&parm)) All listed values must be greater than &min.  %qupcase(%scan(%superq(&parm.&i),&j,%str( ))) is not valid.;
                        %let nerror=%eval(&nerror+1);
                    %end;  
                    %else %if %scan(%superq(&parm.&i),&j,%str( )) lt &min and &contain=1 %then %do;
                        /**Check if value is below minimum threshold**/
                        %put ERROR: (Model &i: %qupcase(&parm)) All listed values must be greater than or equal to &min.  %qupcase(%scan(%superq(&parm.&i),&j,%str( ))) is not valid.;
                        %let nerror=%eval(&nerror+1);
                    %end;                 
                %end;
            %end;   
            /**if missing set to default**/     
            %else %let &parm.&i=&default;       
        %mend;  
        /*Section 1.1.3.2: Plot Numeric Variables*/
        %macro _pnumcheck(parm,min,contain,default,loopmax);
            %local z;
            %do z = 1 %to &loopmax;
                /**Check if missing**/
                %if %sysevalf(%superq(&parm.&z)=,boolean)=0 %then %do;
                    %if %sysfunc(notdigit(%sysfunc(compress(%superq(&parm.&z),-.)))) > 0 %then %do;
                        /**Check if character values are present**/
                        %put ERROR: (Plot &z: %qupcase(&parm)) Must be numeric.  %qupcase(%superq(&parm.&z)) is not valid.;
                        %let nerror=%eval(&nerror+1);
                    %end;  
                    %else %if %superq(&parm.&z) le &min and &contain=0 %then %do;
                        /**Check if value is below minimum threshold**/
                        %put ERROR: (Plot &z: %qupcase(&parm)) Must be greater than &min.  %qupcase(%superq(&parm.&z)) is not valid.;
                        %let nerror=%eval(&nerror+1);
                    %end;  
                    %else %if %superq(&parm.&z) lt &min and &contain=1 %then %do;
                        /**Check if value is below minimum threshold**/
                        %put ERROR: (Plot &z: %qupcase(&parm)) Must be greater than or equal to &min.  %qupcase(%superq(&parm.&z)) is not valid.;
                        %let nerror=%eval(&nerror+1);
                    %end; 
                %end;   
                /**if missing set to default**/     
                %else %let &parm.&z=&default;        
            %end;
        %mend;  
        %macro _pnumcheck2(parm,min,contain,default,loopmax);
            %local z z2;
            %do z = 1 %to &loopmax;
                %do z2 = 1 %to %sysfunc(countw(%superq(&parm.&z),%str( )));
                /**Check if missing**/
                %if %sysevalf(%scan(%superq(&parm.&z),&z2,%str( ))=,boolean)=0 %then %do;
                    %if %sysfunc(notdigit(%sysfunc(compress(%scan(%superq(&parm.&z),&z2,%str( )),-.)))) > 0 %then %do;
                        /**Check if character values are present**/
                        %put ERROR: (Plot &z: %qupcase(&parm)) Must be numeric.  %qupcase(%scan(%superq(&parm.&z),&z2,%str( ))) is not valid.;
                        %let nerror=%eval(&nerror+1);
                    %end;  
                    %else %if %scan(%superq(&parm.&z),&z2,%str( )) le &min and &contain=0 %then %do;
                        /**Check if value is below minimum threshold**/
                        %put ERROR: (Plot &z: %qupcase(&parm)) Must be greater than &min.  %qupcase(%scan(%superq(&parm.&z),&z2,%str( ))) is not valid.;
                        %let nerror=%eval(&nerror+1);
                    %end;  
                    %else %if %scan(%superq(&parm.&z),&z2,%str( )) lt &min and &contain=1 %then %do;
                        /**Check if value is below minimum threshold**/
                        %put ERROR: (Plot &z: %qupcase(&parm)) Must be greater than or equal to &min.  %qupcase(%scan(%superq(&parm.&z),&z2,%str( ))) is not valid.;
                        %let nerror=%eval(&nerror+1);
                    %end; 
                %end;
                %end;       
            %end;
        %mend;  
        /*Section 1.1.3.3: Global Model Numeric Variables*/
        %macro _gnumcheck(parm, min,require);
            /**Check if missing**/
            %if %sysevalf(%superq(&parm)^=,boolean) %then %do;
                %if %sysfunc(notdigit(%sysfunc(compress(%superq(&parm),-.)))) > 0 %then %do;
                    /**Check if character value**/
                    %put ERROR: (Global: %qupcase(&parm)) Must be numeric.  %qupcase(%superq(&parm)) is not valid.;
                    %let nerror=%eval(&nerror+1);
                %end;
                %else %if %sysevalf(&min^=,boolean) %then %do;
                    %if %superq(&parm) < &min %then %do;
                        /**Makes sure number is not less than the minimum**/
                        %put ERROR: (Global: %qupcase(&parm)) Must be greater than %superq(min). %qupcase(%superq(&parm)) is not valid.;
                        %let nerror=%eval(&nerror+1);
                    %end;
                %end;
            %end;
            %else %if &require=1 %then %do;
                /**Throw Error**/
                %put ERROR: (Global: %qupcase(&parm)) Cannot be missing;
                %put ERROR: (Global: %qupcase(&parm)) Possible values are numeric values greater than or equal to %superq(min);
                %let nerror=%eval(&nerror+1);           
            %end;       
        %mend;  
    /*Section 1.1.4: Error Handling on Model Parameters*/
        /*Section 1.1.4.1: Individual Model Parameters*/
        %macro _parmcheck(parm, parmlist);
            %local _test _z;
            %if %sysevalf(%superq(&parm.&i)=,boolean)=0 %then %let &parm.&i=%sysfunc(compress(%qupcase(%superq(&parm.&i)),'""'));
            %local _test _z;
            %let _test=;
            %do _z=1 %to %sysfunc(countw(&parmlist,|,m));
                %if %superq(&parm.&i)=%scan(&parmlist,&_z,|,m) %then %let _test=1;
            %end;
            %if &_test ^= 1 %then %do;
                %put ERROR: (Model &i: %qupcase(&parm)): %superq(&parm.&i) is not a valid value;
                %put ERROR: (Model &i: %qupcase(&parm)): Possible values are &parmlist;
                %let nerror=%eval(&nerror+1);
            %end;
        %mend;  
        /*Section 1.1.4.2: Plot Parameters*/
        %macro _pparmcheck(parm, parmlist,loopmax);
            %local _test _z;
            %do z = 1 %to &loopmax;
                %if %sysevalf(%superq(&parm.&z)=,boolean)=0 %then %let &parm.&z=%sysfunc(compress(%qupcase(%superq(&parm.&z)),'""'));
                %local _test _z;
                %let _test=;
                %do _z=1 %to %sysfunc(countw(&parmlist,|,m));
                    %if %superq(&parm.&z)=%scan(&parmlist,&_z,|,m) %then %let _test=1;
                %end;
                %if &_test ^= 1 %then %do;
                    %put ERROR: (Plot &z: %qupcase(&parm)): %superq(&parm.&z) is not a valid value;
                    %put ERROR: (Plot &z: %qupcase(&parm)): Possible values are &parmlist;
                    %let nerror=%eval(&nerror+1);
                %end;
            %end;
        %mend;    
        /*Section 1.1.4.3: Global Parameters*/
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
    /*Section 1.1.5: Error Handling on Line Pattern Parameters*/
        /*Section 1.1.5.1: Global Line Pattern Parameters*/     
        %macro _glinepattern(parm,_max);
            %local _patternlist z2 _test;
            %let _patternlist=%sysfunc(compress(SOLID|SHORTDASH|MEDIUMDASH|LONGDASH|MEDIUMDASHSHORTDASH|
            DASHDASHDOT|DASH|LONGDASHSHORTDASH|DOT|THINDOT|SHORTDASHDOT|MEDIUMDASHDOTDOT));
            /**Check for missing values**/
            %if %sysevalf(%superq(&parm)^=,boolean) %then %do;           
                %if %sysevalf(&_max^=,boolean) %then %do;
                    %if %sysevalf(%sysfunc(countw(%superq(&parm),%str( )))>&_max,boolean) %then %do;
                        /**Throw error**/
                        %put ERROR: (Global: %qupcase(&parm)): Number of items in list (%sysfunc(countw(%superq(&parm),%str( )))) must be less than or equal to &_max;
                        %let nerror=%eval(&nerror+1);
                    %end;
                %end;
                %do z2=1 %to %sysfunc(countw(%superq(&parm),%str( )));
                    %let _test=;
                    /**Check if values are either in the approved list, or are between 1 and 46**/
                    %if %sysfunc(notdigit(%scan(%superq(&parm),&z2,%str( ))))>0 %then %do _z = 1 %to %sysfunc(countw(&_patternlist,|));
                        %if %qupcase(%scan(%superq(&parm),&z2,%str( )))=%scan(%qupcase(%sysfunc(compress(&_patternlist))),&_z,|,m) %then %let _test=1;
                    %end;
                    %else %if %scan(%superq(&parm),&z2,%str( )) ge 1 and %scan(%superq(&parm),&z2,%str( )) le 46 %then %let _test=1;
                    %if &_test ^= 1 %then %do;
                        /**Throw error**/
                        %put ERROR: (Global: %qupcase(&parm)): %qupcase(%scan(%superq(&parm),&z2,%str( ))) is not in the list of valid values;
                        %put ERROR: (Global: %qupcase(&parm)): Possible values are %qupcase(&_patternlist) or Numbers Between 1 and 46;
                        %let nerror=%eval(&nerror+1);
                    %end;
                %end;
            %end;
            %else %do;
                /**Throw error**/
                %put ERROR: (Global: %qupcase(&parm)): Cannot be missing;           
                %put ERROR: (Global: %qupcase(&parm)): Possible values are %qupcase(&_patternlist) or Numbers Between 1 and 46;
                %let nerror=%eval(&nerror+1);       
            %end;
        %mend; 
        /*Section 1.1.5.1: Plot Model Line Pattern Parameters*/     
        %macro _plinepattern(parm,_max,loopmax);
            %local _patternlist z2 _test;
            %let _patternlist=%sysfunc(compress(SOLID|SHORTDASH|MEDIUMDASH|LONGDASH|MEDIUMDASHSHORTDASH|
            DASHDASHDOT|DASH|LONGDASHSHORTDASH|DOT|THINDOT|SHORTDASHDOT|MEDIUMDASHDOTDOT));
            %do z = 1 %to &loopmax;
                /**Check for missing values**/
                %if %sysevalf(%superq(&parm.&z)^=,boolean) %then %do;           
                    %if %sysevalf(&_max^=,boolean) %then %do;
                        %if %sysevalf(%sysfunc(countw(%superq(&parm),%str( )))>&_max,boolean) %then %do;
                            /**Throw error**/
                            %put ERROR: (%qupcase(&parm)): Number of items in list (%sysfunc(countw(%superq(&parm.&z),%str( )))) must be less than or equal to &_max;
                            %let nerror=%eval(&nerror+1);
                        %end;
                    %end;
                    %do z2=1 %to %sysfunc(countw(%superq(&parm.&z),%str( )));
                        %let _test=;
                        /**Check if values are either in the approved list, or are between 1 and 46**/
                        %if %sysfunc(notdigit(%scan(%superq(&parm.&z),&z2,%str( ))))>0 %then %do _z = 1 %to %sysfunc(countw(&_patternlist,|));
                            %if %qupcase(%scan(%superq(&parm.&z),&z2,%str( )))=%scan(%qupcase(%sysfunc(compress(&_patternlist))),&_z,|,m) %then %let _test=1;
                        %end;
                        %else %if %scan(%superq(&parm.&z),&z2,%str( )) ge 1 and %scan(%superq(&parm.&z),&z2,%str( )) le 46 %then %let _test=1;
                        %if &_test ^= 1 %then %do;
                            /**Throw error**/
                            %put ERROR: (Model &z: %qupcase(&parm)): %qupcase(%scan(%superq(&parm.&z),&z2,%str( ))) is not in the list of valid values;
                            %put ERROR: (Model &z: %qupcase(&parm)): Possible values are %qupcase(&_patternlist) or Numbers Between 1 and 46;
                            %let nerror=%eval(&nerror+1);
                        %end;
                    %end;
                %end;
                %else %do;
                    /**Throw error**/
                    %put ERROR: (Model &z: %qupcase(&parm)): Cannot be missing;           
                    %put ERROR: (Model &z: %qupcase(&parm)): Possible values are %qupcase(&_patternlist) or Numbers Between 1 and 46;
                    %let nerror=%eval(&nerror+1);       
                %end;
            %end;
        %mend; 
    /*Section 1.1.6: Error Handling on List Parameters*/   
        /*Section 1.1.6.1: Plot List Parameters*/   
        %macro _plist(parm,list,_max,loopmax);
            %local _z2 z;
            %do z = 1 %to &loopmax;
                /**Check for missing values**/
                %if %sysevalf(%superq(&parm.&z)^=,boolean) %then %do;
                    %if %sysevalf(&_max^=,boolean) %then %do;
                        %if %sysevalf(%sysfunc(countw(%superq(&parm.&z),%str( ))),>&_max) %then %do;
                            /**Throw error**/
                            %put ERROR: (%qupcase(&parm)): Number of items in list (%sysfunc(countw(%superq(&parm.&z),%str( )))) must be less than &_max;
                            %let nerror=%eval(&nerror+1);
                        %end;
                    %end;
                    %do z2=1 %to %sysfunc(countw(%superq(&parm.&z),%str( )));
                        %let _test=;
                        /**Check if values are either in the approved list**/
                        %do _z = 1 %to %sysfunc(countw(&list,|));
                            %if %scan(%qupcase(%superq(&parm.&z)),&z2,%str( ))=%scan(%qupcase(%sysfunc(compress(&list))),&_z,|,m) 
                                %then %let _test=1;
                        %end;
                        %if &_test ^= 1 %then %do;
                            /**Throw error**/
                            %put ERROR: (Plot &z: %qupcase(&parm)): %scan(%qupcase(%superq(&parm.&z)),&z2,%str( )) is not in the list of valid values;
                            %put ERROR: (Plot &z: %qupcase(&parm)): Possible values are %qupcase(&list);
                            %let nerror=%eval(&nerror+1);
                        %end;
                    %end;
                %end;
                %else %do;
                    /**Throw error**/
                    %put ERROR: (Plot &z: %qupcase(&parm)): Cannot be missing;          
                    %put ERROR: (Plot &z: %qupcase(&parm)): Possible values are %qupcase(&list);
                    %let nerror=%eval(&nerror+1);       
                %end;
            %end;
        %mend;
        /*Section 1.1.6.1: Model List Parameters*/   
        %macro _list(parm,list,_max,loopmax);
            %local _z2 z;
            %do z = 1 %to &loopmax;
                /**Check for missing values**/
                %if %sysevalf(%superq(&parm.&z)^=,boolean) %then %do;
                    %if %sysevalf(&_max^=,boolean) %then %do;
                        %if %sysevalf(%sysfunc(countw(%superq(&parm.&z),%str( ))),>&_max) %then %do;
                            /**Throw error**/
                            %put ERROR: (%qupcase(&parm)): Number of items in list (%sysfunc(countw(%superq(&parm.&z),%str( )))) must be less than &_max;
                            %let nerror=%eval(&nerror+1);
                        %end;
                    %end;
                    %do z2=1 %to %sysfunc(countw(%superq(&parm.&z),%str( )));
                        %let _test=;
                        /**Check if values are either in the approved list**/
                        %do _z = 1 %to %sysfunc(countw(&list,|));
                            %if %scan(%qupcase(%superq(&parm.&z)),&z2,%str( ))=%scan(%qupcase(%sysfunc(compress(&list))),&_z,|,m) 
                                %then %let _test=1;
                        %end;
                        %if &_test ^= 1 %then %do;
                            /**Throw error**/
                            %put ERROR: (Model &z2: %qupcase(&parm)): %scan(%qupcase(%superq(&parm.&z)),&z2,%str( )) is not in the list of valid values;
                            %put ERROR: (Model &z2: %qupcase(&parm)): Possible values are %qupcase(&list);
                            %let nerror=%eval(&nerror+1);
                        %end;
                    %end;
                %end;
                %else %do;
                    /**Throw error**/
                    %put ERROR: (Model &z: %qupcase(&parm)): Cannot be missing;          
                    %put ERROR: (Model &z: %qupcase(&parm)): Possible values are %qupcase(&list);
                    %let nerror=%eval(&nerror+1);       
                %end;
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
                    %put ERROR: (Model &i: &lbl): %qupcase(%scan(%superq(&var.),&_z2,%str( ))) is not in the list of valid values &msg;
                    %put ERROR: (Model &i: &lbl): Possible values are %qupcase(&_patternlist);
                    %let nerror=%eval(&nerror+1);
                %end;
            %end;
            %else %do;
                /**Throw error**/
                %put ERROR: (Model &i: &lbl): %qupcase(%superq(&var.)) is not in the list of valid values &msg;         
                %put ERROR: (Model &i: &lbl): Possible values are %qupcase(&_patternlist);
                %let nerror=%eval(&nerror+1);       
            %end;
        %mend;
        %macro _glistcheck(var=,_patternlist=,lbl=,msg=);
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
        /*Section 1.1.6.2: Global List Parameters*/   
        %macro _glist(parm,list,_max);
            /**Check for missing values**/
            %if %sysevalf(%superq(&parm)^=,boolean) %then %do;
                %if %sysevalf(&_max^=,boolean) %then %do;
                    %if %sysevalf(%sysfunc(countw(%superq(&parm),%str( ))),>&_max) %then %do;
                        /**Throw error**/
                        %put ERROR: (%qupcase(&parm)): Number of items in list (%sysfunc(countw(%superq(&parm),%str( )))) must be less than &_max;
                        %let nerror=%eval(&nerror+1);
                    %end;
                %end;
                %do z2=1 %to %sysfunc(countw(%superq(&parm),%str( )));
                    %let _test=;
                    /**Check if values are either in the approved list**/
                    %do _z = 1 %to %sysfunc(countw(&list,|));
                        %if %scan(%qupcase(%superq(&parm)),&z2,%str( ))=%scan(%qupcase(%sysfunc(compress(&list))),&_z,|,m) 
                            %then %let _test=1;
                    %end;
                    %if &_test ^= 1 %then %do;
                        /**Throw error**/
                        %put ERROR: (Model &z2: %qupcase(&parm)): %scan(%qupcase(%superq(&parm)),&z2,%str( )) is not in the list of valid values;
                        %put ERROR: (Model &z2: %qupcase(&parm)): Possible values are %qupcase(&list);
                        %let nerror=%eval(&nerror+1);
                    %end;
                %end;
            %end;
            %else %do;
                /**Throw error**/
                %put ERROR: (Model &z: %qupcase(&parm)): Cannot be missing;          
                %put ERROR: (Model &z: %qupcase(&parm)): Possible values are %qupcase(&list);
                %let nerror=%eval(&nerror+1);       
            %end;
        %mend;
    /**Section 1.3: Check Global Macro Parameters**/
    %let nerror=0;
    
    
    %_gvarcheck(rowby,0)
    %_gvarcheck(colby,0)
    %_gvarcheck(groupby,0)
    /*Section 1.3.1: Global Parameters*/
    %_gparmcheck(debug,0|1)
    %_gparmcheck(border,TRUE|FALSE)
    %_gparmcheck(pfoot,0|1) 
    %_gparmcheck(xaxislabelon,0|1) 
    %_gparmcheck(lweight,BOLD|NORMAL)
    %_gparmcheck(xtickvalueweight,BOLD|NORMAL)
    %_gparmcheck(sumweight,BOLD|NORMAL)
    %_gparmcheck(showwalls,1|0)
    %_gparmcheck(linecap,1|0)
    %_gparmcheck(shading,4|3|2|1|0)  
    %if &sysvlong >= 9.04.01M3P062415 %then %do;
        %_gparmcheck(destination,RTF|PDF|HTML|EXCEL|POWERPOINT)
    %end;
    %else %do;        
        %_gparmcheck(destination,RTF|PDF|HTML)
    %end;
    %_gparmcheck(show_legend,0|1)
    %_gparmcheck(legendalign,TOP|BOTTOM|LEFT|RIGHT)
    %_gparmcheck(legendvalweight,BOLD|NORMAL)
    %_gparmcheck(legendtitleweight,BOLD|NORMAL)
    %_gparmcheck(titlealign,LEFT|CENTER|RIGHT)
    %_gparmcheck(titleweight,BOLD|NORMAL)
    %_gparmcheck(fnalign,LEFT|CENTER|RIGHT)
    %_gparmcheck(fnweight,BOLD|NORMAL)
    %_gparmcheck(subheaderalign,LEFT|CENTER|RIGHT)
    %_gparmcheck(svg,0|1)
    %_gparmcheck(method,SURVIVAL|LOGISTIC)
    %_gparmcheck(rowbylabelon,0|1)
    %_gparmcheck(rowbyorder_formatted,0|1)
    %_gparmcheck(rowbytable_display,SPAN|SUBHEADERS)
    %_gparmcheck(rowline,0|1)
    %_gparmcheck(colbylabelon,0|1)
    %_gparmcheck(colbyorder_formatted,0|1)
    %_gparmcheck(colline,0|1)
    %_gparmcheck(groupbylabelon,0|1)
    %_gparmcheck(groupbyorder_formatted,0|1)
    %_gparmcheck(groupby_colortext,0|1)
    %_gparmcheck(underlineheaders,0|1)
    %_gparmcheck(colsubtitles,START|END)
    %_gparmcheck(refguidevalign,BOTTOM|TOP)
    %_gparmcheck(refguidehalign,IN|CENTER)
    %_gparmcheck(refguideweight,BOLD|NORMAL)
    %_gparmcheck(refguidelinearrow,FILLED|OPEN|BARBED|CLOSED)   
    %_gparmcheck(show_plot,0|1)
    %_gparmcheck(show_table,0|1)
    %_gparmcheck(plottype,STATIC|BMP|DIB|EMF|EPSI|GIF|JFIF|JPEG|PBM|PCD|PCL|PDF|PICT|PNG|PS|SVG|TIFF|WMF|XBM|XPM)
    %_gparmcheck(modellines,0|1)
    %if &sysvlong >= 9.04.01M3P062415 %then %do;
        %_gparmcheck(surv_method,KM|1-KM|CIF)
    %end;
    %else %do;
        %_gparmcheck(surv_method,KM|1-KM)
    %end;        
            
    /**Transparent Background Option**/
    %if &sysvlong >= 9.04.01M3P062415 %then %do;
        %_gparmcheck(transparent,0|1)
    %end;
    %else %do;
        %_gparmcheck(transparent,0)
    %end;
    %_gparmcheck(tabledataweight,MEDIUM|BOLD)
    %_gparmcheck(tablefootnoteweight,MEDIUM|BOLD)
    %_gparmcheck(tableheaderweight,MEDIUM|BOLD)
    
    /*Section 1.3.2: Global Unit Parameters*/
    %_gunitcheck(height)
    %_gunitcheck(width)
    %_gunitcheck(lsize)
    %_gunitcheck(xtickvaluesize)
    %_gunitcheck(subsize)
    %_gunitcheck(sumsize)
    %_gunitcheck(legendvalsize)
    %_gunitcheck(legendtitlesize)
    %_gunitcheck(titlesize)
    %_gunitcheck(fnsize)
    %_gunitcheck(collinesize)
    %_gunitcheck(rowlinesize)
    %_gunitcheck(xlinesize)
    %_gunitcheck(refguidesize)
    %_gunitcheck(refguidelinesize)
    
    %_gunitcheck(subtitlewidth)
    %_gunitcheck(rowbywidth)
    %_gunitcheck(groupbywidth)
    %_gunitcheck(totalwidth)
    %_gunitcheck(eventswidth)
    %_gunitcheck(ev_twidth)
    %_gunitcheck(pctwidth)
    %_gunitcheck(ev_t_pctwidth)
    %_gunitcheck(pvalwidth)
    %_gunitcheck(hr_estimatewidth)
    %_gunitcheck(hr_est_rangewidth)
    %_gunitcheck(hr_rangewidth)
    %_gunitcheck(med_estimatewidth)
    %_gunitcheck(med_est_rangewidth)
    %_gunitcheck(med_rangewidth)
    %_gunitcheck(km_estimatewidth)
    %_gunitcheck(km_est_rangewidth)
    %_gunitcheck(km_rangewidth)
    %_gunitcheck(or_estimatewidth)
    %_gunitcheck(or_est_rangewidth)
    %_gunitcheck(or_rangewidth)
    %_gunitcheck(bin_estimatewidth)
    %_gunitcheck(bin_est_rangewidth)
    %_gunitcheck(bin_rangewidth)
    %_gunitcheck(c_estimatewidth)
    %_gunitcheck(c_est_rangewidth)
    %_gunitcheck(c_rangewidth)
    %_gunitcheck(dummywidth)
    %_gunitcheck(AICwidth)
    %_gunitcheck(bicwidth)
    %_gunitcheck(log_likelihoodwidth)
    %_gunitcheck(tabledatasize)
    %_gunitcheck(tablefootnotesize)
    %_gunitcheck(tableheadersize)
    
    /*Section 1.3.3: Global Numeric Parameters*/
    %_gnumcheck(nmodels,1)
    %_gnumcheck(antialiasmax,100)
    %_gnumcheck(dpi,100)
    %_gnumcheck(legendnacross,1)
    %_gnumcheck(legendndown,1)
    %_gnumcheck(pvaldigits,0)
    %_gnumcheck(hrdigits,0)
    %_gnumcheck(mediandigits,0)
    %_gnumcheck(cdigits,0)
    %_gnumcheck(ordigits,0)
    %_gnumcheck(AICdigits,0)
    %_gnumcheck(bicdigits,0)
    %_gnumcheck(lldigits,0)
    %_gnumcheck(pctdigits,0)
    %_gnumcheck(refguidespace,0,0)
    %_gnumcheck(rowgutter,0,1)
    %_gnumcheck(columngutter,0,1)
    %if %sysevalf(%qupcase(%superq(kmdigits))^=AUTO,boolean) %then %do; %_gnumcheck(kmdigits,0) %end;
    %if %sysevalf(%qupcase(%superq(bindigits))^=AUTO,boolean) %then %do; %_gnumcheck(bindigits,0) %end;
    /**Global Line Pattern**/
    %_glinepattern(wallpattern,1)
    %_glinepattern(reflinepattern,1)
    %_glinepattern(sreflinepattern,1)
    %_glinepattern(rowlinepattern,1)
    %_glinepattern(collinepattern,1)
    %_glinepattern(refguidelinepattern,1)
    
    /**Section 1.5: Check Individual Model Macro Parameters**/
    /**Section 1.5.1: Create Individual Model Macro Parameters**/
    %local _mvarlist;
    %let _mvarlist=%sysfunc(compress(
            bold_cov_label|bold_cov_value|bold_by_label|bold_by_value|bold_model_title|
            indent_cov_label|indent_cov_value|indent_by_label|indent_by_value|indent_model_title|
            bylabelon|errorbars|linecolor|symbolcolor|symbol|linesize|symbolsize|addspaces|
            
            time|cens|cen_vl|ev_vl|landmark|surv_method|ties|
            timelist|tdivisor|estfmt|conftype|
            
            event|eventcov|
            
            strata|show_adjcovariates|show_modelstats|model_title|model_title_ownrow|
            
            cont_step|cont_display|cat_order|cat_order_formatted|cat_ref|cat_display|
            by|byorder|byorder_formatted|bylabel|
            labels|where|
            
            covariates|type|
            pval_covariates|pval_type3|pval_by|pval_priority
        ));
    %local i j l m n o k; 
    /**Cycle through each macro parameter**/
    %if &nerror=0 %then %do i = 1 %to &nmodels; 
        %do j = 1 %to %sysfunc(countw(&_mvarlist,|));
            %local v&j;
            %let v&j=%scan(%superq(_mvarlist),&j,|);
            %local &&v&j..&i;
            /**If the | delimiter is detected, assign the different values between | to numbered parameters**/
            /**Else Assign the same value to all numbered parameters**/
            %if %index(%superq(&&v&j),|)>0 %then %let &&v&j..&i=%scan(%superq(&&v&j),&i,|,m);
            %else %let &&v&j..&i=%scan(%superq(&&v&j),1,|,m); 
        %end;                
    %end;
      
    /*Check model specific parameters*/
    %if &nerror=0 %then %do i = 1 %to &nmodels; 
        %_parmcheck(bylabelon,.|0|1) 
        %_parmcheck(bold_model_title,.|1|0)
        %_parmcheck(bold_cov_label,.|1|0)
        %_parmcheck(bold_cov_value,.|1|0)
        %_parmcheck(bold_by_label,.|1|0)
        %_parmcheck(bold_by_value,.|1|0)
        %_parmcheck(indent_model_title,.|0|1|2|3|4)
        %_parmcheck(indent_cov_label,.|0|1|2|3|4)
        %_parmcheck(indent_cov_value,.|0|1|2|3|4)
        %_parmcheck(indent_by_label,.|0|1|2|3|4)
        %_parmcheck(indent_by_value,.|0|1|2|3|4)         
        %_parmcheck(errorbars,0|1)         
        %_parmcheck(cat_order_formatted,0|1) 
        %_parmcheck(byorder_formatted,0|1) 
        %_parmcheck(pval_priority,COVARIATE|TYPE3)
        
        %_unitcheck(symbolsize)       
        %_unitcheck(linesize)   
        
        %_numcheck(addspaces,0,1,0)     
        
        %local _ncov&i _ncat&i _ncont&i _lasttype&i _covariates&i _strata&i _test;
        %if %sysevalf(%superq(covariates&i)^=,boolean) %then %do k = 1 %to %sysfunc(countw(%superq(covariates&i),%str( )));
            %let _test=1;
            %if %sysevalf(%qupcase(%scan(%superq(covariates&i),&k,%str( )))=%qupcase(%superq(colby)),boolean) %then %do;
                %put WARNING: (Model &i): %qupcase(%scan(%superq(covariates&i),&k,%str( ))) dropped from model due to matching COLBY; 
                %let _test=0;
            %end;
            %if %sysevalf(%qupcase(%scan(%superq(covariates&i),&k,%str( )))=%qupcase(%superq(rowby)),boolean) %then %do; 
                %put WARNING: (Model &i): %qupcase(%scan(%superq(covariates&i),&k,%str( ))) dropped from model due to matching ROWBY; 
                %let _test=0;
            %end;
            %if %sysevalf(%qupcase(%scan(%superq(covariates&i),&k,%str( )))=%qupcase(%superq(groupby)),boolean) %then %do; 
                %put WARNING: (Model &i): %qupcase(%scan(%superq(covariates&i),&k,%str( ))) dropped from model due to matching GROUPBY; 
                %let _test=0;
            %end;
            %if %sysevalf(%superq(by&i)^=,boolean) %then %do j=1 %to %sysfunc(countw(%superq(by&i),%str( )));
                %if %sysevalf(%qupcase(%scan(%superq(covariates&i),&k,%str( )))=%qupcase(%qscan(%superq(by&i),&j,%str( ))),boolean) %then %do; 
                    %put WARNING: (Model &i): %qupcase(%scan(%superq(covariates&i),&k,%str( ))) dropped from model due to matching a BY variable; 
                    %let _test=0;
                %end;
            %end;
            %if %sysevalf(%superq(strata&i)^=,boolean) %then %do j=1 %to %sysfunc(countw(%superq(strata&i),%str( )));
                %if %sysevalf(%qupcase(%scan(%superq(covariates&i),&k,%str( )))=%qupcase(%qscan(%superq(strata&i),&j,%str( ))),boolean) %then %do;  
                    %put WARNING: (Model &i): %qupcase(%scan(%superq(covariates&i),&k,%str( ))) dropped from model due to matching a STRATA variable; 
                    %let _test=0;
                %end;
            %end;
            %if &_test=1 %then %let _covariates&i=&&_covariates&i %qupcase(%scan(%superq(covariates&i),&k,%str( )));
        %end;
        %if %sysevalf(%superq(strata&i)^=,boolean) %then %do k = 1 %to %sysfunc(countw(%superq(strata&i),%str( )));
            %let _test=1;
            %if %sysevalf(%qupcase(%scan(%superq(strata&i),&k,%str( )))=%qupcase(%superq(colby)),boolean) %then %do;
                %put WARNING: (Model &i): %qupcase(%scan(%superq(strata&i),&k,%str( ))) dropped model strata due to matching COLBY; 
                %let _test=0;
            %end;
            %if %sysevalf(%qupcase(%scan(%superq(strata&i),&k,%str( )))=%qupcase(%superq(rowby)),boolean) %then %do; 
                %put WARNING: (Model &i): %qupcase(%scan(%superq(strata&i),&k,%str( ))) dropped model strata due to matching ROWBY; 
                %let _test=0;
            %end;
            %if %sysevalf(%qupcase(%scan(%superq(strata&i),&k,%str( )))=%qupcase(%superq(groupby)),boolean) %then %do; 
                %put WARNING: (Model &i): %qupcase(%scan(%superq(strata&i),&k,%str( ))) dropped model strata due to matching GROUPBY; 
                %let _test=0;
            %end;
            %if %sysevalf(%superq(by&i)^=,boolean) %then %do j=1 %to %sysfunc(countw(%superq(by&i),%str( )));
                %if %sysevalf(%qupcase(%scan(%superq(strata&i),&k,%str( )))=%qupcase(%qscan(%superq(by&i),&j,%str( ))),boolean) %then %do; 
                    %put WARNING: (Model &i): %qupcase(%scan(%superq(strata&i),&k,%str( ))) dropped model strata due to matching a BY variable; 
                    %let _test=0;
                %end;
            %end;
            %if &_test=1 %then %let _strata&i=&&_strata&i %qupcase(%scan(%superq(strata&i),&k,%str( )));
        %end;
        %let covariates&i=&&_covariates&i;
        %let strata&i=&&_strata&i;
        %let _ncov&i=%sysfunc(countw(%superq(covariates&i),%str( )));
        %let _ncat&i=0;
        %let _ncont&i=0;
        /**Check list parameters**/
        %if &&_ncov&i> 0 %then %_listcheck(var=type&i,_patternlist=1|2);
        %if &&_ncov&i> 0 and &nerror=0 %then %do j = 1 %to &&_ncov&i;
            /*Continuous*/
            %if %scan(%superq(type&i),&j,%str( ))=1 or (&&_lasttype&i=1 and %sysevalf(%scan(%superq(type&i),&j,%str( ))=,boolean)) %then %do;
                %let _lasttype&i=1;
                %let _ncont&i=%sysevalf(&&_ncont&i+1);
                %local _cont&i._&&_ncont&i;
                %let _cont&i._%superq(_ncont&i)=%scan(%superq(covariates&i),&j,%str( ));
            %end;
            /*Categorical*/
            %else %if %scan(%superq(type&i),&j,%str( ))=2 or (&&_lasttype&i=2 and %sysevalf(%scan(%superq(type&i),&j,%str( ))=,boolean)) %then %do;
                %let _lasttype&i=2;
                %let _ncat&i=%sysevalf(&&_ncat&i+1);
                %local _cat&i._&&_ncat&i;
                %let _cat&i._%superq(_ncat&i)=%scan(%superq(covariates&i),&j,%str( ));
            %end;
            %if %sysevalf(%scan(%superq(type&i),&j,%str( ))=,boolean) %then %let type&i=&&type&i &&_lasttype&i;
        %end;
        /*Check that categorical covariates exist*/
        %if &&_ncat&i> 0 and &nerror=0 %then %do j = 1 %to &&_ncat&i;
            %_varcheck(_cat&i._&j,0,0)
        %end;
        /*Check that continuous covariates exist*/
        %if &&_ncont&i> 0 and &nerror=0 %then %do j = 1 %to &&_ncont&i;
            %_varcheck(_cont&i._&j,0,1,nummsg=Continuous covariates must be numeric)
        %end;
        %if %qupcase(&method)=SURVIVAL %then %do;
            /*Check that survival variables exist*/
            %_varcheck(time&i,1,1)
            %_varcheck(cens&i,1,1)

            /*2.2.1: Time and Censor Variables*/
            /*Section 2.2.4.1: Landmark Variables*/
            /**Check if variable parameter is missing**/
            %if %sysevalf(%superq(landmark&i)=,boolean)=0 %then %do;
                %if %sysfunc(notdigit(%sysfunc(compress(%superq(landmark&i),.-)))) > 0 %then %do;
                    /**Check to make sure variable names are not just numbers**/
                    %local datid;
                    /**Open up dataset to check for variables**/
                    %let datid = %sysfunc(open(&data));
                    /**Check if variable exists in dataset**/
                    %if %sysfunc(varnum(&datid,%superq(landmark&i))) = 0 %then %do;
                        %put ERROR: (Model &i: %qupcase(landmark)) Variable %qupcase(%superq(landmark&i)) does not exist in dataset &data;
                        %local closedatid;
                        /**Close dataset**/
                        %let closedatid=%sysfunc(close(&datid));
                        %let nerror=%eval(&nerror+1);
                    %end;
                    %else %do;
                        %local closedatid;
                        %let closedatid=%sysfunc(close(&datid));
                    %end;
                %end;
            %end;
            /*Check survival parameters*/
            %_parmcheck(ties,BRESLOW|DISCRETE|EFRON|EXACT)
            %if %qupcase(&surv_method)^=CIF %then %do;
                %_parmcheck(pval_type3,0|1|2|3)
                %_parmcheck(pval_by,0|1|2)
            %end;
            %else %do;
                %_parmcheck(pval_type3,0|1)
                %_parmcheck(pval_by,0|1)
            %end;
            %_parmcheck(pval_covariates,0|1)
            %_parmcheck(pval_by,0|1|2)
            %if %sysevalf(%qupcase(%superq(conftype&i))=AUTO,boolean) %then %let conftype&i=LOG;
            %_parmcheck(conftype,LOG|LOGLOG|LINEAR|ASINSQRT|LOGIT)
            /*Check numeric variables*/
            %_numcheck(cen_vl)
            %if %sysevalf(%qupcase(%superq(surv_method&i))=CIF,boolean) %then %_numcheck(ev_vl);
            %_numcheck(timelist,0,0,,maxvals=%sysfunc(countw(%superq(timelist&i),%str( ))))
            %_numcheck(tdivisor,0,0)
        %end;
        /*Check that logistic variables exist*/
        %else %if %qupcase(&method)=LOGISTIC %then %do;
            %_varcheck(eventcov&i,1,0)
            %_parmcheck(pval_type3,0|1)
            %_parmcheck(pval_covariates,0|1)
            %_parmcheck(pval_by,0|1|2)
        %end;
        /*Check that stratification variables exist*/
        %_varcheck(strata&i)
        /*Check that BY variables exist*/
        %_varcheck(by&i)
        
        
        
        %_parmcheck(show_modelstats,2|1|0)
        %_parmcheck(show_adjcovariates,1|0)
        %_parmcheck(model_title_ownrow,1|0)
        %_parmcheck(cat_display,1|2|3|4|5)
        %_parmcheck(cont_display,1|2|3)
        %_parmcheck(estfmt,PPT|PCT)
        %_numcheck(cont_step,0,0,maxvals=%sysfunc(countw(%superq(cont_step&i),%str( ))))
    %end;     
        
    /*Confidence Interval Type*/
    %if %qupcase(&conftype)=AUTO and %qupcase(&method)=SURVIVAL %then %let conftype=LOG;
    %else %if %qupcase(&conftype)=AUTO and %qupcase(&method)=LOGISTIC %then %let conftype=BIN;

    %if %sysevalf(%qupcase(&kmdigits)=AUTO,boolean) and %sysevalf(%qupcase(%superq(estfmt))=PCT,boolean) %then %Let kmdigits=1;
    %else %if %sysevalf(%qupcase(&kmdigits)=AUTO,boolean) and %sysevalf(%qupcase(%superq(estfmt))=PPT,boolean) %then %Let kmdigits=2;   
    %if %sysevalf(%qupcase(&bindigits)=AUTO,boolean) and %sysevalf(%qupcase(%superq(estfmt))=PCT,boolean) %then %Let bindigits=1;
    %else %if %sysevalf(%qupcase(&bindigits)=AUTO,boolean) and %sysevalf(%qupcase(%superq(estfmt))=PPT,boolean) %then %Let bindigits=2;
    /**Display Variables**/
    %if %sysevalf(%qupcase(&plot_display)=STANDARD,boolean) %then %do;
        %if %qupcase(&method)=SURVIVAL %then %do;
            %let plot_display=subtitle;
            %if %sysevalf(%sysfunc(compress(%superq(covariates),|))^=,boolean) %then %do;
                %let plot_display=&plot_display hr_plot;
                %if %sysfunc(find(&show_modelstats,1))>0 or %sysfunc(find(&show_modelstats,2))>0 or
                    (%sysevalf(%superq(covariates)^=,boolean) and %sysfunc(find(%superq(type),2))>0
                     and %sysfunc(find(%superq(cat_display),4))>0) %then %let plot_display=&plot_display ev_t hr_est_range;
                %else %let plot_display=&plot_display hr_est_range;
                %if %sysevalf(%superq(timelist)^=,boolean) %then %do i = 1 %to %sysfunc(countw(%superq(timelist),%str( )));
                    %let plot_display=&plot_display km_est_range&i;
                %end;
                %if %sysevalf(%sysfunc(compress(%superq(pval_covariates),0|))^=,boolean) or
                    %sysevalf(%sysfunc(compress(%superq(pval_type3),0|))^=,boolean) or
                    (%sysevalf(%sysfunc(compress(%superq(pval_by),0|))^=,boolean) and %sysevalf(%sysfunc(compress(%superq(by),|))^=,boolean)) %then
                    %let plot_display=&plot_display pval;  
            %end;
            %else %do;
                %if %sysevalf(%superq(timelist)^=,boolean) %then %do i = 1 %to %sysfunc(countw(%superq(timelist),%str( )));
                    %if &i=1 and %sysfunc(find(&show_modelstats,1))>0 %then %let plot_display=&plot_display km_plot&i ev_t;
                    %else %let plot_display=&plot_display km_plot&i;
                    %let plot_display=&plot_display km_est_range&i;
                %end; 
                %else %if %sysfunc(find(&show_modelstats,1))>0 %then %let plot_display=&plot_display med_plot ev_t med_est_range;
                %else %let plot_display=&plot_display med_plot med_est_range;
                %if %sysevalf(%sysfunc(compress(%superq(pval_by),0|))^=,boolean) and %sysevalf(%sysfunc(compress(%superq(by),|))^=,boolean) %then
                    %let plot_display=&plot_display pval;                
            %end;
        %end;
        %else %if %qupcase(&method)=LOGISTIC %then %do;
            %let plot_display=subtitle;
            %if %sysevalf(%sysfunc(compress(%superq(covariates),|))^=,boolean) %then %do;
                %let plot_display=&plot_display or_plot;
                %if %sysfunc(find(&show_modelstats,1))>0 %then %let plot_display=&plot_display ev_t or_est_range;
                %else %let plot_display=&plot_display or_est_range;
                %if %sysevalf(%sysfunc(compress(%superq(pval_covariates),0|))^=,boolean) or
                    %sysevalf(%sysfunc(compress(%superq(pval_type3),0|))^=,boolean) or
                    (%sysevalf(%sysfunc(compress(%superq(pval_by),0|))^=,boolean) and %sysevalf(%sysfunc(compress(%superq(by),|))^=,boolean)) %then
                    %let plot_display=&plot_display pval;
            %end;
            %else %do;
                %if %sysfunc(find(&show_modelstats,1))>0 %then %let plot_display=&plot_display bin_plot ev_t bin_est_range;
                %else %let plot_display=&plot_display bin_plot bin_est_range;
                %if %sysevalf(%sysfunc(compress(%superq(pval_by),0|))^=,boolean) and %sysevalf(%sysfunc(compress(%superq(by),|))^=,boolean) %then
                    %let plot_display=&plot_display pval;                
            %end;
        %end;
    %end;
    %else %if &nerror=0 %then %do;
        %local list;
        %if %qupcase(&method)=SURVIVAL %then %do;
            %let list=SUBTITLE|TOTAL|EVENTS|EV_T|PCT|EV_T_PCT|MED_ESTIMATE|MED_EST_RANGE|MED_RANGE|MED_PLOT;
            %if %sysevalf(%sysfunc(compress(%superq(covariates),|))^=,boolean) %then %do;
                %let list=&list|REF_TOTAL|REF_EVENTS|REF_EV_T|REF_PCT|REF_EV_T_PCT|REF_MED_ESTIMATE|REF_MED_EST_RANGE|REF_MED_RANGE;
                %let list=&list|HR_ESTIMATE|HR_EST_RANGE|HR_RANGE|HR_PLOT|AIC|BIC|LOGLIKELIHOOD;
                %if %sysevalf(%qupcase(&surv_method)^=CIF,boolean) %then %let list=&list|C_ESTIMATE|C_EST_RANGE|C_RANGE|C_PLOT;
            %end;
            %if %sysevalf(%superq(timelist)^=,boolean) %then %do i = 1 %to %sysfunc(countw(%superq(timelist),%str( )));
                %let list=&list|KM_ESTIMATE&i|KM_EST_RANGE&i|KM_RANGE&i|KM_PLOT&i;
                %if %sysevalf(%sysfunc(compress(%superq(covariates),|))^=,boolean) %then %do;
                    %let list=&list|REF_KM_ESTIMATE&i|REF_KM_EST_RANGE&i|REF_KM_RANGE&i;
                %end;
            %end;
            %if %sysfunc(find(%superq(pval_by),1)) or %sysfunc(find(%superq(pval_by),2)) or 
                %sysfunc(find(%superq(pval_type3),1)) or %sysfunc(find(%superq(pval_type3),2)) or %sysfunc(find(%superq(pval_type3),3)) or
                %sysfunc(find(%superq(pval_covariates),1)) %then %let list=&list|PVAL;
            %_glistcheck(var=plot_display,_patternlist=&list,lbl=PLOT_DISPLAY,msg=)
            %if %sysfunc(find(&table_display,C_,i))>0 and %qupcase(&surv_method)=CIF %then
                %put WARNING: C-index cannot be calculated from a competing risks model.;
        %end;
        %else %if %qupcase(&method)=LOGISTIC %then %do;
            %let list=SUBTITLE|TOTAL|EVENTS|EV_T|PCT|EV_T_PCT|BIN_ESTIMATE|BIN_EST_RANGE|BIN_RANGE|BIN_PLOT;
            %if %sysevalf(%sysfunc(compress(%superq(covariates),|))^=,boolean) %then %do;
                %let list=&list|REF_TOTAL|REF_EVENTS|REF_EV_T|REF_PCT|REF_EV_T_PCT|REF_BIN_ESTIMATE|REF_BIN_EST_RANGE|REF_BIN_RANGE;
                %let list=&list|OR_ESTIMATE|OR_EST_RANGE|OR_RANGE|OR_PLOT|AIC|BIC|LOGLIKELIHOOD;
                /*Check if C-indexes can be calculated*/
                %if %sysfunc(countw(%superq(strata),|,m))>1 %then %do i = 1 %to &nmodels;
                    %if %sysevalf(%qscan(%superq(strata),&i,|,m)=,boolean) %then %do;
                        %let list=&list|C_ESTIMATE|C_EST_RANGE|C_RANGE|C_PLOT;
                        %let i=%sysevalf(&nmodels+1);
                    %end;
                %end;
                %else %if %sysevalf(%superq(strata)=,boolean) %then %let list=&list|C_ESTIMATE|C_EST_RANGE|C_RANGE|C_PLOT;
            %end;
            %if %sysfunc(find(%superq(pval_by),1)) or %sysfunc(find(%superq(pval_by),2)) or 
                %sysfunc(find(%superq(pval_type3),1)) or 
                %sysfunc(find(%superq(pval_covariates),1)) %then %let list=&list|PVAL;
            %_glistcheck(var=plot_display,_patternlist=&list,lbl=PLOT_DISPLAY,msg=)
            %if %sysfunc(find(&plot_display,C_,i))>0 and %sysevalf(%sysfunc(compress(%superq(strata),%str( |)))^=,boolean) %then
                %put WARNING: C-index cannot be calculated from a stratified logistic model.;
        %end;
    %end;

    %if %sysevalf(%superq(colby)^=,boolean) and %sysevalf(%qupcase(%superq(colsubtitles))=END,boolean) and %sysfunc(find(&plot_display,subtitle,i))>0 %then %do;
        %let plot_display=%sysfunc(tranwrd(%qupcase(%superq(plot_display)),SUBTITLE,%str())) SUBTITLE;
    %end;
    %else %if %sysevalf(%superq(colby)^=,boolean) and %sysevalf(%qupcase(%superq(colsubtitles))=START,boolean) and %sysfunc(find(&plot_display,subtitle,i))>0 %then %do;
        %let plot_display=SUBTITLE %sysfunc(tranwrd(%qupcase(%superq(plot_display)),SUBTITLE,%str()));
    %end;

    %local _nplot_display _nplot _nplot_pre;
    %let _nplot=0;%let _nplot_pre=;
    %let _nplot_display=%sysfunc(countw(&plot_display,%str( )));
    %if &nerror = 0 %then %do j = 1 %to %superq(_nplot_display);
        %local _plot_display&j. _plot_displayheader&j.;
        %if %qupcase(%scan(%superq(plot_display),&j,%str( )))=SUBTITLE %then %do;
            %let _plot_display&j.=subtitle;
            %let _plot_displayheader&j.=%superq(subtitleheader);
            %let _nsubtitle=&j;
        %end;
        %else %if %sysfunc(find(%scan(%superq(plot_display),&j,%str( )),PLOT,i))>0 %then %do;
            %let _plot_display&j.=%scan(%superq(plot_display),&j,%str( ));
            %let _nplot=%sysevalf(%superq(_nplot)+1);
            %let _plot_displayheader&j.=%qscan(%superq(plot_header),&_nplot,|,m);
            %let _nplot_pre=%sysfunc(strip(%superq(_nplot_pre)))|%qupcase(%sysfunc(strip(%scan(%scan(%superq(plot_display),&j,%str( )),1,_))));
        %end;
        %else %if %qupcase(%scan(%superq(plot_display),&j,%str( )))=EV_T or
            %qupcase(%scan(%superq(plot_display),&j,%str( )))=PCT or
            %qupcase(%scan(%superq(plot_display),&j,%str( )))=EV_T_PCT or
            %qupcase(%scan(%superq(plot_display),&j,%str( )))=PVAL  %then %do;
            %let _plot_display&j.=%scan(%superq(plot_display),&j,%str( ));
            %let _plot_displayheader&j.=%superq(%scan(%superq(plot_display),&j,%str( ))header);
        %end;
        %else %if %sysfunc(find(%scan(%superq(plot_display),&j,%str( )),KM_,i))>0 %then %do;
            %let _plot_display&j.=%scan(%superq(plot_display),&j,%str( ));
            %local k;
            %let k=%sysfunc(compress(%qupcase(%scan(%superq(plot_display),&j,%str( ))),KM_ESTIMATELCLUCLRANGE,i));
            %if %qupcase(%scan(%superq(plot_display),&j,%str( )))=KM_ESTIMATE&k %then %do;
                %let _plot_displayheader&j.=%qscan(%superq(KM_ESTIMATEheader),&k,|,m);
                %if %sysevalf(%superq(_plot_displayheader&j)=,boolean) %then %let _plot_displayheader&j.=Event-free Rate;
            %end;
            %else %if %qupcase(%scan(%superq(plot_display),&j,%str( )))=KM_LCL&k %then %do;
                %let _plot_displayheader&j.=%qscan(%superq(KM_LCLheader),&k,|,m); 
                %if %sysevalf(%superq(_plot_displayheader&j)=,boolean) %then %let _plot_displayheader&j.=Event-free Rate LCL;
            %end;
            %else %if %qupcase(%scan(%superq(plot_display),&j,%str( )))=KM_UCL&k %then %do;
                %let _plot_displayheader&j.=%qscan(%superq(KM_UCLheader),&k,|,m); 
                %if %sysevalf(%superq(_plot_displayheader&j)=,boolean) %then %let _plot_displayheader&j.=Event-free Rate UCL;
            %end;
            %else %if %qupcase(%scan(%superq(plot_display),&j,%str( )))=KM_RANGE&k %then %do;
                %let _plot_displayheader&j.=%qscan(%superq(KM_RANGEheader),&k,|,m);
                %if %sysevalf(%superq(_plot_displayheader&j)=,boolean) %then %let _plot_displayheader&j.=Event-free Rate`(95% CI); 
            %end;
            %else %if %qupcase(%scan(%superq(plot_display),&j,%str( )))=KM_EST_RANGE&k %then %do;
                %let _plot_displayheader&j.=%qscan(%superq(KM_EST_RANGEheader),&k,|,m); 
                %if %sysevalf(%superq(_plot_displayheader&j)=,boolean) %then %let _plot_displayheader&j.=Event-free Rate`(95% CI);
            %end;
        %end;
        %else %do;
            %let _plot_display&j.=%scan(%superq(plot_display),&j,%str( ));
            %let _plot_displayheader&j.=%superq(%scan(%superq(plot_display),&j,%str( ))header); 
        %end;
    %end;
    
    /*Section 1.4.2.1: Plot Display Weights*/
    %if %sysevalf(%superq(PLOT_COLUMNWEIGHTS)^=,boolean) and &nerror=0 %then %do;
        %if %sysevalf(%sysfunc(tranwrd(&PLOT_COLUMNWEIGHTS,%str( ),%str(+)))^=1,boolean) %then %do;
            /**Throw Error**/
            %put ERROR: (Global: PLOT_COLUMNWEIGHTS) Weights must sum to 1;
            %put ERROR: (Global: PLOT_COLUMNWEIGHTS) Current values (&PLOT_COLUMNWEIGHTS) sum to %sysevalf(%sysfunc(tranwrd(&PLOT_COLUMNWEIGHTS,%str( ),%str(+))));
            %let nerror=%eval(&nerror+1);   
        %end;
        %if %sysevalf(%sysfunc(countw(%superq(PLOT_COLUMNWEIGHTS),%str( )))^=%superq(_nplot_display),boolean) %then %do;
            /**Throw Error**/
            %put ERROR: (Global: PLOT_COLUMNWEIGHTS) Number of column weights (%sysfunc(countw(%superq(PLOT_COLUMNWEIGHTS),%str( )))) must equal number of display items (%superq(_nplot_display));
            %let nerror=%eval(&nerror+1);           
        %end;
    %end;  
    
    
    
    
    %if %sysevalf(%qupcase(&table_display)=STANDARD,boolean) %then %do;
        %if %qupcase(&method)=SURVIVAL %then %do;
            %let table_display=;
            %if %sysevalf(%sysfunc(compress(%superq(covariates),|))^=,boolean) %then %do;
                %if %sysfunc(find(&show_modelstats,1))>0 or %sysfunc(find(&show_modelstats,2))>0 or
                    (%sysevalf(%superq(covariates)^=,boolean) and %sysfunc(find(%superq(type),2))>0
                     and %sysfunc(find(%superq(cat_display),4))>0) %then %let table_display=&table_display ev_t hr_est_range;
                %else %let table_display=&table_display hr_est_range;
                %if %sysevalf(%superq(timelist)^=,boolean) %then %do i = 1 %to %sysfunc(countw(%superq(timelist),%str( )));
                    %let table_display=&table_display km_est_range&i;
                %end;
                %if %sysevalf(%sysfunc(compress(%superq(pval_covariates),0|))^=,boolean) or
                    %sysevalf(%sysfunc(compress(%superq(pval_type3),0|))^=,boolean) or
                    (%sysevalf(%sysfunc(compress(%superq(pval_by),0|))^=,boolean) and %sysevalf(%sysfunc(compress(%superq(by),|))^=,boolean)) %then
                    %let table_display=&table_display pval;                    
            %end;
            %else %do;
                %if %sysevalf(%superq(timelist)^=,boolean) %then %do i = 1 %to %sysfunc(countw(%superq(timelist),%str( )));
                    %if &i=1 and %sysfunc(find(&show_modelstats,1))>0 %then %let table_display=&table_display ev_t;
                    %let table_display=&table_display km_est_range&i;
                %end; 
                %else %if %sysfunc(find(&show_modelstats,1))>0 %then %let table_display=&table_display ev_t med_est_range;
                %else %let table_display=&table_display med_est_range;
                %if %sysevalf(%sysfunc(compress(%superq(pval_by),0|))^=,boolean) and %sysevalf(%sysfunc(compress(%superq(by),|))^=,boolean) %then
                    %let table_display=&table_display pval;                  
            %end;
        %end;
        %else %if %qupcase(&method)=LOGISTIC %then %do;
            %let table_display=;
            %if %sysevalf(%sysfunc(compress(%superq(covariates),|))^=,boolean) %then %do;
                %if %sysfunc(find(&show_modelstats,1))>0 %then %let table_display=&table_display ev_t or_est_range;
                %else %let table_display=&table_display or_est_range;
                %if %sysevalf(%sysfunc(compress(%superq(pval_covariates),0|))^=,boolean) or
                    %sysevalf(%sysfunc(compress(%superq(pval_type3),0|))^=,boolean) or
                    (%sysevalf(%sysfunc(compress(%superq(pval_by),0|))^=,boolean) and %sysevalf(%sysfunc(compress(%superq(by),|))^=,boolean)) %then
                    %let table_display=&table_display pval; 
            %end;
            %else %do;
                %if %sysfunc(find(&show_modelstats,1))>0 %then %let table_display=&table_display ev_t bin_est_range;
                %else %let table_display=&table_display bin_est_range;  
                %if %sysevalf(%sysfunc(compress(%superq(pval_by),0|))^=,boolean) and %sysevalf(%sysfunc(compress(%superq(by),|))^=,boolean) %then
                    %let table_display=&table_display pval;                
            %end;
        %end;
    %end;
    %else %do;
        %local list;
        %if %qupcase(&method)=SURVIVAL %then %do;
            %let list=TOTAL|EVENTS|EV_T|PCT|EV_T_PCT|MED_ESTIMATE|MED_EST_RANGE|MED_RANGE;
            %if %sysevalf(%sysfunc(compress(%superq(covariates),|))^=,boolean) %then %do;
                %let list=&list|REF_TOTAL|REF_EVENTS|REF_EV_T|REF_PCT|REF_EV_T_PCT|REF_MED_ESTIMATE|REF_MED_EST_RANGE|REF_MED_RANGE;
                %let list=&list|HR_ESTIMATE|HR_EST_RANGE|HR_RANGE|AIC|BIC|LOGLIKELIHOOD;
                %if %sysevalf(%qupcase(&surv_method)^=CIF,boolean) %then %let list=&list|C_ESTIMATE|C_EST_RANGE|C_RANGE;
            %end;
            %if %sysevalf(%superq(timelist)^=,boolean) %then %do i = 1 %to %sysfunc(countw(%superq(timelist),%str( )));
                %let list=&list|KM_ESTIMATE&i|KM_EST_RANGE&i|KM_RANGE&i;
                %if %sysevalf(%sysfunc(compress(%superq(covariates),|))^=,boolean) %then %do;
                    %let list=&list|REF_KM_ESTIMATE&i|REF_KM_EST_RANGE&i|REF_KM_RANGE&i;
                %end;
            %end;
            %if %sysfunc(find(%superq(pval_by),1)) or %sysfunc(find(%superq(pval_by),2)) or 
                %sysfunc(find(%superq(pval_type3),1)) or %sysfunc(find(%superq(pval_type3),2)) or %sysfunc(find(%superq(pval_type3),3)) or
                %sysfunc(find(%superq(pval_covariates),1)) %then %let list=&list|PVAL;
            %_glistcheck(var=table_display,_patternlist=&list,lbl=TABLE_DISPLAY,msg=)
            %if %sysfunc(find(&table_display,C_,i))>0 and %qupcase(&surv_method)=CIF %then
                %put WARNING: C-index cannot be calculated from a competing risks model.;
        %end;
        %else %if %qupcase(&method)=LOGISTIC %then %do;
            %let list=TOTAL|EVENTS|EV_T|PCT|EV_T_PCT|BIN_ESTIMATE|BIN_EST_RANGE|BIN_RANGE;
            %if %sysevalf(%sysfunc(compress(%superq(covariates),|))^=,boolean) %then %do;
                %let list=&list|REF_TOTAL|REF_EVENTS|REF_EV_T|REF_PCT|REF_EV_T_PCT|REF_BIN_ESTIMATE|REF_BIN_EST_RANGE|REF_BIN_RANGE;
                %let list=&list|OR_ESTIMATE|OR_EST_RANGE|OR_RANGE|C_ESTIMATE|C_EST_RANGE|C_RANGE|AIC|BIC|LOGLIKELIHOOD;
            %end;
            /*Check if C-indexes can be calculated*/
            %if %sysfunc(countw(%superq(strata),|,m))>1 %then %do i = 1 %to &nmodels;
                %if %sysevalf(%qscan(%superq(strata),&i,|,m)=,boolean) %then %do;
                    %let list=&list|C_ESTIMATE|C_EST_RANGE|C_RANGE;
                    %let i=%sysevalf(&nmodels+1);
               %end;
            %end;
            %else %if %sysevalf(%superq(strata)=,boolean) %then %let list=&list|C_ESTIMATE|C_EST_RANGE|C_RANGE|C_PLOT;
            %if %sysfunc(find(%superq(pval_by),1)) or %sysfunc(find(%superq(pval_by),2)) or 
                %sysfunc(find(%superq(pval_type3),1)) or 
                %sysfunc(find(%superq(pval_covariates),1)) %then %let list=&list|PVAL;
            %_glistcheck(var=table_display,_patternlist=&list,lbl=TABLE_DISPLAY,msg=)
            %if %sysfunc(find(&table_display,C_,i))>0 and %sysevalf(%sysfunc(compress(%superq(strata),%str( |)))^=,boolean) %then
                %put WARNING: C-index cannot be calculated from a stratified logistic model.;
        %end;
    %end;
    %local _ntable_display;
    %let _ntable_display=%sysfunc(countw(&table_display,%str( )));
    %if &nerror = 0 %then %do j = 1 %to %superq(_ntable_display);
        %local _table_display&j. _table_displayheader&j. _pval _cindex;
        %if %qupcase(%scan(%superq(table_display),&j,%str( )))=EV_T or
            %qupcase(%scan(%superq(table_display),&j,%str( )))=PCT or
            %qupcase(%scan(%superq(table_display),&j,%str( )))=EV_T_PCT or
            %qupcase(%scan(%superq(table_display),&j,%str( )))=PVAL  %then %do;
            %let _table_display&j.=%scan(%superq(table_display),&j,%str( ));
            %let _table_displayheader&j.=%superq(%scan(%superq(table_display),&j,%str( ))header);
            %if %qupcase(%scan(%superq(table_display),&j,%str( )))=PVAL %then %let _pval=1;
        %end;
        %else %if %sysfunc(find(%scan(%superq(table_display),&j,%str( )),KM_,i))>0 %then %do;
            %let _table_display&j.=%scan(%superq(table_display),&j,%str( ));
            %local k;
            %let k=%sysfunc(compress(%qupcase(%scan(%superq(table_display),&j,%str( ))),KM_ESTIMATELCLUCLRANGE,i));
            %if %qupcase(%scan(%superq(table_display),&j,%str( )))=KM_ESTIMATE&k %then %do;
                %let _table_displayheader&j.=%qscan(%superq(KM_ESTIMATEheader),&k,|,m);
                %if %sysevalf(%superq(_table_displayheader&j)=,boolean) %then %let _table_displayheader&j.=Event-free Rate;
            %end;
            %else %if %qupcase(%scan(%superq(table_display),&j,%str( )))=KM_LCL&k %then %do;
                %let _table_displayheader&j.=%qscan(%superq(KM_LCLheader),&k,|,m); 
                %if %sysevalf(%superq(_table_displayheader&j)=,boolean) %then %let _table_displayheader&j.=Event-free Rate LCL;
            %end;
            %else %if %qupcase(%scan(%superq(table_display),&j,%str( )))=KM_UCL&k %then %do;
                %let _table_displayheader&j.=%qscan(%superq(KM_UCLheader),&k,|,m); 
                %if %sysevalf(%superq(_table_displayheader&j)=,boolean) %then %let _table_displayheader&j.=Event-free Rate UCL;
            %end;
            %else %if %qupcase(%scan(%superq(table_display),&j,%str( )))=KM_RANGE&k %then %do;
                %let _table_displayheader&j.=%qscan(%superq(KM_RANGEheader),&k,|,m);
                %if %sysevalf(%superq(_table_displayheader&j)=,boolean) %then %let _table_displayheader&j.=Event-free Rate`(95% CI); 
            %end;
            %else %if %qupcase(%scan(%superq(table_display),&j,%str( )))=KM_EST_RANGE&k %then %do;
                %let _table_displayheader&j.=%qscan(%superq(KM_EST_RANGEheader),&k,|,m); 
                %if %sysevalf(%superq(_table_displayheader&j)=,boolean) %then %let _table_displayheader&j.=Event-free Rate`(95% CI);
            %end;
        %end;
        %else %do;
            %let _table_display&j.=%scan(%superq(table_display),&j,%str( ));
            %let _table_displayheader&j.=%superq(%scan(%superq(table_display),&j,%str( ))header);    
            %if %qupcase(%scan(%superq(table_display),&j,%str( )))=C_ESTIMATE or 
                %qupcase(%scan(%superq(table_display),&j,%str( )))=C_LCL or 
                %qupcase(%scan(%superq(table_display),&j,%str( )))=C_UCL or 
                %qupcase(%scan(%superq(table_display),&j,%str( )))=C_RANGE or 
                %qupcase(%scan(%superq(table_display),&j,%str( )))=C_EST_RANGE %then %let _cindex=1;       
        %end;
    %end;
    /**Section 1.4.1: Create Plot Macro Parameters**/
    %local _pvarlist _pmvarlist i j k npanels;
    %let _pvarlist=%sysfunc(compress(linecap|tickvalues|min|max|increment|xaxistype|refline|srefline|refguidelower|refguideupper|
                                     xaxislabel|plot_header|symbol|logbase|logminor|logtickstyle));
    %do i = 1 %to &_nplot;
        /**Cycle through each macro parameter**/
        %do j = 1 %to %sysfunc(countw(&_pvarlist,|));
            %local v&j;
            %let v&j=%scan(%superq(_pvarlist),&j,|);
            %local &&v&j..&i;
            /**If the | delimiter is detected, assign the different values between | to numbered parameters**/
            /**Else Assign the same value to all numbered parameters**/
            %if %index(%superq(&&v&j),|)>0 %then %let &&v&j..&i=%scan(%superq(&&v&j),&i,|,m);
            %else %let &&v&j..&i=%scan(%superq(&&v&j),1,|,m); 
        %end;
    %end;  
    
    
    %_pparmcheck(xaxistype,LINEAR|LOG,&_nplot)  
    %_pparmcheck(logbase,2|10|E,&_nplot)
    %_pparmcheck(logminor,TRUE|FALSE,&_nplot)
    %_pparmcheck(logtickstyle,AUTO|LOGEXPAND|LOGEXPONENT|LINEAR,&_nplot) 
    %do i = 1 %to &_nplot;       
        %if &nerror = 0 and %qupcase(%superq(xaxistype&i))=LOG %then %do;
            %if %qupcase(&&logminor&i)=TRUE and 
                %qupcase(&&logtickstyle&i)^=LOGEXPAND and %qupcase(&&logtickstyle&i)^=LOGEXPONENT 
                and %sysevalf(%superq(logbase&i)^=10,boolean) %then %do;
                %put WARNING: MINORTICKS for log axes only display when LOGBASE=10 and LOGTICKSTYLE is LOGEXPAND or LOGEXPONENT;
            %end;
        %end;
    %end;
    %_pnumcheck(refline,,,,&_nplot)
    %_pnumcheck(srefline,,,,&_nplot)
    %_pnumcheck2(tickvalues,,,,&_nplot)
    %_pnumcheck(min,,,,&_nplot)
    %_pnumcheck(max,,,,&_nplot)
    %_pnumcheck(increment,,,,&_nplot) 
    
    %do i = 1 %to &_nplot;  
        %local _elab _nplot_curr;
        %let _nplot_curr=%scan(%superq(_nplot_pre),&i,|);
        
        %if %str(%superq(_nplot_curr))=KM %then %let _elab=Kaplan-Meier estimates;
        %else %if %str(%superq(_nplot_curr))=C %then %let _elab=c-index estimates;
        %else %if %str(%superq(_nplot_curr))=BIN %then %let _elab=binary estimates;  
        %else %if %str(%superq(_nplot_curr))=HR %then %let _elab=hazard ratios;   
        %else %if %str(%superq(_nplot_curr))=%str(OR) %then %let _elab=odds ratios;   
        %else %if %str(%superq(_nplot_curr))=MED %then %let _elab=median estimates;  
        /*Section 1.3.3.0: X-Axis Labels*/        
        %if %sysevalf(%superq(xaxislabel&i)=,boolean) %then %do;
            %if %str(%superq(_nplot_curr))=KM %then %let xaxislabel&i=Kaplan-Meier Estimate;
            %else %if %str(%superq(_nplot_curr))=C %then %let xaxislabel&i=C-index;
            %else %if %str(%superq(_nplot_curr))=BIN %then %let xaxislabel&i=Binary Success Rate;  
            %else %if %str(%superq(_nplot_curr))=HR %then %let xaxislabel&i=Hazard Ratio;   
            %else %if %str(%superq(_nplot_curr))=%str(OR) %then %let xaxislabel&i=Odds ratio;   
            %else %if %str(%superq(_nplot_curr))=MED %then %let xaxislabel&i=Median Time-to-Event;  
        %end;
        /*Section 1.3.3.1: Minimum value*/
        %if &nerror = 0 and %sysevalf(%superq(min&i)^=,boolean) %then %do;
            %if %str(%superq(_nplot_curr))=HR or %str(%superq(_nplot_curr))=%str(OR) %then %do;
                %if %qupcase(%superq(xaxistype&i))=LINEAR %then %do;
                    %if %sysevalf(%superq(min&i) < 0,boolean) %then %do;
                        %put ERROR: Minimum value for MIN (%superq(min&i)) when plotting &_elab. and XAXISTYPE=LINEAR is 0;
                        %let nerror=%eval(&nerror+1);
                    %end;
                %end;
                %else %if %qupcase(%superq(xaxistype&i))=LOG %then %do;
                    %if %sysevalf(%superq(min&i) <= 0,boolean) %then %do;
                        %put ERROR: Minimum value for MIN (%superq(min&i)) when plotting &_elab. and XAXISTYPE=LOG cannot be less than or equal to 0;
                        %let nerror=%eval(&nerror+1);
                    %end;
                %end;
            %end;
            %else %if %str(%superq(_nplot_curr))=KM or %str(%superq(_nplot_curr))=C 
                or %str(%superq(_nplot_curr))=BIN %then %do;
                %if %sysevalf(%superq(min&i) < 0,boolean) %then %do;
                    %put ERROR: Minimum value for MIN (%superq(min&i)) when plotting &_elab. is 0;     
                    %let nerror=%eval(&nerror+1);
                %end;
                %if %qupcase(&estfmt)=PPT %then %do;
                    %if %sysevalf(%superq(min&i) >= 1,boolean) %then %do;
                        %put ERROR: Maximum value for MIN (%superq(min&i)) when plotting &_elab. must be less than 1 when ESTFMT=PPT;                    
                        %let nerror=%eval(&nerror+1);
                    %end;
                %end;
                %else %if %qupcase(&estfmt)=PCT %then %do;
                    %if %sysevalf(%superq(min&i) >= 100,boolean) %then %do;
                        %put ERROR: Maximum value for MIN (%superq(min&i)) when plotting &_elab. must be less than 100 when ESTFMT=PCT;                    
                        %let nerror=%eval(&nerror+1);
                    %end;
                %end;
            %end;
            %else %if %str(%superq(_nplot_curr))=MED %then %do;
                %if %sysevalf(%superq(min&i) < 0,boolean) %then %do;
                    %put ERROR: Minimum value for MIN (%superq(min&i)) when plotting &_elab. is 0;     
                    %let nerror=%eval(&nerror+1);
                %end;
            %end;
            %if %sysevalf(%superq(max&i)^=,boolean) %then %do;
                %if %sysevalf(%superq(min&i) >= %superq(max&i),boolean) %then %do;
                    %put ERROR: MIN (%superq(min&i)) must be less than MAX (%superq(max&i));
                    %let nerror=%eval(&nerror+1);
                %end;               
            %end;
        %end;
        /*Section 1.3.3.2: Maximum value*/
        %if &nerror = 0 and %sysevalf(%superq(max&i)^=,boolean) %then %do;
            %if %str(%superq(_nplot_curr))=HR or %str(%superq(_nplot_curr))=%str(OR) %then %do;
                %if %sysevalf(%superq(max&i) <= 0,boolean) %then %do;
                    %put ERROR: Minimum value for MAX (%superq(max&i)) when plotting &_elab. is greater than 0;
                    %let nerror=%eval(&nerror+1);
                %end;
            %end;
            %else %if %str(%superq(_nplot_curr))=KM or %str(%superq(_nplot_curr))=C 
                or %str(%superq(_nplot_curr))=BIN %then %do;
                %if %sysevalf(%superq(max&i) <= 0,boolean) %then %do;
                    %put ERROR: Minimum value for MAX (%superq(max&i)) when plotting &_elab. is greater than 0;
                    %let nerror=%eval(&nerror+1);
                %end;
                %if %sysevalf(%superq(max&i) > 1,boolean) %then %do;
                    %put ERROR: Maximum value for MAX (%superq(max&i)) when plotting &_elab. is 1;
                    %let nerror=%eval(&nerror+1);
                %end;
                %if %qupcase(&estfmt)=PPT %then %do;
                    %if %sysevalf(%superq(max&i) > 1,boolean) %then %do;
                        %put ERROR: Maximum value for MAX (%superq(max&i)) when plotting &_elab. is 1 when ESTFMT=PPT;
                        %let nerror=%eval(&nerror+1);
                    %end;
                %end;
                %else %if %qupcase(&estfmt)=PCT %then %do;
                    %if %sysevalf(%superq(max&i) > 100,boolean) %then %do;
                        %put ERROR: Maximum value for MAX (%superq(max&i)) when plotting &_elab. is 100 when ESTFMT=PCT;
                        %let nerror=%eval(&nerror+1);
                    %end;
                %end;
            %end;
            %else %if %str(%superq(_nplot_curr))=MED %then %do;
                %if %sysevalf(%superq(max&i) <= 0,boolean) %then %do;
                    %put ERROR: Minimum value for MAX (%superq(max&i)) when plotting &_elab. is greater than 0;
                    %let nerror=%eval(&nerror+1);
                %end;
            %end;
        %end;
        /*Section 1.3.3.3: Increment value*/
        %if &nerror = 0 and %sysevalf(%superq(increment&i)^=,boolean) %then %do;
            %if %qupcase(%superq(xaxistype&i))=LINEAR %then %do;
                %if %sysevalf(%superq(increment&i) <= 0,boolean) %then %do;
                    %put ERROR: Minimum value for INCREMENT (%superq(increment&i)) must be greater than 0;
                    %let nerror=%eval(&nerror+1);
                %end;
                %if %sysevalf(%superq(min&i)^=,boolean) and %sysevalf(%superq(max&i)^=,boolean) %then %do;
                    %if %sysevalf(%superq(increment&i)>(%superq(max&i)-%superq(min&i)),boolean) %then %do;
                        %put ERROR: INCREMENT (%superq(increment&i)) must be less than difference between MAX and MIN (%sysevalf(%superq(max&i)-%superq(min&i)));
                        %let nerror=%eval(&nerror+1);
                    %end;
                %end;
            %end;
            %else %do;
                %put WARNING: Increment has no effect on LOG-based axes;
            %end;
        %end;
    %end;
    
    /*Section 1.3.5: Global Symbol Parameters*/  
    %_plist(symbol,%sysfunc(compress(ARROWDOWN|ASTERISK|CIRCLE|DIAMOND|GREATERTHAN|HASH|
        HOMEDOWN|IBEAM|PLUS|SQUARE|STAR|TACK|TILDE|TRIANGLE|
        UNION|X|Y|Z|CIRCLEFILLED|DIAMONDFILLED|HOMEDOWNFILLED|
        SQUAREFILLED|STARFILLED|TRIANGLEFILLED)),,&_nplot)
      
    
    /**If any errors exist, stop macro and send to end**/
    %if &nerror > 0 %then %do;
        %put ERROR: &nerror pre-run errors listed;
        %put ERROR: Macro MVMODELS will cease;
        %goto errhandl;
    %end;        
           
    
    %if &debug=1 %then %do; 
        options mprint notes;
    %end;
    %local nerror_run;
    %let nerror_run=0; 
    
    %macro _ordercheck(parm,values,_order);
        /**Pull largest value in order list**/
        %local _maxord;
        %let _maxord = %sysfunc(max(%sysfunc(tranwrd(%superq(%superq(_order)),%str( ),%str(,)))));
        /**Pull number of items in order list**/
        %local _nord;
        %let _nord = %sysfunc(countw(%superq(%superq(_order)),%str( )));
        /**Check if there are too many levels given**/
        %if &_nord ^= %sysfunc(countw(%superq(&values),|)) %then %do;
            /**Throw errors**/
            %put ERROR: (Global: %qupcase(%superq(_order))): Number in order list (&_nord) does not equal the number of values for &parm. variable %cmpres(
                ) %qupcase(%superq(parm.)) (%sysfunc(countw(%superq(&values),|)));
            %let nerror_run=%eval(&nerror_run+1);
        %end;
        /**Check if the largest value is larger than the number of levels in the by variable**/
        %else %if &_maxord > %sysfunc(countw(%superq(&values),|)) %then %do;
            /**Throw errors**/
            %put ERROR: (Global: %qupcase(%superq(parm.))): Largest number in order list (&_maxord) is larger than the number of values for &parm. variable %cmpres(
                ) %qupcase(%superq(parm.)) (%sysfunc(countw(%superq(&values),|)));
            %let nerror_run=%eval(&nerror_run+1);
        %end;
        /**Check if all values from 1 to max are represented in the order list**/
        %else %do _z2=1 %to %sysfunc(countw(%superq(&values),|));
            %local _test;
            %let _test=;
            %do z = 1 %to &_maxord;
                %if %scan(%superq(%superq(_order)),&z,%str( )) = &_z2 %then %let _test=1;
            %end;
            %if &_test ^=1 %then %do;
                /**Throw errors**/
                %put ERROR: (Global: %qupcase(%superq(_order))): Number &_z2 was not found in the %superq(_order) list;
                %put ERROR: (Global: %qupcase(%superq(_order))): Each number from 1 to maximum number of levels in &parm. variable %cmpres( 
                    ) %qupcase(%superq(parm.)) (&_maxord) must be represented;
                %let nerror_run=%eval(&nerror_run+1);
            %end;                                   
        %end;
        %if &nerror_run=0 %then %do;
            %local _tlevels j;
            %do j=1 %to %sysfunc(countw(%superq(%superq(_order)),%str( )));
                %if &j=1 %then %let _tlevels=%scan(%superq(&values),%scan(%superq(%superq(_order)),&j,%str( )),|,m);
                %else %let _tlevels=&_tlevels|%scan(%superq(&values),%scan(%superq(%superq(_order)),&j,%str( )),|,m);
            %end;
            %let &values=&_tlevels;%let _tlevels=;
        %end;
    %mend;
    /*Grouping Variables*/
    %local _rows _rowbylevels _columns _colbylevels _groups _groupbylevels _groupby;
    %let _rows=1;%let _columns=1;%let _groups=1;%let _groupby=0;
    %if %sysevalf(%superq(rowby)^=,boolean) or %sysevalf(%superq(colby)^=,boolean) or %sysevalf(%superq(groupby)^=,boolean) %then %do;
        data _temp_group;
            set %do i = 1 %to &nmodels;
                    &data %if %sysevalf(%superq(where&i)^=,boolean) %then %do; (where=(&&where&i)) %end;
                %end;;   
            %if %sysevalf(%superq(rowby)^=,boolean) %then %do;
                %local _rowbyformat;
                /**Selects format and label for row by variable**/
                %if %sysevalf(%superq(rowbylabel)=,boolean) %then %do;
                    call symput("rowbylabel",vlabel(&rowby));
                %end;
                call symput("_rowbyformat",vformat(&rowby));  
            %end;
            %if %sysevalf(%superq(colby)^=,boolean) %then %do;
                %local _colbyformat;
                /**Selects format and label for col by variable**/
                %if %sysevalf(%superq(colbylabel)=,boolean) %then %do;
                    call symput("colbylabel",vlabel(&colby));
                %end;
                call symput("_colbyformat",vformat(&colby));  
            %end;
            %if %sysevalf(%superq(groupby)^=,boolean) %then %do;
                %local _groupbyformat;
                /**Selects format and label for group by variable**/
                %if %sysevalf(%superq(groupbylabel)=,boolean) %then %do;
                    call symput("groupbylabel",vlabel(&groupby));
                %end;
                call symput("_groupbyformat",vformat(&groupby));  
            %end;
        run;
        data _temp_group;
            merge %if %sysevalf(%superq(rowby)^=,boolean) %then %do;
                      _temp_group (rename=(&rowby=_temp_rowby) keep=&rowby)
                  %end;
                  %if %sysevalf(%superq(colby)^=,boolean) %then %do;
                      _temp_group (rename=(&colby=_temp_colby) keep=&colby)
                  %end;
                  %if %sysevalf(%superq(groupby)^=,boolean) %then %do;
                      _temp_group (rename=(&groupby=_temp_groupby) keep=&groupby)
                  %end;;
            %if %sysevalf(%superq(rowby)^=,boolean) %then %do;
                length _rowby_ $300.;
                keep _rowby_ _temp_rowby;
                /*Transform into character variable*/
                if vtype(_temp_rowby)^='N' then _rowby_=strip(vvalue(_temp_rowby)); 
                else if ^(strip(vvalue(_temp_rowby))='.' and _temp_Rowby=.) then _rowby_=strip(vvalue(_temp_rowby));
            %end;
            %if %sysevalf(%superq(colby)^=,boolean) %then %do;
                length _colby_ $300.;
                keep _colby_ _temp_colby;
                /*Transform into character variable*/
                if vtype(_temp_colby)^='N' then _colby_=strip(vvalue(_temp_colby)); 
                else if ^(strip(vvalue(_temp_colby))='.' and _temp_colby=.) then _colby_=strip(vvalue(_temp_colby));
            %end;
            %if %sysevalf(%superq(groupby)^=,boolean) %then %do;
                length _groupby_ $300.;
                keep _groupby_ _temp_groupby;
                /*Transform into character variable*/
                if vtype(_temp_groupby)^='N' then _groupby_=strip(vvalue(_temp_groupby)); 
                else if ^(strip(vvalue(_temp_groupby))='.' and _temp_groupby=.) then _groupby_=strip(vvalue(_temp_groupby));
            %end;
        run;
        
        /*Grab variable levels*/
        proc sql noprint;      
            %if %sysevalf(%superq(rowby)^=,boolean) %then %do;        
                %local _rowbylevels;   
                select distinct %if %sysevalf(%superq(rowbyorder_formatted)=0,boolean) %then %do; _temp_rowby %end;
                                %else %do; _rowby_ %end;
                    into :_rowbylevels separated by '|' 
                    from _temp_group where ^missing(_rowby_);
                %let _rows=%sysfunc(countw(%superq(_rowbylevels),|));
                %if %sysevalf(%superq(rowbyorder)^=,boolean) %then %_ordercheck(rowby,_rowbylevels,rowbyorder);
                %do i = 1 %to &_rows;
                    %local rowheaders&i;
                    %let rowheaders&i=%qscan(%superq(_rowbylevels),&i,|,m);
                %end;
            %end;   
            %if %sysevalf(%superq(colby)^=,boolean) %then %do;        
                %local _colbylevels;   
                select distinct %if %sysevalf(%superq(colbyorder_formatted)=0,boolean) %then %do; _temp_colby %end;
                                %else %do; _colby_ %end;
                    into :_colbylevels separated by '|' 
                    from _temp_group where ^missing(_colby_);
                %let _columns=%sysfunc(countw(%superq(_colbylevels),|));
                %if %sysevalf(%superq(colbyorder)^=,boolean) %then %_ordercheck(colby,_colbylevels,colbyorder);
                %do i = 1 %to &_columns;
                    %local columnheaders&i;
                    %let columnheaders&i=%qscan(%superq(_colbylevels),&i,|,m);
                %end;
            %end;   
            %if %sysevalf(%superq(groupby)^=,boolean) %then %do;        
                %local _groupbylevels;%let _groupby=1;
                select distinct %if %sysevalf(%superq(groupbyorder_formatted)=0,boolean) %then %do; _temp_groupby %end;
                                %else %do; _groupby_ %end;
                    into :_groupbylevels separated by '|' 
                    from _temp_group where ^missing(_groupby_);
                %let _groups=%sysfunc(countw(%superq(_groupbylevels),|));
                %if %sysevalf(%superq(groupbyorder)^=,boolean) %then %_ordercheck(groupby,_groupbylevels,groupbyorder);
                %do i = 1 %to &_groups;
                    %local groupheaders&i;
                    %let groupheaders&i=%qscan(%superq(_groupbylevels),&i,|,m);
                %end;
            %end;
            drop table _temp_group;
        quit;    
    %end;
    
    %local i j step;
    %let step=0;
    /**If any errors exist, stop macro and send to end**/
    %if &nerror_run > 0 %then %goto errhandl2;
    proc sql;
        create table _models 
            (modelnum num,modelsum_row num,show_modelstats num, show_adjcovariates num, nstrata num, ncovariates num, ncat num, ncont num, 
            rowbyvar char(32),rowby char(300),rowby_lvl num,colbyvar char(32),colby char(300),colby_lvl num,
            groupby_label char(300),groupbyvar char(32),groupby char(300),groupby_lvl num,
            byvar char(32), by_num num, by_lvl num,
            subind num, boldind num, subtitle char(300), varnum num, varlevel num,
            covariate char(32), display num, cov_type num,
            cat_nlvl num,cat_val char(300),cat_ref num,cat_refv char(300),cont_step num,
            pval_by num, pval_type3 num, pval_covariates num);
    quit;

    %do i = 1 %to &nmodels;
        %if %sysevalf(%superq(strata&i)^=,boolean) %then %do;
            proc sql;
                alter table _models
                    add 
                        %do j = 1 %to %sysfunc(countw(%superq(strata&i),%str( )));
                            %if &j>1 %then %do; ,  %end;
                            strata&j char(32)
                        %end;;
            quit;
        %end;
        /*Make Temporary Dataset*/
        /*Complete Case Dataset*/
        %local datcheck;
        %let datcheck=0;
        data _subset;
            set &data 
                %if %sysevalf(%superq(where&i)=,boolean)=0 %then %do;
                    (where=(&&where&i))
                %end; end=last;
            if last then call symputx('datcheck',_n_);
        run;
        
        /**Check where clause**/
        %if &datcheck =0 %then %do;
            %put ERROR: (Model &z: WHERE): Issue parsing the WHERE clause;
            %let nerror_run=%eval(&nerror_run+1);
            %goto errhandl2; 
        %end;
        data _tempdsn&i;
            merge 
                %if %sysevalf(%qupcase(%superq(method))=SURVIVAL,boolean) %then %do; 
                    _subset (rename=(%superq(time&i.)=_time_) keep=%superq(time&i))
                    _subset (rename=(%superq(cens&i.)=_cens_) keep=%superq(cens&i.))
                    %if %sysfunc(notdigit(0%sysfunc(compress(%superq(landmark&i),.-)))) > 0 %then %do;
                        _subset (rename=(%superq(landmark&i)=_landmark_) keep=%superq(landmark&i))
                    %end;
                %end;
                %else %if %sysevalf(%qupcase(%superq(method))=LOGISTIC,boolean) %then %do; 
                    _subset (rename=(%superq(eventcov&i.)=_temp_event_) keep=%superq(eventcov&i.))
                %end;                         
                %do j = 1 %to %superq(_ncat&i);
                    _subset (rename=(%superq(_cat&i._&j)=_tcat_&j) keep=%superq(_cat&i._&j))
                %end;
                %do j = 1 %to %superq(_ncont&i);
                    _subset (rename=(%superq(_cont&i._&j)=_cont_&j) keep=%superq(_cont&i._&j))
                %end;                                      
                %do j=1 %to %sysfunc(countw(%superq(strata&i),%str( ))); 
                    _subset (rename=(%scan(%superq(strata&i),&j,%str( ))=_strata_&j) keep=%scan(%superq(strata&i),&j,%str( )))
                %end;                   
                %if %sysevalf(%superq(by&i)^=,boolean) %then %do b = 1 %to %sysfunc(countw(%superq(by&i),%str( )));
                    _subset (rename=(%scan(%superq(by&i),&b,%str( ))=_temp_by_&b) keep=%scan(%superq(by&i),&b,%str( )))
                %end;
                %if %sysevalf(%superq(rowby)^=,boolean) %then %do; _subset (rename=(%superq(rowby)=_temp_rowby_) keep=%superq(rowby)) %end;
                %if %sysevalf(%superq(colby)^=,boolean) %then %do; _subset (rename=(%superq(colby)=_temp_colby_) keep=%superq(colby)) %end;
                %if %sysevalf(%superq(groupby)^=,boolean) %then %do; _subset (rename=(%superq(groupby)=_temp_groupby_) keep=%superq(groupby)) %end;;
            
            modelnum=&i;
            show_adjcovariates=&&show_adjcovariates&i;
            %if %sysevalf(%qupcase(%superq(method))=SURVIVAL,boolean) %then %do; 
                if ^missing(_cens_) then do;
                    if _cens_=&&cen_vl&i then _cens_=0;
                    %if %sysevalf(%qupcase(&surv_method)^=CIF,boolean) %then %do;
                        else _cens_=1;
                    %end;
                    %else %do;
                        else if _cens_=&&ev_vl&i then _cens_=1;
                        else _cens_=2;
                    %end;
                end;
                %if %sysevalf(%superq(tdivisor&i)^=,boolean) %then %do;
                    _time_=_time_/&&tdivisor&i;
                %end;
            %end;
            %do j = 1 %to %superq(_ncat&i);
                length _cat_&j $300 _cat_cov_&j $32.;
                if vtype(_tcat_&j)^='N' then _cat_&j=strip(vvalue(_tcat_&j)); 
                else if ^(strip(vvalue(_tcat_&j))='.' and _tcat_&j=.) then _cat_&j=strip(vvalue(_tcat_&j));
                _cat_lvl_&j.=.;_cat_val_&j.=.;
                _cat_cov_&j=upcase("%superq(_cat&i._&j)");
            %end;
            %do j = 1 %to %superq(_ncont&i);
                length _cont_cov_&j $32.;
                _cont_cov_&j=upcase("%superq(_cont&i._&j)");
            %end;
            %if %sysevalf(%qupcase(%superq(method))=LOGISTIC,boolean) %then %do; 
                length _event_ $300.;
                _event_=strip(vvalue(_temp_event_));
                _event_val=.;
            %end;
            length _rowby_ _colby_ _groupby_  $300;
            %if %sysevalf(%superq(rowby)^=,boolean) %then %do;
                if vtype(_temp_rowby_)^='N' then _rowby_=strip(vvalue(_temp_rowby_)); 
                else if ^(strip(vvalue(_temp_rowby_))='.' and _temp_Rowby=.) then _rowby_=strip(vvalue(_temp_rowby_));
                %do j = 1 %to %sysfunc(countw(%superq(_rowbylevels)));
                    %if &j>1 %then %do; else %end;
                    if _rowby_="%qscan(%superq(_rowbylevels),&j,|,m)" then _rowby_lvl=&j;
                %end;
                drop _temp_rowby_; 
            %end;
            %else %do;
                _rowby_="";_rowby_lvl=1;
            %end;
            %if %sysevalf(%superq(colby)^=,boolean) %then %do;
                if vtype(_temp_colby_)^='N' then _colby_=strip(vvalue(_temp_colby_)); 
                else if ^(strip(vvalue(_temp_colby_))='.' and _temp_colby=.) then _colby_=strip(vvalue(_temp_colby_));
                %do j = 1 %to %sysfunc(countw(%superq(_colbylevels)));
                    %if &j>1 %then %do; else %end;
                    if _colby_="%qscan(%superq(_colbylevels),&j,|,m)" then _colby_lvl=&j;
                %end;
                drop _temp_colby_;
            %end;
            %else %do;
                _colby_="";_colby_lvl=1;
            %end;
            %if %sysevalf(%superq(groupby)^=,boolean) %then %do;
                if vtype(_temp_groupby_)^='N' then _groupby_=strip(vvalue(_temp_groupby_)); 
                else if ^(strip(vvalue(_temp_groupby_))='.' and _temp_groupby_=.) then _groupby_=strip(vvalue(_temp_groupby_));
                %do j = 1 %to %sysfunc(countw(%superq(_groupbylevels)));
                    %if &j>1 %then %do; else %end;
                    if _groupby_="%qscan(%superq(_groupbylevels),&j,|,m)" then _groupby_lvl=&j;
                %end;
                drop _temp_groupby_;
            %end;
            %else %do;
                _groupby_="";_groupby_lvl=1;
            %end;
            if %if %sysevalf(%qupcase(%superq(method))=SURVIVAL,boolean) %then %do; 
                ^missing(_time_) and _time_>=0 and ^missing(_cens_)                            
                %if %sysfunc(notdigit(0%sysfunc(compress(%superq(landmark&i),.-)))) > 0 %then %do;
                    and ^missing(_landmark_)
                %end;  
            %end;
            %else %if %sysevalf(%qupcase(%superq(method))=LOGISTIC,boolean) %then %do; 
                ^missing(_event_)
            %end;
            %do j = 1 %to %superq(_ncat&i);/**Not missing categorical variables**/
                and ^missing(_cat_&j)
            %end;               
            %do j = 1 %to %superq(_ncont&i);/**Not missing continuous variables**/
                and ^missing(_cont_&j)
            %end;
            %if %sysevalf(%superq(strata&i)=,boolean)=0 %then %do k = 1 %to %sysfunc(countw(%superq(strata&i),%str( )));/**Not missing stratification variables**/
                and ^missing(_strata_&k)
            %end;   
            %if %sysevalf(%superq(rowby)^=,boolean) %then %do;
                and ^missing(_rowby_)
            %end;   
            %if %sysevalf(%superq(colby)^=,boolean) %then %do;
                and ^missing(_colby_)
            %end;    
            %if %sysevalf(%superq(groupby)^=,boolean) %then %do;
                and ^missing(_groupby_)
            %end; ;
            length _by_var $32. _by_ $300;
            %if %sysevalf(%superq(by&i)^=,boolean) %then %do;  
                %do b = 1 %to %sysfunc(countw(%superq(by&i),%str( )));
                    _by_var="%scan(%superq(by&i),&b,%str( ))";_by_num=&b;
                    if vtype(_temp_by_&b)^='N' then _by_=strip(vvalue(_temp_by_&b)); 
                    else if ^(strip(vvalue(_temp_by_&b))='.' and _temp_by_&b=.) then _by_=strip(vvalue(_temp_by_&b));
                    _by_lvl=.;
                    if ^missing(_by_) then output;
                %end;
            %end;
            %else %do;
                _by_var="";_by_num=1;_by_="";_by_lvl=1;
            %end;
        run;             
        
        /*Grab Labels*/
        %do j = 1 %to %sysfunc(countw(&&by&i,%str( )));
            %if %sysevalf(%qscan(%superq(bylabel&i),&j,`,m)=,boolean) %then %do;
                %let _bylabel&i._&j=%sysfunc(varlabel(&_data,%sysfunc(varnum(&_data,%scan(%superq(by&i),&j,%str( ))))));
                %if %sysevalf(%superq(_bylabel&i._&j)=,boolean) %then %let _bylabel&i._&j=%scan(%superq(by&i),&j,%str( ));
            %end;
            %else %let _bylabel&i._&j=%qscan(%superq(bylabel&i),&j,`,m);
        %end;
        
        %if &&_ncov&i > 0 %then %do;
            /*Grab Labels*/
            %do j = 1 %to &&_ncov&i;
                %local _label&i._&j;
                %if %sysevalf(%qscan(%superq(labels&i),&j,`,m)=,boolean) %then %do;
                    %let _label&i._&j=%sysfunc(varlabel(&_data,%sysfunc(varnum(&_data,%scan(%superq(covariates&i),&j,%str( ))))));
                    %if %sysevalf(%superq(_label&i._&j)=,boolean) %then %let _label&i._&j=%scan(%superq(covariates&i),&j,%str( ));
                %end;
                %else %let _label&i._&j=%qscan(%superq(labels&i),&j,`,m);
            %end;
            /*Continuous Covariates*/
            %local _last_constep&i;
            %do j = 1 %to &&_ncont&i;
                /*Step Size*/
                %local _cont_step&i._&j;
                %if %sysevalf(%qscan(%superq(cont_step&i),&j,%str( ))=,boolean) %then %let _cont_step&i._&j=&&_last_contstep&i;
                %else %do;
                    %let _cont_step&i._&j=%qscan(%superq(cont_step&i),&j,%str( ));
                    %let _last_contstep&i=%qscan(%superq(cont_step&i),&j,%str( ));
                %end;
            %end;
            /*Categorical Covariates*/
            proc sql noprint;
                %do j = 1 %to &&_ncat&i;
                    %local _catlvls_&i._&j. _catorder_&i._&j.;
                    select distinct %if %sysevalf(%superq(cat_order_formatted)=0,boolean) %then %do; _tcat_&j %end;
                                    %else %do; _cat_&j %end;
                        into :_catlvls_&i._&j. separated by '|'   
                        from _tempdsn&i;
                    alter table _tempdsn&i
                        drop _tcat_&j;
                    %let _catorder_&i._&j.=%qscan(%superq(cat_order&i),&j,`,m);
                    %if %sysevalf(%superq(_catorder_&i._&j.)^=,boolean) %then %_ordercheck(cat_order,_catlvls_&i._&j.,_catorder_&i._&j.);
                    /*Reference*/
                    %local _catref_&i._&j.;
                    %if (%scan(%superq(type&i),1,%str( ))=2 and &j=1 and &&show_adjcovariates&i=0) or &&show_adjcovariates&i=1 %then %do;
                        %if %sysevalf(%qscan(%superq(cat_ref&i),&j,`,m)^=,boolean) %then %do;
                            %let _catref_&i._&j.=%qscan(%superq(cat_ref&i),&j,`,m);
                            %local _refcheck;
                            %let _refcheck=0;
                            select min(test) into :_refcheck separated by ''    
                                from (select _colby_lvl,_rowby_lvl,_groupby_lvl,_by_lvl,max(ifn(_cat_&j="%superq(_catref_&i._&j.)",1,0)) as test 
                                        from _tempdsn&i group by  _colby_lvl,_rowby_lvl,_groupby_lvl,_by_lvl);
                            %if &_refcheck = 0 %then %do;
                                /**Throw errors**/
                                %if %sysevalf(%superq(colby)^=,boolean) or %sysevalf(%superq(rowby)^=,boolean) or %sysevalf(%superq(groupby)^=,boolean) or %sysevalf(%superq(by&i)^=,boolean) %then
                                    %put ERROR: (Model &i: %qupcase(cat_ref) for %qupcase(%superq(_cat&i._&j))): Reference value (%superq(_catref_&i._&j.)) does not exist in all possible subgroups of COLBY, ROWBY, GROUPBY and BY.;
                                %else %put ERROR: (Model &i: %qupcase(cat_ref) for  %qupcase(%superq(_cat&i._&j))): Reference value (%superq(_catref_&i._&j.)) does not exist in &data;
                                %let nerror_run=%eval(&nerror_run+1);
                            %end;
                        %end;
                        %else %if %sysevalf(%superq(colby)^=,boolean) or %sysevalf(%superq(rowby)^=,boolean) or %sysevalf(%superq(groupby)^=,boolean) or %sysevalf(%superq(by&i)^=,boolean) %then %do;
                            %local _ngrpcheck;
                            select count(distinct catx('-',_colby_lvl,_rowby_lvl,_groupby_lvl,_by_lvl)) into :_ngrpcheck separated by ''
                                from _tempdsn&i;
                            select max(_cat_&j) into :_catref_&i._&j. separated by ''    
                                from (select _cat_&j,count(distinct catx('-',_colby_lvl,_rowby_lvl,_groupby_lvl,_by_lvl)) as ngrp
                                        from _tempdsn&i group by _cat_&j)
                                where ngrp=&_ngrpcheck;
                            %if %sysevalf(%superq(_catref_&i._&j.)=,boolean) %then %do;
                                /**Throw errors**/
                                %put ERROR: (Model &i: %qupcase(cat_ref) for %qupcase(%superq(_cat&i._&j))): No consistent values in all possible subgroups of COLBY, ROWBY, GROUPBY and BY to use as reference.;
                                %let nerror_run=%eval(&nerror_run+1);
                            %end;
                        %end;
                        %else %let _catref_&i._&j.=%qscan(%superq(_catlvls_&i._&j),%sysfunc(countw(%superq(_catlvls_&i._&j),|)),|,m);
                    %end;
                %end;
                %if &&_ncat&i>0 %then %do;
                    update _tempdsn&i
                        set %do j = 1 %to &&_ncat&i;
                                %if &j>1 %then %do; , %end;
                                _cat_lvl_&j.=case(_cat_&j)
                                    %do k = 1 %to %sysfunc(countw(%superq(_catlvls_&i._&j.),|,m));
                                        when "%scan(%superq(_catlvls_&i._&j.),&k,|,m)" then &k
                                    %end;
                                    else . end,
                                _cat_val_&j.=ifn(_cat_&j="%superq(_catref_&i._&j.)",0,
                                    case(_cat_&j)
                                        %do k = 1 %to %sysfunc(countw(%superq(_catlvls_&i._&j.),|,m));
                                            when "%scan(%superq(_catlvls_&i._&j.),&k,|,m)" then &k
                                        %end;
                                        else . end)
                            %end;;
                %end;
        %end;
        /*Section 2.6.1.3: Create macro variables containing the values of the by variable*/
        %if &&_ncov&i = 0 %then %do; proc sql; %end;
            /*Section 2.6.1.3.1: By variables*/             
            %local _bylevels_&i._1;   
            %do b = 1 %to %sysfunc(countw(%superq(by&i),%str( )));            
                %local _bylevels_&i._&b;     
                select distinct %if %sysevalf(%superq(byorder_formatted)=0,boolean) %then %do; _temp_by_&b %end;
                                %else %do; _by_ %end;
                    into :_bylevels_&i._&b separated by '|'
                    from _tempdsn&i where _by_num=&b; 
                %let _byorder_&i._&b.=%qscan(%superq(byorder&i),&b,`,m);
                /*Section 2.6.1.3.2: Check that by value orders make sense*/  
                %if %sysevalf(%superq(_byorder_&i._&b.)^=,boolean) %then %_ordercheck(byorder,_bylevels_&i._&b,_byorder_&i._&b.);    
            %end;

            %if %sysevalf(%superq(by&i)^=,boolean) %then %do;
                update _tempdsn&i
                    set _by_lvl=case
                        %do b = 1 %to %sysfunc(countw(%superq(by&i),%str( )));
                            %do k = 1 %to %sysfunc(countw(%superq(_bylevels_&i._&b.),|,m));
                                when _by_num=&b and _by_="%scan(%superq(_bylevels_&i._&b.),&k,|,m)" then &k
                            %end;
                        %end;
                        else . end; 
            %end;
        quit;
        proc sort data=_tempdsn&i;
            by modelnum _rowby_lvl _colby_lvl _groupby_lvl _by_num _by_lvl;
        run;
        %if &&_ncat&i > 1 and &&show_adjcovariates&i=0 %then %do;
            data _tempdsn&i;
                set _tempdsn&i;
                by modelnum _rowby_lvl _colby_lvl _groupby_lvl _by_num _by_lvl;
                if first._by_lvl then do;
                    %do j = %sysevalf(2-(%scan(&&type&i,1,%str( ))=1)) %to &&_ncat&i;
                        _temp_cat&j=_cat_lvl_&j;
                    %end;
                end;
                %do j = %sysevalf(2-(%scan(&&type&i,1,%str( ))=1)) %to &&_ncat&i;
                    if _cat_lvl_&j=_temp_cat&j then _cat_val_&j.=0;
                    retain _temp_cat&j;
                    drop _temp_cat&j;
                %end;
            run;
        %end;
        
    %put MVMODELS has finished model &i error processing, runtime: %sysfunc(putn(%sysevalf(%sysfunc(TIME())-&_starttime.),mmss8.4)); 
        /**If any errors exist, stop macro and send to end**/
        %if &nerror_run > 0 %then %goto errhandl2;
        proc sql noprint;
            %local c r g b bl v cat _cat_indx _cont_indx _vmerge;
            /*Check if rows should be merged*/
            %if &&_ncov&i>1 and &&show_adjcovariates&i=0 %then %let _ncov&i=1;
            %if &&_ncov&i=1 and %scan(&&type&i,1,%str( ))=1 %then %let _vmerge=1;
            %else %if &&_ncov&i=1 and %scan(&&type&i,1,%str( ))=2 %then %let _vmerge=2;
            %else %let _vmerge=0;
            insert into _models
                %do r = 1 %to &_rows;
                    %do c = 1 %to &_columns;
                        %do g = 1 %to &_groups;
                            %if %sysevalf(%superq(model_title&i)^=,boolean) or %sysevalf(%superq(by&i)=,boolean) %then %do;
                            set modelnum=&i,
                                subtitle=
                                case
                                   when ^missing("%superq(model_title&i)") then "%superq(model_title&i)"
                                   %if %sysevalf(%superq(by&i)=,boolean) %then %do;
                                       %if &_vmerge=1 %then %do;
                                       when &_vmerge=1 then "%superq(_label&i._1)"||case (&&cont_display&i)
                                                    when 1 then " (Step Size: "||strip(put(%superq(_cont_step&i._1),12.))||')'
                                                    else '' end
                                       %end;
                                       %if &_vmerge=2 %then %do;
                                       when &_vmerge=2 then "%superq(_label&i._1)"||
                                                case
                                                    when &&cat_display&i =1 and %sysfunc(countw(%superq(_catlvls_&i._1),|))=2 then
                                                        case
                                                            %do cat = 1 %to %sysfunc(countw(%superq(_catlvls_&i._1),|));
                                                                when "%qscan(%superq(_catlvls_&i._1),&cat,|)"^="%superq(_catref_&i._1)" then 
                                                                    " (%qscan(%superq(_catlvls_&i._1),&cat,|) vs %superq(_catref_&i._1))"
                                                            %end;
                                                         else '' end 
                                                    when &&cat_display&i =2 then " (Reference: %superq(_catref_&i._1))"
                                                else '' end
                                        %end;                     
                                   %end;
                                else "Model &i" end,
                                subind=coalesce(&&indent_model_title&i,0),
                                boldind=coalesce(&&bold_model_title&i,1),
                                nstrata=%sysfunc(countw(%superq(strata&i),%str( ))),ncat=&&_ncat&i,ncont=&&_ncont&i,ncovariates=&&_ncat&i+&&_ncont&i,
                                show_adjcovariates=&&show_adjcovariates&i,
                                %if %sysevalf(%superq(by&i)=,boolean) and &&show_modelstats&i>0 %then %do; modelsum_row=1, %end;
                                %else %do; modelsum_row=0, %end;
                                show_modelstats=&&show_modelstats&i,
                                %if %sysevalf(%superq(by&i)^=,boolean) %then %do; by_num=0,by_lvl=0, %end;
                                %else %do; by_num=1,by_lvl=1, %end; 
                                rowby="%qscan(%superq(_rowbylevels),&r,|,m)",rowby_lvl=&r,rowbyvar=upcase("&rowby"),
                                colby="%qscan(%superq(_colbylevels),&c,|,m)",colby_lvl=&c,colbyvar=upcase("&colby"),
                                %if %sysevalf(%superq(groupby)^=,boolean) %then %do; groupby_label="&groupbylabel", %end;
                                groupby="%qscan(%superq(_groupbylevels),&g,|,m)",groupby_lvl=&g,groupbyvar=upcase("&groupby"),
                                varnum=-10,varlevel=0
                            %end;
                            %do b = 1 %to %sysfunc(max(1,%sysfunc(countw(%superq(by&i),%str( )))));
                                %if %sysevalf(%superq(by&i)^=,boolean) and &&bylabelon&i=1 %then %do;
                                    set modelnum=&i,
                                        %if &_vmerge=0 or %sysevalf(%qscan(%superq(bylabel&i),&b,`,m)^=,boolean) %then %do;
                                            subtitle="%superq(_bylabel&i._&b)",
                                        %end;
                                        %else %if &_vmerge=1 %then %do;
                                            subtitle="%superq(_label&i._1)"||
                                                case (&&cont_display&i)
                                                    when 1 then " (Step Size: "||strip(put(%superq(_cont_step&i._1),12.))||')'
                                                else '' end||' by '||"%superq(_bylabel&i._&b)",
                                        %end;
                                        %else %if &_vmerge=2 %then %do;
                                            subtitle="%superq(_label&i._1)"||
                                                case
                                                    when &&cat_display&i =1 and %sysfunc(countw(%superq(_catlvls_&i._1),|))=2 then
                                                        case
                                                            %do cat = 1 %to %sysfunc(countw(%superq(_catlvls_&i._1),|));
                                                                when "%qscan(%superq(_catlvls_&i._1),&cat,|)"^="%superq(_catref_&i._1)" then 
                                                                    " (%qscan(%superq(_catlvls_&i._1),&cat,|) vs %superq(_catref_&i._1))"
                                                            %end;
                                                         else '' end 
                                                    when &&cat_display&i =2 then " (Reference: %superq(_catref_&i._1))"
                                                else '' end||' by '||"%superq(_bylabel&i._&b)",  
                                        %end; 
                                        subind=coalesce(&&indent_cov_label&i,%sysevalf(%superq(model_title&i)^=,boolean)),
                                        boldind=coalesce(&&bold_by_label&i,1),
                                        nstrata=%sysfunc(countw(%superq(strata&i),%str( ))),ncat=&&_ncat&i,ncont=&&_ncont&i,ncovariates=&&_ncat&i+&&_ncont&i,
                                        byvar=upcase("%scan(&&by&i,&b,%str( ))"),by_num=&b,by_lvl=0,
                                        pval_by=&&pval_by&i,
                                        show_adjcovariates=&&show_adjcovariates&i,show_modelstats=&&show_modelstats&i,
                                        rowby="%qscan(%superq(_rowbylevels),&r,|,m)",rowby_lvl=&r,rowbyvar=upcase("&rowby"),
                                        colby="%qscan(%superq(_colbylevels),&c,|,m)",colby_lvl=&c,colbyvar=upcase("&colby"),
                                        %if %sysevalf(%superq(groupby)^=,boolean) %then %do; groupby_label="&groupbylabel", %end;
                                        groupby="%qscan(%superq(_groupbylevels),&g,|,m)",groupby_lvl=&g,groupbyvar=upcase("&groupby"),
                                        varnum=%sysevalf(-1*(&b/100)),varlevel=0
                                %end;
                                %do bl = 1 %to %sysfunc(max(1,%sysfunc(countw(%superq(_bylevels_&i._&b),|))));
                                    %let _cat_indx=0;%let _cont_indx=0;
                                    %if %sysevalf(%superq(by&i)^=,boolean) %then %do;
                                        set modelnum=&i,
                                            subtitle="%qscan(%superq(_bylevels_&i._&b),&bl,|,m)", 
                                            subind=coalesce(&&indent_cov_label&i,%sysevalf(%superq(model_title&i)^=,boolean)+&&bylabelon&i),
                                            boldind=coalesce(&&bold_by_value&i,0),
                                            nstrata=%sysfunc(countw(%superq(strata&i),%str( ))),ncat=&&_ncat&i,ncont=&&_ncont&i,ncovariates=&&_ncat&i+&&_ncont&i,
                                            byvar=upcase("%scan(&&by&i,&b,%str( ))"),by_num=&b,by_lvl=&bl,
                                            show_adjcovariates=&&show_adjcovariates&i,show_modelstats=&&show_modelstats&i,
                                            %if &&show_modelstats&i>0 %then %do; modelsum_row=1, %end;
                                            %else %do; modelsum_row=0, %end;
                                            
                                            rowby="%qscan(%superq(_rowbylevels),&r,|,m)",rowby_lvl=&r,rowbyvar=upcase("&rowby"),
                                            colby="%qscan(%superq(_colbylevels),&c,|,m)",colby_lvl=&c,colbyvar=upcase("&colby"),
                                            %if %sysevalf(%superq(groupby)^=,boolean) %then %do; groupby_label="&groupbylabel", %end;
                                            groupby="%qscan(%superq(_groupbylevels),&g,|,m)",groupby_lvl=&g,groupbyvar=upcase("&groupby"),
                                            varnum=%sysevalf(-1*(&b/100)),varlevel=&bl
                                    %end;
                                    %if &&_ncov&i > 0 %then %do v = 1 %to &&_ncov&i;
                                        %if %sysevalf(%scan(&&type&i,&v,%str( ))=1,boolean) %then %do;
                                            %let _cont_indx=%sysevalf(&_cont_indx+1);
                                            %if &_vmerge=0 %then %do;
                                                set modelnum=&i,
                                                    subtitle="%superq(_label&i._&v)"||
                                                        case (&&cont_display&i)
                                                            when 1 then " (Step Size: "||strip(put(%superq(_cont_step&i._&_cont_indx),12.))||')'
                                                        else '' end,
                                                    subind=coalesce(&&indent_cov_label&i,%sysevalf(%superq(model_title&i)^=,boolean)+&&bylabelon&i+%sysevalf(%superq(by&i)^=,boolean)),
                                                    boldind=coalesce(&&bold_by_value&i,1),
                                                    nstrata=%sysfunc(countw(%superq(strata&i),%str( ))),ncat=&&_ncat&i,ncont=&&_ncont&i,ncovariates=&&_ncat&i+&&_ncont&i,
                                                    show_adjcovariates=&&show_adjcovariates&i,
                                                    show_modelstats=&&show_modelstats&i,modelsum_row=0,
                                                    byvar=upcase("%scan(&&by&i,&b,%str( ))"),by_num=&b,by_lvl=&bl,
                                                    rowby="%qscan(%superq(_rowbylevels),&r,|,m)",rowby_lvl=&r,rowbyvar=upcase("&rowby"),
                                                    colby="%qscan(%superq(_colbylevels),&c,|,m)",colby_lvl=&c,colbyvar=upcase("&colby"),
                                                    %if %sysevalf(%superq(groupby)^=,boolean) %then %do; groupby_label="&groupbylabel", %end;
                                                    groupby="%qscan(%superq(_groupbylevels),&g,|,m)",groupby_lvl=&g,groupbyvar=upcase("&groupby"),
                                            %end;
                                            %else %do; , %end;
                                                covariate=upcase("_cont_&_cont_indx"),display=&&cont_display&i,cov_type=1,
                                                pval_type3=&&pval_type3&i,
                                                pval_covariates=&&pval_covariates&i, 
                                                varnum=&v,varlevel=ifn(&&cont_display&i=3,0,1),cont_step=%superq(_cont_step&i._&_cont_indx)

                                            %if &&cont_display&i=3 %then %do;
                                                set modelnum=&i,
                                                    subtitle="Step Size: "||strip(put(%superq(_cont_step&i._&_cont_indx),12.)),
                                                    subind=coalesce(&&indent_cov_label&i,1+%sysevalf(%superq(model_title&i)^=,boolean)+&&bylabelon&i+%sysevalf(%superq(by&i)^=,boolean)),
                                                    boldind=coalesce(&&bold_by_value&i,0),
                                                    nstrata=%sysfunc(countw(%superq(strata&i),%str( ))),ncat=&&_ncat&i,ncont=&&_ncont&i,ncovariates=&&_ncat&i+&&_ncont&i,
                                                    show_adjcovariates=&&show_adjcovariates&i,
                                                    show_modelstats=&&show_modelstats&i,modelsum_row=0,
                                                    byvar=upcase("%scan(&&by&i,&b,%str( ))"),by_num=&b,by_lvl=&bl,
                                                    covariate=upcase("_cont_&_cont_indx"),display=&&cont_display&i,cov_type=1,
                                                    
                                                    pval_covariates=&&pval_covariates&i, 
                                                    
                                                    rowby="%qscan(%superq(_rowbylevels),&r,|,m)",rowby_lvl=&r,rowbyvar=upcase("&rowby"),
                                                    colby="%qscan(%superq(_colbylevels),&c,|,m)",colby_lvl=&c,colbyvar=upcase("&colby"),
                                                    %if %sysevalf(%superq(groupby)^=,boolean) %then %do; groupby_label="&groupbylabel", %end;
                                                    groupby="%qscan(%superq(_groupbylevels),&g,|,m)",groupby_lvl=&g,groupbyvar=upcase("&groupby"),
                                                    varnum=&v,varlevel=1,cont_step=%superq(_cont_step&i._&_cont_indx)
                                            %end;
                                        %end;/*End continuous section*/
                                        %else %if %sysevalf(%scan(&&type&i,&v,%str( ))=2,boolean) %then %do;
                                            %let _cat_indx=%sysevalf(&_cat_indx+1);
                                            %if &_vmerge=0 /*and (&&_ncat&i >2 or ^(&&_ncat&i=2 and &&cat_display&i=1))*/ %then %do;
                                                set modelnum=&i,
                                                    subtitle="%superq(_label&i._&v)"||
                                                        case
                                                            when &&cat_display&i =1 and %sysfunc(countw(%superq(_catlvls_&i._&_cat_indx),|))=2 then
                                                                case
                                                                    %do cat = 1 %to %sysfunc(countw(%superq(_catlvls_&i._&_cat_indx),|));
                                                                        when "%qscan(%superq(_catlvls_&i._&_cat_indx),&cat,|)"^="%superq(_catref_&i._&_cat_indx)" then 
                                                                            " (%qscan(%superq(_catlvls_&i._&_cat_indx),&cat,|) vs %superq(_catref_&i._&_cat_indx))"
                                                                    %end;
                                                                 else '' end 
                                                            when &&cat_display&i =2 then " (Reference: %superq(_catref_&i._&_cat_indx))"
                                                        else '' end,
                                                    subind=coalesce(&&indent_cov_label&i,%sysevalf(%superq(model_title&i)^=,boolean)+&&bylabelon&i+%sysevalf(%superq(by&i)^=,boolean)),
                                                    boldind=coalesce(&&bold_cov_label&i,1),
                                                    rowby="%qscan(%superq(_rowbylevels),&r,|,m)",rowby_lvl=&r,rowbyvar=upcase("&rowby"),
                                                    colby="%qscan(%superq(_colbylevels),&c,|,m)",colby_lvl=&c,colbyvar=upcase("&colby"),
                                                    %if %sysevalf(%superq(groupby)^=,boolean) %then %do; groupby_label="&groupbylabel", %end;
                                                    groupby="%qscan(%superq(_groupbylevels),&g,|,m)",groupby_lvl=&g,groupbyvar=upcase("&groupby"),
                                                    nstrata=%sysfunc(countw(%superq(strata&i),%str( ))),ncat=&&_ncat&i,ncont=&&_ncont&i,ncovariates=&&_ncat&i+&&_ncont&i,
                                                    show_adjcovariates=&&show_adjcovariates&i,show_modelstats=&&show_modelstats&i,modelsum_row=0,
                                                    byvar=upcase("%scan(&&by&i,&b,%str( ))"),by_num=&b,by_lvl=&bl,
                                            %end;
                                            %else %do; , %end;
                                                covariate=upcase("_cat_&_cat_indx"),display=&&cat_display&i,cov_type=2,
                                                pval_type3=&&pval_type3&i,
                                                varnum=&v,   
                                                %if %sysfunc(countw(%superq(_catlvls_&i._&_cat_indx),|)) >2 or 
                                                    ^(%sysfunc(countw(%superq(_catlvls_&i._&_cat_indx),|))=2 and &&cat_display&i=1) %then %do;
                                                    varlevel=0,
                                                %end;
                                                %else %do;
                                                    varlevel=case
                                                                %do cat = 1 %to %sysfunc(countw(%superq(_catlvls_&i._&_cat_indx),|));
                                                                    when "%qscan(%superq(_catlvls_&i._&_cat_indx),&cat,|)"^="%superq(_catref_&i._&_cat_indx)" then &cat
                                                                %end;
                                                             else . end,
                                                    pval_covariates=&&pval_covariates&i,
                                                    cat_val="%qscan(%superq(_catlvls_&i._&_cat_indx),&cat,|)",
                                                    cat_ref=("%qscan(%superq(_catlvls_&i._&_cat_indx),&cat,|)"="%superq(_catref_&i._&_cat_indx)"),
                                                    cat_refv="%superq(_catref_&i._&_cat_indx)",
                                                %end;        
                                                cat_nlvl=%sysfunc(countw(%superq(_catlvls_&i._&_cat_indx),|))
                                            %do cat = 1 %to %sysfunc(countw(%superq(_catlvls_&i._&_cat_indx),|));
                                                %if ^(&&cat_display&i^=4 and %sysevalf(%qscan(%superq(_catlvls_&i._&_cat_indx),&cat,|)=%superq(_catref_&i._&_cat_indx),boolean)) %then %do;
                                                    %if %sysfunc(countw(%superq(_catlvls_&i._&_cat_indx),|)) >2 or 
                                                        ^(%sysfunc(countw(%superq(_catlvls_&i._&_cat_indx),|))=2 and &&cat_display&i=1) %then %do;
                                                        set modelnum=&i,
                                                            subtitle="%qscan(%superq(_catlvls_&i._&_cat_indx),&cat,|)"||ifc(&&cat_display&i in(1 5)," vs %superq(_catref_&i._&_cat_indx)",''),
                                                            subind=coalesce(&&indent_cov_value&i,1+%sysevalf(%superq(model_title&i)^=,boolean)+&&bylabelon&i+%sysevalf(%superq(by&i)^=,boolean)),
                                                            boldind=coalesce(&&bold_cov_value&i,0),
                                                    %end;
                                                    %else %do; , %end;
                                                    %if &_vmerge=0 %then %do;
                                                        nstrata=%sysfunc(countw(%superq(strata&i),%str( ))),ncat=&&_ncat&i,ncont=&&_ncont&i,ncovariates=&&_ncat&i+&&_ncont&i,
                                                        show_adjcovariates=&&show_adjcovariates&i,show_modelstats=&&show_modelstats&i,modelsum_row=0,
                                                    %end;
                                                        covariate=upcase("_cat_&_cat_indx"),display=&&cat_display&i,cov_type=2,
                                                        
                                                        pval_covariates=&&pval_covariates&i,
                                                        
                                                        byvar=upcase("%scan(&&by&i,&b,%str( ))"),by_num=&b,by_lvl=&bl,
                                                        rowby="%qscan(%superq(_rowbylevels),&r,|,m)",rowby_lvl=&r,rowbyvar=upcase("&rowby"),
                                                        colby="%qscan(%superq(_colbylevels),&c,|,m)",colby_lvl=&c,colbyvar=upcase("&colby"),
                                                        %if %sysevalf(%superq(groupby)^=,boolean) %then %do; groupby_label="&groupbylabel", %end;
                                                        groupby="%qscan(%superq(_groupbylevels),&g,|,m)",groupby_lvl=&g,groupbyvar=upcase("&groupby"),
                                                        varnum=&v,varlevel=&cat,cat_nlvl=%sysfunc(countw(%superq(_catlvls_&i._&_cat_indx),|)),
                                                        cat_val="%qscan(%superq(_catlvls_&i._&_cat_indx),&cat,|)",
                                                        cat_ref=("%qscan(%superq(_catlvls_&i._&_cat_indx),&cat,|)"="%superq(_catref_&i._&_cat_indx)"),
                                                        cat_refv="%superq(_catref_&i._&_cat_indx)"
                                                %end; 
                                            %end;
                                        %end;/*End categorical section*/
                                        %if &&show_adjcovariates&i=0 %then %let v=&&_ncov&i;
                                    %end;/*Covariate Loop*/
                                %end;/*bl loop*/
                           %end;/*b loop*/
                    %end;/*g loop*/
                    %do j = 1 %to &&addspaces&i;
                        set modelnum=&i,
                            subtitle=" ",by_num=&b,
                            rowby="%qscan(%superq(_rowbylevels),&r,|,m)",rowby_lvl=&r,rowbyvar=upcase("&rowby"),
                            colby="%qscan(%superq(_colbylevels),&c,|,m)",colby_lvl=&c,colbyvar=upcase("&colby"),
                            %if %sysevalf(%superq(groupby)^=,boolean) %then %do; groupby_label="&groupbylabel", %end;
                            groupby="%qscan(%superq(_groupbylevels),&g,|,m)",groupby_lvl=&g,groupbyvar=upcase("&groupby")
                    %end;       
                 %end;/*c loop*/
            %end;/*r loop*/;
        quit;        
    %end;
    %put MVMODELS has finished model all error processing, runtime: %sysfunc(putn(%sysevalf(%sysfunc(TIME())-&_starttime.),mmss8.4));
    
    data _tempdsn;
        set %do i = 1 %to &nmodels;
                _tempdsn&i (in=a&i)
            %end;;
        by modelnum _rowby_lvl _colby_lvl _groupby_lvl _by_num _by_lvl;
        if first._by_lvl then model+1;
    run;
    proc sql noprint;
        %local _models;
        select distinct model into :_models separated by ' ' from _tempdsn;
        /**Section 2.6.2.2: EVENTCOV**/ 
        %if &nerror_run=0 and %sysevalf(%qupcase(%superq(method))=LOGISTIC,boolean) %then %do;
            %do i = 1 %to &nmodels;
                %local nmodel_lvls&i models&i min_nev max_nev ev_val_check;
                select max(model) into :nmodel_lvls&i separated by '' from _tempdsn where modelnum=&i;
                select distinct model into :models&i separated by ' ' from _tempdsn where modelnum=&i;
                %if %sysevalf(%superq(event&i)=,boolean) %then %do;
                    select min(_event_) into :event&i separated by '' 
                        from _tempdsn where modelnum=&i; 
                %end;
                update _tempdsn
                    set _event_val=(_event_="%superq(event&i)")
                    where modelnum=&i;
                %let min_nev=;%let max_nev=;%let ev_val_check=;
                select max(_event_val),min(count),max(count) into :ev_val_check separated by '',:min_nev separated by'',:max_nev separated by ''
                    from (select model,max(_event_val) as _event_val,count(distinct _event_) as count from _tempdsn where modelnum=&i group by model);
                %if &ev_val_check=0 %then %do;  
                    %put ERROR: (Model &i: %qupcase(event)): Specified value (%superq(event&i)) not found for EVENTCOV (%superq(eventcov&i));
                    %let nerror_run=%eval(&nerror_run+1);
                %end;
                %else %if &min_nev ^=2 and &max_nev =2 %then %do;
                    %if %sysevalf(%superq(by&i)^=,boolean) or %sysevalf(%superq(colby)^=,boolean) or 
                        %sysevalf(%superq(rowby)^=,boolean) or %sysevalf(%superq(groupby)^=,boolean) %then %do;
                        %put WARNING: (Model &i: %qupcase(eventcov)): Not all subgroups have 2 distinct levels;
                        %put WARNING: (Model &i: %qupcase(eventcov)): Subgroups without 2 distinct levels will be excluded from logistic models;
                    %end;
                %end;
            %end; 
        %end;    
    /**If any errors exist, stop macro and send to end**/
    %if &nerror_run > 0 %then %goto errhandl2;
        /**Transpose Models**/
        %local max_cat_lvl;
        select max(ifn(missing(varlevel),0,varlevel)) into :max_cat_lvl from _models;
        create table _legit_models as
            select distinct modelnum,_rowby_lvl as rowby_lvl,_colby_lvl as colby_lvl,_groupby_lvl as groupby_lvl,_by_num as by_num,_by_lvl as by_lvl,model 
            from _tempdsn;
    quit;
    data _models;
        merge _models _legit_models;
        by modelnum rowby_lvl colby_lvl groupby_lvl by_num by_lvl;
        if missing(model) and (varnum=-10 or (by_num>0 and by_lvl=0)) then model=0;
        if ^missing(model) then output;
    run;
    %local max_cat_covs max_cont_covs min_strata max_strata;
    proc sql noprint;
        select max(ncat),max(ncont),min(nstrata),max(nstrata)
            into :max_cat_covs separated by '',:max_cont_covs separated by '',:min_strata separated by '',:max_strata separated by '' from 
            (select model,max(nstrata) as nstrata,max(ncat) as ncat,max(ncont) as ncont 
                from _models group by model);
    quit;
    %local _cindex;
    %if (&max_cat_covs>0 or &max_cont_covs>0) and (%sysfunc(find(&plot_display,C_,i))>0 or %sysfunc(find(&table_display,C_,i))>0) %then %let _cindex=1;
    %else %let _cindex=0;

    %local nstrata;
    %let nstrata=0;
    %if &max_cat_covs>0 or &max_cont_covs>0 %then %do;
        %do i = 1 %to &nmodels;
            %if %sysfunc(countw(%superq(strata&i),%str( )))>&nstrata %then %let nstrata=%sysfunc(countw(%superq(strata&i),%str( )));
        %end;
        data _tempdsn;
            set _tempdsn;
            array _cat_cov_ {%sysfunc(max(&max_cat_covs,1))} $32.;
            array _cat_val_ {%sysfunc(max(&max_cat_covs,1))};
            array _cat_lvl_ {%sysfunc(max(&max_cat_covs,1))};
            array _cat_ {%sysfunc(max(&max_cat_covs,1))} $300.;
            array _cont_cov_ {%sysfunc(max(&max_cont_covs,1))} $32.;
            array _cont_ {%sysfunc(max(&max_cont_covs,1))};
            array cat_cov {%sysfunc(max(&max_cat_covs,1))} $32.;
            array cont_cov {%sysfunc(max(&max_cont_covs,1))} $32.;
            do i = 1 to dim(_cat_cov_);
                if missing(_cat_cov_(i)) then do;
                    _cat_val_(i)=0;
                    call missing(_cat_(i),_cat_lvl_(i),_cat_cov_(i));
                end;
            end;
            do i = 1 to dim(_cont_cov_);
                if missing(_cont_cov_(i)) then do;
                    _cont_(i)=0;
                    call missing(_cont_cov_(i));
                end;
            end;
        run;
    %end;
    data _tempdsn_p2;
        length _varname_ $40. _varval_ $300.;
        set %if &max_cat_covs=0 %then %do; _tempdsn (in=all); %end;
            %else %do i = 1 %to %sysfunc(countw(&_models,%str( )));
                _tempdsn (in=all&i where=(model=%scan(&_models,&i,%str( )))) 
                %do j = 1 %to &max_cat_covs;
                    _tempdsn (in=cat&i._&j where=(model=%scan(&_models,&i,%str( ))) rename=(_cat_lvl_&j=_varlvl_ _cat_&j=_varval_))
                %end;
            %end;;
        %if &max_cat_covs=0 %then %do; _varname_='_all_';_varval_='all';_varlvl_=.; %end;
        %else %do i = 1 %to %sysfunc(countw(&_models,%str( )));
            %if &i>1 %then %do; else %end;
            if all&i then do;_varname_='_all_';_varval_='all';end;
            %do j = 1 %to &max_cat_covs;
                else if cat&i._&j then do;
                    if ^(&j>1 and show_adjcovariates=0) then _varname_="_cat_&j";
                    else delete;
                end;
            %end;
        %end;
    run;
    proc sort data=_tempdsn_p2;
        by model _varname_ _varval_;
    run;
    %if &max_cat_covs>0 %then %do;
        proc sql;
            delete from _models
                where cov_type=2 and varlevel>0 and
                catx('--',modelnum,rowby_lvl,colby_lvl,groupby_lvl,by_num,by_lvl,covariate,varlevel)
                ^in(select catx('--',modelnum,_rowby_lvl,_colby_lvl,_groupby_lvl,_by_num,_by_lvl,upcase(_varname_),_varlvl_) from _tempdsn_p2);
            quit;
    %end;
        
            
    %if %sysevalf(%qupcase(&method)=LOGISTIC,boolean) and 
        (%sysfunc(find(&plot_display &table_display,bin_,i))>0  
        %sysfunc(find(&plot_display &table_display,total,i))>0 or %sysfunc(find(&plot_display &table_display,events,i))>0 or 
        %sysfunc(find(&plot_display &table_display,ev_t,i))>0 or %sysfunc(find(&plot_display &table_display,pct,i))>0) %then %do;
        /**section 4.5.2.1: Set up data with all Events**/ 
        data _bin_calc_;
            set _tempdsn_p2;
            by model _varname_ _varval_;
            array _bin_ {2} (2*0);
            
            if first._varval_ then do i = 1 to 2;
                _bin_(i)=0;
            end;
            if _event_val=1 then _bin_(1)+1;
            else _bin_(2)+1;
            
            if last._varval_ then do i = 1 to 2;
                _count_=_bin_(i);
                _level_=i;
                output;
            end;
            keep model _by_num _by_lvl _varname_ _varval_ _count_ _level_;
        run;
    
        proc freq data=_bin_calc_ noprint;
            by model _varname_ _varval_;
            table _level_ / bin (level='1');
            weight _count_ / zeros;
            output out=_bin_ bin;
        run;    
    %end;
    %if %sysevalf(%qupcase(&method)=LOGISTIC,boolean) and 
        %sysevalf(%superq(by)^=,boolean) and (%sysevalf(%superq(pval_by)=1,boolean) or %sysevalf(%superq(pval_by)=2,boolean))
        and %sysfunc(find(&table_display &plot_display,pval,i))>0 %then %do;               
        proc sort data=_tempdsn_p2 out=_tempdsn_p3;
            by modelnum _rowby_lvl _colby_lvl _groupby_lvl _by_num _by_lvl;
            where _varname_='_all_';
        run;   
        data _bin_calc_2;
            set _tempdsn_p3;
            by modelnum _rowby_lvl _colby_lvl _groupby_lvl _by_num _by_lvl;
            array _bin_ {2} (2*0);
            
            if first._by_lvl then do i = 1 to 2;
                _bin_(i)=0;
            end;
            if _event_val=1 then _bin_(1)+1;
            else _bin_(2)+1;
            
            if last._by_lvl then do i = 1 to 2;
                _count_=_bin_(i);
                _level_=i;
                output;
            end;
            keep modelnum _rowby_lvl _colby_lvl _groupby_lvl _by_num _by_lvl _varname_ _varval_ _count_ _level_;
        run;              
        proc freq data=_bin_calc_2 noprint;
            by modelnum _rowby_lvl _colby_lvl _groupby_lvl _by_num;
            table _by_lvl*_level_ / chisq nowarn
                %if %sysevalf(%superq(pval_by)=2,boolean) %then %do; fisher %end; sparse;
            weight _count_ / zeros;
            output out=_kmp chisq %if %sysevalf(%superq(pval_by)=2,boolean) %then %do; fisher %end;;
        run; 
    %end;
    %if %sysevalf(%qupcase(&method)=SURVIVAL,boolean) and 
        (%sysfunc(find(&plot_display &table_display,km_,i))>0 or %sysfunc(find(&plot_display &table_display,med_,i))>0 or 
        %sysfunc(find(&plot_display &table_display,total,i))>0 or %sysfunc(find(&plot_display &table_display,events,i))>0 or 
        %sysfunc(find(&plot_display &table_display,ev_t,i))>0 or %sysfunc(find(&plot_display &table_display,pct,i))>0) %then %do;
        %if %sysevalf(%qupcase(%superq(surv_method))^=CIF,boolean) %then %do;
            proc lifetest data=_tempdsn_p2
                %if %sysevalf(%superq(timelist)^=,boolean) %then %do;
                    outs=_km reduceout /**Outputs survival estimates at only requested times**/
                    timelist=&timelist /**Gives list of time-points for event-free rates**/
                %end;
                    conftype=&conftype /**Method for confidence limits**/;
                by model _varname_;
                where ^missing(_varval_);
                strata  _varval_ / notest nodetail;
                /**Runs the time-call**/
                time _time_*_cens_(0);
                ods output quartiles=_quart (where=(percent=50))
                    censoredsummary=_sum /**Outputs number of patients/events from model**/;     
            run;

            %if %sysevalf(%superq(surv_method)=%str(1-S),boolean) and %sysevalf(%superq(timelist)^=,boolean) %then %do;
                proc sql;
                    update _km
                        set survival=1-survival,
                        sdf_lcl=1-sdf_ucl,
                        sdf_ucl=1-sdf_lcl;
                quit;
            %end;
        %end;
        %else %do;
            proc lifetest data=_tempdsn_p2 outcif=_cif /*Outputs estimates for quartiles*/
                %if %sysevalf(%superq(timelist)^=,boolean) %then %do;
                    timelist=&timelist /**Gives list of time-points for event-free rates**/
                %end;
                    conftype=&conftype /**Method for confidence limits**/;
                by model _varname_;
                where ^missing(_varval_);
                strata  _varval_ / notest nodetail;
                /**Runs the time-call**/
                time _time_*_cens_(0) / eventcode=1;
                ods output 
                    %if %sysevalf(%superq(timelist)^=,boolean) %then %do;
                        cif=_km (rename=(cif=survival cif_lcl=sdf_lcl cif_ucl=sdf_ucl))
                    %end; 
                    failuresummary=_sum (rename=(event=failed))/**Outputs number of patients/events from model**/;     
            run;
            proc sql;
                create table _quart as
                    select model,_varname_, 50 as percent,
                    min(ifn(cif>=0.5,_time_,.)) as estimate,
                    min(ifn(cif_ucl>=0.5,_time_,.)) as lowerlimit,
                    min(ifn(cif_lcl>=0.5,_time_,.)) as upperlimit
                    from _cif
                    group by model,_varname_;
                drop table _cif;
            quit;
        %end;
    %end;
    %if %sysevalf(%qupcase(&method)=SURVIVAL,boolean) and 
        %sysevalf(%superq(by)^=,boolean) and %sysevalf(%superq(pval_by)=1,boolean) and %sysfunc(find(&table_display &plot_display,pval,i))>0 %then %do;
        proc sort data=_tempdsn_p2 out=_tempdsn_p3;
            by modelnum _rowby_lvl _colby_lvl _groupby_lvl _by_num _by_lvl;
            where _varname_='_all_';
        run;
        
        %if %sysevalf(%qupcase(&surv_method)^=CIF,boolean) %then %do;
            proc lifetest data=_tempdsn_p3;
                by modelnum _rowby_lvl _colby_lvl _groupby_lvl _by_num;
                where ^missing(_by_);
                strata 
                    %if &nstrata >0 %then %do;                                   
                        %do j=1 %to &nstrata; 
                            _strata_&j
                        %end; / logrank wilcoxon group=_by_lvl;/**Applies Stratification**/
                    %end;
                    %else %do;
                        _by_lvl / logrank wilcoxon
                    %end;;/**Calls the Logrank p-values**/
                /**Runs the time-call**/
                time _time_*_cens_(0);
                ods output homtests=_kmp;     
            run;
        %end;
        %else %do;
            proc lifetest data=_tempdsn_p3;
                by modelnum _rowby_lvl _colby_lvl _groupby_lvl _by_num;
                where ^missing(_by_);
                strata 
                    %if &nstrata >0 %then %do;                                   
                        %do j=1 %to &nstrata; 
                            _strata_&j
                        %end; / group=_by_lvl;/**Applies Stratification**/
                    %end;
                    %else %do;
                        _by_lvl 
                    %end;;/**Calls the p-values**/
                /**Runs the time-call**/
                time _time_*_cens_(0) / eventcode=1;
                ods output graytest=_kmp;     
            run;
        %end;
    %end;
    /*LOGISTIC Models*/
    %if (&max_cat_covs>0 or &max_cont_covs>0) and %sysevalf(%qupcase(&method)=LOGISTIC,boolean) and 
            (%sysfunc(find(&plot_display &table_display,or_,i)) or %sysfunc(find(&plot_display &table_display,c_,i)) or
            (%sysfunc(find(&plot_display &table_display,pval,i))>0 and %sysfunc(find(&pval_covariates,1,i))>0) or
            (%sysfunc(find(&plot_display &table_display,pval,i))>0 and %sysfunc(find(&pval_type3,1,i))>0)) %then %do;
        %if &min_strata = 0 %then %do;    
            proc logistic data=_tempdsn;
                /**Splits analysis by current BY variable**/
                by model;
                %if &max_strata > 0 %then %do;
                    where cmiss(%do i = 1 %to &nstrata; %if &i>1 %then %do; , %end; _strata_&i %end;)^=0;
                %end;
                class               
                    /**Creates class covariates with reference groups**/
                    %do j = 1 %to &max_cat_covs;
                        _cat_val_&j (ref="0")
                    %end; ;
                /**Runs model statement**/
                model _event_val (event='1') /**Event variables**/=
                    %do j = 1 %to &max_cat_covs;/**Character covariates**/
                        _cat_val_&j
                    %end;
                    %do j = 1 %to &max_cont_covs;/**Continuous covariates**/
                        _cont_&j
                    %end;
                    / clodds=wald;
                /**Calculate Odds Ratios**/
                %do j = 1 %to &max_cat_covs;
                    oddsratio "_cat_val_&j" _cat_val_&j / diff=ref;
                %end;
                %do j = 1 %to &max_cont_covs;
                    oddsratio "_cont_&j" _cont_&j;
                %end;   
                /**Outputs temporary datasets**/
                ods output parameterestimates=_parm /**Parameter estimates and wald p-values**/
                       oddsratioswald=_odds /**Odds Ratios**/
                       modelanova=_t3 /**Type 3 p-values**/
                       globaltests=_gpval /**Global model p-values**/
                       fitstatistics=_fit /**Model fit statistics**/;
                %if &_cindex=1 %then %do;
                    output out=_preds predicted=_pred_ xbeta=_xbeta_ /**Outputs the betas for C-index calculations**/;
                %end;
            run;
        %end;
        %if &nstrata >0 %then %do;        
            proc logistic data=_tempdsn;
                /**Splits analysis by current BY variable**/
                by model;
                where cmiss(%do i = 1 %to &nstrata; %if &i>1 %then %do; , %end; _strata_&i %end;)^=&nstrata;
                
                %if &nstrata >0 %then %do;                                   
                    strata %do j=1 %to &nstrata; 
                        _strata_&j
                    %end; / missing;/**Applies Stratification**/
                %end;
                class               
                    /**Creates class covariates with reference groups**/
                    %do j = 1 %to &max_cat_covs;
                        _cat_val_&j (ref="0")
                    %end; ;
                /**Runs model statement**/
                model _event_val (event='1') /**Event variables**/=
                    %do j = 1 %to &max_cat_covs;/**Character covariates**/
                        _cat_val_&j
                    %end;
                    %do j = 1 %to &max_cont_covs;/**Continuous covariates**/
                        _cont_&j
                    %end;
                    / clodds=wald;
                /**Calculate Odds Ratios**/
                %do j = 1 %to &max_cat_covs;
                    oddsratio "_cat_val_&j" _cat_val_&j / diff=ref;
                %end;
                %do j = 1 %to &max_cont_covs;
                    oddsratio "_cont_&j" _cont_&j;
                %end;   
                /**Outputs temporary datasets**/ 
                %if &min_strata = 0 %then %do;    
                    ods output parameterestimates=_parm_s /**Parameter estimates and wald p-values**/
                       oddsratioswald=_odds_s /**Odds Ratios**/
                       modelanova=_t3_s /**Type 3 p-values**/
                       globaltests=_gpval_s /**Global model p-values**/
                       fitstatistics=_fit_s (rename=(withcovariates=interceptandcovariates)) /**Model fit statistics**/;
                %end;
                %else %do;/**All models have strata**/
                    ods output parameterestimates=_parm /**Parameter estimates and wald p-values**/
                       oddsratioswald=_odds /**Odds Ratios**/
                       modelanova=_t3 /**Type 3 p-values**/
                       globaltests=_gpval /**Global model p-values**/
                       fitstatistics=_fit (rename=(withcovariates=interceptandcovariates)) /**Model fit statistics**/;
                %end;
            run;
            %if &min_strata = 0 %then %do;
                data _parm;set _parm _parm_s;run;
                data _odds;set _odds _odds_s;run;
                data _t3;set _t3 _t3_s;run;
                data _gpval;set _gpval _gpval_s;run;
                data _fit;set _fit _fit_s;run;
                proc datasets nolist nodetails;
                    %if &debug=0 %then %do;
                        delete _parm_s _odds_s _t3_s _gpval_s _fit_s;
                    %end;
                quit;
            %end;
        %end;
        %if &_cindex=1 and &min_strata=0 %then %do; 
            /**Calculate C-index and standard error if no stratification**/
            /**Based on Hanley JA, and McNeil BJ: The meaning and use of the area under a receiver
            operating characteristic (ROC) curve. Radiology 143:29-36, 1982.**/ 
            proc sort data=_preds out=_cindex_prep1;
                by model _xbeta_;    
            run; 
            proc sql noprint;
                %local _nmodels;
                select count(distinct model) into :_nmodels separated by '' from _tempdsn;
            %do j= 1 %to %superq(_nmodels);
                %local _nrank_&j;
            %end;
            data _cindex_prep2;
                set _cindex_prep1;
                by model _xbeta_;
                if first.model then _rank_=0;
                if first._xbeta_ then _rank_+1;
                if last.model then 
                    call symput("_nrank_"||strip(put(model,12.)),strip(put(_rank_,12.)));
            run;
            
            data _cindex;
                set _cindex_prep2;
                by model;
                array _ranks_ {%superq(_nmodels)} 
                    (%do j = 1 %to %superq(_nmodels);
                        &&_nrank_&j %if &j<%superq(_nmodels) %then %do;,%end;
                     %end;);
                array tab2 {%sysfunc(max(%do j = 1 %to %superq(_nmodels);
                        &&_nrank_&j %if &j<%superq(_nmodels) %then %do;,%end;
                     %end;)),7} _temporary_;
                if first.model then do i = 1 to _ranks_(model);
                    do j=1 to 7;
                        tab2(i,j)=0;
                    end;
                end;
            
                if _event_val=1 then tab2(_rank_,3)+1;
                else tab2(_rank_,1)+1;
                if last.model then do;  
                    sum1=0;
                    sum3=0;
                    do i = 1 to _ranks_(model);
                        sum1=sum1+tab2(i,1);
                        sum3=sum3+tab2(i,3);
                    end;  
                    tab2(1,2)=sum3-tab2(1,3);
                    do i = 2 to _ranks_(model);
                        tab2(i,2)=tab2(i-1,2)-tab2(i,3);
                    end;  
                    do i = 2 to _ranks_(model);
                        tab2(i,4)=tab2(i-1,1)+tab2(i-1,4);
                    end;
                    do i = 1 to _ranks_(model);
                        tab2(i,5)=tab2(i,1)*tab2(i,2)+0.5*tab2(i,1)*tab2(i,3);
                        tab2(i,6)=tab2(i,3)*(tab2(i,4)**2+tab2(i,4)*tab2(i,1)+(1/3)*tab2(i,1)**2);
                        tab2(i,7)=tab2(i,1)*(tab2(i,2)**2+tab2(i,2)*tab2(i,3)+(1/3)*tab2(i,3)**2);
                    end;      
                    sum5=0;
                    sum6=0;
                    sum7=0;
                    do i = 1 to _ranks_(model);
                        sum5=sum5+tab2(i,5);
                        sum6=sum6+tab2(i,6);
                        sum7=sum7+tab2(i,7);
                    end;        
                    w=sum5/(sum1*sum3);
                    q2=sum6/(sum3*sum1**2);
                    q1=sum7/(sum1*sum3**2);
                    se=sqrt((w*(1-w)+(sum3-1)*(q1-w**2)+(sum1-1)*(q2-w**2))/(sum1*sum3));
                    _bindex=model;
                    strata=.;
                    output;
                end;  
                rename _bindex=model;
                keep w q2 q1 se strata _bindex;
                rename w=c;
            run;
            
            proc datasets nolist nodetails;
                %if &debug=0 %then %do;
                    delete _cindex_prep1 _cindex_prep2 _preds;
                %end;
            quit;
        %end;
    %end;
    /*Cox Models*/
    %if (&max_cat_covs>0 or &max_cont_covs>0) and %sysevalf(%qupcase(&method)=SURVIVAL,boolean) and 
            (%sysfunc(find(&plot_display &table_display,hr_,i)) or %sysfunc(find(&plot_display &table_display,c_,i)) or
            (%sysfunc(find(&plot_display &table_display,pval,i))>0 and %sysfunc(find(&pval_covariates,1,i))>0) or
            (%sysfunc(find(&plot_display &table_display,pval,i))>0 and %sysfunc(find(&pval_type3,1,i))>0)) %then %do;
        proc phreg data=_tempdsn;
            /**Splits analysis by current BY variable**/
            by model;
            %if &nstrata >0 %then %do;                                   
                strata %do j=1 %to &nstrata; 
                    _strata_&j
                %end; / missing;/**Applies Stratification**/
            %end;
            class               
                /**Creates class covariates with reference groups**/
                %do j = 1 %to &max_cat_covs;
                    _cat_val_&j (ref="0")
                %end; ;
            /**Runs model statement**/
            model _time_*_cens_ (0) /**Time and status variables**/=
                %do j = 1 %to &max_cat_covs;/**Character covariates**/
                    _cat_val_&j
                %end;
                %do j = 1 %to &max_cont_covs;/**Continuous covariates**/
                    _cont_&j
                %end;
                / rl type3(score lr wald) /**Creates p-values**/ 
                  ties=&ties /**Ties method**/
                  %if %sysevalf(%qupcase(%superq(surv_method))=CIF) %then %do;
                      eventcode=1
                  %end;;
            /**Outputs temporary datasets**/
            ods output parameterestimates=_parm /**Parameter estimates and wald p-values**/
                       modelanova=_t3 /**Type 3 p-values**/
                       globaltests=_gpval /**Global model p-values**/
                       fitstatistics=_fit /**Model fit statistics**/;
            %if &_cindex=1 %then %do;
                output out=_xbeta  xbeta=xbeta /**Outputs the betas for C-index calculations**/;
            %end;
        run;
        
        %if &_cindex=1 %then %do;
            /**Sorts by present stratification**/
            %if &max_strata>0 %then %do;
                proc sort data=_xbeta out=_strata;
                    by model
                    %do j=1 %to &max_strata; 
                        _strata_&j
                    %end;;
                run;
            %end;
            /**Counts number of stratification levels**/
            data _stratlevels;
                /**Pulls if strata are present**/
                %if &max_strata>0 %then %do;
                    set _strata end=__last;
                    by model
                    %do j=1 %to &max_strata; 
                        _strata_&j
                    %end;;
                    if first.model then _strata_=0;
                    if first._strata_&max_strata then _strata_+1;
                %end;
                /**Pulls if no strata are present**/
                %else %do;
                    set _xbeta end=__last;
                    by model;
                    _strata_=1;
                %end;
                /**Saves number of strata into macro variable**/
                if last.model then 
                    call symputx('_nstrata'||strip(put(model,12.)),strip(put(_strata_,12.)));
            run;
            /**Performs analysis by stratification levels**/
            /**Sorts by time and descending status**/
            proc sort data=_stratlevels out=__step1;
                by model _strata_ _time_ descending _cens_;
                /**Sorts by the distinct betas to get an ordered list**/
            proc sort data=__step1 (keep=model _strata_ xbeta) nodupkey out=__ordered_xbeta;
                by model _strata_ xbeta;
            run;
            /**Counts the number of distinct betas**/
            data __ordered_xbeta;
                set __ordered_xbeta;
                by model _strata_;
                if first._strata_ then n = 0;
                n+1;
            run;
            /**Create macro variables for later**/
            proc sql noprint;
                %local _null_ _null2_;
                select model,_strata_,count(*),count(distinct xbeta)
                    into :_null_,:_null_,:n separated by ', ',:_uv separated by ', '
                    from __step1 group by model,_strata_;/**Number of patients, Number of distinct xbetas**/
                create table __step2 as
                    select a.*,b.N as __rank from __step1 a
                        left join 
                          (select distinct model,_strata_,xbeta, N from __ordered_xbeta) as b
                        on a.model=b.model and a._strata_=b._strata_ and a.xbeta=b.xbeta
                        order by a.model,a._strata_,a._time_,a._cens_ desc; /**Ranks patients by xbeta**/
            quit;
            /**Creates binary tree for indexing patients**/
            /**This copies BTREE from survConcordance.fit**/
            proc sort data=__step2 out=_ranks_prep (keep=model _strata_) nodupkey;
                by model _strata_;
            run;
            data _ranks;
                set _ranks_prep;
                by model _strata_;
                 
                /**Create arrays and variables to match survConcordance.fit**/
                array _uvs_ {%sysfunc(countw(%superq(_uv),%str(,)))} (&_uv);
                array yet_to_do {%sysfunc(max(0,&_uv))};
                array indx {%sysfunc(max(0,&_uv))};
                array ranks {%sysfunc(max(0,&_uv))};
                if first._strata_ then m+1;
                
                call missing(of yet_to_do(*),of indx(*),of ranks(*));
                depth=floor(log2(_uvs_(m)));
                start=2**depth;
                lastrow_length=1+_uvs_(m)-start;
                do i = 1 to _uvs_(m);
                    yet_to_do(i)=i;
                end;
                do i = 1 to lastrow_length;
                    indx(i)=1+2*(i-1);
                end;
                do i = 1 to _uvs_(m);
                    if ^missing(indx(i)) then do;
                        ranks(yet_to_do(indx(i)))=start+(i-1);
                    end;
                end;
                do i = 1 to dim(indx);
                    if ^missing(indx(i)) then do;
                        yet_to_do(indx(i))=.;
                    end;
                end;
                count=1;
                do i = 1 to dim(yet_to_do);
                    if ^missing(yet_to_do(i)) then do;
                        yet_to_do(count)=yet_to_do(i);
                        count=count+1;
                        yet_to_do(i)=.;
                    end;
                end;
                do while(start>1);
                    start=int(start/2);
                    do i = 1 to dim(indx);
                        indx(i)=.;
                    end;
                    do i = 1 to start;
                        indx(i)=1+2*(i-1);
                    end;
                    do i = 1 to dim(indx);
                        if ^missing(indx(i)) then do;
                            ranks(yet_to_do(indx(i)))=start+(i-1);
                        end;
                    end;
                    do i = 1 to dim(indx);
                        if ^missing(indx(i)) then do;
                            yet_to_do(indx(i))=.;
                        end;
                    end;
                    count=1;
                    do i = 1 to dim(yet_to_do);
                        if ^missing(yet_to_do(i)) then do;
                           yet_to_do(count)=yet_to_do(i);
                           count=count+1;
                           yet_to_do(i)=.;
                        end;
                    end;
                end;
                do i = 1 to dim(ranks);
                    /**Outputs indexes for the ranks**/
                    *call symput('_r'||strip(put(i,12.)),strip(put(ranks(i)-1,12.)));
                    ranks(i)=ranks(i)-1;
                end;
                                        
                keep model _strata_ ranks:;
            run;
            data __step2;
                merge __step2 _ranks;
                by model _strata_;
            run;
            /**Performs the C-index calculations**/
            /**Copies the function docount from survConcordance.fit**/
            data _step3;
                set __step2 end=last;
                by model _strata_;
                /**Initializes arrays and variables for calculations**/
                /**Method is to save values into temporary arrays and 
                then perform calculations on the last observation**/
                array ranks {*} ranks:;
                array _ns_ {%sysfunc(countw(%superq(n),%str(,)))} (&n);
                array _uvs_ {%sysfunc(countw(%superq(_uv),%str(,)))} (&_uv);
                array y {2,%sysfunc(max(&n))} _temporary_;
                array wt {%sysfunc(max(&n))} _temporary_;
                array indx {%sysfunc(max(&n))} _temporary_;
                array count {5};
                array twt (%sysevalf(2*%sysfunc(max(0,&_uv))));
                array nwt (%sysevalf(2*%sysfunc(max(0,&_uv))));
                if first._strata_ then do;
                    call missing(of y(*),of wt(*),of indx(*));
                    _nc_=0;
                    _nstrata_+1;
                end;
                _nc_+1;                            
                n=_ns_(_nstrata_);
                y(1,_nc_)=_time_;
                y(2,_nc_)=_cens_;
                wt(_nc_)=1;
                i=1;
                do while (__rank^=i);
                    i=i+1;
                end;
                indx(_nc_)=ranks(i);
                ntree=_uvs_(_nstrata_);
                vss=0;/**Initializes for standard error calculation**/
                if last._strata_ then do;/**Starts calculations**/
                    do i = 1 to dim(twt);
                        twt(i)=0;nwt(i)=0;
                    end;
                    do i = 1 to dim(count);
                        count(i)=0;
                    end;
                    i=n-1;
                    do while(i ge 0);/**First While loop**/
                        ndeath=0;
                        if y[2,i+1]=1 then do;/**Event Section**/
                            j=i;
                            if j > 0 then do while(j>0 and y(2,j+1)=1 and y(1,j+1)=y(1,i+1));/**Start J Loop**/
                                ndeath=ndeath+wt(j+1);
                                index=indx(j+1);
                                k=i;
                                if k > j then do while(k>j);/**Adds to ties**/
                                    count(4)=count(4)+wt(j+1)*wt(k+1);
                                    k=k-1;
                                end;
                                else k=k-1;
                                count(3)=count(3)+wt(j+1)*nwt(index+1);/**Adds to time ties**/
                                child=2*index+1;
                                if child < ntree then
                                    count(1)=count(1)+wt(j+1)*twt(child+1);/**Adds to concordant pairs**/
                                child=child+1;
                                if child < ntree then
                                    count(2)=count(2)+wt(j+1)*twt(child+1);/**Adds to discordant pairs**/
                                do while(index >0);
                                    parent=int((index-1)/2);
                                    if band(index,1) then
                                        count(2)=count(2)+wt(j+1)*(twt(parent+1)-twt(index+1));/**Adds to discordant pairs**/
                                    else count(1)=count(1)+wt(j+1)*(twt(parent+1)-twt(index+1));/**Adds to concordant pairs**/
                                    index=parent;
                                end;
                                j=j-1;
                            end;/**Ends J loop**/
                            else if j=0 then do;/**Finishes J=0 level of original loop**/
                                if y(2,j+1)=1 and y(1,j+1)=y(1,i+1) then do;/**Event Loop**/
                                    ndeath=ndeath+wt(j+1);
                                    index=indx(j+1);
                                    k=i;
                                    if k > j then do while(k>j);
                                        count(4)=count(4)+wt(j+1)*wt(k+1);/**Adds to ties**/
                                        k=k-1;
                                    end;
                                    else k=k-1;
                                    count(3)=count(3)+wt(j+1)*nwt(index+1);/**Adds to time ties**/
                                    child=2*index+1;
                                    if child < ntree then
                                        count(1)=count(1)+wt(j+1)*twt(child+1);/**Adds to concordant pairs**/
                                    child=child+1;
                                    if child < ntree then
                                        count(2)=count(2)+wt(j+1)*twt(child+1);/**Adds to discordant pairs**/
                                    do while(index >0);
                                        parent=int((index-1)/2);
                                        if band(index,1) then
                                            count(2)=count(2)+wt(j+1)*(twt(parent+1)-twt(index+1));/**Adds to discordant pairs**/
                                        else count(1)=count(1)+wt(j+1)*(twt(parent+1)-twt(index+1));/**Adds to concordant pairs**/
                                        index=parent;
                                    end;
                                    j=j-1;
                                end;/**Ends event loop**/
                            end;/**Ends J=0 loop**/
                        end;/**Ends Event section**/
                        else j = i-1;
                        if i>j then do while (i>j);/**Sum of squares section**/
                            wsum1=0;
                            oldmean=twt(1)/2;
                            index=indx(i+1);
                            nwt(index+1)=nwt(index+1)+wt(i+1);
                            twt(index+1)=twt(index+1)+wt(i+1);
                            wsum2=nwt(index+1);
                            child=2*index + 1;
                            if child < ntree then wsum1=wsum1+twt(child+1);
                            do while(index > 0);
                                parent=int((index-1)/2);
                                twt(parent+1)=twt(parent+1)+wt(i+1);
                                if ^(band(index,1)) then wsum1=wsum1+(twt(parent+1)-twt(index+1));
                                index=parent;
                            end;
                            wsum3=twt(1) - (wsum1+wsum2);
                            lmean=wsum1/2;
                            umean=wsum1+wsum2+wsum3/2;
                            newmean=twt(1)/2;
                            myrank=wsum1+wsum2/2;
                            /**Adds to sum of squares**/
                            vss=vss+wsum1*(newmean+oldmean-2*lmean)*(newmean-oldmean);
                            vss=vss+wsum3*(newmean+oldmean+wt(i+1)-2*umean)*(oldmean-newmean);
                            vss=vss+wt(i+1)*(myrank-newmean)*(myrank-newmean);
                            i=i-1;
                        end;/**Ends sum of squares section**/
                        else i=i-1;
                        count(5)=count(5)+ndeath*vss/twt(1);/**Adds to variance**/
                    end;/**Ends first loop**/
                    concordant=count(1);
                    discordant=count(2);
                    ties=count(3);
                    ties_time=count(4);
                    std=2*sqrt(count(5));/**Calculates standard deviation**/
                    if concordant+discordant+ties > 0 then do;
                        c=(concordant+ties/2)/(concordant+discordant+ties);/**Calculates concordance**/
                        se=std/(2*sum(concordant,discordant,ties));/**Calculates standard error**/
                    end;
                    else do;
                        c=0;se=0;
                    end;
                    output;
                end;
                keep model _strata_ concordant discordant ties ties_time std c se;
            run;
            /**Puts all calculations by strata level into same dataset**/
            /**Split by current BY level**/
            /**Calculates overall C-index within current by level**/
            data _cindex;
                set _step3;
                by model _strata_;
                drop _strata_;
                array temp {5}  _temporary_;
                if first.model then do i = 1 to 5;
                    temp(i)=0;
                end;
                if ^(first.model and last.model) then do;
                    temp(1)=temp(1)+concordant;
                    temp(2)=temp(2)+discordant;
                    temp(3)=temp(3)+ties;
                    temp(4)=temp(4)+ties_time;
                    temp(5)=temp(5)+std;
                    c=.;
                    se=.;
                    strata=_strata_;
                    output;
                    /**Calculates overall c-index**/
                    if last.model then do;
                        concordant=temp(1);
                        discordant=temp(2);
                        ties=temp(3);
                        ties_time=temp(4);
                        std=temp(5);
                        c=(concordant+ties/2)/(concordant+discordant+ties);
                        se=std/(2*sum(concordant,discordant,ties));
                        strata=.;
                        output;
                    end;
                    drop i;
                end;
                else do;
                    strata=.;
                    output;
                end;
            run;
            proc datasets nolist nodetails;
                %if &debug=0 %then %do;
                    delete  _stratlevels _strata _xbeta __ordered_xbeta _ranks _ranks_prep
                         __step1 __step2 _step3 _ranks _cindex_prep1 _cindex_prep2;
                %end;
            quit;
        %end;
    %end;
    
    
    
    %local step;
    %let step=0;
    data _tempdsn_0;
        set _models;
        where ^(^missing(covariate) and (covariate=byvar or covariate=colby or covariate=rowby or covariate=groupby)) or sum(ncat,ncont)=0;
    run;
    proc sort data=_tempdsn_0;
        by colby_lvl rowby_lvl modelnum groupby_lvl by_num by_lvl varnum varlevel;
    run;
    %if %sysevalf(%superq(groupby)^=,boolean) %then %do;
        proc sort data=_tempdsn_0;
            by modelnum rowby_lvl colby_lvl by_num by_lvl varnum varlevel groupby_lvl;
        run;
        data _tempdsn_0;
            set _tempdsn_0;
            by modelnum rowby_lvl colby_lvl by_num by_lvl varnum varlevel groupby_lvl;
            if first.varlevel then do;
                _temp_=groupby_lvl;_temp2_=model;_temp3=cat_refv;_temp4=cat_ref;_temp5=cat_val;
                groupby_lvl=0;call missing(model,cat_val,cat_ref,cat_refv);output;
                groupby_lvl=_temp_;model=_temp2_;cat_refv=_temp3;cat_ref=_temp4;cat_val=_temp5;call missing(subtitle);
                if ^missing(groupby_lvl) then output;
            end;
            else do;
                call missing(subtitle);output;
            end;
            drop _temp_ _temp2_ _temp3 _temp4 _temp5;
        run;
    %end;
    proc sql;
        %if %qupcase(&method)=SURVIVAL %then %do;
            %local _classvalcheck;
            %if (&max_cat_covs>0 or &max_cont_covs>0) and (%sysfunc(find(&plot_display &table_display,hr_,i))>0 or 
                (%upcase(&method)=SURVIVAL and %sysfunc(find(&plot_display &table_display,pval,i))>0 and %sysfunc(find(&pval_covariates,1,i))>0)) %then %do;
                select max((upcase(name)='CLASSVAL0')) into :_classvalcheck separated by ''
                    from sashelp.vcolumn where libname='WORK' and memname=('_PARM');
            %end;
            create table _tempdsn_final as
                    select a.*,. as null
                    %if %sysfunc(find(&plot_display &table_display,total,i))>0 or %sysfunc(find(&plot_display &table_display,events,i))>0 or 
                        %sysfunc(find(&plot_display &table_display,ev_t,i))>0 or %sysfunc(find(&plot_display &table_display,pct,i))>0 %then %do;
                        ,strip(put(b.total,12.0)) as total,strip(put(c.total,12.0)) as ref_total
                        ,strip(put(b.failed,12.0)) as events 
                        ,strip(put(c.failed,12.0)) as ref_events
                        ,ifc(^missing(b.failed) and ^missing(b.total),strip(put(100*b.failed/b.total,12.&pctdigits))||'%','') as pct
                        ,ifc(^missing(c.failed) and ^missing(c.total),strip(put(100*c.failed/c.total,12.&pctdigits))||'%','') as ref_pct
                        ,ifc(^missing(b.failed) and ^missing(b.total),strip(put(b.failed,12.0))||'/'||strip(put(b.total,12.0)),'') as ev_t
                        ,ifc(^missing(c.failed) and ^missing(c.total),strip(put(c.failed,12.0))||'/'||strip(put(c.total,12.0)),'') as ref_ev_t
                        ,ifc(^missing(b.failed) and ^missing(b.total),strip(put(b.failed,12.0))||'/'||strip(put(b.total,12.0))||' ('||strip(put(100*b.failed/b.total,12.&pctdigits))||'%)','') as ev_t_pct
                        ,ifc(^missing(c.failed) and ^missing(c.total),strip(put(c.failed,12.0))||'/'||strip(put(c.total,12.0))||' ('||strip(put(100*c.failed/c.total,12.&pctdigits))||'%)','') as ref_ev_t_pct
                    %end;
                    %if %sysfunc(find(&plot_display &table_display,med_,i))>0 %then %do;
                        ,d.estimate as med_est,d.lowerlimit as med_lcl,d.upperlimit as med_ucl
                        ,ifc(^missing(d.model),
                            ifc(^missing(d.estimate),strip(put(d.estimate,12.&mediandigits)),'NE'),
                            '') as med_estimate
                        ,ifc(^missing(d.model),
                            ifc(^missing(d.estimate),strip(put(d.estimate,12.&mediandigits)),'NE')||' ('||
                            ifc(^missing(d.lowerlimit),strip(put(d.lowerlimit,12.&mediandigits)),'NE')||'-'||
                            ifc(^missing(d.upperlimit),strip(put(d.upperlimit,12.&mediandigits)),'NE')||')',
                            '') as med_est_range
                        ,ifc(^missing(d.model),
                            ifc(^missing(d.lowerlimit),strip(put(d.lowerlimit,12.&mediandigits)),'NE')||'-'||
                            ifc(^missing(d.upperlimit),strip(put(d.upperlimit,12.&mediandigits)),'NE'),
                            '') as med_range  
                        ,ifc(^missing(e.model),
                            ifc(^missing(e.estimate),strip(put(e.estimate,12.&mediandigits)),'NE'),
                            '') as ref_med_estimate
                        ,ifc(^missing(e.model),
                            ifc(^missing(e.estimate),strip(put(e.estimate,12.&mediandigits)),'NE')||' ('||
                            ifc(^missing(e.lowerlimit),strip(put(e.lowerlimit,12.&mediandigits)),'NE')||'-'||
                            ifc(^missing(e.upperlimit),strip(put(e.upperlimit,12.&mediandigits)),'NE')||')',
                            '') as ref_med_est_range
                        ,ifc(^missing(e.model),
                            ifc(^missing(e.lowerlimit),strip(put(e.lowerlimit,12.&mediandigits)),'NE')||'-'||
                            ifc(^missing(e.upperlimit),strip(put(e.upperlimit,12.&mediandigits)),'NE'),
                            '') as ref_med_range 
                    %end;
                    %if %sysfunc(find(&plot_display &table_display,km_,i))>0 %then %do;
                        %local nkm;
                        %let nkm=%sysfunc(countw(&timelist,%str( )));
                        %do k = 1 %to &nkm;
                            ,ifn(^missing(b&k..survival),ifn(upcase("&estfmt.")="PPT",1,100)*b&k..survival,.) as km_est&k
                            ,ifn(^missing(b&k..sdf_lcl),ifn(upcase("&estfmt.")="PPT",1,100)*b&k..sdf_lcl,.) as km_lcl&k
                            ,ifn(^missing(b&k..sdf_ucl),ifn(upcase("&estfmt.")="PPT",1,100)*b&k..sdf_ucl,.) as km_ucl&k
                            ,ifn(^missing(c&k..survival),ifn(upcase("&estfmt.")="PPT",1,100)*c&k..survival,.) as ref_km_est&k
                            ,ifn(^missing(c&k..sdf_lcl),ifn(upcase("&estfmt.")="PPT",1,100)*c&k..sdf_lcl,.) as ref_km_lcl&k
                            ,ifn(^missing(c&k..sdf_ucl),ifn(upcase("&estfmt.")="PPT",1,100)*c&k..sdf_ucl,.) as ref_km_ucl&k
                            
                            ,ifc(^missing(b&k..model),
                                ifc(^missing(calculated km_est&k),strip(put(calculated km_est&k,12.&kmdigits)),'NE'),
                                '') as km_estimate&k
                            ,ifc(^missing(b&k..model),
                                ifc(^missing(calculated km_est&k),strip(put(calculated km_est&k,12.&kmdigits)),'NE')||' ('||
                                ifc(^missing(calculated km_lcl&k),strip(put(calculated km_lcl&k,12.&kmdigits)),'NE')||'-'||
                                ifc(^missing(calculated km_ucl&k),strip(put(calculated km_ucl&k,12.&kmdigits)),'NE')||')',
                                '') as km_est_range&k
                            ,ifc(^missing(b&k..model),
                                ifc(^missing(calculated km_lcl&k),strip(put(calculated km_lcl&k,12.&kmdigits)),'NE')||'-'||
                                ifc(^missing(calculated km_ucl&k),strip(put(calculated km_ucl&k,12.&kmdigits)),'NE'),
                                '') as km_range&k
                            ,ifc(^missing(c&k..model),
                                ifc(^missing(calculated ref_km_est&k),strip(put(calculated ref_km_est&k,12.&kmdigits)),'NE'),
                                '') as ref_km_estimate&k
                            ,ifc(^missing(c&k..model),
                                ifc(^missing(calculated ref_km_est&k),strip(put(calculated ref_km_est&k,12.&kmdigits)),'NE')||' ('||
                                ifc(^missing(calculated ref_km_lcl&k),strip(put(calculated ref_km_lcl&k,12.&kmdigits)),'NE')||'-'||
                                ifc(^missing(calculated ref_km_ucl&k),strip(put(calculated ref_km_ucl&k,12.&kmdigits)),'NE')||')',
                                '') as ref_km_est_range&k
                            ,ifc(^missing(c&k..model),
                                ifc(^missing(calculated ref_km_lcl&k),strip(put(calculated ref_km_lcl&k,12.&kmdigits)),'NE')||'-'||
                                ifc(^missing(calculated ref_km_ucl&k),strip(put(calculated ref_km_ucl&k,12.&kmdigits)),'NE'),
                                '') as ref_km_range&k
                        %end;
                    %end;
                    %if (&max_cat_covs>0 or &max_cont_covs>0) %then %do;
                        %if %sysfunc(find(&plot_display &table_display,hr_,i))>0 or 
                            (%sysfunc(find(&plot_display &table_display,pval,i))>0 and %sysfunc(find(&pval_covariates,1,i))>0) %then %do;
                            ,ifn(^missing(cont_step) and f.hazardratio>0,exp(cont_step*log(f.hazardratio)),f.hazardratio) as hr_est format=12.&hrdigits
                            ,ifn(^missing(cont_step) and f.hrlowercl>0,exp(cont_step*log(f.hrlowercl)),f.hrlowercl) as hr_lcl format=12.&hrdigits
                            ,ifn(^missing(cont_step) and f.hruppercl>0,exp(cont_step*log(f.hruppercl)),f.hruppercl) as hr_ucl format=12.&hrdigits
                            ,case (a.cov_type)
                                    when 2 then ifc(^missing(f.model),strip(put(f.hazardratio,12.&hrdigits)),
                                                                ifc(cat_ref=1,'Reference',''))
                             else ifc(^missing(f.model),
                                    ifc(^missing(cont_step) and f.hazardratio>0,strip(put(exp(cont_step*log(f.hazardratio)),12.&hrdigits)),strip(put(f.hazardratio,12.&hrdigits))),
                                    '') end as hr_estimate
                            ,case (a.cov_type)
                                    when 2 then ifc(^missing(f.model),strip(put(f.hazardratio,12.&hrdigits))||' ('||
                                                                strip(put(f.hrlowercl,12.&hrdigits))||'-'||
                                                                strip(put(f.hruppercl,12.&hrdigits))||')',
                                                                ifc(cat_ref=1,'Reference',''))
                             else ifc(^missing(f.model),
                                    ifc(^missing(cont_step) and f.hazardratio>0,strip(put(exp(cont_step*log(f.hazardratio)),12.&hrdigits)),strip(put(f.hazardratio,12.&hrdigits)))||' ('||
                                    ifc(^missing(cont_step) and f.hrlowercl>0,strip(put(exp(cont_step*log(f.hrlowercl)),12.&hrdigits)),strip(put(f.hrlowercl,12.&hrdigits)))||'-'||
                                    ifc(^missing(cont_step) and f.hruppercl>0,strip(put(exp(cont_step*log(f.hruppercl)),12.&hrdigits)),strip(put(f.hruppercl,12.&hrdigits)))||')',
                                    '') end as hr_est_range
                            ,case (a.cov_type)
                                    when 2 then ifc(^missing(f.model),strip(put(f.hrlowercl,12.&hrdigits))||'-'||
                                                                strip(put(f.hruppercl,12.&hrdigits)),
                                                                ifc(cat_ref=1,'Reference',''))
                             else ifc(^missing(f.model),
                                    ifc(^missing(cont_step) and f.hrlowercl>0,strip(put(exp(cont_step*log(f.hrlowercl)),12.&hrdigits)),strip(put(f.hrlowercl,12.&hrdigits)))||'-'||
                                    ifc(^missing(cont_step) and f.hruppercl>0,strip(put(exp(cont_step*log(f.hruppercl)),12.&hrdigits)),strip(put(f.hruppercl,12.&hrdigits))),
                                    '') end as hr_range  
                            ,ifc(a.pval_covariates=1 and ^missing(f.model),strip(put(f.probchisq,pvalue6.&pvaldigits)),'') as cov_pval
                            ,ifc(a.pval_covariates=1 and ^missing(f.model),ifc(a.nstrata>0,'S','')||'COVWALD','') as cov_pval_type
                            
                        %end;
                        %if %sysfunc(find(&plot_display &table_display,pval,i))>0 and 
                            (%sysfunc(find(&pval_type3,1,i))>0 or 
                             %sysfunc(find(&pval_type3,2,i))>0 or 
                             %sysfunc(find(&pval_type3,3,i))>0) %then %do;
                            ,ifc(^missing(g.model),
                                  case (a.pval_type3)
                                     when 1 then strip(put(g.probchisq,pvalue6.&pvaldigits))
                                     %if %qupcase(&method)=SURVIVAL and %sysevalf(%qupcase(&surv_method)^=CIF,boolean) %then %do;
                                         when 2 then strip(put(g.probscorechisq,pvalue6.&pvaldigits))
                                         when 3 then strip(put(g.problrchisq,pvalue6.&pvaldigits))
                                     %end;
                                  else '' end,'') as t3_pval
                            ,ifc(^missing(g.model),
                                  case (a.pval_type3)
                                     when 1 then ifc(a.nstrata>0,'S','')||'T3WALD'
                                     when 2 then ifc(a.nstrata>0,'S','')||'T3SCORE'
                                     when 3 then ifc(a.nstrata>0,'S','')||'T3LR'
                                  else '' end,'') as t3_pval_type
                        %end;
                        %if %sysfunc(find(&plot_display &table_display,AIC,i))>0 or %sysfunc(find(&plot_display &table_display,bic,i))>0 or
                            %sysfunc(find(&plot_display &table_display,LOGLIKELIHOOD,i))>0 %then %do;
                            ,strip(put(j.withcovariates,12.&AICdigits)) as AIC
                            ,strip(put(k.withcovariates,12.&bicdigits)) as bic
                            ,strip(put(l.withcovariates,12.&lldigits)) as LOGLIKELIHOOD
                        %end;  
                        %if %sysfunc(find(&plot_display &table_display,c_,i))>0 %then %do;                            
                            ,m.c as c_est
                            ,m.c-1.96*m.se as c_lcl
                            ,m.c+1.96*m.se as c_ucl   
                            ,ifc(^missing(m.model),
                                    strip(put(m.c,12.&cdigits)),
                                    '') as c_estimate
                            ,ifc(^missing(m.model),
                                    strip(put(m.c,12.&cdigits))||' ('||
                                    strip(put(m.c-1.96*m.se,12.&cdigits))||'-'||
                                    strip(put(m.c+1.96*m.se,12.&cdigits))||')',
                                    '') as c_est_range
                            ,ifc(^missing(m.model),
                                    strip(put(m.c-1.96*m.se,12.&cdigits))||'-'||
                                    strip(put(m.c+1.96*m.se,12.&cdigits)),
                                    '') as c_range                         
                        %end;  
                    %end;
                    %if %sysfunc(find(&plot_display &table_display,pval,i))>0 and %sysevalf(%superq(by)^=,boolean) and 
                        (%sysfunc(find(&pval_by,1,i))>0 or %sysfunc(find(&pval_by,2,i))>0) %then %do;
                        ,ifc(^missing(h._by_num),
                               case(a.pval_by)
                                 when 1 then strip(put(h.probchisq,pvalue6.&pvaldigits))  
                                 %if %qupcase(&surv_method)^=CIF %then %do;
                                     when 2 then strip(put(i.probchisq,pvalue6.&pvaldigits))
                                 %end;
                               else '' end,'') as by_pval
                        ,ifc(^missing(h._by_num ),
                               case(a.pval_by)
                                 %if %qupcase(&surv_method)^=CIF %then %do;
                                     when 1 then ifc(a.nstrata>0,'S','')||'LOGRANK'
                                     when 2 then ifc(a.nstrata>0,'S','')||'WILCOXON'
                                 %end;
                                 %else %do;
                                     when 1 then ifc(a.nstrata>0,'S','')||'GRAY'
                                 %end;        
                               else '' end,'') as by_pval_type    
                    %end;
                    from _tempdsn_0 as a 
                    %if %sysfunc(find(&plot_display &table_display,total,i))>0 or %sysfunc(find(&plot_display &table_display,events,i))>0 or 
                        %sysfunc(find(&plot_display &table_display,ev_t,i))>0 or %sysfunc(find(&plot_display &table_display,pct,i))>0 %then %do;
                        left join _sum as b
                            on a.model=b.model and 
                                upcase(ifc(modelsum_Row=1 and ^(a.varlevel>0 and a.cov_type=2 and a.show_modelstats=2),'_all_',
                                case (a.cov_type)
                                    when 2 then ifc(a.varlevel>0 and (a.display=4 or a.show_modelstats=2),covariate,'')
                                else '' end)) = upcase(b._varname_) and             
                                ifc(modelsum_row=1 and ^(a.varlevel>0 and a.cov_type=2 and a.show_modelstats=2),'all',case (a.cov_type)
                                    when 2 then strip(cat_val)
                                else '' end) = b._varval_
                            left join _sum as c
                            on a.model=c.model and 
                                upcase(case (a.cov_type)
                                    when 2 then ifc(a.varlevel>0,covariate,'')
                                else '' end) = upcase(c._varname_) and             
                                case (a.cov_type)
                                    when 2 then cat_refv
                                else '' end = c._varval_
                    %end;
                    %if %sysfunc(find(&plot_display &table_display,med_,i))>0 %then %do;
                        left join _quart as d
                        on a.model=d.model and 
                            upcase(ifc(modelsum_Row=1,'_all_',case (a.cov_type)
                               when 2 then ifc(a.varlevel>0 and (a.display=4 or a.show_modelstats=2),covariate,'')
                            else '' end)) = upcase(d._varname_) and             
                            ifc(modelsum_row=1,'all',case (a.cov_type)
                               when 2 then strip(cat_val)
                            else '' end) = d._varval_
                            left join  _quart as e
                            on a.model=e.model and 
                                upcase(case (a.cov_type)
                                    when 2 then ifc(a.varlevel>0,covariate,'')
                                else '' end) = upcase(e._varname_) and             
                                case (a.cov_type)
                                    when 2 then cat_refv
                                else '' end = e._varval_
                    %end;
                    %if %sysfunc(find(&plot_display &table_display,km_,i))>0 %then %do;
                        %do k = 1 %to &nkm;
                            left join (select * from _km where timelist=%scan(&timelist,&k,%str( ))) as b&k
                            on a.model=b&k..model and 
                            upcase(ifc(modelsum_Row=1,'_all_',case (a.cov_type)
                               when 2 then ifc(a.varlevel>0 and (a.display=4 or a.show_modelstats=2),covariate,'')
                            else '' end)) = upcase(b&k.._varname_) and             
                            ifc(modelsum_Row=1,'all',case (a.cov_type)
                               when 2 then strip(cat_val)
                            else '' end) = b&k.._varval_
                            left join (select * from _km where timelist=%scan(&timelist,&k,%str( ))) as c&k
                            on a.model=c&k..model and 
                                upcase(case (a.cov_type)
                                    when 2 then ifc(a.varlevel>0,covariate,'')
                                else '' end) = upcase(c&k.._varname_) and             
                                case (a.cov_type)
                                    when 2 then cat_refv
                                else '' end = c&k.._varval_
                        %end;
                    %end;
                    %if (&max_cat_covs>0 or &max_cont_covs>0) %then %do;
                        %if %sysfunc(find(&plot_display &table_display,hr_,i))>0 or 
                            (%sysfunc(find(&plot_display &table_display,pval,i))>0 and %sysfunc(find(&pval_covariates,1,i))>0) %then %do;
                           left join _parm as f
                                on a.model=f.model and 
                                    upcase(case (a.cov_type)
                                       when 2 then ifc(a.varlevel>0,'_cat_val_'||scan(covariate,3,'_','m'),'')
                                       when 1 then ifc(a.cont_step>. and a.varlevel=1,covariate,'')
                                    else '' end) = upcase(f.parameter)           
                                    %if &_classvalcheck=1  %then %do;
                                        and case (a.cov_type)
                                            when 2 then strip(put(varlevel,12.0))
                                        else '' end = f.classval0
                                    %end;
                        %end;
                        %if %sysfunc(find(&plot_display &table_display,pval,i))>0 and 
                            (%sysfunc(find(&pval_type3,1,i))>0 or 
                             %sysfunc(find(&pval_type3,2,i))>0 or 
                             %sysfunc(find(&pval_type3,3,i))>0) %then %do;
                            left join _t3 as g
                                on a.model=g.model and 
                                upcase(case (a.cov_type)
                                    when 2 then ifc(a.varlevel=0 or (a.varlevel=1 and a.cat_nlvl=2 and a.display=1),'_cat_val_'||scan(covariate,3,'_','m'),'')
                                    when 1 then ifc(a.varlevel=0 or (a.varlevel=1 and a.display in(1 2)),covariate,'')
                                else '' end) = upcase(g.effect)
                        %end;
                        %if %sysfunc(find(&plot_display &table_display,AIC,i))>0 or %sysfunc(find(&plot_display &table_display,bic,i))>0 or
                            %sysfunc(find(&plot_display &table_display,LOGLIKELIHOOD,i))>0 %then %do;
                            left join (select * from _fit where criterion='AIC') as j
                            on ifn(modelsum_Row=1,a.model,.)=j.model
                            left join (select * from _fit where criterion='SBC') as k
                            on ifn(modelsum_Row=1,a.model,.)=k.model
                            left join (select * from _fit where criterion='-2 LOG L') as l
                            on ifn(modelsum_Row=1,a.model,.)=l.model
                        %end;
                        %if %sysfunc(find(&plot_display &table_display,c_,i))>0 %then %do;
                            left join (select * from _cindex where ^missing(c)) as m
                            on ifn(modelsum_Row=1,a.model,.)=m.model                        
                        %end;
                    %end;
                    %if %sysfunc(find(&plot_display &table_display,pval,i))>0 and %sysevalf(%superq(by)^=,boolean) and 
                        (%sysfunc(find(&pval_by,1,i))>0 or %sysfunc(find(&pval_by,2,i))>0) %then %do;
                        left join
                            (select * from _kmp %if %qupcase(&surv_method)^=CIF %then %do; where test^='Wilcoxon' %end;) as h
                            on a.modelnum=h.modelnum and a.rowby_lvl=h._rowby_lvl and a.colby_lvl=h._colby_lvl and a.groupby_lvl=h._groupby_lvl and
                                ifn(a.by_lvl=0,a.by_num,.)=h._by_num 
                            %if %qupcase(&surv_method)^=CIF %then %do;
                                left join (select * from _kmp where test='Wilcoxon') as i
                                on a.modelnum=i.modelnum and a.rowby_lvl=i._rowby_lvl and a.colby_lvl=i._colby_lvl and a.groupby_lvl=i._groupby_lvl and
                                ifn(a.by_lvl=0,a.by_num,.)=i._by_num
                            %end;
    
                    %end;
                    order by modelnum, rowby_lvl, colby_lvl,by_num, by_lvl, varnum, varlevel, groupby_lvl;    
        %end;
        %if %qupcase(&method)=LOGISTIC %then %do;
            select max((upcase(name)='CLASSVAL0')) into :_classvalcheck separated by ''
                from sashelp.vcolumn where libname='WORK' and memname=('_odds');
            create table _tempdsn_final as
                select a.*,. as null
                %if %sysfunc(find(&plot_display &table_display,total,i))>0 or %sysfunc(find(&plot_display &table_display,events,i))>0 or 
                    %sysfunc(find(&plot_display &table_display,ev_t,i))>0 or %sysfunc(find(&plot_display &table_display,pct,i))>0 %then %do;
                    ,strip(put(b.n,12.0)) as total
                    ,strip(put(c.n,12.0)) as ref_total
                    ,strip(put(b.n*b._bin_,12.0)) as events
                    ,strip(put(c.n*c._bin_,12.0)) as ref_events
                    ,ifc(^missing(b._bin_),strip(put(100*b._bin_,12.&pctdigits))||'%','') as pct
                    ,ifc(^missing(c._bin_),strip(put(100*c._bin_,12.&pctdigits))||'%','') as ref_pct
                    ,ifc(^missing(b._bin_) and ^missing(b.n),strip(put(b._bin_*b.n,12.0))||'/'||strip(put(b.n,12.0)),'') as ev_t
                    ,ifc(^missing(c._bin_) and ^missing(c.n),strip(put(c._bin_*c.n,12.0))||'/'||strip(put(c.n,12.0)),'') as ref_ev_t
                    ,ifc(^missing(b._bin_) and ^missing(b.n),strip(put(b._bin_*b.n,12.0))||'/'||strip(put(b.n,12.0))||' ('||strip(put(100*b._bin_,12.&pctdigits))||'%)','') as ev_t_pct
                    ,ifc(^missing(c._bin_) and ^missing(c.n),strip(put(c._bin_*c.n,12.0))||'/'||strip(put(c.n,12.0))||' ('||strip(put(100*c._bin_,12.&pctdigits))||'%)','') as ref_ev_t_pct       
                %end;
                %if %sysfunc(find(&plot_display &table_display,bin_,i))>0 %then %do;
                    ,ifn(^missing(d._bin_),ifn(upcase("&estfmt.")="PPT",1,100)*d._bin_,.) as bin_est
                    ,ifn(upcase("&conftype")="BIN",ifn(^missing(d.l_bin),ifn(upcase("&estfmt.")="PPT",1,100)*d.l_bin,.),ifn(^missing(d.xl_bin),ifn(upcase("&estfmt.")="PPT",1,100)*d.xl_bin,.)) as bin_lcl
                    ,ifn(upcase("&conftype")="BIN",ifn(^missing(d.u_bin),ifn(upcase("&estfmt.")="PPT",1,100)*d.u_bin,.),ifn(^missing(d.xu_bin),ifn(upcase("&estfmt.")="PPT",1,100)*d.xu_bin,.)) as bin_ucl
                    ,ifn(^missing(e._bin_),ifn(upcase("&estfmt.")="PPT",1,100)*e._bin_,.) as ref_bin_est
                    ,ifn(upcase("&conftype")="BIN",ifn(^missing(e.l_bin),ifn(upcase("&estfmt.")="PPT",1,100)*e.l_bin,.),ifn(^missing(e.xl_bin),ifn(upcase("&estfmt.")="PPT",1,100)*e.xl_bin,.)) as ref_bin_lcl
                    ,ifn(upcase("&conftype")="BIN",ifn(^missing(e.u_bin),ifn(upcase("&estfmt.")="PPT",1,100)*e.u_bin,.),ifn(^missing(e.xu_bin),ifn(upcase("&estfmt.")="PPT",1,100)*e.xu_bin,.)) as ref_bin_ucl
                    ,ifc(^missing(d.model),ifc(^missing(calculated bin_est),strip(put(calculated bin_est,12.&bindigits)),'NE'),'') as bin_estimate
                    ,ifc(^missing(e.model),ifc(^missing(calculated ref_bin_est),strip(put(calculated ref_bin_est,12.&bindigits)),'NE'),'') as ref_bin_estimate
                    ,ifc(^missing(d.model),
                        ifc(^missing(calculated bin_est),strip(put(calculated bin_est,12.&bindigits)),'NE')||' ('||
                        ifc(^missing(d.l_bin),strip(put(calculated bin_lcl,12.&bindigits)),'NE')||'-'||
                        ifc(^missing(d.u_bin),strip(put(calculated bin_ucl,12.&bindigits)),'NE')||')',
                        '') as bin_est_range
                    ,ifc(^missing(e.model),
                        ifc(^missing(calculated ref_bin_est),strip(put(calculated ref_bin_est,12.&bindigits)),'NE')||' ('||
                        ifc(^missing(e.l_bin),strip(put(calculated ref_bin_lcl,12.&bindigits)),'NE')||'-'||
                        ifc(^missing(e.u_bin),strip(put(calculated ref_bin_ucl,12.&bindigits)),'NE')||')',
                        '') as ref_bin_est_range
                    ,ifc(^missing(d.model),
                        ifc(^missing(d.l_bin),strip(put(calculated bin_lcl,12.&bindigits)),'NE')||'-'||
                        ifc(^missing(d.u_bin),strip(put(calculated bin_ucl,12.&bindigits)),'NE'),
                        '') as bin_range  
                    ,ifc(^missing(e.model),
                        ifc(^missing(e.l_bin),strip(put(calculated ref_bin_lcl,12.&bindigits)),'NE')||'-'||
                        ifc(^missing(e.u_bin),strip(put(calculated ref_bin_ucl,12.&bindigits)),'NE'),
                        '') as ref_bin_range   
                %end;
                %if (&max_cat_covs>0 or &max_cont_covs>0) %then %do;
                    %if %sysfunc(find(&plot_display &table_display,or_,i))>0 or 
                        (%sysfunc(find(&plot_display &table_display,pval,i))>0 and %sysfunc(find(&pval_covariates,1,i))>0) %then %do;
                        ,ifn(^missing(cont_step) and g.oddsratioest>0,exp(cont_step*log(g.oddsratioest)),g.oddsratioest) as or_est format=12.&ordigits
                        ,ifn(^missing(cont_step) and g.lowercl>0,exp(cont_step*log(g.lowercl)),g.lowercl) as or_lcl format=12.&ordigits
                        ,ifn(^missing(cont_step) and g.uppercl>0,exp(cont_step*log(g.uppercl)),g.uppercl) as or_ucl format=12.&ordigits 
                        ,case (a.cov_type)
                                when 2 then ifc(^missing(f.model),strip(put(g.oddsratioest,12.&ordigits)),
                                                            ifc(cat_ref=1,'Reference',''))   
                         else ifc(^missing(f.model),
                                strip(put(exp(cont_step*log(g.oddsratioest)),12.&ordigits)),
                                '') end as or_estimate       
                        ,case (a.cov_type)
                                when 2 then ifc(^missing(f.model),strip(put(g.oddsratioest,12.&ordigits))||' ('||
                                                            strip(put(g.lowercl,12.&ordigits))||'-'||
                                                            strip(put(g.uppercl,12.&ordigits))||')',
                                                            ifc(cat_ref=1,'Reference',''))
                         else ifc(^missing(f.model),
                                strip(put(exp(cont_step*log(g.oddsratioest)),12.&ordigits))||' ('||
                                strip(put(exp(cont_step*log(g.lowercl)),12.&ordigits))||'-'||
                                strip(put(exp(cont_step*log(g.uppercl)),12.&ordigits))||')',
                                '') end as or_est_range
                        ,case (a.cov_type)
                                when 2 then ifc(^missing(f.model),strip(put(g.lowercl,12.&ordigits))||'-'||
                                                            strip(put(g.uppercl,12.&ordigits)),
                                                            ifc(cat_ref=1,'Reference',''))
                         else ifc(^missing(f.model),
                                strip(put(exp(cont_step*log(g.lowercl)),12.&ordigits))||'-'||
                                strip(put(exp(cont_step*log(g.uppercl)),12.&ordigits)),
                                '') end as or_range  
                        ,ifc(a.pval_covariates=1 and ^missing(f.model),strip(put(f.probchisq,pvalue6.&pvaldigits)),'') as cov_pval
                        ,ifc(a.pval_covariates=1 and ^missing(f.model),ifc(a.nstrata>0,'S','')||'COVWALD','') as cov_pval_type
                    %end;                    
                    %if (%sysfunc(find(&plot_display &table_display,pval,i))>0 and 
                        (%sysfunc(find(&pval_type3,1,i))>0 or %sysfunc(find(&pval_type3,2,i))>0 or %sysfunc(find(&pval_type3,3,i))>0)) %then %do;                        
                        ,ifc(^missing(h.model),
                              case (a.pval_type3)
                                 when 1 then strip(put(h.probchisq,pvalue6.&pvaldigits))
                                 %if %qupcase(&method)=SURVIVAL and %sysevalf(%qupcase(&surv_method)^=CIF,boolean) %then %do;
                                     when 2 then strip(put(h.probscorechisq,pvalue6.&pvaldigits))
                                     when 3 then strip(put(h.problrchisq,pvalue6.&pvaldigits))
                                 %end;
                              else '' end,'') as t3_pval
                        ,ifc(^missing(h.model),
                              case (a.pval_type3)
                                 when 1 then ifc(a.nstrata>0,'S','')||'T3WALD'
                                 when 2 then ifc(a.nstrata>0,'S','')||'T3SCORE'
                                 when 3 then ifc(a.nstrata>0,'S','')||'T3LR'
                              else '' end,'') as t3_pval_type
                    %end;
                    %if %sysfunc(find(&plot_display &table_display,AIC,i))>0 or %sysfunc(find(&plot_display &table_display,bic,i))>0 or
                        %sysfunc(find(&plot_display &table_display,LOGLIKELIHOOD,i))>0 %then %do;
                        ,strip(put(j.interceptandcovariates,12.&AICdigits)) as AIC
                        ,strip(put(k.interceptandcovariates,12.&bicdigits)) as bic
                        ,strip(put(l.interceptandcovariates,12.&lldigits)) as LOGLIKELIHOOD
                    %end;
                    %if %sysfunc(find(&plot_display &table_display,c_,i))>0 and ^(%qupcase(&method)=LOGISTIC and &min_strata>0) %then %do;                    
                        ,m.c as c_est
                        ,m.c-1.96*m.se as c_lcl
                        ,m.c+1.96*m.se as c_ucl   
                        ,ifc(^missing(m.model),
                                strip(put(m.c,12.&cdigits)),
                                '') as c_estimate
                        ,ifc(^missing(m.model),
                                strip(put(m.c,12.&cdigits))||' ('||
                                strip(put(m.c-1.96*m.se,12.&cdigits))||'-'||
                                strip(put(m.c+1.96*m.se,12.&cdigits))||')',
                                '') as c_est_range
                        ,ifc(^missing(m.model),
                                strip(put(m.c-1.96*m.se,12.&cdigits))||'-'||
                                strip(put(m.c+1.96*m.se,12.&cdigits)),
                                '') as c_range 
                    %end;
                %end;
                %if %sysfunc(find(&plot_display &table_display,pval,i))>0 and 
                    %sysevalf(%superq(by)^=,boolean) and (%sysfunc(find(&pval_by,1,i))>0 or %sysfunc(find(&pval_by,2,i))>0) %then %do;
                    ,ifc(^missing(i._by_num),
                           case(a.pval_by)
                             when 1 then strip(put(i.p_pchi,pvalue6.&pvaldigits)) 
                             %if %sysfunc(find(&pval_by,2,i))>0 %then %do;
                                when 2 then strip(put(i.xp2_fish,pvalue6.&pvaldigits))
                             %end;
                           else '' end,'') as by_pval
                    ,ifc(^missing(i._by_num ),
                           case(a.pval_by)
                             when 1 then 'CHISQ'
                             when 2 then 'FISHER'
                           else '' end,'') as by_pval_type
                %end;
                from _tempdsn_0 as a 
                %if %sysfunc(find(&plot_display &table_display,total,i))>0 or %sysfunc(find(&plot_display &table_display,events,i))>0 or 
                    %sysfunc(find(&plot_display &table_display,ev_t,i))>0 or %sysfunc(find(&plot_display &table_display,pct,i))>0 %then %do;
                    left join _bin_ as b
                    on a.model=b.model and 
                        upcase(ifc(modelsum_Row=1,'_all_',case (a.cov_type)
                            when 2 then ifc(a.varlevel>0,covariate,'')
                        else '' end)) = upcase(b._varname_) and             
                        ifc(modelsum_Row=1,'all',case (a.cov_type)
                            when 2 then strip(cat_val)
                        else '' end) = b._varval_
                    left join _bin_ as c
                    on a.model=c.model and 
                        upcase(case (a.cov_type)
                            when 2 then ifc(a.varlevel>0,covariate,'')
                        else '' end) = upcase(c._varname_) and             
                        case (a.cov_type)
                            when 2 then cat_refv
                        else '' end = c._varval_
                %end;
                %if %sysfunc(find(&plot_display &table_display,bin_,i))>0 %then %do; 
                    left join _bin_ as d
                    on a.model=d.model and 
                        upcase(ifc(modelsum_Row=1,'_all_',case (a.cov_type)
                           when 2 then ifc(a.varlevel>0,covariate,'')
                        else '' end)) = upcase(d._varname_) and             
                        ifc(modelsum_Row=1,'all',case (a.cov_type)
                           when 2 then strip(cat_val)
                        else '' end) = d._varval_
                        left join  _bin_ as e
                        on a.model=e.model and 
                            upcase(case (a.cov_type)
                                when 2 then ifc(a.varlevel>0,covariate,'')
                            else '' end) = upcase(e._varname_) and             
                            case (a.cov_type)
                                when 2 then cat_refv
                            else ''  end = e._varval_             
                %end;
                %if (&max_cat_covs>0 or &max_cont_covs>0) %then %do;
                    %if %sysfunc(find(&plot_display &table_display,or_,i))>0 or 
                        (%sysfunc(find(&plot_display &table_display,pval,i))>0 and %sysfunc(find(&pval_covariates,1,i))>0) %then %do;
                        left join _parm as f
                        on a.model=f.model and 
                            upcase(case (a.cov_type)
                                when 2 then ifc(a.varlevel>0,'_cat_val_'||scan(covariate,3,'_','m'),'')
                                when 1 then ifc(a.cont_step>.,covariate,'')
                            else '' end) = upcase(f.variable)             
                            %if %sysfunc(find(&type,2)) %then %do;
                                and case (a.cov_type)
                                    when 2 then strip(put(varlevel,12.0))
                                else '' end = f.classval0
                            %end;
                        left join _odds as g
                            on a.model=g.model and 
                            upcase(case (a.cov_type)
                                when 2 then ifc(a.varlevel>0,'_cat_val_'||scan(covariate,3,'_','m'),'')
                                when 1 then ifc(a.cont_step>.,covariate,'')
                            else '' end) = upcase(scan(g.effect,1,' '))             
                            %if %sysfunc(find(&type,2)) %then %do;
                                and case (a.cov_type)
                                    when 2 then strip(put(varlevel,12.0))
                                else '' end = scan(g.effect,2,' ')
                            %end;                        
                    %end;
                    %if (%sysfunc(find(&plot_display &table_display,pval,i))>0 and 
                        (%sysfunc(find(&pval_type3,1,i))>0 or %sysfunc(find(&pval_type3,2,i))>0 or %sysfunc(find(&pval_type3,3,i))>0)) %then %do;
                        left join _t3 as h
                        on a.model=h.model and 
                        upcase(case (a.cov_type)
                            when 2 then ifc(a.varlevel=0,'_cat_val_'||scan(covariate,3,'_','m'),'')
                            when 1 then ifc(a.varlevel=0,covariate,'')
                        else '' end) = upcase(h.effect)                        
                    %end;
                    %if %sysfunc(find(&plot_display &table_display,AIC,i))>0 or %sysfunc(find(&plot_display &table_display,bic,i))>0 or
                        %sysfunc(find(&plot_display &table_display,LOGLIKELIHOOD,i))>0 %then %do;
                        left join (select * from _fit where criterion='AIC') as j
                        on ifn(modelsum_Row=1,a.model,.)=j.model
                        left join (select * from _fit where criterion='SC') as k
                        on ifn(modelsum_Row=1,a.model,.)=k.model
                        left join (select * from _fit where upcase(criterion)='-2 LOG L') as l
                        on ifn(modelsum_Row=1,a.model,.)=l.model                        
                    %end;
                    %if %sysfunc(find(&plot_display &table_display,c_,i))>0 and ^(%qupcase(&method)=LOGISTIC and &min_strata>0) %then %do;
                        left join (select * from _cindex where ^missing(c)) as m
                        on ifn(modelsum_Row=1,a.model,.)=m.model                    
                    %end;
                %end;
                %if %sysfunc(find(&plot_display &table_display,pval,i))>0 and 
                    %sysevalf(%superq(by)^=,boolean) and (%sysfunc(find(&pval_by,1,i))>0 or %sysfunc(find(&pval_by,2,i))>0) %then %do;
                    left join _kmp as i
                    on a.modelnum=i.modelnum and a.rowby_lvl=i._rowby_lvl and a.colby_lvl=i._colby_lvl and a.groupby_lvl=i._groupby_lvl and
                        ifn(a.by_lvl=0,a.by_num,.)=i._by_num                     
                %end;;
        %end;
    quit;

    %errhandl2:
    
    proc datasets nolist nodetails;
        %if &debug=0 %then %do;
            delete %do i = 0 %to &step; _tempdsn_&i %end;
                _subset _cindex _gpval _km _kmp _models _models2 _models3 _legit_models
                _parm _quart _sum _tempdsn 
                %do i = 1 %to &nmodels; _tempdsn&i %end;
                _tempdsn_p2 _tempdsn_p3 _t3 _fit
                _bin_calc_ _bin_ _bin_calc_2 _odds;
        %end;
    quit;
    /**If errors occurred then throw message and end macro**/
    %if &nerror_run > 0 %then %do;
        %put ERROR: &nerror_run run-time errors listed;
        %put ERROR: Macro MVMODELS will cease;           
        %goto errhandl;
    %end;
        
        
    %local npfoot;
    %let npfoot=0;
    data _tempdsn_final;
        set _tempdsn_final end=last;
        %if %sysfunc(find(&table_display &plot_display,pval,i))>0 %then %do;
            length pfoot _pval pval_listing $30.;
            array pfoots {40} $30.;
            array pfs {22} $30. ("GSCORE","GLR","GWALD","T3SCORE","T3LR","T3WALD","COVWALD","LOGRANK","WILCOXON","SGSCORE","SGLR","SGWALD","ST3SCORE","ST3LR",
                "ST3WALD","SCOVWALD","SLOGRANK","SWILCOXON","CHISQ","FISHER","GRAY","SGRAY");
            array pmsgs {22} $100. ("Global score p-value","Global likelihood-ratio p-value","Global Wald p-value","
                Type 3 score p-value","Type 3 likelihood-ratio p-value","Type 3 Wald p-value","
                Covariate Wald p-value","Logrank p-value","Wilcoxon p-value","Stratified global score p-value","Stratified global likelihood-ratio p-value","Stratified global Wald p-value",
                "Stratified type 3 score p-value","Stratified type 3 likelihood-ratio p-value","Stratified type 3 Wald p-value",
                "Stratified covariate Wald p-value","Stratified logrank p-value","Stratified Wilcoxon p-value","Chi-square p-value","Fisher exact p-value",
                "Gray's Test for Equality","Stratified Gray's Test for Equality");
                
            if ^missing(by_pval) then do;
                pval=vvalue(by_pval);pfoot=by_pval_type;
            end;
            else if ^missing(cov_pval) and ^missing(t3_pval) then do;
                if upcase("&pval_priority")="COVARIATE" then do;
                    pval=vvalue(cov_pval);pfoot=cov_pval_type;
                end;
                else do;
                    pval=vvalue(t3_pval);pfoot=t3_pval_type;
                end;
            end;
            else if ^missing(cov_pval) then do;                
                pval=vvalue(cov_pval);pfoot=cov_pval_type;
            end;
            else if ^missing(t3_pval) then do;
                pval=vvalue(t3_pval);pfoot=t3_pval_type;
            end;
            
            if ^missing(pval) then do i = 1 to dim(pfoots);
                if missing(pfoots(i)) then do;
                    pfoots(i)=strip(pfoot);
                    pfoot_index=i;
                    i=dim(pfoots);
                    _pval=strip(pval) %if &pfoot=1 %then %do; ||'^{super '||strip(put(pfoot_index,12.0))||'}' %end;;
                    pval_listing=strip(pval) %if &pfoot=1 %then %do; ||repeat('*',pfoot_index-1) %end;;
                end;
                else if pfoots(i)=strip(pfoot) then do;
                    pfoot_index=i;
                    i=dim(pfoots);
                    _pval=strip(pval) %if &pfoot=1 %then %do; ||'^{super '||strip(put(pfoot_index,12.0))||'}' %end;;
                    pval_listing=strip(pval) %if &pfoot=1 %then %do; ||repeat('*',pfoot_index-1) %end;;
                end;
            end;
            
            if last then do;
                do i = 1 to dim(pfoots)-cmiss(of pfoots(*));
                    do j = 1 to dim(pfs);
                        if pfoots(i)=pfs(j) then do;
                             %if &pfoot=1 %then %do; call symputx("pfoot"||strip(put(i,12.0)),strip(pmsgs(j)),'l'); %end;
                        end;
                    end;  
                end;
                call symputx('npfoot',strip(put(dim(pfoots)-cmiss(of pfoots(*)),12.0)),'l');
            end;
            retain pfoots;
            drop i j pfoots: pfs: pmsgs: pfoot pval;
            rename _pval=pval;
        %end;
        %else %do;
            if last then call symputx('npfoot','0','l');
        %end;
    run;
    
    %if &npfoot=1 and &pfoot=1 %then %do;
        /*Place footnote tag in label instead of data*/
        data _tempdsn_final;
            set _tempdsn_final;
            if ^missing(pval) then pval=scan(pval,1,'^');
            pval_listing=compress(pval_listing,'*');
        run;
    %end;
    proc sort data=_tempdsn_final;
        by rowby_lvl modelnum by_num by_lvl varnum varlevel groupby_lvl;
    run;
    proc sql noprint;
        %local _colby _rowby;
        select max(^missing(colby)),max(^missing(rowby)) into :_colby separated by ' ',:_rowby separated by ' '
            from _tempdsn_final;
    quit;
    %if &show_table %then %do;
        data _table;
            merge %do k=1 %to &_columns;
                _tempdsn_final (keep=modelnum--by_lvl  subtitle subind boldind varnum varlevel
                             %do j=1 %to %sysfunc(countw(%superq(table_display),%str( )));
                                 %scan(%superq(table_display),&j,%str( ))
                                 %if %sysevalf(%qupcase(%scan(%superq(table_display),&j,%str( )))=PVAL,boolean) %then %do;
                                    %scan(%superq(table_display),&j,%str( ))_listing
                                 %end;
                             %end;
                         rename=(colby=colby_&k colby_lvl=colbylvl_&k
                             %do j=1 %to %sysfunc(countw(%superq(table_display),%str( )));
                                 %scan(%superq(table_display),&j,%str( ))=%scan(%superq(table_display),&j,%str( ))_&k
                                 %if %sysevalf(%qupcase(%scan(%superq(table_display),&j,%str( )))=PVAL,boolean) %then %do;
                                    %scan(%superq(table_display),&j,%str( ))_listing=%scan(%superq(table_display),&j,%str( ))_listing_&k
                                 %end;
                             %end;)
                         where=(colbylvl_&k=&k))
                 %end;;  
             by rowby_lvl modelnum by_num by_lvl varnum varlevel;               
             %if %sysevalf(%superq(_rowby)=1,boolean) %then %do;
                 rowbylabel="&rowbylabel";
                 %if %sysevalf(%qupcase(%superq(rowbytable_display))=SUBHEADER) %then %do; 
                    subind=subind+1;
                 %end;
             %end;
             %else %do;
                rowbylabel="";
             %end;
             if groupby_lvl=0 and ^missing(groupby) then call missing(groupby);
            null='';
        run;   
        
        %if %sysevalf(%superq(_colby)=1,boolean) %then %do;
            proc sort data=_table out=_colbycorrect;
                where cmiss(%do i = 1 %to &_columns; 
                    %if &i>1 %then %do; , %end; 
                        colby_&i 
                    %end;)>0; 
                by rowby_lvl modelnum varnum varlevel by_num by_lvl groupby_lvl;
            run;
            data _colbycorrect2;
                set _colbycorrect;
                by rowby_lvl modelnum  varnum varlevel by_num by_lvl groupby_lvl;
                if first.varlevel then output;
            run;
            data _table;
                set _table (where=(cmiss(%do i = 1 %to &_columns; 
                    %if &i>1 %then %do; , %end; 
                        colby_&i 
                    %end;)=0))
                    _colbycorrect2;
            run;
            proc sort data=_table;
                by rowby_lvl modelnum by_num by_lvl varnum varlevel groupby_lvl;
            run;
            proc datasets nolist nodetails;
                %if &debug=0 %then %do;
                    delete _colbycorrect _colbycorrect2;
                %end;
            quit;
        %end;
        
        data _table;
            set _table end=last;
            by rowby_lvl modelnum by_num by_lvl varnum varlevel;

            %if &shading=1 %then %do;
                shadeind=mod(_n_,2);
            %end;
            %else %if &shading=2 %then %do;
                if first.by_num and by_lvl=0 then _shade=0;
                else if first.by_num and by_lvl>0 then _shade=1;
                else if first.by_lvl then _shade+1;
                if varnum in(0 0.25) then shadeind=0;
                else shadeind=mod(_shade,2);
                drop _shade;
                retain _shade;
            %end;
            %else %if &shading=3 %then %do;
                if first.by_num then _shade+1;
                if varnum in(0) then shadeind=0;
                else shadeind=mod(_shade-1,2);
                drop _shade;
                retain _shade;
            %end;
            %else %if &shading=4 %then %do;
                if varnum in(0 0.25) then shadeind=0;
                else shadeind=1;
            %end;
            %else %do;
                shadeind=.;
            %end;
            null2='';
        run;
    %end;    
    ods select all;
    ods results; 
    %if &show_table=1 or &show_plot=1 %then %do;
        /**Creates document to save**/
        %if %sysevalf(%superq(outdoc)=,boolean)=0 %then %do;
            ods escapechar='^';
            /**Sets up DPI and ODS generated file**/
            ods &destination
            %if %qupcase(&destination)=HTML %then %do; 
                %if %upcase(&sysscpl)=LINUX or %upcase(&sysscpl)=UNIX %then %do;
                    path="%substr(&outdoc,1,%sysfunc(find(&outdoc,/,-%sysfunc(length(&outdoc)))))"
                    file="%scan(&outdoc,1,/,b)"
                %end;
                %else %do;
                    path="%substr(&outdoc,1,%sysfunc(find(&outdoc,\,-%sysfunc(length(&outdoc)))))"
                    file="%scan(&outdoc,1,\,b)"
                %end;
            %end;
            %else %if %qupcase(&destination)=PDF %then %do; 
                bookmarkgen=off notoc file="&outdoc"
            %end;
            %else %do; 
                file="&outdoc"  
            %end;;
        %end;
    %end;          
    /*Set up Plot*/
    %if &show_plot=1 %then %do;
        data _plot;
            merge %do k=1 %to &_columns;
                _tempdsn_final (in=in&k keep=modelnum--by_lvl subtitle subind boldind varnum varlevel groupby_lvl
                             %let _nplot_=0;
                             %do j=1 %to %sysfunc(countw(%superq(plot_display),%str( )));
                                 %if %sysfunc(find(%scan(%superq(plot_display),&j,%str( )),plot,i))>0 %then %do;
                                    %let _nplot_=%sysevalf(&_nplot_ + 1);
                                    %if %sysfunc(find(%scan(%superq(plot_display),&j,%str( )),KM_PLOT,i))=0 %then %do;
                                        %scan(%scan(%superq(plot_display),&j,%str( )),1,_)_est
                                        %scan(%scan(%superq(plot_display),&j,%str( )),1,_)_lcl
                                        %scan(%scan(%superq(plot_display),&j,%str( )),1,_)_ucl
                                    %end;
                                    %else %do;
                                        %let i=%sysfunc(compress(%scan(%superq(plot_display),&j,%str( )),KM_PLOT,i));
                                        %scan(%scan(%superq(plot_display),&j,%str( )),1,_)_est&i
                                        %scan(%scan(%superq(plot_display),&j,%str( )),1,_)_lcl&i
                                        %scan(%scan(%superq(plot_display),&j,%str( )),1,_)_ucl&i
                                    %end;                                        
                                 %end;
                                 %else %if %sysevalf(%qupcase(%scan(%superq(plot_display),&j,%str( )))=PVAL,boolean) %then %do;
                                    %scan(%superq(plot_display),&j,%str( )) pfoot_index
                                 %end;
                                 %else %if %sysevalf(%qupcase(%scan(%superq(plot_display),&j,%str( )))^=SUBTITLE,boolean) %then %do;
                                    %scan(%superq(plot_display),&j,%str( ))
                                 %end;
                             %end;
                         rename=(colby=colby_&k colby_lvl=colbylvl_&k
                             %let _nplot_=0;
                             %do j=1 %to %sysfunc(countw(%superq(plot_display),%str( )));
                                 %if %sysfunc(find(%scan(%superq(plot_display),&j,%str( )),plot,i))>0 %then %do;
                                    %let _nplot_=%sysevalf(&_nplot_ + 1);
                                    %if %sysfunc(find(%scan(%superq(plot_display),&j,%str( )),KM_PLOT,i))=0 %then %do;
                                        %scan(%scan(%superq(plot_display),&j,%str( )),1,_)_est=estimate&_nplot_._&k 
                                        %scan(%scan(%superq(plot_display),&j,%str( )),1,_)_lcl=lcl&_nplot_._&k 
                                        %scan(%scan(%superq(plot_display),&j,%str( )),1,_)_ucl=ucl&_nplot_._&k
                                    %end;
                                    %else %do;
                                        %let i=%sysfunc(compress(%scan(%superq(plot_display),&j,%str( )),KM_PLOT,i));
                                        %scan(%scan(%superq(plot_display),&j,%str( )),1,_)_est&i=estimate&_nplot_._&k 
                                        %scan(%scan(%superq(plot_display),&j,%str( )),1,_)_lcl&i=lcl&_nplot_._&k 
                                        %scan(%scan(%superq(plot_display),&j,%str( )),1,_)_ucl&i=ucl&_nplot_._&k
                                    %end;
                                 %end;
                                 %else %if %sysevalf(%qupcase(%scan(%superq(plot_display),&j,%str( )))=PVAL,boolean) %then %do;
                                    %scan(%superq(plot_display),&j,%str( ))=%scan(%superq(plot_display),&j,%str( ))_&k 
                                    pfoot_index=pfoot_index_&k
                                 %end;
                                 %else %if %sysevalf(%qupcase(%scan(%superq(plot_display),&j,%str( )))^=SUBTITLE,boolean) %then %do;
                                    %scan(%superq(plot_display),&j,%str( ))=%scan(%superq(plot_display),&j,%str( ))_&k
                                 %end;
                             %end;)
                         where=(colbylvl_&k=&k))
                 %end;;  
             by rowby_lvl modelnum by_num by_lvl varnum varlevel groupby_lvl;
             %if %sysfunc(find(%superq(plot_display),PVAL,i))>0 and &pfoot=1 %then %do i=1 %to &_columns;
                pval_&i=scan(pval_&i,1,'^');
             %end;
        run;  
   
        %if %sysevalf(%superq(_colby)=1,boolean) %then %do;
            proc sort data=_plot out=_colbycorrect;
                where cmiss(%do i = 1 %to &_columns; 
                    %if &i>1 %then %do; , %end; 
                        colby_&i 
                    %end;)>0; 
                by rowby_lvl modelnum varnum varlevel by_num by_lvl groupby_lvl;
            run;
    
            data _colbycorrect2;
                set _colbycorrect;
                by rowby_lvl modelnum varnum varlevel by_num by_lvl groupby_lvl;
                if first.groupbylvl then output;
            run;
            data _plot;
                set _plot (where=(cmiss(%do i = 1 %to &_columns; 
                    %if &i>1 %then %do; , %end; 
                        colby_&i 
                    %end;)=0))
                    _colbycorrect2;
                 %do k=1 %to &_columns;
                    colbylvl_&k=&k;
                %end;
            run;
            proc sort data=_plot;
                by rowby_lvl modelnum by_num by_lvl varnum varlevel groupby_lvl;
            run; 
            proc datasets nolist nodetails;
                %if &Debug=0 %then %do;
                    delete _colbycorrect _colbycorrect2;
                %end;
            quit;
        %end;
        %local nlvls;
        proc sql noprint;
            select count(distinct groupby_lvl)-1 into :nlvls separated by '' from _tempdsn_final;
        quit;
        data _plot;
            set _plot end=last;
            by rowby_lvl modelnum by_num by_lvl varnum varlevel;
            nlvls=&nlvls;
            if first.rowby_lvl=1 then do;
                _y=0;
                _groupby_lvl=0;
            end;

            if groupby_lvl>0 and ^missing(groupby) then _groupby_lvl+1;
            else _groupby_lvl=0;
            if first.varlevel then _y+1;
            if (groupby_lvl=0 and ^missing(groupby)) or missing(groupby) then y=_y-0.5;
            else y=_y-1+(_groupby_lvl/(1+nlvls));
            %if &shading=1 %then %do;
                shadeind=mod(_y+1,2);
            %end;
            %else %if &shading=2 %then %do;
                if first.by_num and by_lvl=0 then _shade=0;
                else if first.by_num and by_lvl>0 then _shade=1;
                else if first.by_lvl then _shade+1;
                if varnum in(0 0.25) then shadeind=0;
                else shadeind=mod(_shade,2);
                drop _shade;
                retain _shade;
            %end;
            %else %if &shading=3 %then %do;
                if first.by_num then _shade+1;
                if varnum in(0) then shadeind=0;
                else shadeind=mod(_shade-1,2);
                drop _shade;
                retain _shade;
            %end;
            %else %if &shading=4 %then %do;
                if varnum in(0 0.25) then shadeind=0;
                else shadeind=1;
            %end;
            %else %do;
                shadeind=.;
            %end;
            drop _y;
        run;
            
        %local _max_vlevels _max_by_nums;
        proc sql noprint;
            select max(by_num) into :_max_by_nums separated by ' ' from _plot;
        quit;

        proc sql noprint; 
            %do j = 1 %to %superq(_nplot);       
                %local min_val&j max_val&j;
            %end;
            %if &_nplot>0 %then %do;        
                select  %do j = 1 %to %superq(_nplot); %if &j>1 %then %do; , %end; min(lcl&j),max(ucl&j) %end;
                   into %do j = 1 %to %superq(_nplot); %if &j>1 %then %do; , %end; :min_val&j, :max_val&j %end;
                        from (select %do j = 1 %to %superq(_nplot);  
                                         %if &j>1 %then %do; , %end;
                                         %if &_columns>1 %then %do; 
                                             min(%do c = 1 %to &_columns; 
                                                    %if &c>1 %then %do; , %end;
                                                    lcl&j._&c
                                                 %end;) as lcl&j
                                         %end;
                                         %else %do;
                                            lcl&j._1 as lcl&j
                                        %end;
                                     %end;,
                                     %do j = 1 %to %superq(_nplot);  
                                         %if &j>1 %then %do; , %end;
                                         %if &_columns>1 %then %do; 
                                             min(%do c = 1 %to &_columns; 
                                                    %if &c>1 %then %do; , %end;
                                                    ucl&j._&c
                                                 %end;) as ucl&j
                                         %end;
                                         %else %do;
                                            ucl&j._1 as ucl&j
                                        %end;
                                     %end;
                                     from _plot);
            %end;
        quit;
           
        
        %do j = 1 %to %superq(_nplot);       
            %if %sysevalf(%superq(min_val&j)^=,boolean) and 
                %sysevalf(%superq(min&j)=,boolean) %then 
                    %let min&j=%sysfunc(floor(%superq(min_val&j)));
            %else %if %sysevalf(%superq(min&j)=,boolean) %then %let min&j=0;
            
            %if %sysevalf(%superq(max_val&j)^=,boolean) and 
                %sysevalf(%superq(max&j)=,boolean) %then 
                    %let max&j=%sysfunc(ceil(%superq(max_val&j)));
            %else %if %sysevalf(%superq(max&j)=,boolean) %then %let max&j=4;
            
            %if %sysevalf(%superq(increment&j)=,boolean) %then 
                %let increment&j=%sysevalf((%superq(max&j)-%superq(min&j))/5);
            
            %if %qupcase(%superq(xaxistype&j))=LOG %then %do;
                %if (%superq(min&j)=0 or %sysevalf(%superq(min&j)=,boolean)) and %sysevalf(%superq(min_val&j)^=,boolean) %then %let min&j=&&min_val&j;
                %else %if (%superq(min&j)=0 or %sysevalf(%superq(min&j)=,boolean)) %then %let min&j=0.01;
                %if (%superq(max&j)=0 or %sysevalf(%superq(max&j)=,boolean)) and %sysevalf(%superq(max_val&j)^=,boolean) %then %let max&j=&&max_&j;
                %else %if (%superq(max&j)=0 or %sysevalf(%superq(max&j)=,boolean)) %then %let max&j=0.01;
                
                %if %qupcase(%superq(logbase&j))=E %then %do;
                    %let min&j=%sysfunc(sum(%sysfunc(constant(e))**%sysfunc(floor(%sysfunc(log(%superq(min&j)))/
                               %sysfunc(log(%sysfunc(constant(e))))))));
                    %let max&j=%sysfunc(sum(%sysfunc(constant(e))**%sysfunc(ceil(%sysfunc(log(%superq(max&j)))/
                               %sysfunc(log(%sysfunc(constant(e))))))));
                %end;
                %else %do;
                    %let min&j=%sysfunc(sum(%superq(logbase&j)**%sysfunc(floor(%sysfunc(log(%superq(min&j)))/
                               %sysfunc(log(%superq(logbase&j)))))));
                    %let max&j=%sysfunc(sum(%superq(logbase&j)**%sysfunc(ceil(%sysfunc(log(%superq(max&j)))/
                               %sysfunc(log(%superq(logbase&j)))))));
                %end;
            %end;
        %end;
             
        data _ticks;
            e=constant('e');
            %do j = 1 %to %superq(_nplot);  
                plot=&j;
                %if %qupcase(%superq(xaxistype&j))=LINEAR %then %do;
                    %if %sysevalf(%superq(tickvalues&j)^=,boolean) %then %do;                                    
                        do tick&j=%do k = 1 %to %sysfunc(countw(&&tickvalues&j,%str( )));
                                      %if &k>1 %then %do; , %end;
                                      %scan(&&tickvalues&j,&k,%str( ))
                                  %end;;output;end;
                    %end;
                    %else %do;
                        do tick&j=&&min&j to &&max&j by &&increment&j;output;end; 
                    %end;
                    tick&j=.;mtick&j=.;
                %end;
                %else %if %qupcase(%superq(xaxistype&j))=LOG %then %do;
                    %if %sysevalf(%superq(tickvalues&j)^=,boolean) %then %do;
                        do tick&j=%do k = 1 %to %sysfunc(countw(&&tickvalues&j,%str( )));
                                      %if &k>1 %then %do; , %end;
                                      %scan(&&tickvalues&j,&k,%str( ))
                                  %end;;output;end;
                    %end;
                    %else %do;
                        do x=log(&&min&j)/log(&&logbase&j) to log(&&max&j)/log(&&logbase&j) by 1;
                            mtick&j=.;tick&j=&&logbase&j**x;output;
                            %if %qupcase(&&logminor&j)=TRUE and &&logbase&j=10 and (%qupcase(&&logtickstyle&j)=LOGEXPAND or %qupcase(&&logtickstyle&j)=LOGEXPONENT) %then %do;
                                if x<log(&&max&j)/log(&&logbase&j) then do mtick&j=2*10**x to 9*10**x by 10**x;call missing(tick&j);output;end;                            
                            %end;
                        end;
                    %end;
                    mtick&j=.;tick&j=.;
                %end;
            %end;
        run;
        proc sql noprint;
            %do j = 1 %to %superq(_nplot);  
                %local _ticklist&j _mticklist&j;
                select tick&j into :_ticklist&j separated by ' ' from _ticks where ^missing(tick&j);
                %if %qupcase(&&logminor&j)=TRUE and &&logbase&j=10 and (%qupcase(&&logtickstyle&j)=LOGEXPAND or %qupcase(&&logtickstyle&j)=LOGEXPONENT) %then %do;
                    select mtick&j into :_mticklist&j separated by ' ' from _ticks where ^missing(mtick&j);
                %end;
            %end;
        quit;
        data _plot;
            set _plot end=last;
            
            %if %superq(_nplot)>0 %then %do j = 1 %to %superq(_nplot);
                array lcl&j._ {&_columns} ;
                array ucl&j._ {&_columns} ;  
                array estimate&j._ {&_columns} ;  
                array lcl&j._cap {&_columns} $8.;
                array ucl&j._cap {&_columns} $8.;  
                /**Check mins and maxes**/
                drop i;
                do i = 1 to dim(lcl&j._);
                    if ^missing(lcl&j._(i)) then do;
                        if lcl&j._(i) lt %superq(min&j) then do;
                            lcl&j._(i) = %superq(min&j);
                            lcl&j._cap(i)='None';
                        end;
                        else if lcl&j._(i) ge %superq(max&j) then 
                            lcl&j._(i)=.;
                        else lcl&j._cap(i)='Serif';
                    end;
                    if ^missing(ucl&j._(i)) then do;
                        if ucl&j._(i) gt %superq(max&j) then do;
                            ucl&j._(i) = %superq(max&j);
                            ucl&j._cap(i)='None';
                        end;
                        else if ucl&j._(i) le %superq(min&j) then 
                            ucl&j._(i)=.;
                        else ucl&j._cap(i)='Serif';
                    end;
                    
                    if ^(%superq(min&j) le estimate&j._(i) le %superq(max&j)) then estimate&j._(i)=.;
                end;
            %end;           
            
            if last then do;
                call symput("_maxy",strip(put(y,12.)));
            end;
        run;
        
        proc sql noprint;
            %local r;
            %local _maxdv_ _maxdv2_;
            %do r = 1 %to &_rows;
                %local _maxrows_&r ;
                select max(ceil(y)) into :_maxrows_&r separated by ' '
                    from _plot where rowby_lvl=&r;  
            %end;
            select count(*) into :_maxdv_ separated by ' ' 
                from _plot ;   
            select max(n) into :_maxdv2_ separated by ' ' 
                from (select colby_lvl,count(*) as n from _tempdsn_final group by colby_lvl);
        quit;      
        
        /**Make columns into macro variables**/
        proc sql noprint;
            %local _plotnames _colby _rowby;
            select distinct name into :_plotnames separated by ','
                from sashelp.vcolumn where upcase(libname)='WORK' and upcase(memname)='_PLOT';
            %do j=1 %to %sysfunc(countw(%superq(_plotnames),%str(,)));
                %local %scan(%superq(_plotnames),&j,%quote(,));
            %end;
            select &&_plotnames into :%scan(%superq(_plotnames),1,%str(,)) separated by '|'
                %do j=2 %to %sysfunc(countw(%superq(_plotnames),%str(,)));
                    , :%scan(%superq(_plotnames),&j,%str(,)) separated by '|'
                %end;
                from _plot;    
        quit;
        /***Set up Plot Column Weights***/
        %do j = 1 %to %superq(_nplot_display); %local _cweight&j; %end;
        %if %sysevalf(%superq(plot_columnweights)^=,boolean) %then %do j = 1 %to %superq(_nplot_display);            
            %let _cweight&j. = %scan(%superq(plot_columnweights),&j,%str( ));
            %if &j=&_nsubtitle %then %let _wsubtitle=%superq(_cweight&j.);
        %end;
        %else %do;
            proc sql noprint;
                select %do j = 1 %to %superq(_nplot_display); 
                           %if &j>1 %then %do; , %end;
                           ifn(upcase("%superq(_plot_display&j)")="SUBTITLE",max(20),max(length&j)) as length&j
                       %end;
                       into %do j = 1 %to %superq(_nplot_display); 
                                %if &j>1 %then %do; , %end;
                                :length&j separated by ''
                            %end;
                    from 
                        (select %do j = 1 %to %superq(_nplot_display);
                                    %if &j>1 %then %do; , %end;
                                    %if %sysfunc(find(%superq(_plot_display&j),plot,i))=0 %then %do;
                                        max(%do i=1 %to %sysfunc(countw(%superq(_plot_displayheader&j),`,m));
                                                lengthn(strip("%qscan(%superq(_plot_displayheader&j),&i,`,m)")),
                                            %end;
                                            %if %sysevalf(%qupcase(%superq(_plot_display&j))=PVAL,boolean) %then %do;
                                                lengthn(scan(%superq(_plot_display&j),1,'^','m'))) as length&j
                                            %end;
                                            %else %do;
                                                lengthn(strip(%superq(_plot_display&j)))) as length&j
                                            %end;
                                    %end;
                                    %else %do; 30 as length&j %end;
                                %end; from _tempdsn_final);
            quit;
            %local nbsp;
            data _null_;
                array lengths {&_nplot_display} (%do j = 1 %to &_nplot_display; 
                                                    %if &j>1 %then %do; , %end;
                                                    &&length&j
                                                %end;);
                array weights {&_nplot_display};
                tot_length=sum(of lengths(*));
                do i = 1 to dim(lengths);
                    weights(i)=lengths(i)/(tot_length);
                    call symputx('_cweight'||strip(put(i,12.0)),weights(i));
                end;
                call symput('nbsp','A0'x);
            run;
        %end;
        ods path WORK.TEMPLAT(UPDATE) SASHELP.TMPLMST (READ); 
        *options nonotes;
        proc template;
            /**Design independent axes**/
            define statgraph _forest;
            begingraph / designheight=&height designwidth=&width    
                backgroundcolor=&bgcolor   
                %if %superq(transparent)=1 %then %do;
                    opaque=false 
                %end;
                /**Turns the border around the plot off if border=0**/
                %if %qupcase(%superq(border))=FALSE %then %do;
                    border=false 
                    %if %superq(transparent)=1 %then %do;
                        pad=0px    
                    %end;
                %end;
                %else %do;
                     border=&border borderattrs=(color=&bordercolor)
                %end;;
                %do i = 1 %to %sysfunc(countw(%superq(title),`,m));
                    entrytitle halign=&titlealign "%scan(%superq(title),&i,`,m)" / 
                        textattrs=(size=&titlesize weight=&titleweight family="Albany AMT" color=&fontcolor);
                %end;
                %if &npfoot > 0 and &pfoot=1 %then %do;
                    entryfootnote halign=left   
                        %do i = 1 %to &npfoot;
                            {sup "&i"} "&&pfoot&i; "
                        %end;
                        / textattrs=(size=&fnsize weight=&fnweight family="Albany AMT" color=&fontcolor);
                %end;
                %do i = 1 %to %sysfunc(countw(%superq(footnote),`,m));
                    entryfootnote halign=&fnalign "%scan(%superq(footnote),&i,`,m)" / 
                        textattrs=(size=&fnsize weight=&fnweight family="Albany AMT" color=&fontcolor);
                %end;
                
                /**Set up Legends**/
                /**Set up symbols and colors**/ 
                %if %sysevalf(%superq(_groupby)=1,boolean) %then %do;
                    discreteattrmap name="attrs" / ignorecase=false;  
                        %do b2 = 1 %to %sysfunc(countw(%superq(_groupbylevels),|));                    
                            value "%scan(%superq(_groupbylevels),&b2,|)" /                             
                                markerattrs=(
                                       %if %sysevalf(%qscan(%superq(symbol1),&b2,%str( ))=,boolean) %then %do;
                                           symbol=circlefilled
                                       %end;
                                       %else %do;
                                           symbol=%qscan(%superq(symbol1),&b2,%str( ))
                                       %end;
                                       %if %sysevalf(%qscan(%superq(symbolcolor1),&b2,%str( ))^=,boolean) %then %do;
                                           color=%qscan(%superq(symbolcolor1),&b2,%str( ))
                                       %end;
                                       size=%superq(symbolsize1))
                                    lineattrs=(pattern=1
                                       %if %sysevalf(%scan(%superq(linecolor1),&b2,%str( ))^=,boolean) %then %do;
                                           color=%scan(%superq(linecolor1),&b2,%str( ))
                                       %end;
                                       %if %sysevalf(%superq(errorbars1)=1,boolean) %then %do;
                                           thickness=%superq(linesize1)
                                       %end;
                                       %else %do;
                                           thickness=0pt
                                       %end;);
                        %end;
                    enddiscreteattrmap;
                    discreteattrvar attrvar=_attrs_ var=groupby attrmap="attrs" ; 
                %end;
                %else %do;
                    discreteattrmap name="attrs" / ignorecase=false;  
                        %do i = 1 %to &nmodels;
                            value "&i" /                             
                                markerattrs=(
                                       %if %sysevalf(%qscan(%superq(symbol&i),1,%str( ))=,boolean) %then %do;
                                           symbol=circlefilled
                                       %end;
                                       %else %do;
                                           symbol=%qscan(%superq(symbol&i),1,%str( ))
                                       %end;
                                       %if %sysevalf(%qscan(%superq(symbolcolor&i),1,%str( ))^=,boolean) %then %do;
                                           color=%qscan(%superq(symbolcolor&i),1,%str( ))
                                       %end;
                                       %else %do;
                                           color=black
                                       %end;
                                       size=%superq(symbolsize&i))
                                    lineattrs=(pattern=1
                                       %if %sysevalf(%scan(%superq(linecolor&i),1,%str( ))^=,boolean) %then %do;
                                           color=%scan(%superq(linecolor&i),1,%str( ))
                                       %end;
                                       %else %do;
                                           color=black
                                       %end;
                                       %if %sysevalf(%superq(errorbars&i)=1,boolean) %then %do;
                                           thickness=%superq(linesize&i)
                                       %end;
                                       %else %do;
                                           thickness=0pt
                                       %end;);
                        %end;
                    enddiscreteattrmap;
                    discreteattrvar attrvar=_attrs_ var=modelnum attrmap="attrs" ; 
                %end;
                layout lattice / rows=1 columns=1 border=false;/**Outer Lattice for legend**/  
                     %if %sysevalf(%superq(rowbylabelon)=1,boolean) %then %do;  
                                sidebar / align=left;
                                    layout gridded /columns=1 rows=%sysfunc(countw(%qupcase(&rowbylabel),`,m)) border=false
                                        valign=center halign=center;
                                        %do k = 1 %to %sysfunc(countw(%qupcase(&rowbylabel),`,m));
                                            entry ' ' / textattrs=(weight=bold color=&fontcolor family="Albany AMT" size=&sumsize) rotate=90;
                                            %if %sysevalf(%superq(rowbylabel)^=,boolean) and 
                                                %sysevalf(%superq(_cweight&_nsubtitle)<100,boolean) %then %do;
                                                drawtext textattrs=(weight=bold color=&fontcolor family="Albany AMT" size=&sumsize)
                                                    "%scan(%superq(rowbylabel),&k,`,m)" / y=50 
                                                    x=%sysevalf(100-100*&k/%sysfunc(countw(%qupcase(&rowbylabel),`,m)))
                                                   drawspace=layoutpercent anchor=top justify=center width=10000 rotate=90;
                                            %end;
                                        %end;
                                    endlayout;
                                endsidebar;
                            %end;              
                    /*Legend Setup*/                
                    %if %sysevalf(%qsysfunc(compress(%superq(groupby),%str(| )))^=,boolean) and &show_legend=1 %then %do;/*Legend Do Block*/      
                        sidebar / align=&legendalign;
                            layout gridded / rows=%sysevalf(&groupbylabelon+1) border=false; /*Outer grid for title and legend*/
                                %if %sysevalf(%superq(groupbylabelon)=1,boolean) %then %do;
                                    entry halign=center "&groupbylabel" / border=false opaque=false
                                        textattrs=(weight=&legendtitleweight size=&legendtitlesize  color=&fontcolor);
                                %end;                          
                                mergedlegend "line" "mark" / 
                                   down=&legendndown border=false valign=top opaque=false
                                   across=&legendnacross displayclipped=true
                                   autoitemsize=true 
                                   valueattrs=(weight=&legendvalweight size=&legendvalsize  color=&fontcolor)
                                   exclude=(""); 
                            endlayout;/**End Outer grid**/
                        endsidebar;
                    %end;/**End Legend Do Block**/      
                    /**Set up the schema**/
                    %local _adj _wsubadj _nsubspace _maxrowheader;                    
                    %if &_columns>1 and &_nsubtitle>0 %then %do;
                        %let _wsubadj=%sysevalf((%superq(_cweight&_nsubtitle)/&_columns));/*Space per column*/
                        %let _wsubadj=%sysevalf(&_wsubadj*(&_columns-1));/*Total space to be allocated*/
                        %let _wsubadj=%sysevalf(&_wsubadj/(&_nplot_display-1));/*Number of display items to allocate across*/
                        
                        %let _nsubspace=%sysevalf(1-(%superq(_cweight&_nsubtitle)/&_columns));
                    %end;
                    %else %do;
                        %let _wsubadj=0;
                        %let _nsubspace=1;
                    %end;      
                    %local _exrows;
                    %let _exrows=0;
                    %do i=1 %to %superq(_nplot);
                        %if %sysevalf(%superq(refline&i)^=,boolean) and (%sysevalf(%superq(refguidelower)^=,boolean) or %sysevalf(%superq(refguideupper)^=,boolean)) %then %do;
                            %let _exrows=%sysfunc(max(&_exrows,%sysfunc(countw(%superq(refguidelower&i),`,m)),%sysfunc(countw(%superq(refguideupper&i),`,m))));
                        %end;
                    %end;
                    %do i=1 %to %superq(_nplot);
                        %if %sysevalf(%superq(refline&i)^=,boolean) %then %do;
                            %if %sysevalf(%superq(refguidelower&i)^=,boolean) and %sysfunc(countw(%superq(refguidelower&i),`,m))<&_exrows %then 
                                %let refguidelower&i=%sysfunc(repeat(&nbsp.`,&_exrows-%sysfunc(countw(%superq(refguidelower&i),`,m))-1))&&refguidelower&i;
                        %end;
                    %end;
                    %if &_exrows>=1 %then %let _exrows=%sysevalf(&_exrows+1);
                    layout lattice / rows=%sysevalf(&_rows+&_exrows) 
                        rowweights=(%if %sysevalf(%qupcase(%superq(refguidevalign))=TOP,boolean) %then %do i=1 %to &_exrows; 
                                        &refguidespace
                                    %end;
                                    %do i=1 %to &_rows;
                                        %sysevalf((1-&_exrows*0.04)/&_rows) 
                                    %end; 
                                    %if %sysevalf(%qupcase(%superq(refguidevalign))=BOTTOM,boolean) %then %do i=1 %to &_exrows; 
                                        &refguidespace 
                                    %end;) order=rowmajor  border=false            
                        columns=%sysevalf(&_columns * %superq(_nplot_display)-%sysevalf(&_nsubtitle>0,boolean)*(&_columns-1))
                        columnweights=(%do i = 1 %to &_columns;
                                          %if &i=&_columns or &i=1 %then %let _adj=0;
                                          %do j = 1 %to &_nplot_display;
                                              %if &j^=&_nsubtitle %then %do;
                                                  %let _adj=%sysevalf(&_adj+(%superq(_cweight&j)+&_wsubadj)/&_columns);
                                                  %if &i < &_columns or &j < &_nplot_display %then %do;
                                                      %sysevalf((%superq(_cweight&j)+&_wsubadj)/&_columns)
                                                  %end;
                                                  %else %if &i=&_columns and &j=&_nplot_display %then %do;
                                                      %sysevalf((%superq(_cweight&j)+&_wsubadj)/&_columns + &_nsubspace/&_columns-&_adj)
                                                  %end;
                                              %end;
                                              %else %if &_columns>1 and ((%qupcase(&colsubtitles)=START and &i=1) or (%qupcase(&colsubtitles)=END and &i=&_columns)) %then %do;
                                                  %let _adj=%sysevalf(&_adj+%superq(_cweight&j)/&_columns);
                                                  %sysevalf((%superq(_cweight&j))/&_columns)
                                              %end;
                                              %else %if &_columns=1 %then %do;
                                                  %let _adj=%sysevalf(&_adj+%superq(_cweight&j)/&_columns);
                                                  %sysevalf((%superq(_cweight&j))/&_columns)
                                              %end;
                                          %end;
                                       %end;)
                        columndatarange=union rowdatarange=union
                        rowgutter=&rowgutter columngutter=&columngutter; /**Start of paneling lattice**/
                    
                        /*Y axes*/
                        rowaxes;  
                            %if %sysevalf(%qupcase(%superq(refguidevalign))=TOP,boolean) %then %do i=1 %to &_exrows; 
                                rowaxis / display=none type=linear linearopts=(viewmin=0 viewmax=100);
                            %end;
                            %do r = 1 %to &_rows;
                                rowaxis / reverse=true display=none displaysecondary=none
                                    tickvalueattrs=(family="Albany AMT") type=linear 
                                    linearopts=(viewmin=0 viewmax=&&_maxrows_&r tickvaluepriority=false tickvaluesequence=(start=0 end=&&_maxrows_&r increment=1))
                                    offsetmin=0.0 offsetmax=0.0;  
                            %end;
                            %if %sysevalf(%qupcase(%superq(refguidevalign))=BOTTOM,boolean) %then %do i=1 %to &_exrows; 
                                rowaxis / display=none type=linear linearopts=(viewmin=0 viewmax=100);
                            %end;
                        endrowaxes;
                        /*X Axes*/
                        columnaxes;
                            %local _pi;
                            %do i = 1 %to &_columns;                        
                                %let _pi=0;/**Plot Index**/
                                %do j = 1 %to %superq(_nplot_display);
                                    %if %sysfunc(find(%superq(_plot_display&j.),PLOT,i))>0 %then %do;
                                        %let _pi=%sysevalf(&_pi+1);
                                        columnaxis / type=%superq(xaxistype&_pi)   
                                            tickvalueattrs=(family="Albany AMT" size=&xtickvaluesize weight=&xtickvalueweight color=&fontcolor) 
                                            %if %qupcase(%superq(xaxistype&_pi))=LINEAR %then %do;
                                                linearopts=(
                                                    %if %sysevalf(%superq(tickvalues&_pi)^=,boolean) %then %do;
                                                        tickvaluelist=(&&tickvalues&_pi)
                                                    %end;
                                                    %else %do;
                                                        tickvaluelist=(&&_ticklist&_pi)
                                                    %end;                                                    
                                                viewmin=%superq(min&_pi) viewmax=%superq(max&_pi) tickvaluefitpolicy=none)
                                            %end;
                                            %else %do;
                                                logopts=(base=%superq(logbase) tickintervalstyle=%superq(logtickstyle)
                                                    %if %sysevalf(%superq(tickvalues&_pi)^=,boolean) %then %do;
                                                       tickvaluelist=(&&tickvalues&_pi)
                                                    %end;
                                                    %else %do;
                                                       tickvaluelist=(&&_ticklist&_pi)
                                                    %end;
                                                viewmin=%superq(min&_pi) viewmax=%superq(max&_pi))
                                            %end;
                                            griddisplay=off 
                                            display=(tickvalues ) offsetmin=0 offsetmax=0;
                                    %end;
                                    %else %if (%sysevalf(%superq(colby)^=,boolean) and ((&i=1 or &j^=&_nsubtitle) and %qupcase(&colsubtitles)=START) or
                                        ((&i=&_columns or &j^=&_nsubtitle) and %qupcase(&colsubtitles)=END)) or %sysevalf(%superq(colby)=,boolean) %then %do;
                                        columnaxis / type=linear linearopts=(viewmin=0 viewmax=1) griddisplay=off display=none offsetmin=0 offsetmax=0;                                                
                                    %end;
                                %end;
                            %end;
                        endcolumnaxes;
                        
                        /**X-axis labels**/
                        %if %sysevalf(%superq(xaxislabelon)=1,boolean) %then %do;
                            columnheaders;                            
                                %do i = 1 %to &_columns;              
                                    %let _pi=0;/**Plot Index**/
                                    %do j = 1 %to %superq(_nplot_display);
                                        %if %sysfunc(find(%superq(_plot_display&j.),PLOT,i))>0 %then %do;
                                            %let _pi=%sysevalf(&_pi+1);
                                            entry halign=center "&&xaxislabel&_pi" / 
                                                textattrs=(weight=&lweight color=&fontcolor family="Albany AMT" size=&lsize);
                                        %end;
                                        %else %if &i=1 or &j^=&_nsubtitle %then %do;
                                            entry ' ' /  textattrs=(weight=&lweight color=&fontcolor family="Albany AMT" size=&lsize);
                                        %end;                                            
                                    %end;    
                                %end;
                            endcolumnheaders;  
                        %end;   
                        /**Column Headers**/
                        sidebar / align=top;   
                            layout lattice / rows=1 border=false              
                                columns=%sysevalf(&_columns * %superq(_nplot_display)-%sysevalf(&_nsubtitle>0,boolean)*(&_columns-1))
                                columnweights=(%do i = 1 %to &_columns;
                                                  %if &i=&_columns or &i=1 %then %let _adj=0;
                                                  %do j = 1 %to &_nplot_display;
                                                      %if &j^=&_nsubtitle %then %do;
                                                          %let _adj=%sysevalf(&_adj+(%superq(_cweight&j)+&_wsubadj)/&_columns);
                                                          %if &i < &_columns or &j < &_nplot_display %then %do;
                                                              %sysevalf((%superq(_cweight&j)+&_wsubadj)/&_columns)
                                                          %end;
                                                          %else %if &i=&_columns and &j=&_nplot_display %then %do;
                                                              %sysevalf((%superq(_cweight&j)+&_wsubadj)/&_columns + &_nsubspace/&_columns-&_adj)
                                                          %end;
                                                      %end;
                                                      %else %if &_columns>1 and ((%qupcase(&colsubtitles)=START and &i=1) or (%qupcase(&colsubtitles)=END and &i=&_columns)) %then %do;
                                                          %let _adj=%sysevalf(&_adj+%superq(_cweight&j)/&_columns);
                                                          %sysevalf((%superq(_cweight&j))/&_columns)
                                                      %end;
                                                      %else %if &_columns=1 %then %do;
                                                          %let _adj=%sysevalf(&_adj+%superq(_cweight&j)/&_columns);
                                                          %sysevalf((%superq(_cweight&j))/&_columns)
                                                      %end;
                                                  %end;
                                               %end;)
                                columngutter=0;         
                                %do i = 1 %to &_columns;          
                                    %let _pi=0;/**Plot Index**/
                                    %do j=1 %to %superq(_NPLOT_DISPLAY);
                                        %if ((&i=1 or &j^=&_nsubtitle) and %qupcase(&colsubtitles)=START) or
                                            ((&i=&_columns or &j^=&_nsubtitle) and %qupcase(&colsubtitles)=END) %then %do;
                                            %if %sysfunc(find(%superq(_plot_display&j.),PLOT,i))>0 %then %let _pi=%sysevalf(&_pi+1);
                                            layout gridded /columns=1 rows=%sysfunc(countw(%qupcase(&&_plot_displayheader&j.),`,m))
                                                valign=bottom
                                                %if &j=&_nsubtitle %then %do;
                                                     halign=&subheaderalign
                                                %end;
                                                %else %do;
                                                    halign=center
                                                %end;;
                                            %do k = 1 %to %sysfunc(countw(%qupcase(&&_plot_displayheader&j.),`,m));
                                                entry ' ' / textattrs=(weight=bold  color=&fontcolor family="Albany AMT" size=&sumsize);
                                                %if %sysevalf(%superq(_plot_displayheader&j.)^=,boolean) and 
                                                    %sysevalf(%superq(_cweight&j.)>0,boolean) %then %do;
                                                    drawtext textattrs=(weight=bold  color=&fontcolor family="Albany AMT" size=&sumsize)
                                                        "%scan(%superq(_plot_displayheader&j.),&k,`,m)"
                                                        %if %qupcase(%superq(_plot_display&j.))=PVAL and &npfoot=1 and &pfoot=1 %then %do;
                                                             {sup '1'}
                                                        %end; / 
                                                        y=%sysevalf(100-100*&k/%sysfunc(countw(%qupcase(&&_plot_displayheader&j.),`,m)))
                                                       drawspace=layoutpercent  width=10000
                                                       %if &j=&_nsubtitle %then %do;
                                                           %if %qupcase(&subheaderalign)=LEFT %then %do;
                                                               x=0 justify=&subheaderalign anchor=bottomleft
                                                           %end;
                                                           %else %if %qupcase(&subheaderalign)=CENTER %then %do;
                                                               x=50 justify=&subheaderalign anchor=bottom
                                                           %end;
                                                           %else %if %qupcase(&subheaderalign)=RIGHT %then %do;
                                                               x=100 justify=&subheaderalign anchor=bottomright
                                                           %end;
                                                       %end;
                                                       %else %do;
                                                           x=50 justify=center anchor=bottom
                                                       %end;;
                                                       
                                                %end;
                                            %end;
                                            %if %sysevalf(%superq(_plot_displayheader&j.)^=,boolean) and &underlineheaders=1 %then %do;
                                                drawline x1=2 x2=98 y1=0 y2=0 / drawspace=layoutpercent 
                                                    lineattrs=(thickness=0.5pt color=black pattern=1);
                                            %end;
                                        endlayout;
                                        %end;
                                    %end;
                                %end;
                            endlayout;
                        endsidebar;   
                        
                        %if %sysevalf(%superq(_colby)=1,boolean) %then %do; 
                            sidebar / align=top;
                                layout lattice / border=false columns=%sysevalf(&_columns+1) 
                                    rows=1 columngutter=0
                                    columnweights=(%if %sysevalf(%qupcase(&colsubtitles)=START,boolean) and &_nsubtitle>0 %then %do; %sysevalf(%superq(_cweight&_nsubtitle)/&_columns) %end;
                                                   %do i=1 %to &_columns;
                                                       %if &_nsubtitle>0 %then %do;
                                                           %sysevalf((1-%superq(_cweight&_nsubtitle)/&_columns)/(&_columns))
                                                       %end;
                                                       %else %do;
                                                           %sysevalf(1/&_columns)
                                                       %end;
                                                   %end;
                                                   %if %sysevalf(%qupcase(&colsubtitles)=END,boolean) and &_nsubtitle>0 %then %do; %sysevalf(%superq(_cweight&_nsubtitle)/&_columns) %end;);
                                    %if %sysevalf(%qupcase(&colsubtitles)=START,boolean) and &_nsubtitle>0 %then %do; entry ' '; %end;
                                    %do j=1 %to &_columns;                          
                                        layout gridded /columns=1 rows=%sysfunc(countw(%qupcase(&&columnheaders&j.),`,m)) border=false
                                            valign=bottom halign=center;
                                            %do k = 1 %to %sysfunc(countw(%qupcase(&&columnheaders&j.),`,m));
                                                entry ' ' / textattrs=(weight=bold color=&fontcolor family="Albany AMT" size=&sumsize);
                                                %if %sysevalf(%superq(columnheaders&j.)^=,boolean) and 
                                                    %sysevalf(%superq(_cweight&j.)>0,boolean) %then %do;
                                                    drawtext textattrs=(weight=bold color=&fontcolor family="Albany AMT" size=&sumsize)
                                                        "%scan(%superq(columnheaders&j.),&k,`,m)" / x=50 
                                                        y=%sysevalf(100-100*&k/%sysfunc(countw(%qupcase(&&columnheaders&j.),`,m)))
                                                       drawspace=layoutpercent anchor=bottom justify=center width=10000;
                                                %end;
                                            %end;
                                            
                                            %if &underlineheaders=1 %then %do;
                                                drawline x1=2 x2=98 y1=25 y2=25 / drawspace=layoutpercent 
                                                    lineattrs=(thickness=0.5pt color=black pattern=1);
                                            %end;
                                        endlayout;
                                    %end;
                                    %if %sysevalf(%qupcase(&colsubtitles)=END,boolean) and &_nsubtitle>0 %then %do; entry ' '; %end;                       
                                endlayout;
                            endsidebar;
                            %if %sysevalf(%superq(colbylabelon)=1,boolean) %then %do;               
                                sidebar / align=top;
                                    layout lattice / border=false columns=2
                                        rows=1 columngutter=0
                                        columnweights=(%if %sysevalf(%qupcase(&colsubtitles)=START,boolean) and &_nsubtitle>0 %then %do; %sysevalf(%superq(_cweight&_nsubtitle)/&_columns) %end;
                                                       %sysevalf(1-%superq(_cweight&_nsubtitle)/&_columns)
                                                       %if %sysevalf(%qupcase(&colsubtitles)=END,boolean) and &_nsubtitle>0 %then %do; %sysevalf(%superq(_cweight&_nsubtitle)/&_columns) %end;);
                                        %if %sysevalf(%qupcase(&colsubtitles)=START,boolean) and &_nsubtitle>0 %then %do; entry ' '; %end;
                                        layout gridded /columns=1 rows=%sysfunc(countw(%qupcase(&colbylabel),`,m)) border=false
                                            valign=bottom halign=center;
                                            %do k = 1 %to %sysfunc(countw(%qupcase(&colbylabel),`,m));
                                                entry ' ' / textattrs=(weight=bold color=&fontcolor family="Albany AMT" size=&sumsize);
                                                %if %sysevalf(%superq(colbylabel)^=,boolean) and 
                                                    %sysevalf(%superq(_cweight&_nsubtitle)<100,boolean) %then %do;
                                                    drawtext textattrs=(weight=bold color=&fontcolor family="Albany AMT" size=&sumsize)
                                                        "%scan(%superq(colbylabel),&k,`,m)" / x=50 
                                                        y=%sysevalf(100-100*&k/%sysfunc(countw(%qupcase(&colbylabel),`,m)))
                                                       drawspace=layoutpercent anchor=bottom justify=center width=10000;
                                                %end;
                                            %end;
                                        endlayout;
                                        %if %sysevalf(%qupcase(&colsubtitles)=END,boolean) and &_nsubtitle>0 %then %do; entry ' '; %end;                       
                                    endlayout;
                                endsidebar;
                            %end;
                        %end;
                        /**Row Headers**/
                        %if %sysevalf(%superq(_rowby)=1,boolean)  %then %do;  
                            rowheaders;
                                %if %sysevalf(%qupcase(%superq(refguidevalign))=TOP,boolean) %then %do i=1 %to &_exrows; 
                                    entry " " / textattrs=(weight=bold color=&fontcolor family="Albany AMT" size=&sumsize) rotate=90 pad=(left=0 right=0);
                                %end;
                                %do r = 1 %to &_rows;
                                    layout gridded /columns=%sysfunc(countw(%superq(rowheaders&r),`,m)) rows=1 border=false
                                        valign=bottom halign=center;
                                            %do k = 1 %to %sysfunc(countw(%superq(rowheaders&r),`,m));
                                                entry " " / textattrs=(weight=bold color=&fontcolor family="Albany AMT" size=&sumsize) rotate=90
                                                    pad=(left=0 right=0);
                                                %if %sysevalf(%superq(rowheaders&r)^=,boolean) %then %do;
                                                    drawtext textattrs=(weight=bold color=&fontcolor family="Albany AMT" size=&sumsize)
                                                        "%scan(%superq(rowheaders&r),&k,`,m)" / y=50 
                                                        x=%sysevalf(100-100*&k/%sysfunc(countw(%qupcase(&rowbylabel),`,m)))
                                                        drawspace=layoutpercent anchor=top justify=center width=10000 rotate=90;
                                                %end;
                                            %end;
                                     endlayout;
                                %end;
                                %if %sysevalf(%qupcase(%superq(refguidevalign))=BOTTOM,boolean) %then %do i=1 %to &_exrows; 
                                    entry " " / textattrs=(weight=bold color=&fontcolor family="Albany AMT" size=&sumsize) rotate=90 pad=(left=0 right=0);
                                %end;
                            endrowheaders;
                        %end;     
                        
                        %if %sysevalf(%qupcase(%superq(refguidevalign))=TOP,boolean) %then %do i=1 %to &_exrows; 
                            %do c = 1 %to &_columns;/**Start Column loop**/
                                %let _pi=0;/**Plot Index**/
                                %do j = 1 %to %superq(_nplot_display); /**Start plot sections loop**/
                                    %if ^(%qupcase(&&_plot_display&j.) = SUBTITLE and &c>1 and %qupcase(&colsubtitles)=START) and 
                                        ^(%qupcase(&&_plot_display&j.) = SUBTITLE and &c<&_columns and %qupcase(&colsubtitles)=END) %then %do; 
                                    
                                        %if &colline=1 and &_columns>1 and &c<&_columns and &j=%superq(_nplot_display) %then %do;
                                            drawline x1=100 x2=100 y1=0 y2=100 
                                                / drawspace=layoutpercent
                                                  lineattrs=(color=black thickness=&collinesize pattern=&collinepattern);
                                        %end;
                                        %if %sysfunc(find(&&_plot_display&j.,PLOT,i))>0 %then %do;
                                            %let _pi=%sysevalf(&_pi+1);
                                            layout overlay / opaque=false border=false walldisplay=none;
                                                scatterplot x=eval(y*0+1) y=eval(y*0+1) / markerattrs=(size=0pt);  
                                                 /**Draws reference line**/
                                                 %if %sysevalf(%superq(refline&_pi)^=,boolean) %then %do;
                                                    drawline x1=&&refline&_pi x2=&&refline&_pi y1=0 y2=100 / x1space=datavalue x2space=datavalue y1space=layoutpercent y2space=layoutpercent
                                                        lineattrs=(pattern=&reflinepattern color=&reflinecolor thickness=&xlinesize);
                                                 %end;
                                                 /**Draws second line**/
                                                 %if %sysevalf(%superq(srefline&_pi)^=,boolean) %then %do;
                                                    drawline x1=&&srefline&_pi x2=&&srefline&_pi y1=0 y2=100 / x1space=datavalue x2space=datavalue y1space=layoutpercent y2space=layoutpercent
                                                        lineattrs=(pattern=&sreflinepattern color=&sreflinecolor thickness=&xlinesize);
                                                 %end;   
                                                 %if &showwalls=1 %then %do;
                                                    drawline x1=0 x2=0 y1=0 y2=100 
                                                        / drawspace=layoutpercent
                                                          lineattrs=(color=black thickness=&rowlinesize pattern=&rowlinepattern);
                                                    drawline x1=100 x2=100 y1=0 y2=100 
                                                        / drawspace=layoutpercent
                                                          lineattrs=(color=black thickness=&rowlinesize pattern=&rowlinepattern);
                                                 %end;
                                                 %if %sysevalf(%superq(refline&_pi)^=,boolean) and %sysevalf(%superq(refguidelower&_pi)^=,boolean) %then %do;
                                                    drawtext textattrs=(weight=&refguideweight color=&refguidecolor family="Albany AMT" size=&refguidesize)
                                                        "%scan(%superq(refguidelower&_pi),&i,`,m)" / y=0 width=10000
                                                        %if %sysevalf(%qupcase(%superq(xaxistype&_pi))=LINEAR,boolean) %then %do;
                                                            %if %sysevalf(%qupcase(%superq(refguidehalign))=%str(IN),boolean) %then %do;
                                                                x=%sysevalf(100*(&&refline&_pi-%superq(min&_pi))/(%superq(max&_pi)-%superq(min&_pi)) - 5) justify=right anchor=bottomright
                                                            %end;
                                                            %else %if %sysevalf(%qupcase(%superq(refguidehalign))=CENTER,boolean) %then %do;
                                                                x=%sysevalf(100*((&&refline&_pi-%superq(min&_pi))/2)/(%superq(max&_pi)-%superq(min&_pi))) justify=center anchor=bottom
                                                            %end;
                                                        %end;
                                                        %else %do;
                                                            %if %sysevalf(%qupcase(%superq(refguidehalign))=%str(IN),boolean) %then %do;
                                                                x=%sysevalf(100*(%sysfunc(log(&&refline&_pi))-%sysfunc(log(%superq(min&_pi))))/
                                                                     (%sysfunc(log(%superq(max&_pi)))-%sysfunc(log(%superq(min&_pi)))) - 5) justify=right anchor=bottomright
                                                            %end;
                                                            %else %if %sysevalf(%qupcase(%superq(refguidehalign))=CENTER,boolean) %then %do;
                                                                x=%sysevalf(100*((%sysfunc(log(&&refline&_pi))-%sysfunc(log(%superq(min&_pi))))/2)/
                                                                             (%sysfunc(log(%superq(max&_pi)))-%sysfunc(log(%superq(min&_pi))))) justify=center anchor=bottom
                                                            %end;                                                      
                                                        %end;
                                                        drawspace=layoutpercent;
                                                    %if &i=&_exrows %then %do;
                                                        drawarrow
                                                            %if %sysevalf(%qupcase(%superq(xaxistype&_pi))=LINEAR,boolean) %then %do;
                                                                x1=%sysevalf(100*(&&refline&_pi-%superq(min&_pi))/(%superq(max&_pi)-%superq(min&_pi)) - 5)
                                                            %end;
                                                            %else %do;
                                                                x1=%sysevalf(100*(%sysfunc(log(&&refline&_pi))-%sysfunc(log(%superq(min&_pi))))/
                                                                                 (%sysfunc(log(%superq(max&_pi)))-%sysfunc(log(%superq(min&_pi)))) - 5)                                                        
                                                            %end;
                                                            x2=5 y1=100 y2=100
                                                            / arrowheaddirection=out ARROWHEADSHAPE=&refguidelinearrow                                                        
                                                            drawspace=layoutpercent 
                                                            lineattrs=(pattern=&refguidelinepattern color=&refguidelinecolor thickness=&refguidelinesize);
                                                    %end;
                                                %end;
                                                %if %sysevalf(%superq(refline&_pi)^=,boolean) and %sysevalf(%superq(refguideupper&_pi)^=,boolean) %then %do;
                                                 /**Draw reference line guides**/
                                                    %if %sysevalf(%superq(refline&_pi)^=,boolean) and %sysevalf(%superq(refguideupper&_pi)^=,boolean) %then %do;  
                                                        drawtext textattrs=(weight=&refguideweight color=&refguidecolor family="Albany AMT" size=&refguidesize)  
                                                            "%scan(%superq(refguideupper&_pi),&i,`,m)" / y=0
                                                            width=10000
                                                            %if %sysevalf(%qupcase(%superq(xaxistype&_pi))=LINEAR,boolean) %then %do;
                                                                %if %sysevalf(%qupcase(%superq(refguidehalign))=%str(IN),boolean) %then %do;
                                                                    x=%sysevalf(100*(&&refline&_pi-%superq(min&_pi))/(%superq(max&_pi)-%superq(min&_pi)) + 5) justify=left anchor=bottomleft
                                                                %end;
                                                                %else %if %sysevalf(%qupcase(%superq(refguidehalign))=CENTER,boolean) %then %do;
                                                                    x=%sysevalf(100*((%superq(max&_pi)-&&refline&_pi)/2 + (&&refline&_pi-%superq(min&_pi)))/
                                                                            (%superq(max&_pi)-%superq(min&_pi))) justify=center anchor=bottom
                                                                %end;
                                                            %end;
                                                            %else %do;
                                                                %if %sysevalf(%qupcase(%superq(refguidehalign))=%str(IN),boolean) %then %do;
                                                                    x=%sysevalf(100*(%sysfunc(log(&&refline&_pi))-%sysfunc(log(%superq(min&_pi))))/
                                                                         (%sysfunc(log(%superq(max&_pi)))-%sysfunc(log(%superq(min&_pi)))) + 5) justify=left anchor=bottomleft
                                                                %end;
                                                                %else %if %sysevalf(%qupcase(%superq(refguidehalign))=CENTER,boolean) %then %do;
                                                                    x=%sysevalf(100*((%sysfunc(log(%superq(max&_pi)))-%sysfunc(log(&&refline&_pi)))/2 + 
                                                                            (%sysfunc(log(&&refline&_pi))-%sysfunc(log(%superq(min&_pi)))))/
                                                                            (%sysfunc(log(%superq(max&_pi)))-%sysfunc(log(%superq(min&_pi))))) justify=center anchor=bottom
                                                                %end;                                                      
                                                            %end;
                                                            drawspace=layoutpercent;
                                                    
                                                        %if &i=&_exrows %then %do;
                                                            drawarrow 
                                                                %if %sysevalf(%qupcase(%superq(xaxistype&_pi))=LINEAR,boolean) %then %do;
                                                                    x1=%sysevalf(100*(&&refline&_pi-%superq(min&_pi))/(%superq(max&_pi)-%superq(min&_pi)) + 5)
                                                                %end;
                                                                %else %do;
                                                                    x1=%sysevalf(100*(%sysfunc(log(&&refline&_pi))-%sysfunc(log(%superq(min&_pi))))/
                                                                                     (%sysfunc(log(%superq(max&_pi)))-%sysfunc(log(%superq(min&_pi)))) + 5)
                                                                %end;
                                                                x2=95 y1=100 y2=100
                                                                / arrowheaddirection=out  ARROWHEADSHAPE=&refguidelinearrow  
                                                                drawspace=layoutpercent
                                                                lineattrs=(pattern=&refguidelinepattern color=&refguidelinecolor thickness=&refguidelinesize);
                                                        %end;
                                                    %end;
                                                 %end;  
                                             endlayout;
                                        %end;
                                        %else %do; 
                                            entry ' ' ;
                                        %end;
                                    %end;
                                %end;
                            %end;
                        %end;
                        %do r = 1 %to &_rows; /**Start Row Loop**/
                            %do c = 1 %to &_columns;/**Start Column loop**/
                                %let _pi=0;/**Plot Index**/
                                %do j = 1 %to %superq(_nplot_display); /**Start plot sections loop**/
                                    %if ^(%qupcase(&&_plot_display&j.) = SUBTITLE and &c>1 and %qupcase(&colsubtitles)=START) and 
                                        ^(%qupcase(&&_plot_display&j.) = SUBTITLE and &c<&_columns and %qupcase(&colsubtitles)=END) %then %do;   
                                        layout overlay / opaque=false border=false walldisplay=none;
                                            
                                            %if &rowline=1 and &r>1 %then %do;
                                                drawline x1=0 x2=100 y1=100 y2=100 
                                                    / drawspace=layoutpercent
                                                      lineattrs=(color=black thickness=&rowlinesize pattern=&rowlinepattern);
                                            %end;
                                            %if &colline=1 and &_columns>1 and &c<&_columns and &j=%superq(_nplot_display) %then %do;
                                                drawline x1=100 x2=100 y1=0 y2=100 
                                                    / drawspace=layoutpercent
                                                      lineattrs=(color=black thickness=&collinesize pattern=&collinepattern);
                                            %end;
                                            %if %qupcase(&&_plot_display&j.) = SUBTITLE %then %do; 
                                                scatterplot x=eval(y*0+1) y=eval(y*0+1) / markerattrs=(size=0pt);  
                                                %do k = 1 %to %superq(_maxdv_);             
                                                    /**Draws Entry Statements to show the current row level**/ 
                                                    %if %sysevalf(%qscan(%superq(subtitle),&k,|,m)^=,boolean) and %sysevalf(%qscan(&rowby_lvl,&k,|,m)=&r,boolean) %then %do;
                                                        drawtext  
                                                            %if %scan(%superq(boldind),&k,|,m)=1 %then %do;
                                                                textattrs=(family="Albany AMT" weight=bold color=&fontcolor size=&subsize)
                                                            %end;
                                                            %else %do;
                                                                textattrs=(family="Albany AMT" weight=normal color=&fontcolor size=&subsize)
                                                            %end;
                                                            %do l=1 %to %scan(%superq(subind),&k,|,m);
                                                                '   '
                                                            %end; 
                                                            " %scan(%superq(subtitle),&k,|,m)" / anchor=left
                                                            x=0 y=%scan(%superq(y),&k,|,m) xspace=layoutpercent yspace=datavalue width=10000;
                                                    %end;
                                                %end;
                                            %end;
                                            %else %if %sysfunc(find(&&_plot_display&j.,PLOT,i))>0 %then %do;
                                                %let _pi=%sysevalf(&_pi+1);
                                                /**Draws the error bars**/
                                                highlowplot low=lcl&_pi._&c high=ucl&_pi._&c y=eval(ifn(rowby_lvl=&r,y,.)) / 
                                                     lowcap=lcl&_pi._cap&c highcap=ucl&_pi._cap&c name="line" group=_attrs_;
                                                /**Draws the estimates**/
                                                scatterplot x=estimate&_pi._&c y=eval(ifn(rowby_lvl=&r,y,.)) / 
                                                    name="mark" group=_attrs_;   
                                                 /**Draws reference line**/
                                                 %if %sysevalf(%superq(refline&_pi)^=,boolean) %then %do;
                                                    drawline x1=&&refline&_pi x2=&&refline&_pi y1=0 y2=100 / x1space=datavalue x2space=datavalue y1space=layoutpercent y2space=layoutpercent
                                                        lineattrs=(pattern=&reflinepattern color=&reflinecolor thickness=&xlinesize);
                                                 %end;
                                                 /**Draws second line**/
                                                 %if %sysevalf(%superq(srefline&_pi)^=,boolean) %then %do;
                                                    drawline x1=&&srefline&_pi x2=&&srefline&_pi y1=0 y2=100 / x1space=datavalue x2space=datavalue y1space=layoutpercent y2space=layoutpercent
                                                        lineattrs=(pattern=&sreflinepattern color=&sreflinecolor thickness=&xlinesize);
                                                 %end;    
                                                 %if &showwalls=1 %then %do;
                                                    drawline x1=0 x2=0 y1=0 y2=100 
                                                        / drawspace=layoutpercent
                                                          lineattrs=(color=black thickness=&rowlinesize pattern=&rowlinepattern);
                                                    drawline x1=100 x2=100 y1=0 y2=100 
                                                        / drawspace=layoutpercent
                                                          lineattrs=(color=black thickness=&rowlinesize pattern=&rowlinepattern);
                                                 %end;
                                                                   
                                                 /**Draws Axis line**/
                                                 %if &r=&_rows and ^(&_exrows>0 and %qupcase(%superq(refguidevalign))=BOTTOM) %then %do;
                                                    drawline x1=0 x2=100 y1=0 y2=0 
                                                        / drawspace=layoutpercent
                                                          lineattrs=(color=black thickness=&rowlinesize pattern=&rowlinepattern);
                                                          
                                                    %do k = 1 %to %sysfunc(countw(%superq(_ticklist&_pi),%str( )));
                                                        drawline x1=%scan(%superq(_ticklist&_pi),&k,%str( )) x2=%scan(%superq(_ticklist&_pi),&k,%str( )) y1=0 y2=-6 
                                                            / x1space=datavalue x2space=datavalue y1space=layoutpercent y2space=layoutpixel
                                                              lineattrs=(color=black thickness=&rowlinesize pattern=&rowlinepattern);                                                        
                                                    %end;
                                                    
                                                    %if %qupcase(&&logminor&_pi)=TRUE and &&logbase&_pi=10 and %sysevalf(%superq(tickvalues&_pi)=,boolean)
                                                        and %qupcase(&&xaxistype&_pi)=LOG and
                                                        (%qupcase(&&logtickstyle&_pi)=LOGEXPAND or %qupcase(&&logtickstyle&_pi)=LOGEXPONENT) %then %do k = 1 %to %sysfunc(countw(%superq(_mticklist&_pi),%str( )));
                                                        drawline x1=%scan(%superq(_mticklist&_pi),&k,%str( )) x2=%scan(%superq(_mticklist&_pi),&k,%str( )) y1=0 y2=-3 
                                                            / x1space=datavalue x2space=datavalue y1space=layoutpercent y2space=layoutpixel
                                                            lineattrs=(color=black thickness=&rowlinesize pattern=&rowlinepattern);
                                                    %end;
                                                 %end;
                                            %end;                                         
                                            %else %if %qupcase(&&_plot_display&j.) = PVAL %then %do;   
                                                scatterplot x=eval(y*0+1) y=eval(y*0+1) / markerattrs=(size=0pt);                                    
                                                /**Draw Summary Statistics**/
                                                %do k = 1 %to %superq(_maxdv_);
                                                    %if %sysevalf(%qscan(%superq(&&_plot_display&j.._&c),&k,|,m)^=,boolean) and %sysevalf(%qscan(&rowby_lvl,&k,|,m)=&r,boolean) %then %do;
                                                        drawtext 
                                                            textattrs=(weight=normal 
                                                                %if &_groupby=0 or &groupby_colortext=0 %then %do; color=&fontcolor %end;
                                                                %else %do;  
                                                                    %if %sysevalf(%scan(%superq(linecolor1),%qscan(%superq(groupby_lvl),&k,|,m),%str( ))^=,boolean) %then %do;
                                                                        color=%scan(%superq(linecolor1),%qscan(%superq(groupby_lvl),&k,|,m),%str( ))
                                                                    %end;
                                                                    %else %if %sysfunc(mod(%qscan(%superq(groupby_lvl),&k,|,m),12))=0 %then %do; 
                                                                        color=graphdata12:color 
                                                                    %end;
                                                                    %else %do; 
                                                                        color=graphdata%sysevalf(%sysfunc(mod(%qscan(%superq(groupby_lvl),&k,|,m),12))):color 
                                                                    %end;
                                                                %end; family="Albany AMT" size=&sumsize)
                                                            "%scan(%superq(&&_plot_display&j.._&c),&k,|,m)"
                                                                %if %sysevalf(%qscan(%superq(pfoot_index_&c),&k,|,m)^=,boolean) and &pfoot=1 and &npfoot>1 %then %do;
                                                                    {sup "%qscan(%superq(pfoot_index_&c),&k,|,m)"} 
                                                                %end; / 
                                                            x=50 y=%qscan(%superq(y),&k,|,m)
                                                            xspace=layoutpercent yspace=datavalue anchor=center
                                                            width=10000 justify=center;
                                                            
                                       
                                                    %end;  
                                                %end;
                                            %end;                                          
                                            %else %if %qupcase(&&_plot_display&j.) ^= SUBTITLE %then %do;
                                                scatterplot x=eval(y*0+1) y=eval(y*0+1) / markerattrs=(size=0pt);                                        
                                                /**Draw Summary Statistics**/
                                                %do k = 1 %to %superq(_maxdv_);
                                                    %if %sysevalf(%qscan(%superq(&&_plot_display&j.._&c),&k,|,m)^=,boolean) and %sysevalf(%qscan(&rowby_lvl,&k,|,m)=&r,boolean) %then %do;
                                                        drawtext 
                                                            textattrs=(weight=normal 
                                                            %if &_groupby=0 or &groupby_colortext=0 %then %do; color=&fontcolor %end;
                                                            %else %do;  
                                                                %if %sysevalf(%scan(%superq(linecolor1),%qscan(%superq(groupby_lvl),&k,|,m),%str( ))^=,boolean) %then %do;
                                                                    color=%scan(%superq(linecolor1),%qscan(%superq(groupby_lvl),&k,|,m),%str( ))
                                                                %end;
                                                                %else %if %sysfunc(mod(%qscan(%superq(groupby_lvl),&k,|,m),12))=0 %then %do; 
                                                                    color=graphdata12:color 
                                                                %end;
                                                                %else %do; 
                                                                    color=graphdata%sysevalf(%sysfunc(mod(%qscan(%superq(groupby_lvl),&k,|,m),12))):color 
                                                                %end;
                                                            %end; 
                                                            family="Albany AMT" size=&sumsize)
                                                            "%scan(%superq(&&_plot_display&j.._&c),&k,|,m)" / 
                                                            x=50 y=%qscan(%superq(y),&k,|,m)
                                                            xspace=layoutpercent yspace=datavalue anchor=center
                                                            width=10000 justify=center;
                                                            
                                                            
                                                            
                                                    %end;  
                                                %end;
                                            %end;   
                                            /**Alternating Shading**/
                                            %if &shading=1 %then %do k = 2 %to &&_maxrows_&r %by 2;
                                                beginpolygon x=0 y=%sysevalf(&k) / fillattrs=(color=GREYE5) display=(fill) layer=back
                                                    xspace=layoutpercent yspace=datavalue;
                                                    draw x=100 y=%sysevalf(&k);
                                                    draw x=100 y=%sysevalf(&k-1);
                                                    draw x=0 y=%sysevalf(&k-1);
                                                endpolygon;
                                            %end;
                                            /**Shading by Indicator**/
                                            %else %if &shading = 2 or &shading = 3 or &shading = 4 %then %do k = 1 %to %superq(_maxdv2_);
                                                %if %scan(&rowby_lvl,&k,|,m)=&r %then %do;
                                                    %if %scan(&shadeind,&k,|,m)=1 and %sysevalf(%scan(&y,&k,|,m)^=,boolean) %then %do;
                                                        beginpolygon x=0 y=%sysevalf(%scan(&y,&k,|,m)+0.5) / fillattrs=(color=GREYE5) display=(fill) layer=back
                                                            xspace=layoutpercent yspace=datavalue;
                                                            draw x=100 y=%sysevalf(%scan(&y,&k,|,m)+0.5);
                                                            draw x=100 y=%sysevalf(%scan(&y,&k,|,m)-0.5);
                                                            draw x=0 y=%sysevalf(%scan(&y,&k,|,m)-0.5);
                                                        endpolygon;
                                                    %end;
                                                %end;
                                            %end;
                                        endlayout;/**End Plot Panel**/
                                    %end;
                                %end; /**End Plot loop**/
                            %end;/**End Column loop**/ 
                       %end;/**End Row loop**/
                      
                       %if %sysevalf(%qupcase(%superq(refguidevalign))=BOTTOM,boolean) %then %do i=1 %to &_exrows; 
                            %do c = 1 %to &_columns;/**Start Column loop**/
                                %let _pi=0;/**Plot Index**/
                                %do j = 1 %to %superq(_nplot_display); /**Start plot sections loop**/
                                    %if ^(%qupcase(&&_plot_display&j.) = SUBTITLE and &c>1 and %qupcase(&colsubtitles)=START) and 
                                        ^(%qupcase(&&_plot_display&j.) = SUBTITLE and &c<&_columns and %qupcase(&colsubtitles)=END) %then %do; 
                                    
                                        layout overlay / opaque=false border=false walldisplay=none;
                                            %if &colline=1 and &_columns>1 and &c<&_columns and &j=%superq(_nplot_display) %then %do;
                                                drawline x1=100 x2=100 y1=0 y2=100 
                                                    / drawspace=layoutpercent
                                                      lineattrs=(color=black thickness=&collinesize pattern=&collinepattern);
                                            %end;
                                            %if %sysfunc(find(&&_plot_display&j.,PLOT,i))>0 %then %do;
                                                %let _pi=%sysevalf(&_pi+1);
                                                    scatterplot x=eval(y*0+1) y=eval(y*0+1) / markerattrs=(size=0pt);  
                                                    %if &i=&_exrows %then %do;
                                                        drawline x1=0 x2=100 y1=0 y2=0 
                                                            / drawspace=layoutpercent
                                                              lineattrs=(color=black thickness=&rowlinesize pattern=&rowlinepattern);
                                                              
                                                        %do k = 1 %to %sysfunc(countw(%superq(_ticklist&_pi),%str( )));
                                                            drawline x1=%scan(%superq(_ticklist&_pi),&k,%str( )) x2=%scan(%superq(_ticklist&_pi),&k,%str( )) y1=0 y2=-6 
                                                                / x1space=datavalue x2space=datavalue y1space=layoutpercent y2space=layoutpixel
                                                                  lineattrs=(color=black thickness=&rowlinesize pattern=&rowlinepattern);                                                        
                                                        %end;
                                                        
                                                        %if %qupcase(&&logminor&_pi)=TRUE and &&logbase&_pi=10 and 
                                                            (%qupcase(&&logtickstyle&_pi)=LOGEXPAND or %qupcase(&&logtickstyle&_pi)=LOGEXPONENT) %then %do k = 1 %to %sysfunc(countw(%superq(_mticklist&_pi),%str( )));
                                                            drawline x1=%scan(%superq(_mticklist&_pi),&k,%str( )) x2=%scan(%superq(_mticklist&_pi),&k,%str( )) y1=0 y2=-3 
                                                                / x1space=datavalue x2space=datavalue y1space=layoutpercent y2space=layoutpixel
                                                                lineattrs=(color=black thickness=&rowlinesize pattern=&rowlinepattern);
                                                        %end;
                                                     %end;
                                                     /**Draws reference line**/
                                                     %if %sysevalf(%superq(refline&_pi)^=,boolean) %then %do;
                                                        drawline x1=&&refline&_pi x2=&&refline&_pi y1=0 y2=100 / x1space=datavalue x2space=datavalue y1space=layoutpercent y2space=layoutpercent
                                                            lineattrs=(pattern=&reflinepattern color=&reflinecolor thickness=&xlinesize);
                                                     %end;
                                                     /**Draws second line**/
                                                     %if %sysevalf(%superq(srefline&_pi)^=,boolean) %then %do;
                                                        drawline x1=&&srefline&_pi x2=&&srefline&_pi y1=0 y2=100 / x1space=datavalue x2space=datavalue y1space=layoutpercent y2space=layoutpercent
                                                            lineattrs=(pattern=&sreflinepattern color=&sreflinecolor thickness=&xlinesize);
                                                     %end;   
                                                     %if &showwalls=1 %then %do;
                                                        drawline x1=0 x2=0 y1=0 y2=100 
                                                            / drawspace=layoutpercent
                                                              lineattrs=(color=black thickness=&rowlinesize pattern=&rowlinepattern);
                                                        drawline x1=100 x2=100 y1=0 y2=100 
                                                            / drawspace=layoutpercent
                                                              lineattrs=(color=black thickness=&rowlinesize pattern=&rowlinepattern);
                                                     %end;
                                                     %if %sysevalf(%superq(refline&_pi)^=,boolean) and %sysevalf(%superq(refguidelower&_pi)^=,boolean) %then %do;
                                                        %if &i <&_exrows %then %do;
                                                            drawtext textattrs=(weight=&refguideweight color=&refguidecolor family="Albany AMT" size=&refguidesize)
                                                                "%scan(%superq(refguidelower&_pi),&i,`,m)" / y=50 width=10000
                                                                %if %sysevalf(%qupcase(%superq(xaxistype&_pi))=LINEAR,boolean) %then %do;
                                                                    %if %sysevalf(%qupcase(%superq(refguidehalign))=%str(IN),boolean) %then %do;
                                                                        x=%sysevalf(100*(&&refline&_pi-%superq(min&_pi))/(%superq(max&_pi)-%superq(min&_pi)) - 5) justify=right anchor=right
                                                                    %end;
                                                                    %else %if %sysevalf(%qupcase(%superq(refguidehalign))=CENTER,boolean) %then %do;
                                                                        x=%sysevalf(100*((&&refline&_pi-%superq(min&_pi))/2)/(%superq(max&_pi)-%superq(min&_pi))) justify=center anchor=center
                                                                    %end;
                                                                %end;
                                                                %else %do;
                                                                    %if %sysevalf(%qupcase(%superq(refguidehalign))=%str(IN),boolean) %then %do;
                                                                        x=%sysevalf(100*(%sysfunc(log(&&refline&_pi))-%sysfunc(log(%superq(min&_pi))))/
                                                                             (%sysfunc(log(%superq(max&_pi)))-%sysfunc(log(%superq(min&_pi)))) - 5) justify=right anchor=right
                                                                    %end;
                                                                    %else %if %sysevalf(%qupcase(%superq(refguidehalign))=CENTER,boolean) %then %do;
                                                                        x=%sysevalf(100*((%sysfunc(log(&&refline&_pi))-%sysfunc(log(%superq(min&_pi))))/2)/
                                                                                     (%sysfunc(log(%superq(max&_pi)))-%sysfunc(log(%superq(min&_pi))))) justify=center anchor=center
                                                                    %end;                                                      
                                                                %end;
                                                                drawspace=layoutpercent;
                                                        %end;
                                                        %if &i=&_exrows %then %do;
                                                            drawarrow
                                                                %if %sysevalf(%qupcase(%superq(xaxistype&_pi))=LINEAR,boolean) %then %do;
                                                                    x1=%sysevalf(100*(&&refline&_pi-%superq(min&_pi))/(%superq(max&_pi)-%superq(min&_pi)) - 5)
                                                                %end;
                                                                %else %do;
                                                                    x1=%sysevalf(100*(%sysfunc(log(&&refline&_pi))-%sysfunc(log(%superq(min&_pi))))/
                                                                                     (%sysfunc(log(%superq(max&_pi)))-%sysfunc(log(%superq(min&_pi)))) - 5)                                                        
                                                                %end;
                                                                x2=5 y1=50 y2=50
                                                                / arrowheaddirection=out ARROWHEADSHAPE=&refguidelinearrow                                                        
                                                                drawspace=layoutpercent 
                                                                lineattrs=(pattern=&refguidelinepattern color=&refguidelinecolor thickness=&refguidelinesize);
                                                        %end;
                                                    %end;
                                                    %if %sysevalf(%superq(refline&_pi)^=,boolean) and %sysevalf(%superq(refguideupper&_pi)^=,boolean) %then %do;
                                                     /**Draw reference line guides**/
                                                        %if %sysevalf(%superq(refline&_pi)^=,boolean) and %sysevalf(%superq(refguideupper&_pi)^=,boolean) %then %do;  
                                                            %if &i<&_exrows %then %do;
                                                                drawtext textattrs=(weight=&refguideweight color=&refguidecolor family="Albany AMT" size=&refguidesize)  
                                                                    "%scan(%superq(refguideupper&_pi),&i,`,m)" / y=50
                                                                    width=10000
                                                                    %if %sysevalf(%qupcase(%superq(xaxistype&_pi))=LINEAR,boolean) %then %do;
                                                                        %if %sysevalf(%qupcase(%superq(refguidehalign))=%str(IN),boolean) %then %do;
                                                                            x=%sysevalf(100*(&&refline&_pi-%superq(min&_pi))/(%superq(max&_pi)-%superq(min&_pi)) + 5) justify=left anchor=left
                                                                        %end;
                                                                        %else %if %sysevalf(%qupcase(%superq(refguidehalign))=CENTER,boolean) %then %do;
                                                                            x=%sysevalf(100*((%superq(max&_pi)-&&refline&_pi)/2 + (&&refline&_pi-%superq(min&_pi)))/
                                                                                    (%superq(max&_pi)-%superq(min&_pi))) justify=center anchor=center
                                                                        %end;
                                                                    %end;
                                                                    %else %do;
                                                                        %if %sysevalf(%qupcase(%superq(refguidehalign))=%str(IN),boolean) %then %do;
                                                                            x=%sysevalf(100*(%sysfunc(log(&&refline&_pi))-%sysfunc(log(%superq(min&_pi))))/
                                                                                 (%sysfunc(log(%superq(max&_pi)))-%sysfunc(log(%superq(min&_pi)))) + 5) justify=left anchor=left
                                                                        %end;
                                                                        %else %if %sysevalf(%qupcase(%superq(refguidehalign))=CENTER,boolean) %then %do;
                                                                            x=%sysevalf(100*((%sysfunc(log(%superq(max&_pi)))-%sysfunc(log(&&refline&_pi)))/2 + 
                                                                                    (%sysfunc(log(&&refline&_pi))-%sysfunc(log(%superq(min&_pi)))))/
                                                                                    (%sysfunc(log(%superq(max&_pi)))-%sysfunc(log(%superq(min&_pi))))) justify=center anchor=center
                                                                        %end;                                                      
                                                                    %end;
                                                                    drawspace=layoutpercent;
                                                            %end;
                                                        
                                                            %if &i=&_exrows %then %do;
                                                                drawarrow 
                                                                    %if %sysevalf(%qupcase(%superq(xaxistype&_pi))=LINEAR,boolean) %then %do;
                                                                        x1=%sysevalf(100*(&&refline&_pi-%superq(min&_pi))/(%superq(max&_pi)-%superq(min&_pi)) + 5)
                                                                    %end;
                                                                    %else %do;
                                                                        x1=%sysevalf(100*(%sysfunc(log(&&refline&_pi))-%sysfunc(log(%superq(min&_pi))))/
                                                                                         (%sysfunc(log(%superq(max&_pi)))-%sysfunc(log(%superq(min&_pi)))) + 5)
                                                                    %end;
                                                                    x2=95 y1=50 y2=50
                                                                    / arrowheaddirection=out  ARROWHEADSHAPE=&refguidelinearrow  
                                                                    drawspace=layoutpercent
                                                                    lineattrs=(pattern=&refguidelinepattern color=&refguidelinecolor thickness=&refguidelinesize);
                                                            %end;
                                                        %end;
                                                     %end;  
                                            %end;
                                            %else %do; 
                                                entry ' ' ;
                                            %end;
                                        endlayout;
                                    %end;
                                %end;
                            %end;
                        %end;
                    endlayout;/**End of paneling lattice**/
               endlayout;
            endgraph;
            end;
        run;/**Creates document to save**/
        %if %sysevalf(%superq(outdoc)=,boolean)=0 %then %do;
            ods escapechar='^';
            /**Sets up DPI and ODS generated file**/
            ods &destination 
                %if %qupcase(&destination)=RTF %then %do; 
                    image_dpi=&dpi 
                %end;
                %else %if %qupcase(&destination)=HTML %then %do; 
                    image_dpi=&dpi 
                %end;
                %else %if %qupcase(&destination)=PDF %then %do; 
                    dpi=&dpi 
                %end;
                %else %if %qupcase(&destination)=EXCEL %then %do; 
                    dpi=&dpi 
                %end;
                %else %if %qupcase(&destination)=POWERPOINT %then %do; 
                    dpi=&dpi 
                %end;;
        %end;
        %else %do;
            %if &_listing=1 %then %do;
                ods listing image_dpi=&dpi;
            %end;
            %else %do;
                ods listing close image_dpi=&dpi;
            %end;
        %end;
        
        /**Save image to specified location**/
        %if %sysevalf(%superq(gpath)=,boolean)=0 %then %do;
            ods listing gpath="&gpath";
        %end;
        /**Names and formats the image**/
        %if %sysevalf(%superq(plottype)^=,boolean) %then %do; 
            %if %qupcase(&plottype)=EMF or (&svg=1 and %qupcase(&destination)=RTF) 
                or (&svg=1 and %qupcase(&destination)=EXCEL)
                or (&svg=1 and %qupcase(&destination)=POWERPOINT) %then %do;
                %local _any_trans;
                %let _any_trans=0;
                options printerpath='emf';
                ods graphics / imagefmt=&plottype;  
                %if &sysver=9.4 and &transparent=0 and &_any_trans=0 %then %do;
                    /**Modifies temporary registry keys to create better EMF image in 9.4**/
                    /**Taken from SAS Technical Support Martin Mincey**/
                    %local workdir;
                    %let workdir=%trim(%sysfunc(pathname(work))); 
                    /**Creates the new keys**/
                    data _null_;
                    %if %qupcase(&sysscp)=WIN %then %do; 
                        file "&workdir.\_newsurv_emf94.sasxreg";
                    %end;
                    %else %do;
                        file "&workdir./_newsurv_emf94.sasxreg";
                    %end;
                    put '[CORE\PRINTING\PRINTERS\EMF\ADVANCED]';
                    put '"Description"="Enhanced Metafile Format"';
                    put '"Metafile Type"="EMF"';
                    put '"Vector Alpha"=int:0';
                    put '"Image 32"=int:1';
                    run;    
                    %if %qupcase(&sysscp)=WIN %then %do; 
                        proc registry export="&workdir.\_newsurv_preexisting.sasxreg";/* Exports current SASUSER Keys */
                        proc registry import="&workdir.\_newsurv_emf94.sasxreg"; /* Import the new keys */
                        run;
                    %end;
                    %else %do;
                        proc registry export="&workdir./_newsurv_preexisting.sasxreg";/* Exports current SASUSER Keys */
                        proc registry import="&workdir./_newsurv_emf94.sasxreg"; /* Import the new keys */
                        run;
                    %end;
                %end;
                %else %do;
                    ods graphics / imagefmt=&plottype;  
                %end;
            %end;
            %else %if %qupcase(&plottype)=TIFF or %qupcase(&plottype)=TIF %then %do;
                ods graphics / imagefmt=png;    
            %end;
            %else %do;
                ods graphics / imagefmt=&plottype;  
            %end;          
        %end;
        %if %sysevalf(%superq(plotname)^=,boolean) %then %do; 
            ods graphics / reset=index imagename="&plotname";
        %end;  
        /**Turns on Scalable-Vector-Graphics**/
        %if &svg = 1 %then %do;
            %if %qupcase(&destination) = RTF or %qupcase(&destination) = EXCEL or %qupcase(&destination) = POWERPOINT %then %do;
                ods graphics / OUTPUTFMT=EMF;
            %end;
            %else %if %qupcase(&destination) = HTML %then %do;
                ods graphics / OUTPUTFMT=SVG;
            %end;
            %else %do;
                ods graphics / OUTPUTFMT=STATIC;
            %end;
        %end;
        
        /**Sets plot options**/
        ods graphics /  antialias antialiasmax=&antialiasmax scale=off width=&width height=&height;
        /**Generates the Plot**/
        options notes;
        ods select all;
        ods results;
        proc sgrender data=_plot template=_forest;
        run;
        %if &debug=0 %then %do; options nonotes; %end;
        %if &_listing^=1 %then %do;
            ods listing close;
        %end;
            
        /**Changes Potential Registry Changes back**/
        %if %qupcase(&plottype)=EMF or (&svg=1 and %qupcase(&destination)=RTF)
            or (&svg=1 and %qupcase(&destination)=EXCEL)
            or (&svg=1 and %qupcase(&destination)=POWERPOINT) %then %do;
            %if &sysver=9.4 and &transparent=0 and &_any_trans=0 %then %do;
                proc registry clearsasuser; /* Deletes the SASUSER directory */
                proc registry import="&workdir./_newsurv_preexisting.sasxreg";/* Imports starting SASUSER Keys */
                run;
            %end;
        %end;
        /**Creates the TIFF file from the PNG file created earlier**/
        %else %if %qupcase(&plottype)=TIFF or %qupcase(&plottype)=TIF %then %do;
            %local _fncheck _fncheck2;
            %if &debug=0 %then %do; options nonotes; %end;
            %if %sysevalf(%superq(gpath)=,boolean) %then %do;
                filename nsurvpng "./&plotname..png"; 
                filename nsurvtif "./&plotname..tiff";
                data _null_;
                    x=fexist('nsurvpng');
                    x2=fdelete('nsurvtif');
                    call symput('_fncheck',strip(put(x,12.)));
                    call symput('_fncheck2',strip(put(x2,12.)));
                run;
                %if %sysevalf(%superq(_fncheck)^=1,boolean) %then %do;
                    filename nsurvpng "./&plotname.1.png"; 
                %end;
            %end;
            %else %do;
                filename nsurvpng "%sysfunc(tranwrd(&gpath./&plotname..png,//,/))"; 
                filename nsurvtif "%sysfunc(tranwrd(&gpath./&plotname..tiff,//,/))"; 
                data _null_;
                    x=fexist('nsurvpng');
                    x2=fdelete('nsurvtif');
                    call symput('_fncheck',strip(put(x,12.)));
                    call symput('_fncheck2',strip(put(x2,12.)));
                run;
                %if %sysevalf(%superq(_fncheck)^=1,boolean) %then %do;
                    filename nsurvpng "%sysfunc(tranwrd(&gpath./&plotname.1.png,//,/))"; 
                %end;
            %end;
            options notes;
            goptions device=&tiffdevice gsfname=nsurvtif 
                xmax=&width ymax=&height 
                xpixels=%sysevalf(%sysfunc(compress(&width,abcdefghijklmnopqrstuvwxyz,i))*&dpi) 
                ypixels=%sysevalf(%sysfunc(compress(&height,abcdefghijklmnopqrstuvwxyz,i))*&dpi)
                imagestyle=fit iback=nsurvpng;
            proc gslide;
            run;
            quit; 
            data _null_;
                x=fdelete('nsurvpng');
            run;
            %if &debug=0 %then %do; options nonotes; %end;
            filename nsurvpng clear;
            filename nsurvtif clear;
        %end;
    %end;
    %if &show_table=1 %then %do;
        /**Design Report Table**/
        %if &debug=0 %then %do; options nonotes;  %end;
        ods path WORK.TEMPLAT(UPDATE) SASHELP.TMPLMST (READ);
        proc template;
            define style _analysistable;
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
                    fontfamily="&TABLEHEADERFAMILY" ;
                style Header /
                   color=black
                   backgroundcolor = white
                   bordercolor = white
                   borderstyle = none
                    fontfamily="&TABLEHEADERFAMILY" 
                    fontsize=&TABLEHEADERSIZE
                    fontweight=&TABLEHEADERWEIGHT;
                style Data /
                   color=black
                   backgroundcolor = white
                   bordercolor = white
                   borderstyle = none
                    fontfamily="&TABLEdataFAMILY" 
                    fontsize=&TABLEdataSIZE
                    fontweight=&TABLEdataWEIGHT;
            End;
            define style _analysistableppt;
                parent=styles.powerpointlight;
                class Header / 
                    background=white 
                    fontsize=&tableheadersize 
                    color=black 
                    fontfamily="&TABLEheaderfamily" 
                    fontweight=&TABLEheaderweight 
                    vjust=bottom 
                    borderstyle=solid 
                    bordercolor=black 
                    borderwidth=0.1 ;
                class Data / 
                    background=white 
                    fontsize=&tabledatasize 
                    color=black 
                    fontfamily="&TABLEdatafamily" 
                    fontweight=&TABLEdataweight 
                    vjust=top
                    borderstyle=hidden;
                class linecontent / 
                    background=white 
                    fontsize=&TABLEdatasize 
                    color=black 
                    fontfamily="TABLEdatafamily" 
                    fontweight=&TABLEdataweight
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
        run;
        %if %sysevalf(%superq(outdoc)^=,boolean) %then %do;
            ods &destination style=_analysistable;
        %end;
        proc sql noprint;
            %local _ppt _html _other _destinations _styles k pfoot_list _rtf;
            select max(ifn(upcase(destination) ^in('HTML' 'LISTING' 'OUTPUT' 'POWERPOINT' 'RTF'),1,0)),
                max(ifn(upcase(destination) in('HTML'),1,0)),
                max(ifn(upcase(destination) in('POWERPOINT'),1,0)),
                max(ifn(upcase(destination) in('RTF'),1,0))
                into :_other separated by '',:_html separated by '',:_ppt separated by '',:_rtf separated by '' from sashelp.vdest;
            select upcase(destination),upcase(style) into :_destinations separated by '|',:_styles separated by '|'
                from sashelp.vdest
                where upcase(destination)^in('OUTPUT' 'LISTING');
        quit;
        ods results;  
        ods select all;
        ods escapechar='^';
        %if &_listing = 1 %then %do;
            %do i = 1 %to %sysfunc(countw(%superq(_destinations),|));
                ods %scan(%superq(_destinations),&i,|) select none;
            %end;
            data _out_listing;
                set _table;
                array _chars_ (*) $2000. _character_;      
                do i = 1 to dim(_chars_);
                    _chars_(i)='A0A0A0'x||strip(_chars_(i));
                end;
                if subind>0 then subtitle=repeat('A0A0'x,subind-1)||strip(subtitle);
                if groupby_lvl=0 then call missing(groupby);
                %if %sysfunc(find(&table_display,PVAL,i))>0 %then %do;
                    drop 
                        %do c=1 %to &_columns;
                            pval_&c
                        %end;;
                    rename  
                        %do c=1 %to &_columns;
                            pval_listing_&c=pval_&c
                        %end;;
                %end;
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
                       
                %do j=1 %to %sysfunc(countw(%superq(table_display),%str( )));
                    %local headlength&j;
                    %if %sysfunc(find(%superq(_table_displayheader&j),`))>0 %then
                        %do k = 1 %to %sysfunc(countw(%superq(_table_displayheader&j),`,m));
                        %if &k=1 %then %let headlength&j=%length(%qscan(%superq(_table_displayheader&j),&k,`,m));
                        %else %let headlength&j=%sysfunc(max(&&headlength&j,%length(%qscan(%superq(_table_displayheader&j),&k,`,m))));
                    %end;
                    %else %let headlength&j=%length(%superq(_table_displayheader&j));
                    %if %qupcase(%scan(%superq(table_display),&j,%str( )))=PVAL and &npfoot=1 and &pfoot=1 %then %let headlength&j=%sysevalf(&&headlength&j+1);
                    %do i = 1 %to &_columns;
                        %let _list_%scan(%superq(table_display),&j,%str( ))_&i=%sysfunc(max(&&headlength&j,%superq(_list_%scan(%superq(table_display),&j,%str( ))_&i)));
                    %end;
                %end;
                %local _list_totlength _list_rowby_list_groupby;
                %let _list_totlength=0;
                %do i = 1 %to &_columns;
                    %local _list_c&i._totlength;
                    %if &i=1 %then %let _list_c&i._totlength=0;
                    %do j=1 %to %sysfunc(countw(%superq(table_display),%str( )));
                        %let _list_c&i._totlength=%sysevalf(2+&&_list_c&i._totlength+%superq(_list_%scan(%superq(table_display),&j,%str( ))_&i));
                    %end;           
                        
                    %let _list_totlength=%sysevalf(&&_list_c&i._totlength + &_list_totlength);                
                %end;
                
                %if %sysevalf(%superq(_rowby)=1,boolean) and %sysevalf(%qupcase(%superq(rowbytable_display))=SPAN,boolean) %then %do;                
                    %if %sysfunc(find(%superq(rowbylabel),`))>0 %then %do k = 1 %to %sysfunc(countw(%superq(rowbylabel),`,m));
                        %let _list_rowby=%sysfunc(max(&_list_rowby,%length(%qscan(%superq(rowbylabel),&k,`,m))));                        
                    %end;
                    %else %let _list_rowby=%sysfunc(max(%length(%superq(rowbylabel)),&_list_rowby));
                    %let _list_totlength=%sysevalf(&_list_rowby + &_list_totlength + 2);  
                %end;
                %if %sysevalf(%superq(_groupby)=1,boolean) %then %do;                
                    %if %sysfunc(find(%superq(groupbylabel),`))>0 %then %do k = 1 %to %sysfunc(countw(%superq(groupbylabel),`,m));
                        %let _list_groupby=%sysfunc(max(&_list_groupby,%length(%qscan(%superq(groupbylabel),&k,`,m))));                        
                    %end;
                    %else %let _list_groupby=%sysfunc(max(%length(%superq(groupbylabel)),&_list_groupby));
                    %let _list_totlength=%sysevalf(&_list_groupby + &_list_totlength + 2);  
                %end;
                %let _list_subtitle=%sysevalf(&_list_subtitle+2);
                %let _list_totlength=%sysevalf(&_list_totlength + &_list_subtitle);
                 
                alter table _out_listing
                    modify %do i = 1 %to %sysfunc(countw(%superq(_list_cvars),|,m)); 
                                %if &i>1 %then %do; , %end;
                                %scan(%superq(_list_cvars),&i,|,m) char(%superq(_list_%scan(%superq(_list_cvars),&i,|,m)))
                            %end;;  
            quit;
            options linesize=%sysfunc(max(64,%sysfunc(min(256,&_list_totlength)))) nocenter notes;
            proc report data=_out_listing nowd split='`' spanrows spacing=0 missing;
                columns
                    /**Adds title to top of summary table**/
                    ("%sysfunc(tranwrd(%superq(title),`,`))`%sysfunc(repeat(-,&_list_totlength-1))"
                    /**Used for sorting and distinguishing Models**/
                    (rowbylabel rowby_lvl rowby modelnum subind boldind shadeind subtitle groupby)
                        /*Start COLBY Label*/
                        %if %sysevalf(%superq(_colby)=1,boolean) and %sysevalf(%superq(colbylabelon)=1,boolean) %then %do;
                            ("&colbylabel"
                        %end;
                        %do k = 1 %to &_columns;  
                            /*Add a space between COLBY levels*/
                            %if &k>1 %then %do; 
                                 (dummy&k) 
                            %end;
                            /*Add Column level headers*/
                            %if %sysevalf(%superq(_colby)=1,boolean) %then %do;
                               ("%scan(%superq(_colbylevels),&k,|,m)`%sysfunc(repeat(-,&&_list_c&k._totlength-1))"
                            %end;   
                            /*table_display Variables*/
                            %do i = 1 %to %sysfunc(countw(%superq(table_display),%str( )));
                                %qupcase(%scan(%superq(table_display),&i,%str( ))_&k)
                            %end;    
                            /*Close COLBY header parenthases*/          
                            %if %sysevalf(%superq(_colby)=1,boolean) %then %do;
                               )
                            %end;
                        /*End k loop*/     
                        %end;  
                        /*Close COLBY Label parenthases*/          
                        %if %sysevalf(%superq(_colby)=1,boolean) and %sysevalf(%superq(colbylabelon)=1,boolean) %then %do;
                            )
                        %end;
                    /*Closes title parenthases*/    
                    );
            
                    define modelnum / order noprint;/**Used to keep models in order**/
                    define rowbylabel / order noprint;/**Used to keep rows in order**/
                    define rowby_lvl / order noprint;/**Used to keep rows in order**/
                    define rowby / order "&rowbylabel`%sysfunc(repeat(-,&_list_rowby-1))" 
                        %if %sysevalf(%superq(_rowby)=0,boolean) or %sysevalf(%qupcase(%superq(rowbytable_display))=SUBHEADERS,boolean) %then %do;
                            noprint;
                        %end;;/**Used to table_display rows groups**/
                    define groupby / display "&groupbylabel`%sysfunc(repeat(-,&_list_groupby-1))" 
                        %if %sysevalf(%superq(_groupby)=0,boolean) %then %do;
                            noprint;
                        %end;;/**Used to table_display rows groups**/
                    define subind / display noprint; /**Not Printed but defined**/
                    define boldind / display noprint;/**Used to determine font weight**/
                    define shadeind / display noprint;/**Used to determine row shading**/
                    %if %sysevalf(%superq(_rowby)=1,boolean) and %sysevalf(%qupcase(%superq(rowbytable_display))=SUBHEADERS,boolean) %then %do;
                        compute before rowby;
                            len=length(rowbylabel);
                            %if &rowbylabelon=1 %then %do;
                                line @1 rowbylabel $varying. len ': ' rowby $100.;
                            %end;
                            %else %do;
                                line @1 rowby $100.;
                            %end;
                            line @1 "%sysfunc(repeat(-,&_list_totlength-1))";
                                
                        endcomp;
                    %end;
                    %do k = 1 %to &_columns;  
                        %do i = 1 %to %sysfunc(countw(%superq(table_display),%str( )));
                            define %qupcase(%scan(%superq(table_display),&i,%str( ))_&k) / display center
                                %if %qupcase(%scan(%superq(table_display),&i,%str( )))^=PVAL or (&npfoot>1 and &pfoot=1) %then %do;
                                    "%superq(_table_displayheader&i)`%sysfunc(repeat(-,%superq(_list_%scan(%superq(table_display),&i,%str( ))_&k)-1))"
                                %end;
                                %else %if %qupcase(%scan(%superq(table_display),&i,%str( )))=PVAL and &npfoot=1 and &pfoot=1 %then %do;
                                    "%superq(_table_displayheader&i)*`%sysfunc(repeat(-,%superq(_list_%scan(%superq(table_display),&i,%str( ))_&k)-1))"
                                %end;;
                        %end;  
                        /*Sets up DUMMY variable to create space between column headers*/
                        %if &k>1 %then %do;
                            define dummy&k / computed " `%sysfunc(repeat(-,4-1))" width=4;
                        %end;
                    %end;
                    /*Subtitle*/
                    define subtitle / display "&subtitleheader`%sysfunc(repeat(-,&_list_subtitle-1))" id;
                    compute before modelnum;
                        /**Separate models with line**/
                        x="%sysfunc(repeat(-,&_list_totlength-1))";
                        %if &modellines=1 %then %do;
                            if ^missing(modelnum) then do;
                                if modelnum=1 then len=0;
                                else len=length(x);
                                line @1 x $varying. len;
                            end;
                        %end;
                        if ^missing(strip(tranwrd(rowby,'A0'x,''))) then len2=length(x);
                        else len2=0;
                        *line @1 x $varying. len2;                    
                    endcomp;
                    /**Creates the overall footnotes at the bottom of the table**/
                    compute after / style={just=l};
                        line @1 "%sysfunc(repeat(-,&_list_totlength-1))";
                        /**Creates footnotes with symbols based on which columns are requested with TABLEdisplay**/
                        %if &_pval=1 and &pfoot=1 %then %do;
                            line @1 %do i = 1 %to &npfoot; 
                                        "%sysfunc(repeat(*,&i-1))%sysfunc(strip(%superq(pfoot&i)));" 
                                    %end;; 
                        %end;  
                        /**Lists the table footnote**/
                        %do i = 1 %to %sysfunc(max(1,%sysfunc(countw(%superq(footnote),`,m))));
                            line @4 "%scan(%superq(footnote),&i,`,m) ";
                        %end;
                    endcomp;
            run;           
            options &_center nonotes;
            proc datasets nolist nodetails;
                %if &debug=0 %then %do;
                    delete _outldict _out_listing ;
                %end;
            quit;
            %if &debug=1 %then %do; options notes; %end;
            ods select all;
        %end;
        %if &_other = 1 or &_ppt = 1 or &_html=1 or &_rtf=1 or %sysevalf(%superq(outdoc)^=,boolean) %then %do;
            %if &_listing=1 %then %do;
                ODS LISTING CLOSE;
            %end;
            %do k = 1 %to %sysfunc(countw(%superq(_destinations),|));
                %if %sysevalf(%qupcase(%qscan(%superq(_destinations),&k,|))=POWERPOINT,boolean) %then %do;
                    ods powerpoint style=_analysistableppt;
                %end;
                %else %if %sysevalf(%qupcase(%qscan(%superq(_destinations),&k,|))=EXCEL,boolean) %then %do;
                    ods excel options(sheet_name="&excel_sheetname" 
                        frozen_rowheaders="%sysevalf(1+(%sysevalf(%superq(_rowby)=1,boolean) and %sysevalf(%qupcase(%superq(rowbytable_display))=SPAN,boolean)))"
                        frozen_headers="%sysevalf(%sysevalf(%superq(_colby)=1,boolean)*(1+&colbylabelon) + 2)") style=_analysistable;
                %end;
                %else %if %sysevalf(%qupcase(%qscan(%superq(_destinations),&k,|))^=RTF,boolean) %then %do;
                    ods %scan(%superq(_destinations),&k,|) style=_analysistable;
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
                    ods POWERPOINT  style=_analysistableppt;
                    %do k = 1 %to %sysfunc(countw(%superq(_destinations),|));
                        %if %sysevalf(%qupcase(%qscan(%superq(_destinations),&k,|))^=POWERPOINT,boolean) %then %do;
                            ods %scan(%superq(_destinations),&k,|) exclude all;
                        %end;
                    %end;
                %end;
                ods escapechar='^';
                %local _hbtmbrd _htwidth;
                %if %sysevalf(%scan(%superq(_rloop),&rloop,|)=RTF,boolean) %then %let _hbtmbrd=^S={borderbottomstyle=solid borderbottomwidth=0.1 borderbottomcolor=black};
                %else %let _hbtmbrd=;
                %if %sysevalf(%scan(%superq(_rloop),&rloop,|)=HTML,boolean) %then %let _htwidth=1;
                %else %let _htwidth=0.1;
                options notes;
                proc report data=_table nowd split='`' spanrows missing
                    %if %sysevalf(%scan(%superq(_rloop),&rloop,|)^=PPT,boolean) %then %do;
                        style(header)={%if %sysevalf(%scan(%superq(_rloop),&rloop,|)=HTML,boolean) %then %do; borderstyle=none %end;
                                       background=white fontsize=&tableheadersize color=black fontfamily="&tableheaderfamily" fontweight=&tableheaderweight vjust=bottom}
                        style(column)={%if %sysevalf(%scan(%superq(_rloop),&rloop,|)=HTML,boolean) %then %do; borderstyle=none %end;
                                       background=white fontsize=&tabledatasize color=black fontfamily="&tabledatafamily" fontweight=&tabledataweight vjust=top}
                        style(lines)={%if %sysevalf(%scan(%superq(_rloop),&rloop,|)=HTML,boolean) %then %do; borderstyle=none %end;
                                       background=white fontsize=&tabledatasize color=black fontfamily="&tabledatafamily" fontweight=&tabledataweight}
                        style(report)={%if %sysevalf(%scan(%superq(_rloop),&rloop,|)=HTML,boolean) %then %do; borderstyle=none %end;
                                       cellspacing=0 rules=groups frame=void cellpadding=0}
                    %end;;
                    
                    columns
                        (/**Used for sorting and distinguishing Models**/
                         rowbylabel rowby_lvl rowby modelnum subind boldind shadeind subtitle groupby)
                        /*Start COLBY Label*/
                        %if %sysevalf(%superq(_colby)=1,boolean) and %sysevalf(%superq(colbylabelon)=1,boolean) %then %do;
                            null=collabel, (
                        %end;
                            %do c = 1 %to &_columns;
                               /*Add a space between COLBY levels*/
                               %if &c>1 %then %do; 
                                    (null2=dummy&c) 
                               %end;
                               /*Add Column level headers*/
                               %if %sysevalf(%superq(_colby)=1,boolean) %then %do;
                                  null=colval&c,(
                               %end;   
                               /*table_display items*/    
                               %do i = 1 %to %sysfunc(countw(%superq(table_display),%str( )));
                                   %qupcase(%scan(%superq(table_display),&i,%str( ))_&c)
                               %end;    
                               /*Close COLBY header parenthases*/          
                               %if %sysevalf(%superq(_colby)=1,boolean) %then %do;
                                  )
                               %end;
                            /*End C loop*/     
                            %end;
                        /*Close COLBY Label parenthases*/          
                        %if %sysevalf(%superq(_colby)=1,boolean) and %sysevalf(%superq(colbylabelon)=1,boolean) %then %do;
                            )
                        %end; _last_;
                    
                    /*Last is for compute block*/
                    define _last_ / computed noprint;               
                    /*Subtitle*/
                    define subtitle / display "&_hbtmbrd.&subtitleheader" id
                        style(column)={cellwidth=&subtitlewidth leftmargin=0.05in} style(header)={just=left bordertopstyle=none};
                    /*Column By Headers*/
                    %if %sysevalf(%superq(_colby)=1,boolean) and %sysevalf(%superq(colbylabelon)=1,boolean) %then %do;
                        define collabel / across missing "&colbylabel"
                            style(header)={borderbottomstyle=none just=center};
                    %end;
                    %if %sysevalf(%superq(_colby)=1,boolean) %then %do c = 1 %to &_columns;
                        define colval&c / across missing "%scan(%superq(_colbylevels),&c,|,m)"
                            style(header)={borderbottomstyle=solid borderbottomwidth=&_htwidth borderbottomcolor=black just=center} ;
                    %end;
                    /*Set up indent for compute block*/  
                    define modelnum / order noprint;/**Used to keep models in order**/
                    define rowbylabel / order noprint;/**Used to keep rows in order**/
                    define rowby_lvl / order noprint;/**Used to keep rows in order**/
                    define rowby / order "&_hbtmbrd.&rowbylabel" style(column)={leftmargin=0.05in cellwidth=&rowbywidth} missing id
                        %if %sysevalf(%superq(_rowby)=0,boolean) or 
                            (%sysevalf(%superq(_rowby)=1,boolean) and %sysevalf(%qupcase(%superq(rowbytable_display))=SUBHEADERS,boolean)) %then %do;
                            noprint;
                        %end;;/**Used to display rows groups**/
                    define groupby / display "&_hbtmbrd.&groupbylabel" style(column)={cellwidth=&groupbywidth} missing id
                        %if %sysevalf(%superq(_groupby)=0,boolean) %then %do;
                            noprint;
                        %end;;/**Used to display groupby values**/
                    %if %sysevalf(%superq(_rowby)=1,boolean) and %sysevalf(%qupcase(%superq(rowbytable_display))=SUBHEADERS,boolean) %then %do;
                        compute before rowby / style={bordertopstyle=solid bordertopwidth=&_htwidth bordertopcolor=black 
                                                      borderbottomstyle=solid borderbottomwidth=&_htwidth borderbottomcolor=black
                                                      fontsize=&tableheadersize fontweight=&tableheaderweight fontfamily="&tableheaderfamily"};
                            len=length(rowbylabel);
                            line @1 %if &rowbylabelon=1 %then %do; rowbylabel $varying. len ': ' %end; rowby $100.;
                        endcomp;
                    %end;
                    define subind / display noprint; /**Not Printed but defined**/
                    define boldind / display noprint;/**Used to determine font weight**/
                    define shadeind / display noprint;/**Used to determine row shading**/
                    
                    %do k = 1 %to &_columns;  
                        %do i = 1 %to %sysfunc(countw(%superq(table_display),%str( )));
                            %if %sysfunc(find(%qupcase(%scan(%superq(table_display),&i,%str( ))_&k),KM_,i))>0 %then %do;
                                define %qupcase(%scan(%superq(table_display),&i,%str( ))_&k) / display center "&_hbtmbrd.%superq(_table_displayheader&i)"
                                    style={cellwidth=%superq(%sysfunc(compress(&&_table_display&i,0123456789))width)};
                            %end;
                            %else %do;
                                define %qupcase(%scan(%superq(table_display),&i,%str( ))_&k) / display center
                                    %if %qupcase(%scan(%superq(table_display),&i,%str( )))^=PVAL or (&npfoot>1 and &pfoot=1) %then %do;
                                        "&_hbtmbrd.%superq(_table_displayheader&i)"
                                    %end;
                                    %else %if %qupcase(%scan(%superq(table_display),&i,%str( )))=PVAL and &npfoot=1 and &pfoot=1 %then %do;
                                        "&_hbtmbrd.%superq(_table_displayheader&i)^{super 1}"
                                    %end;
                                    style={cellwidth=%superq(&&_table_display&i..width)};
                            %end;
                        %end;  
                        %if &k>1 %then %do;                
                            define dummy&k / display "&_hbtmbrd. " style(column)={cellwidth=0.1in };/**Used to make gap between columns**/                    
                        %end;
                    %end; 
                    /*Set up indents and shading with compute block*/
                   compute _last_;
                        count+1;                    
                        if count=1 and missing(rowby) then call define(_row_,'style/merge',"style={bordertopstyle=solid bordertopcolor=black bordertopwidth=&_htwidth}");
                        %if &shading=1 %then %do;
                            /**Creates alternating-shading using modulo arithmatic**/
                            if ^missing(rowby) then shade=0;
                            shade+1;
                            if mod(shade,2)=0 then call define(_row_, 'style/merge','style={background=GREYEF');
                        %end;
                        %else %if &shading^=1 %then %do;
                            /**Creates alternating-shading using modulo arithmatic**/
                            if shadeind=1 then call define(_row_, 'style/merge','style={background=GREYEF');
                        %end;
                        /**Creates an indented list of class levels using the subind variable**/
                        if boldind=1 then call define('subtitle','style/merge','style={fontweight=bold}');
                        %do i = 1 %to 6;
                            %if &i>1 %then %do; else %end;
                            %if %sysevalf(%scan(%superq(_rloop),&rloop,|)=RTF,boolean) %then %do;
                                if subind=&i then call define('subtitle','style/merge',"style={leftmargin=%sysevalf(0.12*&i)in}");
                            %end;
                            %else %do;
                                if subind=&i then call define('subtitle','style/merge',"style={indent=%sysevalf(0.12*&i)in}");
                            %end;
                        %end;
                        /**Separate models with line**/
                        %if &modellines=1 %then %do;
                            if ^missing(modelnum) then do;
                                if modelnum>1 then call define(_row_,'style/merge',"style={bordertopstyle=solid bordertopcolor=black bordertopwidth=&_htwidth}");
                            end;
                        %end;
                        if ^missing(rowby) then call define(_row_,'style/merge',"style={bordertopstyle=solid bordertopcolor=black bordertopwidth=&_htwidth}");
                    endcomp;
                    /*Print title before table*/
                    compute before _page_/ 
                        style={leftmargin=0.06in bordertopstyle=none borderbottomstyle=solid borderbottomwidth=&_htwidth borderbottomcolor=black
                               vjust=bottom fontsize=&tableheadersize fontweight=&tableheaderweight just=left color=black background=white};
                        %do i = 1 %to %sysfunc(max(1,%sysfunc(countw(%superq(title),`,m))));
                            line @1 "%scan(%superq(title),&i,`,m)";
                        %end;
                    endcomp;
                    /*Print p-values and footnotes after table*/
                    compute after / style={leftmargin=0.06in bordertopstyle=solid bordertopwidth=&_htwidth bordertopcolor=black vjust=top 
                                           fontsize=&&tablefootnotesize fontfamily="&tablefootnotefamily" fontweight=&tablefootnoteweight just=left color=black};
                       /*Prints p-value footnotes*/
                       %if &_pval=1 and &pfoot=1 %then %do;
                            line @1 %do i = 1 %to &npfoot; 
                                        "^{super &i}%sysfunc(strip(%superq(pfoot&i)));" 
                                    %end;; 
                        %end;  
                        /**Lists the table footnote**/
                        %if %sysevalf(%superq(footnote)=,boolean) =0 %then %do;
                            line @1 "&footnote";
                        %end;
                        %if (%sysevalf(%superq(_pval)^=1,boolean) or %sysevalf(%superq(pfoot)^=1,boolean)) and 
                            %sysevalf(%superq(footnote)=,boolean) %then %do;
                            line @1 ' ';
                        %end;
                   endcomp;
                run;  
                %if &debug=0 %then %do; options nonotes; %end;
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
        %if &debug=0 %then %do; options nonotes;  %end;
    %end;
    /**Closes the ODS file**/
    %if %sysevalf(%superq(outdoc)=,boolean)=0 %then %do;
        ods &destination close;
    %end;

    %if &debug=0 %then %do; options nonotes; %end;
    /*Output datasets*/
    %if %sysevalf(%superq(out_plot)^=,boolean) and &show_plot %then %do;
        data &out_plot;
            set _plot;
        run;
    %end;
    %if %sysevalf(%superq(out_table)^=,boolean) and &show_table %then %do;
        data &out_table;
            set _table;
        run;
    %end;
    
    %errhandl:
    %if %sysevalf(%superq(_data)^=,boolean) %then %let _data=%sysfunc(close(&_data));
    %if &_listing=1 %then %do;
        ODS LISTING;
    %end;
    %else %do;
        ODS LISTING CLOSE;
    %end;
    proc datasets nolist nodetails;
        %if &debug=0 %then %do;
            delete  _tempdsn_final _temp _combined _out _plot _table _ticks;
        %end;
    quit;
    ods select all;
    
    /**Reload previous Options**/ 
    ods path &_odspath;
    options mergenoby=&_mergenoby &_notes &_qlm linesize=&_linesize msglevel=&_msglevel;
    %put MVMODELS has finished processing, runtime: %sysfunc(putn(%sysevalf(%sysfunc(TIME())-&_starttime.),mmss8.4)); 
    
    %mend;
