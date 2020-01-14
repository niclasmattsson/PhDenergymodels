# GENIE
 
The GENIE energy system model - a demonstration model with piecewise linear experience curves. Requires Ampl and CPLEX.

## Run the model

Go to the model folder, start Ampl and run `genie.run`.

```
C:\Stuff\models>cd Genie

C:\Stuff\models\Genie>ampl genie.run

```

This should find a globally optimal solution in less than 30 seconds on a fast computer. Run `genie_altcase.run` to find an alternative locally optimal solution without solar PV or fuel cells.

## Results

Results (numerical tables) are dumped to the console and copied to log files (\*.log). 
