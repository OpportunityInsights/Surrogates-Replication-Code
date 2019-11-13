# Replication Code for "The Surrogate Index: Combining Short-Term Proxies to Estimate Long-Term Treatment Effects More Rapidly and Precisely"
This code replicates the application to the GAIN job training program in 
[Athey, Chetty, Imbens and Kang (2019)](https://opportunityinsights.org/wp-content/uploads/2019/11/surrogate_paper.pdf "Full Paper"), using a simulated dataset of employment outcomes. 

The code can be run directly from **_Surrogates Metafile.do_** by setting the global ${surrogates} to point to  this repository. 

Alternatively, each file in the folder **_Code_** can be run individually. 
The main .do file is **_Estimate treatment effects (experimental, surrogate index, single surrogate, naive).do_**, which is contained in **_Code/Compute Estimates_**. 
When the files are run individually, this file should be run first. 
The other .do files use output from this file to produce figures, tables and scalars that appear in the text. 
These files can be run in any order. 

The data on the GAIN program are from Riverside, CA are from Hotz, Imbens and Klerman (2006). 
Although the data themselves are not publicly available, a simulated version of the data is saved in the folder **_Data (Raw)_**. 
The simulation is intended to approximate the main results in the paper, and demonstrate the method used. 
The file **_Codebook for GAIN Data.pdf_**, also in **_Data (Raw)_**, contains further background and variable names.  
