# spatiochromatic_cov
Implementation of the paper "Yiye Jiang, Jérémie Bigot, Edoardo Provenzi. Commutativity of spatiochromatic covariance matrices in natural image statistics."

The folder "Result_data" contains the numeric results calculated from our dataset, which are also used to generate figures in the paper. These results are all in .mat format, and can be loaded into Matlab. Most of them are named as "C_hat" in Matlab. Running them with the lines requiring "C_hat" varibale in "main.m" file will generate the graphical results.

**C0_s_1_50_N0_2.mat** and **C0_s_1_50_N0_5.mat** are used in the *Validations of estimators’ properties* section, **C_hat_raw.mat** is used in *Regression* section, while **cat_C_hat.mat** is used in the "JointDiag.R" file. 
