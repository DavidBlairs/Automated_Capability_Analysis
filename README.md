# Automated Capability Analysis
SAS macros to automate / simplify the process of capability analysis performed in SAS.

### SAS Code Documentation

This SAS code defines several functions for working with significant figures and reformatting numbers. Below is a summary of each function, the parameters they accept, and the output they provide:

#### `rndgt(x, sf)`

- **Description:** This function rounds a number `x` to the specified number of significant figures (`sf`).

- **Parameters:**
  - `x`: The number to be rounded.
  - `sf`: The desired number of significant figures.

- **Output:** The rounded number with `sf` significant figures.

#### `extsf(x)`

- **Description:** This function extracts significant digits from a number `x`.

- **Parameters:**
  - `x`: The number from which significant digits are to be extracted.

- **Output:** A character string representing the significant digits of `x`.

#### `sigFig(x, sf)`

- **Description:** This function displays a number `x` with the specified number of significant figures (`sf`) as a character string.

- **Parameters:**
  - `x`: The number to be displayed.
  - `sf`: The desired number of significant figures.

- **Output:** A character string representation of `x` with `sf` significant figures. Trailing zeros are added if necessary.

#### `re_format(x)`

- **Description:** This function reformats a number `x` by either returning the integer part of `x` if it has three or more digits or applying the `sigFig` function with three significant figures to `x` if it has fewer than three digits.

- **Parameters:**
  - `x`: The number to be reformatted.

- **Output:** The reformatted number.

#### `re_format_dataset(Data_In, Var)`

- **Description:** This macro reformats a dataset by applying formatting conditions to a specified variable.

- **Parameters:**
  - `Data_In`: The name of the input dataset to be reformatted.
  - `Var`: The name of the variable within the dataset to be reformatted.

- **Reformatting Logic:**
  - If the value of `Var` is greater than 0:
    - If `Var` is greater than or equal to 100, it is rounded down to the nearest integer using the `floor` function.
    - If `Var` is less than 100, it is reformatted to have three significant figures using the `SigFig` function.
  - If `Var` is exactly 0, it remains unchanged as 0.
  - If `Var` is less than 0:
    - If `Var` is less than or equal to -100, it is rounded up to the nearest integer using the `ceil` function.
    - If `Var` is greater than -100, it is reformatted to have three significant figures using the `SigFig` function while preserving its negative sign.

- **Output:** The dataset specified by `Data_In` is modified in place with the variable `Var` reformatted according to the specified conditions. The `Var` variable is also formatted using the `BEST.` format.

- **Usage:**
  To use this macro, call it by passing the name of the input dataset (`Data_In`) and the name of the variable to be reformatted (`Var`) as arguments.

  Example Usage:
  ```sas
  %re_format_dataset(MyData, MyVariable);
  ```
  
#### `Get_data(Data_In, Line_Loc, Var, Data_Out_Var)`

- **Description:** This macro retrieves the value from a specified cell in a dataset and assigns it to a macro variable.

- **Parameters:**
  - `Data_In`: The name of the dataset from which the value will be retrieved.
  - `Line_Loc`: The row index (observation number) of the cell from which the value will be retrieved.
  - `Var`: The column name (variable) of the cell from which the value will be retrieved.
  - `Data_Out_Var`: The name of the macro variable to which the retrieved value will be assigned.

- **Functionality:**
  - The macro initializes a global macro variable named `&Data_Out_Var` to hold the retrieved data.
  - It then reads through the dataset specified by `Data_In` and, when it reaches the row specified by `Line_Loc`, it assigns the value of the variable `Var` from that row to the macro variable `&Data_Out_Var`.
  - The assignment is done using the `symput` function, which assigns the value of `Var` to the macro variable named in `Data_Out_Var`.

- **Output:** The macro variable specified by `Data_Out_Var` will contain the value retrieved from the specified cell in the dataset.

- **Usage:**
  To use this macro, call it by passing the name of the input dataset (`Data_In`), the row index (`Line_Loc`), the column name (`Var`), and the name of the macro variable to store the data (`Data_Out_Var`).

  Example Usage:
  ```sas
  %Get_data(MyDataset, 3, MyVariable, OutputVariable);
  ```

  
#### `Check_Condition(Var, Out)`

- **Description:** This macro converts a numeric variable (`Var`) into a TRUE or FALSE condition and assigns the result to a macro variable (`Out`) based on a specified threshold.

- **Parameters:**
  - `Var`: The numeric variable to be evaluated.
  - `Out`: The name of the macro variable where the TRUE or FALSE condition will be stored.

- **Functionality:**
  - The macro initializes a global macro variable named `&Out` to hold the TRUE or FALSE condition.
  - It evaluates the value of the variable `Var` against the threshold of 1.33.
  - If `Var` is less than 1.33, it assigns the string "TRUE" to the macro variable `&Out`. Otherwise, it assigns "FALSE."

- **Output:** The macro variable specified by `Out` will contain either "TRUE" or "FALSE" based on whether the condition with the threshold was met.

- **Usage:**
  To use this macro, call it by passing the numeric variable (`Var`) that you want to evaluate and the name of the macro variable (`Out`) where the TRUE or FALSE condition will be stored.

  Example Usage:
  ```sas
  %Check_Condition(MyNumericVar, MyCondition);
  ```

#### `get_sentence(Data_In, Sentence_Loc, Data_Out_Var)`

- **Description:** This macro filters a dataset (`Data_In`) to retrieve a specific sentence identified by `Sentence_Loc` and stores it in a macro variable (`Data_Out_Var`).

- **Parameters:**
  - `Data_In`: The name of the dataset containing sentences.
  - `Sentence_Loc`: The location or identifier of the target sentence to retrieve.
  - `Data_Out_Var`: The name of the macro variable where the retrieved sentence will be stored.

- **Functionality:**
  - The macro creates a temporary dataset called `temp_sentence` by filtering the rows in `Data_In` where the variable `Sentence` matches the value of `Sentence_Loc`.
  - It then checks the number of observations (`NOBS`) in the `temp_sentence` dataset and initializes the macro variable `&Data_Out_Var` to an empty string.
  - If there are observations in the `temp_sentence` dataset (i.e., `NOBS > 0`), the macro retrieves the `Text` column from the first observation and stores it in the macro variable `&Data_Out_Var`.

- **Output:** The macro variable specified by `Data_Out_Var` will contain the retrieved sentence, or it will be an empty string if the specified sentence is not found in the dataset.

- **Usage:**
  To use this macro, call it by passing the name of the input dataset (`Data_In`), the identifier of the target sentence (`Sentence_Loc`), and the name of the macro variable (`Data_Out_Var`) where the retrieved sentence will be stored.

  Example Usage:
  ```sas
  %get_sentence(MyDataset, "Identifier123", MySentence);
  ```

#### `Histogram_Plot(Data_In, LSL, USL, Var_Con, Title_Label, Footnote, Image_Loc, Image_Name, DPI)`

- **Description:** This macro generates a histogram plot for a variable (`Var_Con`) in a dataset (`Data_In`) and includes control limits (`LSL` and `USL`) as reference lines. It allows customization of various plot settings.

- **Parameters:**
  - `Data_In`: The name of the dataset containing the variable to be plotted.
  - `LSL`: The Lower Specification Limit (control limit) for the variable.
  - `USL`: The Upper Specification Limit (control limit) for the variable.
  - `Var_Con`: The name of the variable to be plotted in the histogram.
  - `Title_Label`: The title to be displayed on the histogram plot.
  - `Footnote`: The footnote to be displayed on the histogram plot.
  - `Image_Loc`: The location where the generated plot image will be saved.
  - `Image_Name`: The name to be assigned to the generated plot image.
  - `DPI`: The resolution (Dots Per Inch) for the generated image.

- **Functionality:**
  - The macro sets ODS (Output Delivery System) options to control the output format and image quality.
  - It uses PROC MEANS to calculate summary statistics for the specified variable (`Var_Con`) and stores them in a table called `descriptive_table`.
  - The macro extracts the minimum (`Min`) and maximum (`Max`) values from the `descriptive_table` and assigns them to macro variables.
  - It determines suitable lower (`LOWER`) and upper (`UPPER`) limits for the x-axis based on the specified control limits (`LSL` and `USL`) and the minimum and maximum values.
  - Using PROC SGPLOT, the macro generates a histogram plot with the specified variable, fills the histogram bars with a specified color, adds reference lines for control limits, and customizes axis labels and settings.
  - The generated plot is saved as an HTML image with the specified resolution and filename.

- **Output:** The macro generates a histogram plot for the specified variable with control limits and saves it as an image in the specified location.

- **Usage:**
  To use this macro, call it by passing the necessary parameters, including the dataset name, variable name, control limits, plot title, and other customization options.

  Example Usage:
  ```sas
  %Histogram_Plot(MyDataset, 10, 30, MyVariable, "Histogram of MyVariable", "Footnote Text", "C:\Output\Images\", MyHistogram, 300);
  ```
  
#### `Histogram_Plot(Data_In, LSL, USL, Var_Con, Title_Label, Footnote, Image_Loc, Image_Name, DPI)`

- **Description:** This macro generates a histogram plot for a variable (`Var_Con`) in a dataset (`Data_In`) and includes control limits (`LSL` and `USL`) as reference lines. It allows customization of various plot settings.

- **Parameters:**
  - `Data_In`: The name of the dataset containing the variable to be plotted.
  - `LSL`: The Lower Specification Limit (control limit) for the variable.
  - `USL`: The Upper Specification Limit (control limit) for the variable.
  - `Var_Con`: The name of the variable to be plotted in the histogram.
  - `Title_Label`: The title to be displayed on the histogram plot.
  - `Footnote`: The footnote to be displayed on the histogram plot.
  - `Image_Loc`: The location where the generated plot image will be saved.
  - `Image_Name`: The name to be assigned to the generated plot image.
  - `DPI`: The resolution (Dots Per Inch) for the generated image.

- **Functionality:**
  - The macro sets ODS (Output Delivery System) options to control the output format and image quality.
  - It uses PROC MEANS to calculate summary statistics for the specified variable (`Var_Con`) and stores them in a table called `descriptive_table`.
  - The macro extracts the minimum (`Min`) and maximum (`Max`) values from the `descriptive_table` and assigns them to macro variables.
  - It determines suitable lower (`LOWER`) and upper (`UPPER`) limits for the x-axis based on the specified control limits (`LSL` and `USL`) and the minimum and maximum values.
  - Using PROC SGPLOT, the macro generates a histogram plot with the specified variable, fills the histogram bars with a specified color, adds reference lines for control limits, and customizes axis labels and settings.
  - The generated plot is saved as an HTML image with the specified resolution and filename.

- **Output:** The macro generates a histogram plot for the specified variable with control limits and saves it as an image in the specified location.

- **Usage:**
  To use this macro, call it by passing the necessary parameters, including the dataset name, variable name, control limits, plot title, and other customization options.

  Example Usage:
  ```sas
  %Histogram_Plot(MyDataset, 10, 30, MyVariable, "Histogram of MyVariable", "Footnote Text", "C:\Output\Images\", MyHistogram, 300);
  ```

#### `Generate_difference(Ordered_Difference, p_value, vlabel)`

- **Description:** This macro generates a sentence summarizing the results of an ANOVA analysis, including the p-value and whether it is below or above a significance level (e.g., 0.05).

- **Parameters:**
  - `Ordered_Difference`: The name of the dataset containing differences between groups.
  - `p_value`: The p-value resulting from the ANOVA analysis.
  - `vlabel`: A label or description of the variable being analyzed.

- **Functionality:**
  - The macro first handles the p-value formatting. If the p-value is "<.0001," it is converted to "0.0001." Otherwise, it is converted to a numeric value using the `INPUT` function.
  - It then constructs an initial sentence (`Current_State`) describing the ANOVA analysis and the variable of interest (`vlabel`) with a placeholder for the p-value.
  - Based on whether the p-value is less than 0.05, the macro determines whether to state that the p-value is "below" or "above" a significance level.
  - The `Ordered_Difference` dataset is processed to handle p-value formatting and to create a new variable called `Statement` that describes the positions being compared in the ANOVA.
  - Depending on the p-value condition, the `Current_State` sentence is updated to include "below" or "above" significance.

- **Output:** The macro updates the `Current_State` sentence to describe the ANOVA results, including whether the p-value is below or above a significance level.

- **Usage:**
  To use this macro, call it by passing the necessary parameters, including the dataset name containing differences between groups (`Ordered_Difference`), the p-value, and a label for the variable being analyzed (`vlabel`).

  Example Usage:
  ```sas
  %Generate_difference(MyDifferences, 0.0001, "MyVariable");
  ```

#### `pp_capability(Data_In, Var_Con, Var_Cat, Image_Loc, Output_Excel, Threshold, LSL, USL, Encode, units = mg/100ml, Main_Title = Capability Results)`

- **Description:** This macro generates a PowerPoint slide prototype for displaying capability analysis results, including histograms, box plots, descriptive statistics, and textual information.

- **Parameters:**
  - `Data_In`: The name of the dataset containing the analysis data.
  - `Var_Con`: The continuous variable of interest.
  - `Var_Cat`: The categorical variable for grouping.
  - `Image_Loc`: The location where generated images will be saved.
  - `Output_Excel`: The name of the Excel file containing analysis results.
  - `Threshold`: The threshold for significance.
  - `LSL`: The Lower Specification Limit.
  - `USL`: The Upper Specification Limit.
  - `Encode`: A dataset containing encoding for text replacement.
  - `units`: Units of measurement for the variable (default: "mg/100ml").
  - `Main_Title`: The main title for the slide (default: "Capability Results").

- **Functionality:**
  - The macro starts by setting up the output environment for PowerPoint and importing relevant data.
  - It prepares the data for analysis and retrieves necessary values for generating the slide.
  - Descriptive statistics, histograms, and box plots are generated and saved as images.
  - The ANOVA analysis is run, and p-values and differences are retrieved.
  - Text replacement is performed based on encoding provided in the `Encode` dataset.
  - The slide layout is designed with titles, text, tables, and images, and all elements are placed on the slide as per the prototype design.

- **Output:** The macro generates a PowerPoint slide prototype with various elements, including images, tables, and text, to display capability analysis results.

- **Usage:**
  To use this macro, call it by passing the necessary parameters, including the dataset name, variable names, and other customization options.

  Example Usage:
  ```sas
  %pp_capability(MyData, Measurement, Group, "C:\Output\Images\", "AnalysisResults.xlsx", 0.05, 10, 30, EncodeData, "mg/100ml", "Capability Analysis");
  ```
