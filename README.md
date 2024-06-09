# Guaranteed_AFD_ADL
Repository for the code used in: "Optimal Input Design for Guaranteed Fault Diagnosis of Nonlinear Systems: An Active Deep Learning ApproacOptimal Input Design for Guaranteed Fault Diagnosis of Nonlinear Systems: An Active Deep Learning Approach"


Code was written in Matlab version R2023b and python version 3.11.

This code requires integration between Matlab and python using the matlab engine in python.

For all problems: An active version of matlab is necessary. Furthermore the Continuous Reachability Analyzer Toolkit (CORA) for matlab is required.

For all the linear problems: Yalmip for matlab is required.

For the KKT solve of the linear problem: Gurobi in matlab is required.

The Python methods are the same for the linear and nonlinear problems and only FDSepartion needs to be modified to change the input file. The 6D and 10D Matlab methods are generated the same way and just need dims in cstrGenerateData changed.

To export the figures as .pdf files, export_figure_toolbox is required
