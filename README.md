%% Luminosity Threshold
% Created by TM 18/10/2021
%
%
% Calculate and plot contrast
% Dependencies: Psychtoolbox 3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Instructions %%
%% List of scripts, data files, functions, and plotting scripts in the photosim toolbox

Main codes to run the simulation:
- simulateReferenceDatabase: (first script to run) Generate real-world spectra, display spectra, and calculate photoreceptor excitations and MacLeod-Boynton coorindates from real-world spectra
- runMetrics: (second script to run) Calculate "photosim" metrics for given displays

Data:
-99Reflectances.csv: Data on 99 reflectance samples from IES TM-30-2015 used in this analysis
-99Reflectances_sampleTypes.csv: Type of surface for each reflectance in the 99Reflectances database
-401Illuminants.csv: Data on 401 illuminants from the Houser et al., 2013 databse used in this analysis
-401Illuminants_sampleTypes.csv: Type of illuminant for each illuminant in the 401Illuminants database
-lin2012xyz10e_1_7sf.csv: CIE 2015 XYZ functions
-CRT: Radiance spectrum of primaries from NEC CRT Color Monitor MultiSync FP2141SB (NEC Display Solutions, Tokyo, Japan)
-LCD: Radiance spectrum of primaries from Dell U2715H LCD Monitor (Dell, Austin, TX, USA)
-Display++: Radiance spectrum of primaries from CRS Display++ LCD Monitor (Cambridge Research Systems, Rochester, UK)

Functions:
-getSimulatedSpectra: Generate radiance spectra of the 401 illuminants from the 99 surfaces
-getSpectralLocusSpectra: Generate spectral locus over specified wavelength range
-normIllSpd: Normalize illuminant spectra to habe unit area
-XYZToxyY: Convert CIE 2015 XYZ coordinates to CIE xyY chromaticity coordinates (http://psychtoolbox.org/docs/XYZToxyY)
-GetCIES026: Return CIE026 spectral sensitivity functions (https://github.com/spitschan/SilentSubstitutionToolbox/blob/master/PhotoreceptorSensitivity/GetCIES026.m)
-getDistortions: Calculate distortions introduced to each photoreceptor signal when you constrain reproduction on a 3-primary display
-getColourGamut: Return % of real-world chromaticities that can be displayed in gamut for each display
-getPSRM: Return photoreceptor reproduction metric, PSRM, i.e. % of real-world (undistorted) LMSRI quintuplets that can be reproduced by a display (to a specified degree of accuracy)
-getPSDM: Return photoreceptor distortion metric, PSDM, for each display
-getPCDM: Return correlation distortion metric, PCDM, for each display

Plotting scripts:
-Plots figures from corresponding manuscript: Journal of Vision in press (to be uploaded when this is published) 