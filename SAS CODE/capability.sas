* Program for generating Capability Analysis Reports; 

/*
Establish some global functions (for use on sig fig)
Main function: SigFig(x, n) returns x to n significant figures. 

source: https://communities.sas.com/t5/SAS-Programming/Significant-Figure/td-p/451800

*/
PROC FCMP outlib = Work.func.format; 
	* Round to the specified digit according to significant figure; 
	function rndgt(x, sf);
		I = if x < 1 then 0 else 1; 
		rd = int(log10(x)) - sf + I; 
		
		return(round(x, 10**rd));
	endsub; 
	
	* Extract significant digits from a number; 
	function extsf(x) $30; 
		attrib sfc length = $30; 
		xcx = compress(put(x, BEST30.)); 

		sfc=prxchange("s/\.//", -1, xc); /* Eliminate decimal point */
    	sfc=prxchange("s/0*([1-9][0-9]*)/$1/", -1, sfc); /* Eliminate leading 0's */

		return(sfc);
	endsub; 

	* Show significant figure result as a Char. ;  
	function sigFig(x, sf) $30; 
	    attrib sfc length=$30;  
	    * 1. Round number ;
	    xr=rndgt(x, sf); /* Rounding result */
	    xrc=compress(put(xr, BEST30.)); /* Char. of xr */

	    * 2. Adding trailing 0s ;
	    n0=sf - length(extsf(xr)); /* Number of adding 0s */

	    if n0 > 0 then do; /* The case we need to add 0s */
	      zeros=repeat("0", n0 - 1); /* zeros we add*/
	      out=if index(xrc, ".") then cats(xrc, zeros)
	        else cats(xrc, ".", zeros); /* For integer, adding decimal point */
	    end;
	    else out=xrc;
	    return(out);
		endsub;

	*reformating function; 
	function re_format(x);	
	  	integer = floor(x);
		digits = floor(log10(x)) + 1;

		out = if digits >= 3 then integer 
			  else SigFig(x, 3); 
		return(out);
	endsub;
  
options cmplib = Work.func.format;

* Re fomat dataset with conditions; 
%MACRO re_format_dataset(Data_In, Var); 
	DATA &Data_In.; 
		Set &Data_In.;
		
		if &Var. > 0 then do;
			if &Var. >= 100 then &Var. = floor(&Var.);
			else &Var. = SigFig(&Var., 3);
		End; 
		Else if &Var. = 0 then do;
			&Var. = 0; 
		End;
		Else do;
			if &Var. <= -100 then &Var. = ceil(&Var.);
			else &Var. = -SigFig(-&Var., 3);
		End;
		

		Format &Var. BEST.;
	RUN;
%MEND;


/*
Macro to assign a cell of a dataset to a macro variable. 
source: http://www.dataminingblog.com/sas-macro-how-to-retrieve-a-value-from-a-dataset/

Data_In     : The dataset with the value. 
Line_Loc    : row index of the cell. 
Var         : column of the cell. 
Data_Out_Var: Macro variable to send the data. 
*/
%MACRO Get_data(Data_In, Line_Loc, Var, Data_Out_Var);
	%GLOBAL &Data_Out_Var.;
	DATA _null_;
		Set &Data_In.;

		If _N_ = &Line_Loc. then do;
			Call symput(symget('Data_Out_Var'), &Var.);
		End;
	RUN;
%MEND Get_data;

* convert number to TRUE FALSE condition; 
%MACRO Check_Condition(Var, Out);
	%GLOBAL &Out.;
	DATA _null_;
		If &Var. < 1.33 Then 
			do;
				Call symput(symget("Out"), "TRUE");
			end;
		Else
			do; 
				Call symput(symget("Out"), "FALSE");
			end; 
	RUN;
%MEND; 

* filter and retrieve the sentence; 
%MACRO get_sentence(Data_In, Sentence_Loc, Data_Out_Var);
	%GLOBAL &Data_Out_Var.; 
	DATA temp_sentence;
		Set &Data_In.; 
		Where Sentence = &Sentence_Loc.; 
	RUN;

	%let DSID = %sysfunc(OPEN(temp_sentence,IN));
    %let NOBS = %sysfunc(ATTRN(&DSID.,NOBS));
    %let RC   = %sysfunc(CLOSE(&DSID.));

	%PUT &NOBS.;
	
	DATA _null_;
		Call symputx(symget('Data_Out_Var'), ""); 
	RUN;

	%If &NOBS. > 0 %Then %Do;
		DATA _null_;
			Set temp_sentence;
			Call symputx(symget("Data_Out_Var"), Text);
		RUN;
	%End;  
%MEND; 

* Generate histogram; 
%MACRO Histogram_Plot(Data_In, LSL, USL, Var_Con, Title_Label, Footnote, Image_Loc, Image_Name, DPI);
	ODS HTML image_dpi = &DPI. gpath = &Image_Loc.;
	ODS GRAPHICS ON / width=8cm height=6cm reset=index imagename="HIST_&Var_Con._&Image_Name.";

	PROC MEANS Data = &Data_In.; 
		Var &Var_Con.; 
		Output Out = descriptive_table; 
	RUN;

	DATA _null_;
		Set descriptive_table; 
		Call symputx(_STAT_, &Var_Con.);
	RUN; 

	DATA _null_; 
		If &LSL. < &Min. then Call symputx("LOWER", &LSL. - 5);
		Else Call symputx("LOWER", &Min. - 5);

		If &USL. > &Min. then Call symputx("UPPER", &USL. + 5); 
		Else Call symputx("UPPER", &Max. + 5);
	RUN;

	PROC SGPLOT data = &Data_In.;
		Histogram &Var_Con. / fillattrs=(color = CXb6c98f);
		Refline &LSL. &USL. / Axis = x lineattrs = (thickness = 3 color = black pattern = dash) label = ("Lower Limit" "Upper Limit");
		xAxis Label = "&Title_Label." Min = &LOWER. Max = &UPPER.;
		yAxis Display = (nolabel);
	RUN;

	TITLE;
	FOOTNOTE;
%MEND; 

* Generate boxplot; 
%MACRO Box_Plot(Data_In, LSL, USL, Var_Con, Var_Cat, Title_Label, Image_Loc, Image_Name, DPI);
	ODS HTML image_dpi = &DPI. gpath = &Image_Loc.;
	ODS GRAPHICS ON / width=16cm height=12cm reset=index imagename="BOX_&Var_Con._&Image_Name.";

	PROC MEANS Data = &Data_In.; 
		Var &Var_Con.; 
		Output Out = descriptive_table; 
	RUN;

	DATA _null_;
		Set descriptive_table; 
		Call symputx(_STAT_, &Var_Con.);
	RUN; 

	DATA _null_; 
		If &LSL. < &Min. then Call symputx("LOWER", &LSL. - 5);
		Else Call symputx("LOWER", &Min. - 5);

		If &USL. > &Min. then Call symputx("UPPER", &USL. + 5); 
		Else Call symputx("UPPER", &Max. + 5);
	RUN;

	PROC SGPLOT Data = &Data_In.;
		Hbox &Var_Con. / category = &Var_Cat. medianattrs = (color = blue) meanattrs = (color = white) whiskerattrs = (color = blue) fillattrs = (color = white) lineattrs = (color = blue);
		Refline &LSL. &USL. / axis = x lineattrs = (thickness = 3 color = black pattern = dash) label = ("Lower Limit" "Upper Limit");
		xAxis Label = "&Title_Label." Min = &LOWER. Max = &UPPER.;
	RUN;

	TITLE;
	FOOTNOTE;
%MEND; 

* Generate a sentence of the anova;
%MACRO Generate_difference(Ordered_Difference, p_value, vlabel);
	DATA _null_; 
		If &p_value. = "<.0001" then do; 
			Call symputx("p_overall", 0.0001);
		End; 
		Else do; 
			Call symputx("p_overall", INPUT(&p_value., 20.));
		End;

		Call symputx("Current_State", CAT("An analysis of the variation between START, MIDDLE and END resulted in a p-value for ", &vlabel., " being "));
		
		If &p_overall. < 0.05 then Call symput("Cond_Overall", "TRUE");
		Else Call symput("Cond_Overall", "FALSE");
	RUN;

	%PUT &Cond_Overall.;

	DATA _&Ordered_Difference.; 
		Set &Ordered_Difference.;
		If Probt = "<.0001" then Probt = "0"; 
	RUN;

	DATA _&Ordered_Difference.; 
		Set _&Ordered_Difference.;
		P_value = INPUT(Probt, 10.);

		If P_Value = . then P_Value = 0; 
		
		Statement = TRANWRD(CATS(Position, "_and_", _Position), "_", " ");
	RUN;	

	DATA _null_; 
		If &Cond_Overall. = "TRUE" then do; 
			Call symputx("Current_State", CAT("&Current_State.", " below "));
		End; 
		Else Do; 
			Call symputx("Current_State", CAT("&Current_State.", " above "));
		End;
	RUN;

	%Put &Current_State.;
%MEND;

%Generate_difference(Ordered_Difference = Diff_lsmeans, p_value = "0.005", vlabel = "vitamin");

/* 
Macro to generate a capability slide (prototype)
*/
%MACRO pp_capability(Data_In, Var_Con, Var_Cat, Image_Loc, Output_Excel, Threshold, LSL, USL, Encode, units = mg/100ml, Main_Title = Capability Results);
	ODS POWERPOINT EXCLUDE ALL;

	* Strip down the data; 
	DATA cap_temp;
		Set &Data_In.(keep = &Var_Con.);
	RUN;

	* Run the analysis and retrieve relevant output; 
	PROC IMPORT DATAFILE = &Output_Excel. OUT = cap_Indices DBMS = xlsx REPLACE;
  		SHEET = "capability";
	RUN;
	PROC IMPORT DATAFILE = &Output_Excel. OUT = cap_specifications DBMS = xlsx REPLACE;
  		SHEET = "percentages";
	RUN;

	* Find all relevant values to create conditions; 
	* re format the numbers tables; 
	%re_format_dataset(Data_In = Cap_Specifications, Var = Percent_Value); 

	%re_format_dataset(Data_In = Cap_Indices, Var = Value_Of_Capability); 
	%re_format_dataset(Data_In = Cap_Indices, Var = Lower_95_); 
	%re_format_dataset(Data_In = Cap_Indices, Var = Upper_95_); 

	* Start with CPL and CPU + confidence interval; 
	%Get_data(Data_In = Cap_indices, Line_Loc = 2, Var = Value_Of_Capability, Data_Out_Var = CPL)
	%Get_data(Data_In = Cap_indices, Line_Loc = 2, Var = Lower_95_, Data_Out_Var = CPL_Lower)

	%Get_data(Data_In = Cap_indices, Line_Loc = 3, Var = Value_Of_Capability, Data_Out_Var = CPU)
	%Get_data(Data_In = Cap_indices, Line_Loc = 3, Var = Lower_95_, Data_Out_Var = CPU_Lower)

	* Amount above and below; 
	%Get_data(Data_In = Cap_specifications, Line_Loc = 1, Var = Percent_Value, Data_Out_Var = CPL_BELOW_PERCENT)
	%Get_data(Data_In = Cap_specifications, Line_Loc = 3, Var = Percent_Value, Data_Out_Var = CPU_ABOVE_PERCENT)
	
	DATA _null_;
		Call symput("CPL_BELOW_ABS", &CPL_BELOW_PERCENT. * 10000);
		Call symput("CPU_ABOVE_ABS", &CPU_ABOVE_PERCENT. * 10000);

		Call symput("Image_Title", RAND("Integer", 1, 2147483646));
		Call symput("Box_Title",   RAND("Integer", 1, 2147483646));
	RUN; 

	%Check_Condition(&CPL., CPL133);
	%Check_Condition(&CPU., CPU133);
	%Check_Condition(&CPL_Lower., CPLLOWER133);
	%Check_Condition(&CPU_Lower., CPULOWER133);

	* Replace in the temp encodings; 
	DATA fufilled_encodings; 
		Set &Encode.; 

		Where
			CPL___1_33 = "&CPL133." AND      
			CPU___1_33 = "&CPU133." AND     
			CPL_LOWER___1_33 = "&CPLLOWER133." AND
			CPU_LOWER___1_33 = "&CPULOWER133.";
		
		Text = TRANWRD(TRANWRD(TRANWRD(TRANWRD(TRANWRD(TRANWRD(TRANWRD(TRANWRD(TRANWRD(TRANWRD(TRANWRD(Text,
			  "[CPU-ABOVE-PERCENT]", "&CPU_Above_Percent."),
			  "[CPU-ABOVE-ABS]", "&CPU_Above_Abs."),
			  "[CPL-BELOW-PERCENT]", "&CPL_Below_Percent."),
			  "[CPL-BELOW-ABS]", "&CPL_Below_Abs."),
			  "[CPL-Lower]", "&CPL_Lower."),
			  "[CPU-Lower]", "&CPU_Lower."), 
			  "[CPU]", "&CPU."), 
			  "[CPL]", "&CPL."),
			  "(        ", "("),
			  "        ", " "),
			  "       ", " ");
	RUN;

	* assign text to sentence macro variables; 
	%get_sentence(Data_In = fufilled_encodings, Sentence_Loc = 1, Data_Out_Var = Sentence_1);
	%get_sentence(Data_In = fufilled_encodings, Sentence_Loc = 2, Data_Out_Var = Sentence_2);
	%get_sentence(Data_In = fufilled_encodings, Sentence_Loc = 3, Data_Out_Var = Sentence_3);

	* setup the histogram;
	DATA _null_;
		Set &Data_In.(obs = 1);
		Call symputx("HIST_TITLE", vlabel(&Var_Con.));
	RUN;

	%Histogram_Plot(Data_In = &Data_In., LSL = &LSL., USL = &USL., Var_Con = &Var_Con., Title_Label = &HIST_TITLE., Footnote = "1.1 Histogram showing capability", Image_Loc = &Image_Loc., Image_Name = &Image_Title., DPI = 200);
	%Box_Plot(Data_In = &Data_In., LSL = &LSL., USL = &USL., Var_Con = &Var_Con., Var_Cat = &Var_Cat., Title_Label = &HIST_TITLE., Image_Loc = &Image_Loc., Image_Name = &Box_Title., DPI = 200);
	DATA _null_;
		Call symput("HIST_LOC", CATS(&Image_Loc., COMPRESS("\\HIST_&Var_Con._&Image_Title..png")));
		Call symput("BOX_LOC" , CATS(&Image_Loc., COMPRESS("\\BOX_&Var_Con._&Box_Title..png")));
	RUN;

	*run the anova; 
	ODS OUTPUT Tests3 = type_3_tests Diffs = diff_lsmeans;
	PROC MIXED Data = &Data_In.; 
		Class &Var_Cat.;
		Model &Var_Con. = &Var_Cat.;
		Lsmeans &Var_Cat. / diff;
	RUN;
	
	*assign values;
	%Get_data(Data_In = type_3_tests, Line_Loc = 1, Var = ProbF, Data_Out_Var = p_overall);
	
/*	%Generate_difference(Ordered_Difference = diff_lsmeans, p_value = p_overall);*/

	* Generate the document; 
	TITLE;
	FOOTNOTE;

	ODS SELECT ALL;
	ODS ESCAPECHAR = "^";

	OPTIONS papersize = (10in 5.63in); 
	OPTIONS nodate nonumber; 

	ODS LAYOUT GRIDDED rows = 1 columns = 2 column_widths=(47% 47%) column_gutter=1pct;
		ODS REGION;
			ODS TEXT = "^{style [font_size=30pt color = CX6ba8c9 fontfamily = Calibri] &Main_Title.}";
		ODS REGION;
			PROC ODSTEXT;
				p "Lower Legal Limit: &LSL. &units.^{newline} Upper Limit: &USL. &units. " / style = {just = r font_size = 14pt fontfamily = Calibri};
			RUN;
	ODS LAYOUT END;

	ODS LAYOUT GRIDDED rows = 1 columns = 1 column_widths=(98%) column_gutter = 1pct; 
		ODS REGION;
			PROC ODSLIST;
				Item "^{style [font_size = 12pt fontfamily = Calibri] &Sentence_1.}";
				Item "^{style [font_size = 12pt fontfamily = Calibri] &Sentence_2.}";
				Item "^{style [font_size = 12pt fontfamily = Calibri] &Sentence_3.}";
			RUN;
	ODS LAYOUT END;	

	ODS LAYOUT GRIDDED rows = 1 columns = 2 column_widths=(47% 47%) column_gutter = 1pct;
		ODS REGION;
			ODS TEXT = "^{newline 2}";
			PROC PRINT Data = cap_indices(Drop = VarName) label noobs;
				Label Capability          = "Capability"
					  Value_Of_Capability = "Index"
					  Lower_95_           = "Lower CI"
					  Upper_95_           = "Upper CI"; 
				Var Capability          / style = [cellwidth = 2cm backgroundcolor = CXa3c9d1 fontfamily = Calibri font_size = 10pt];
				Var Value_Of_Capability / style = [cellwidth = 2cm backgroundcolor = CXa3c9d1 fontfamily = Calibri font_size = 10pt];
				Var Lower_95_           / style = [cellwidth = 2cm backgroundcolor = CXa3c9d1 fontfamily = Calibri font_size = 10pt];
				Var Upper_95_           / style = [cellwidth = 2cm backgroundcolor = CXa3c9d1 fontfamily = Calibri font_size = 10pt];
			RUN;
		ODS REGION;
			PROC REPORT Data = SASHELP.Class(keep = Name) Style(Report)={preimage = "&HIST_LOC." bordercolor = black};
				Define Name / order noprint; 
			RUN;
	ODS LAYOUT END;
	ODS POWERPOINT STARTPAGE = NOW;
%MEND; 
