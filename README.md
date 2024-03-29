%% Luminosity Threshold
% Created by TM 5/12/2021\

% Dependencies: Psychtoolbox 3, brewermap (https://www.mathworks.com/matlabcentral/fileexchange/45208-colorbrewer-attractive-and-distinctive-colormaps) 

All codes are written using MATLAB R2020a.
To save figures, the toolbox use a function "exportgraphics" introduced in R2020a.
If you use an early version of MATLAB, the exportgraphics should be replaced by anotehr function (e.g. print).

[Associated publication]
Takuma Morimoto, Ai Numata, Kazuho Fukuda, Keiji Uchikawa; Luminosity thresholds of colored surfaces are determined by their upper-limit luminances empirically internalized in the visual system. Journal of Vision 2021;21(13):3. doi: https://doi.org/10.1167/jov.21.13.3.

%% Instructions %%

This repository stores raw data and codes to reproduce figures in the publication above.
Clone the repository and set the repository to current directory in MATLAB.
Run LT_main.m and all figures will be saved in a folder called Figs.

Main codes to run the simulation:
- LT_main.m

Data:
- LT_Data.m: This stores raw experimental data and chromatic properties of experimental stimuli. The field name describes what it stores. The raw data is also deposited to https://doi.org/10.5281/zenodo.5590120
- OP_MB: This folder has mat files that store MacLeod-Boynton chromaticity coordinates of 90,301 optimal colors under illuminants from 3000K to 2000K (500K steps) and magenta and green illuminants (L/(L+M), S/(L+M) and L+M from first to third columns where L+M is relative to a white surface with 100% reflectance over visible wavelengths).
- MB_bbl_500to25000with500step.mat : This stores MacLeod-Boynton chromaticity coordinates of black body radiance from 500K to 25000K with 500K steps (L/(L+M) and S/(L+M) for first and second columns, respectively).
- SOCS_MB.mat: This stores SOCS reflectance dataset in MacLeod-Boynton chromaticity coordinates.
- SpectrumLocus_MB.mat: This stores MacLeod-Boynton chromaticity coordinates of spectrum locus (wavelength in nm, L/(L+M), S/(L+M) and L+M from first to fourth columns).
- ill6500K.mat: Spectrum of 6500K illuminant (wavelength and relative energy for first and second columns)
- colormap_observers.mat : Color map to plot individual observer data in sRGB format

Plotting scripts:
- LT_FigureX.m: Generate Figure X

