## Directory Structure 

│  Project.pdf  
│  README.md  
└─code  
	│  `binary.m`  
	│  `Binaryp.m `  
	│  `fixwinpbinary.m`   
    │  `movewinbinary.m  `   
    │  `NC_012920_1.fasta`   
    │  `NC_012920_1_cds.txt`   
    │  `real.m`   
    │  `Realp.m`   
    │  `voss.m`   
    │  `vossp.m`   
    │  `zcurve.m`   
    │  `Zcurvep.m`        

**Project.pdf** is the experiment report.  
**`NC*`** is the source file of the input DNA sequence.  
**`*p.m`** is the file used to obtain the power spectrum of different mapping schemes, for example, `vossp.m` is the file used to obtain the power spectrum of Voss mapping.    
**`fixwinpbinary.m`** is the implementation of Fixed length sliding window algorithm, and **`movewinbinary.m `** is the implementation of Moving sequence algorithm.

## How to Run

Just run the corresponding **`*p.m`** file and you can get the power spectrum image of the corresponding mapping scheme.   
Run **`fixwinpbinary.m`** to get the result of gene detection using the Fixed length sliding window algorithm.  
And run **`movewinbinary.m `** to get the result of gene detection using the Moving sequence algorithm.
