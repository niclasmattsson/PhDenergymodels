# GET - Resource slicing
 
A version of the GET (Global Energy Transition) energy system model with resource-based slicing. Requires GAMS and CPLEX (tested with GAMS 23.8).

## Setup

* Edit lines 69-70 of sets.gms to set the number of solar and wind slices.
* Make a copy of the file called "GISoutput2015 NxN.xlsx" with the corresponding number of slices, and call it "GISoutput.xlsx" (delete any existing file with this name).
* Make a copy of the file called "results - template.xlsx", and call it "results.xlsx" (delete any existing file with this name).

Finally ensure that Excel is not running (or no output files will be produced).

## Run the model

Go to the model folder, start GAMS and run GET_7.gms.

```
C:\Stuff\models>cd "GET - resource slices"

C:\Stuff\models\GET - resource slices>gams GET_7.gms

```

A run with 3x3 slices should finish in 2-3 minutes on a reasonably fast computer.

## Results file

Open results.xlsx to examine the model results. Electricity generation in each region, slice and model year can be found in the worksheet "El sliced graphs". You can change cells K28 and L28 to switch region and year (2050, 2070 and 2100 only).
