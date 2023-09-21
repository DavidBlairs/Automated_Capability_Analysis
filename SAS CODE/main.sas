* Program for generating Capability Analysis Reports; 

%LET stem = Capability Analysis Generator; 
%LET Image_Loc = OUTPUT;

LIBNAME data "&stem.\SAS DATA";
%INCLUDE "capability.sas";

PROC IMPORT DATAFILE = "&stem.\RAW DATA\encoding.csv"
			OUT      = DATA.Encodings
			DBMS     = CSV
			REPLACE; 
RUN; 

DATA testing; 
	Set DATA.Example;
	index = 1;
RUN;


ODS POWERPOINT  File = "&Stem.\OUTPUT\slides.ppt" nogtitle nogfootnote;
	%pp_capability(Data_In = testing, Var_Con = Eurofins_Result_mg_100ml, Var_Cat = POSITION, Encode = DATA.Encodings, Output_Excel = "&STEM.\RAW DATA\figures.xlsx", LSL = 10, USL = 20 , Image_Loc = "&Image_Loc.", Main_Title = Vitamin Capability Results);
ODS POWERPOINT CLOSE;


