%% Luminosity Threshold
% Created by TM 18/10/2021
% Dependencies: Psychtoolbox 3

All codes are written using MATLAB R2020a.
To save figures, the toolbox use a function "exportgraphics" introduced in R2020a.
If you use an early version of MATLAB, the exportgraphics should be replaced by anotehr function to save figures (e.g. print).

Associated publication 
Takuma Morimoto, and Hannah E. Smithson, “Discrimination of spectral reflectance under complex environmental illumination,” Journal of the Optical Society of America A, 35, 4, B244-B255 (2018) https://doi.org/10.1364/JOSAA.35.00B244

%% Instructions %%
This repository stores raw data and codes to reproduce figures in a following paper. 
"Luminosity thresholds of colored surfaces are determined by their upper-limit luminances internalized in the visual system", (in press for Journal of Vision)

Main codes to run the simulation:
- runMetrics:

Data:
- 99Reflectances.csv: Data on 99 reflectance samples from IES TM-30-2015 used in this analysis

Functions:
-getSimulatedSpectra: Generate radiance spectra of the 401 illuminants from the 99 surfaces

Plotting scripts:
-Plots figures from corresponding manuscript: Journal of Vision in press (to be uploaded when this is published) 