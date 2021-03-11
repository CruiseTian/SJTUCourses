## Installation

For the installation of the Quanser robot simulation environment, please see [this page](https://git.ias.informatik.tu-darmstadt.de/quanser/clients)

For the implementation of the algorithms, the following packages are required:

+ python = 3.6.2
+ pytorch = 1.0.1
+ numpy = 1.12.1
+ matplotlib = 2.1.1
+ gym

You can simply create the same environment as ours by using [Anaconda](https://www.anaconda.com/).
All the required packages are included in the ```environment.yaml``` file. You can create the environment by the following command

```angular2html
conda env create -f environment.yaml
```

Then, activate your environment by

```
source activate pytorch
```
 
## How to run

1. Choose the algorithm you want to use and change to the corresponding folder (DQN or MPC)
2. Choose the environment you want to evaluate and change to the folder (CartPoleStab, Double, Qube or Swing)
3. Change the configuration file ```config.yml``` to the parameters you want, and follow the instructions in the folder
