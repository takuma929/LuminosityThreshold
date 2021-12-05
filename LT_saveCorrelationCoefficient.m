clearvars;close all;clc  % clean up

load SOCS_MB % Load SOCS datasets
load LT_Data % Load observer settings

convWindow = 3; % the size of convolutional window

illList = [3000 6500 20000];
Type = {'A' 'B'};

disp('Calculating and saving correlation...')
for Exp = 1:3
    clear corCoeff_linear UpperLuminance_MaxLum PeakCT_record UpperLuminance_OP_Peak UpperLuminance_Real_smoothed UpperLuminance_Real

    % Extract relevant data for this experiment
    Key = LT_Data.(['Exp',num2str(Exp)]).Key;
    Results = LT_Data.(['Exp',num2str(Exp)]).Results;
    SE_Data = LT_Data.(['Exp',num2str(Exp)]).SE;
    Stimuli = LT_Data.(['Exp',num2str(Exp)]).Stimuli;
    TestChromaticity = LT_Data.(['Exp',num2str(Exp)]).TestChromaticity;
    illList = LT_Data.(['Exp',num2str(Exp)]).illList;
    
for dN = 1:length(Key.distribution)
for cctN = 1:length(Key.illuminant)
    % Lum_k indicates the illuminant intensity
    if Exp == 3
        if cctN == 1
            typeN = 2;
            Lum_k = 9.9185;
        elseif cctN == 2 % Green
            typeN = 2;
            Lum_k = 15.4481;
        end
    else
        typeN = 1;
        Lum_k = 35;
    end
    
for type = 1:typeN
    
% Get test chromaticity for this condition
if Exp == 3
    Test_Chromaticity = TestChromaticity.(Key.distribution{dN}).(Key.illuminant{cctN}).(Type{type});
    temp = Test_Chromaticity;temp(:,3) = 1;
    Stimuli_MB = Stimuli.(Key.distribution{dN}).(Key.illuminant{cctN}).('All');
    Result_MB = Results.(Key.distribution{dN}).(Key.illuminant{cctN}).(Type{type});
    SE = SE_Data.(Key.distribution{dN}).(Key.illuminant{cctN}).(Type{type});
else
    Test_Chromaticity = TestChromaticity.(Key.distribution{dN}).(Key.illuminant{cctN});
    temp = Test_Chromaticity;temp(:,3) = 1;
    Stimuli_MB = Stimuli.(Key.distribution{dN}).(Key.illuminant{cctN});
    Result_MB = Results.(Key.distribution{dN}).(Key.illuminant{cctN});
    SE = SE_Data.(Key.distribution{dN}).(Key.illuminant{cctN});
end

if Exp == 1 || Exp == 2
    MB_SOCS = SOCS_MB.(['ill',num2str(illList(cctN))]);
elseif Exp == 3
    MB_SOCS = SOCS_MB.(Key.illuminant{cctN});
end

% First in a range of chromaticity
resolution = 26;

%%
load(['OP_',num2str(illList(cctN)),'_MB']);
MB_OP = MB;

TestMB = [];
for ii = 1:length(Key.illuminant)
    if Exp == 1 || Exp == 2
        TestMB = vertcat(TestMB,TestChromaticity.(Key.distribution{1}).(Key.illuminant{ii}));
    else
        TestMB = vertcat(TestMB,TestChromaticity.(Key.distribution{1}).(Key.illuminant{ii}).(Type{type}));
    end
end

% Find the luminance of optimal color and highest luminance in surrounding stimuli at test chromaticities
UpperLuminance_OP_GT = [];
UpperLuminance_MaxLum = [];
for N = 1:length(Test_Chromaticity)
    [~,Id] = min(sqrt((20*MB(:,1) - 20*Test_Chromaticity(N,1)).^2+(MB(:,2) - Test_Chromaticity(N,2)).^2));
    UpperLuminance_OP_GT(N,:) = MB(Id,3);
    
    [~,Id] = min(sqrt((20*Stimuli_MB(:,1) - 20*Test_Chromaticity(N,1)).^2));
    UpperLuminance_MaxLum(N,:) = Stimuli_MB(Id,3);
end

rmin = min(TestMB(:,1))-0.0001;rmax = max(TestMB(:,1))+0.0001;
bmin = min(log10(TestMB(:,2)))-0.001;bmax = max(log10(TestMB(:,2)))+0.001;

[MB_UB_SOCS,Z_SOCS,r,b] = LT_OPAnalysis_GetUpperBoundary_MB(MB_SOCS,resolution,0,rmin,rmax,bmin,bmax);
Z_SOCS_smoothed = conv2(Z_SOCS, ones(convWindow,convWindow)/convWindow^2, 'same');

UpperLuminance_Real = ones(size(Test_Chromaticity,1),1);
UpperLuminance_Real_smoothed = ones(size(Test_Chromaticity,1),1);

% Find upper limit of real surfaces and optimal color
for N = 1:length(Test_Chromaticity)
    temp_r = find(r.range-Test_Chromaticity(N,1)>0);
    temp_b = find(b.range-log10(Test_Chromaticity(N,2))>0);
    Id_r = temp_r(1) - 1;
    Id_b = temp_b(1) - 1;

    UpperLuminance_Real(N) = Z_SOCS(resolution-Id_b,Id_r);
    UpperLuminance_Real_smoothed(N) = Z_SOCS_smoothed(resolution-Id_b,Id_r);
end

% Find the Peak
if Exp == 1 || Exp == 2
UpperLuminance_Real_Peak = ones(size(Test_Chromaticity,1),size(Result_MB,2));
UpperLuminance_Real_smoothed_Peak = ones(size(Test_Chromaticity,1),size(Result_MB,2));

for observerN = 1:size(Result_MB,2) 
Results_GT = Result_MB(:,observerN);
[~,Id] = max(Results_GT);

% Find peak luminance
PeakChromaticity = Test_Chromaticity(Id,:);

load MB_bbl_500to25000with500step
[~,Id] = min(sqrt((PeakChromaticity(1)*20-MB_bbl_500to25000with500step(:,1)*20).^2+(PeakChromaticity(2)-MB_bbl_500to25000with500step(:,2)).^2));
CT = 500:500:25000;
PeakCT = CT(Id);

if Exp == 1 || Exp == 2
    PeakCT_record(dN,cctN,observerN) = PeakCT;
end

load(['OP_',num2str(PeakCT),'_MB']);
MB_OP_Peak = MB;

for ii = 1:length(Key.illuminant)
    TestMB = vertcat(TestMB,TestChromaticity.(Key.distribution{1}).(Key.illuminant{ii}));
end

% Find the luminance of optimal color under peak color temperature
for N = 1:length(Test_Chromaticity)
    [~,Id] = min(sqrt((20*MB_OP_Peak(:,1) - 20*Test_Chromaticity(N,1)).^2+(MB_OP_Peak(:,2) - Test_Chromaticity(N,2)).^2));
    UpperLuminance_OP_Peak(N,observerN,:) = MB_OP_Peak(Id,3);
end

MB_SOCS_Peak = SOCS_MB.(['ill',num2str(PeakCT)]);

rmin = min(TestMB(:,1))-0.0001;rmax = max(TestMB(:,1))+0.0001;
bmin = min(log10(TestMB(:,2)))-0.001;bmax = max(log10(TestMB(:,2)))+0.001;

[MB_UB_SOCS,Z_SOCS_Peak,r,b] = LT_OPAnalysis_GetUpperBoundary_MB(MB_SOCS_Peak,resolution,0,rmin,rmax,bmin,bmax);
Z_SOCS_smoothed_Peak = conv2(Z_SOCS_Peak, ones(convWindow,convWindow)/convWindow^2, 'same');

% Find upper limit of real surfaces and optimal color
for N = 1:length(Test_Chromaticity)
    temp_r = find(r.range-Test_Chromaticity(N,1)>0);
    temp_b = find(b.range-log10(Test_Chromaticity(N,2))>0);
    Id_r = temp_r(1) - 1;
    Id_b = temp_b(1) - 1;

    UpperLuminance_Real_Peak(N,observerN) = Z_SOCS_Peak(resolution-Id_b,Id_r);
    UpperLuminance_Real_smoothed_Peak(N,observerN) = Z_SOCS_smoothed_Peak(resolution-Id_b,Id_r);
end

end
end

if Exp == 3
    corCoeff_linear.OP_GT(dN,cctN,type,:) = corr(Result_MB,UpperLuminance_OP_GT*Lum_k);
    corCoeff_linear.Real_GT(dN,cctN,type,:) = corr(Result_MB,UpperLuminance_Real*Lum_k);
    corCoeff_linear.Real_smoothed_GT(dN,cctN,type,:) = corr(Result_MB,UpperLuminance_Real_smoothed*Lum_k);
    corCoeff_linear.MaxLum(dN,cctN,type,:) = corr(Result_MB,UpperLuminance_MaxLum*Lum_k);
else
    corCoeff_linear.OP_GT(dN,cctN,:) = corr(Result_MB,UpperLuminance_OP_GT*Lum_k);
    corCoeff_linear.Real_GT(dN,cctN,:) = corr(Result_MB,UpperLuminance_Real*Lum_k);
    corCoeff_linear.Real_smoothed_GT(dN,cctN,:) = corr(Result_MB,UpperLuminance_Real_smoothed*Lum_k);
    corCoeff_linear.MaxLum(dN,cctN,:) = corr(Result_MB,UpperLuminance_MaxLum*Lum_k);

    for observerN = 1:size(Result_MB,2)
        corCoeff_linear.OP_Peak(dN,cctN,observerN) = corr(Result_MB(:,observerN),UpperLuminance_OP_Peak(:,observerN)*Lum_k);
        corCoeff_linear.Real_Peak(dN,cctN,observerN) = corr(Result_MB(:,observerN),UpperLuminance_Real_Peak(:,observerN)*Lum_k);
        corCoeff_linear.Real_smoothed_Peak(dN,cctN,observerN) = corr(Result_MB(:,observerN),UpperLuminance_Real_smoothed_Peak(:,observerN)*Lum_k);
    end
end
end
end
end

if Exp == 2
    save(['CorCoeff_Exp',num2str(Exp)],'corCoeff_linear','PeakCT_record')
elseif Exp == 1 || Exp == 3
    save(['CorCoeff_Exp',num2str(Exp)],'corCoeff_linear')
end

end
disp('Done.')