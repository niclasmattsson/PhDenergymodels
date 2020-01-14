# PhDenergymodels
 
Energy system models used in [my PhD thesis](https://research.chalmers.se/en/publication/?id=514513).

## Contents

Each model is in its own subfolder, with a README that briefly demonstrates how to run the model.

* **Genie** - The GENIE energy system model - a demonstration model with piecewise linear experience curves.
* **Stokgenie** - A version of the GENIE experience curve energy model with stochastic programming of learning rate uncertainty.
* **GET-Climate** - A version of the GET (Global Energy Transition) energy system model with a hard-linked climate module.
* **GET - resource slices** - A version of the GET energy system model with resource-based slicing. 

The code belonging to paper 5 of my thesis is in two other repositories: [https://github.com/niclasmattsson/GlobalEnergyGIS](GlobalEnergyGIS) and [https://github.com/niclasmattsson/Supergrid](Supergrid).

Please note that the models are quite messy and mostly undocumented. The main reason for publishing them here is to allow the grading committee to inspect them beforehand. Also, I believe that model-based studies should always have its underlying code published, even if the code may be hard to follow. 
