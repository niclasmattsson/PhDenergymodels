# GET-Climate
 
A version of the GET (Global Energy Transition) energy system model with a hard-linked climate module. Requires GAMS, CPLEX and CONOPT (tested with GAMS 23.8).

## Run the model

Go to the model folder, start GAMS and run GETstart_tc2010.gms.

```
C:\Stuff\models>cd "GET-Climate"

C:\Stuff\models\GET-Climate>gams GETstart_tc2010.gms

```

You may see "optimal solution" flash by quickly in the solution log, but this is just some initial calibration of the climate module and a linear presolve of the energy model. The entire run with default settings should finish in 5-10 minutes on a reasonably fast computer.

To inspect the energy model, start in `GET_7.gms`. Most of the climate module is in `climate-Joos-UDEBM-feedback-tc2010-implicit`.

## Results file

Open latestresults.xlsx to examine the model results.
