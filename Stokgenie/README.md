# Stochastic GENIE
 
A version of the GENIE experience curve energy model with stochastic programming of learning rate uncertainty. Requires Ampl and CPLEX.

## Run the model

Go to the model folder, start Ampl and run `stokgenie.run` to run a case with 50% probability of both high fuel cell learning rates and high solar PV learning rates. Run `superscript.run` to iterate 49 runs with varying probabilities of high learning rates.

```
C:\Stuff\models>cd Stokgenie

C:\Stuff\models\Stokgenie>ampl stokgenie.run

C:\Stuff\models\Stokgenie>ampl superscript.run

```

Most runs should complete in less than a minute, although some may require a few minutes.

## Results

Results (numerical tables) are dumped to the console and copied to log files (\*.log), or to `superout.txt` for a summary of the iterative runs.
