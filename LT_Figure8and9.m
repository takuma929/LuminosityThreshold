clearvars
close all

% Change directory
cd('/Users/takuma/Documents/GitHub/LuminosityThreshold')

% Save all figures to Figures
savedir = [pwd,'/Figures/'];

load SOCSAllData % Load SOCS reflectance dataset
load LT_Data % Load observer settings

% Set column size
twocolumn = 18.5;
onecolumn = twocolumn/2;

% Set font size for general use and axis
fontsize = 7;
fontsize_axis = 8;
fontname = 'Arial';

convWindow = 3;

% Exclude complete white included in the dataset for some reason
PRD_Id = find(sum(Reflectance,2)==31);
Reflectance(PRD_Id,:) = [];

Reflectance(end+1,:) = ones(1,31);

illList = [3000 6500 20000];
Type = {'A' 'B'};

Exp = 2;

Key = LT_Data.(['Exp',num2str(Exp)]).Key;
Results = LT_Data.(['Exp',num2str(Exp)]).Results;
Stimuli = LT_Data.(['Exp',num2str(Exp)]).Stimuli;
TestChromaticity = LT_Data.(['Exp',num2str(Exp)]).TestChromaticity;
illList = LT_Data.(['Exp',num2str(Exp)]).illList;

for dN = 1:length(Key.distribution)
for cctN = 1:length(Key.illuminant)

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
else
    Test_Chromaticity = TestChromaticity.(Key.distribution{dN}).(Key.illuminant{cctN});
    temp = Test_Chromaticity;temp(:,3) = 1;
    Stimuli_MB = Stimuli.(Key.distribution{dN}).(Key.illuminant{cctN});
    Result_MB = Results.(Key.distribution{dN}).(Key.illuminant{cctN});
end

Test_Chromaticity_sRGB = HSLightProbe_MBtoRGBImage(temp);

if Exp == 1 || Exp == 2
    temp = GetBlackBodyspd(illList(cctN),400:10:700);
elseif Exp == 3
    temp = GetBlackBodyspd(6500,400:10:700);
    temp(:,2) = temp(:,2).*LT_Data.Exp3.Filter.(Key.illuminant{cctN});
end
ill = (temp(:,2)/max(temp(:,2)))';

% MacLeod-Boynton Chromaticity for all SOCS database
[MB_temp,~] = HSLightProbe_MultiSpectralVectortoMBandRGB_400to700(Reflectance.*repmat(ill,length(Reflectance),1));
MB_SOCS = MB_temp(1:end-1,:);
MB_SOCS(:,3) = MB_SOCS(:,3)/MB_temp(end,3);

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

% Find the luminance of optimal color at test chromaticities
UpperLuminance_OP = [];
for N = 1:length(Test_Chromaticity)
    [~,Id] = min(sqrt((20*MB(:,1) - 20*Test_Chromaticity(N,1)).^2+(MB(:,2) - Test_Chromaticity(N,2)).^2));
    UpperLuminance_OP(N,:) = MB(Id,3);
end

rmin = min(TestMB(:,1))-0.0001;rmax = max(TestMB(:,1))+0.0001;
bmin = min(log10(TestMB(:,2)))-0.001;bmax = max(log10(TestMB(:,2)))+0.001;

[MB_UB_SOCS,Z_SOCS,r,b] = LT_OPAnalysis_GetUpperBoundary_MB(MB_SOCS,resolution,0,rmin,rmax,bmin,bmax);
Z_SOCS_smoothed = conv2(Z_SOCS, ones(convWindow,convWindow)/convWindow^2, 'same');

if Exp == 1 || Exp == 2
    if illList(cctN) == 3000
        cmap = [0.9925 0.8325 0.6660];
    elseif illList(cctN) == 6500
        cmap = [0.8657 0.8657 0.8657];
    elseif illList(cctN) == 20000
        cmap = [0.7941 0.8679 0.9439];
    end
elseif strcmp(illList(cctN),'Magenta')
        cmap = [237 87 247]/255;
elseif strcmp(illList(cctN),'Green')
        cmap = [168 246 76]/255;
end

UpperLuminance_Real = [];
UpperLuminance_Real_smoothed = [];

% Find upper limit of real surfaces and optimal color
for N = 1:length(Test_Chromaticity)
    temp_r = find(r.range-Test_Chromaticity(N,1)>0);
    temp_b = find(b.range-log10(Test_Chromaticity(N,2))>0);
    Id_r = temp_r(1) - 1;
    Id_b = temp_b(1) - 1;

    UpperLuminance_Real(N,:) = Z_SOCS(resolution-Id_b,Id_r);
    UpperLuminance_Real_smoothed(N,:) = Z_SOCS_smoothed(resolution-Id_b,Id_r);
end

% Keep the maximum value the same
%UpperLuminance_Real_smoothed = UpperLuminance_Real_smoothed/max(UpperLuminance_Real_smoothed(:))*max(UpperLuminance_Real(:));

% Convert MB to meanLMS
Stimuli_meanLMS(1) = mean(Stimuli_MB(:,1).*Stimuli_MB(:,3));
Stimuli_meanLMS(3) = mean(Stimuli_MB(:,2).*Stimuli_MB(:,3));
Stimuli_meanLMS(2) = mean(Stimuli_MB(:,3)-Stimuli_meanLMS(1));

% Convert meanLMS to MB
Stimuli_meanLMS_MB(1) = Stimuli_meanLMS(1)./(Stimuli_meanLMS(1)+Stimuli_meanLMS(2));
Stimuli_meanLMS_MB(2) = Stimuli_meanLMS(3)./(Stimuli_meanLMS(1)+Stimuli_meanLMS(2));
Stimuli_meanLMS_MB(3) = Stimuli_meanLMS(1)+Stimuli_meanLMS(2);

cmap_o = brewermap(4,'Spectral');
fig = figure;

load('OP_3000_MB');MB_3000 = MB(end,:);
load('OP_6500_MB');MB_6500 = MB(end,:);
load('OP_20000_MB');MB_20000 = MB(end,:);
line([MB_3000(1) MB_3000(1)],[-100 100],'LineStyle','-','Color',[1 0 0],'LineWidth',0.3);hold on;
line([MB_6500(1) MB_6500(1)],[-100 100],'LineStyle','-','Color',[0 0 0],'LineWidth',0.3);hold on;
line([MB_20000(1) MB_20000(1)],[-100 100],'LineStyle','-','Color',[0 0 1],'LineWidth',0.3);hold on;

% Draw a frame for 20000K and Exp 2
if illList(cctN) == 20000
    line([0.65 0.65],[15 41],'LineStyle','-','Color',[0.5 0.5 0.5],'LineWidth',0.5);hold on;
    line([0.65 0.75],[15 15],'LineStyle','-','Color',[0.5 0.5 0.5],'LineWidth',0.5);hold on;
    line([0.75 0.75],[15 41],'LineStyle','-','Color',[0.5 0.5 0.5],'LineWidth',0.5);hold on;
    line([0.65 0.75],[41 41],'LineStyle','-','Color',[0.5 0.5 0.5],'LineWidth',0.5);hold on;    
end

% Plot Stimulus distribution

scatter(Stimuli_MB(:,1),Stimuli_MB(:,3),20,cmap,'o','filled','MarkerEdgeColor',[0.8 0.8 0.8],'MarkerFaceAlpha',0.3,'LineWidth',0.2);hold on;
scatter(Stimuli_meanLMS_MB(1),Stimuli_meanLMS_MB(3),100,'kx','Linewidth',1.5)

bluegreen = [0 255 255]/255*0.80;
red = [236 93 87]/255;
blue = [78 86 246]/255;

Test_Chromaticity_sRGB = [0 0 0];

% Plot errorr bar (SEM)
for n = 1:size(Test_Chromaticity,1)
    errorbar(Test_Chromaticity(n,1),mean(Result_MB(n,:),2),std(Result_MB(n,:),[],2)/sqrt(length(Key.observer)),'-','Color',Test_Chromaticity_sRGB,'LineWidth',0.5);hold on;
end

% Insert this
x = Test_Chromaticity(:,1);

s = [70,50,70];

plot(x,mean(Result_MB,2),'-','Color',[0.2 0.2 0.2],'LineWidth',2,'MarkerFaceColor','k');hold on;
plot(x,UpperLuminance_Real_smoothed*Lum_k,'-','Color',blue,'LineWidth',2);hold on;
plot(x,UpperLuminance_OP*Lum_k,'-','Color','m','LineWidth',2,'MarkerFaceColor','b');hold on;

scatter(x,mean(Result_MB,2),32,[0.7 0.7 0.7],'o','filled','MarkerFaceAlpha',1);hold on;
cmap_o = brewermap(length(Key.observer),'Spectral');

scatter(x,UpperLuminance_Real_smoothed*Lum_k,32,[0.7 0.7 0.7],'o','filled','MarkerFaceAlpha',1);hold on;

scatter(x,UpperLuminance_OP*Lum_k,32,[0.7 0.7 0.7],'o','filled','MarkerFaceAlpha',1);hold on;
scatter(x,UpperLuminance_Real_smoothed*Lum_k,25,blue,'o','filled','MarkerEdgeColor',[1 1 1],'MarkerFaceAlpha',0.8);hold on;
scatter(x,UpperLuminance_OP*Lum_k,25,'mo','filled','MarkerEdgeColor',[1 1 1],'MarkerFaceAlpha',0.8);hold on;
scatter(x,mean(Result_MB,2),25,Test_Chromaticity_sRGB,'o','filled','MarkerEdgeColor',[1 1 1],'MarkerFaceAlpha',0.8);hold on;

corCoeff_linear.OP(dN,cctN) = corr(mean(Result_MB,2),UpperLuminance_OP*Lum_k);
corCoeff_linear.Real(dN,cctN) = corr(mean(Result_MB,2),UpperLuminance_Real*Lum_k);
corCoeff_linear.Real_smoothed(dN,cctN) = corr(mean(Result_MB,2),UpperLuminance_Real_smoothed*Lum_k);

N = length(mean(Result_MB,2));

axis square;ax = gca;

ax.XLim = [0.63 0.85];ax.XTick = [0.630 0.735 0.850];
ax.XTickLabel = ["0.63","0.74","0.85"];xlabel('L/(L+M)');

ax.YLim = [-1 50];ax.YTick = [0 25 50];ax.YTickLabel = ["0.00","25.0","50.0"];        

fig.PaperType       = 'a4';fig.PaperUnits = 'centimeters';
fig.Units           = 'centimeters';fig.Color  = 'w';
fig.InvertHardcopy  = 'off';
fig.PaperPosition   = [0,10,9.5,8.45];
fig.Position = [0,10,twocolumn/4,twocolumn/4];

ylabel('Luminance [cd/m^2]');

ax.FontName = fontname;ax.FontSize = fontsize;
ax.LineWidth = 0.5;
ax.Units = 'centimeters';
axis square;
ax.Color  = [0.97 0.97 0.97];
ax.Position = [0.97 0.8 3.4 3.4];
box on
grid minor
ax.XMinorGrid = 'off';ax.YMinorGrid = 'on';

exportgraphics(fig,fullfile('Figs',['Figure8_',Key.distribution{dN},'_',Key.illuminant{cctN},'.pdf']),'ContentType','vector')

%% Enlarged Figure for 20000K
if illList(cctN) == 20000
UpperLuminance_OP_GT = UpperLuminance_OP;
UpperLuminance_Real_smoothed_GT = UpperLuminance_Real_smoothed;
UpperLuminance_Real_GT = UpperLuminance_Real;
Results_GT = log10(mean(Result_MB,2));
[~,Id] = max(Results_GT);

% Find peak luminance
PeakChromaticity = Test_Chromaticity(Id,:);

load MB_bbl_500to25000with500step
%[~,Id] = min(sqrt(sum((PeakChromaticity(1)*10-MB_bbl_500to25000with500step(:,1)*10).^2+(PeakChromaticity(2)-MB_bbl_500to25000with500step(:,2)).^2,2)));
[~,Id] = min(sqrt(sum((PeakChromaticity(1)*10-MB_bbl_500to25000with500step(:,1)*10).^2,2)));
CT = 500:500:25000;
PeakCT = CT(Id);
PeakCT_record(dN) = PeakCT;

if illList(cctN) == 6500 && dN == 1
    PeakCT = 5500;
end

load(['OP_',num2str(PeakCT),'_MB']);
MB_OP_Peak = MB;

TestMB = [];
for ii = 1:length(Key.illuminant)
    TestMB = vertcat(TestMB,TestChromaticity.(Key.distribution{1}).(Key.illuminant{ii}));
end

% Find the luminance of optimal color at test chromaticities
UpperLuminance_OP_Peak = [];
for N = 1:length(Test_Chromaticity)
    [~,Id] = min(sqrt((20*MB_OP_Peak(:,1) - 20*Test_Chromaticity(N,1)).^2+(MB_OP_Peak(:,2) - Test_Chromaticity(N,2)).^2));
    UpperLuminance_OP_Peak(N,:) = MB_OP_Peak(Id,3);
end

rmin = min(TestMB(:,1))-0.0001;rmax = max(TestMB(:,1))+0.0001;
bmin = min(log10(TestMB(:,2)))-0.001;bmax = max(log10(TestMB(:,2)))+0.001;

[MB_UB_OP_Peak,Z_OP_Peak,r,b] = LT_OPAnalysis_GetUpperBoundary_MB(MB_OP_Peak,resolution,0,rmin,rmax,bmin,bmax);
%[MB_UB_SOCS_Peak,Z_SOCS_Peak,r,b] = LT_OPAnalysis_GetUpperBoundary_MB(MB_SOCS_Peak,resolution,0,rmin,rmax,bmin,bmax);

%Z_SOCS_smoothed_Peak = conv2(Z_SOCS,ones(convWindow,convWindow)/convWindow^2, 'same');

if illList(cctN) == 3000
    cmap = [0.9925    0.8325    0.6660];
elseif illList(cctN) == 6500
    cmap = [0.8657    0.8657    0.8657];
elseif illList(cctN) == 20000
    cmap = [0.7941    0.8679    0.9439];
end

UpperLuminance_Real_Peak = [];
UpperLuminance_Real_smoothed_Peak = [];

% Find upper limit of real surfaces and optimal color
for N = 1:length(Test_Chromaticity)
    temp_r = find(r.range-Test_Chromaticity(N,1)>0);
    temp_b = find(b.range-log10(Test_Chromaticity(N,2))>0);
    Id_r = temp_r(1) - 1;
    Id_b = temp_b(1) - 1;

    %UpperLuminance_Real_Peak(N,:) = Z_SOCS(resolution-Id_b,Id_r);
    %UpperLuminance_Real_smoothed_Peak(N,:) = Z_SOCS_smoothed(resolution-Id_b,Id_r);
end

fig = figure;

load(['OP_',num2str(illList(cctN)),'_MB']);MB_GT = MB(end,:);
load(['OP_',num2str(PeakCT),'_MB']);MB_Peak = MB(end,:);

bluegreen = [0 255 255]/255*0.80;
red = [236 93 87]/255;
blue = [78 86 246]/255;
cyan = [48 211 252]/255;

Test_Chromaticity_sRGB = [0 0 0];

for n = 1:size(Test_Chromaticity,1)
    errorbar(Test_Chromaticity(n,1),mean(Result_MB(n,:),2),std(Result_MB(n,:),[],2)/sqrt(length(Key.observer)),'-','Color',Test_Chromaticity_sRGB,'LineWidth',0.5);hold on;
end

% Insert this
x = Test_Chromaticity(:,1);

plot(x,UpperLuminance_OP_GT*Lum_k,'-','Color',[255 0 255]/255,'LineWidth',1);hold on;
scatter(x,UpperLuminance_OP_GT*Lum_k,40,[1 1 1],'o','filled','MarkerFaceAlpha',1);hold on;
scatter(x,UpperLuminance_OP_GT*Lum_k,40,[255 0 255]/255,'o','filled','MarkerEdgeColor',[1 1 1],'MarkerFaceAlpha',1);hold on;

plot(x,mean(Result_MB,2),'-','Color',[0.2 0.2 0.2],'LineWidth',2,'MarkerFaceColor','k');hold on;
%plot(x,UpperLuminance_Real_smoothed_GT*Lum_k,'-','Color',blue,'LineWidth',2);hold on;
plot(x,UpperLuminance_OP_Peak*Lum_k,'-','Color',[64 192 192]/255,'LineWidth',2,'MarkerFaceColor',cyan);hold on;

% Old pink [255 204 255]/255
scatter(x,mean(Result_MB,2),50,[0.7 0.7 0.7],'o','filled','MarkerFaceAlpha',1);hold on;

%scatter(x,UpperLuminance_Real_smoothed*Lum_k,88,[0.7 0.7 0.7],'o','filled','MarkerFaceAlpha',1);hold on;

scatter(x,UpperLuminance_OP_Peak*Lum_k,50,[0.7 0.7 0.7],'o','filled','MarkerFaceAlpha',1);hold on;

%scatter(x,UpperLuminance_Real_smoothed*Lum_k,70,blue,'o','filled','MarkerEdgeColor',[1 1 1],'MarkerFaceAlpha',0.8);hold on;
scatter(x,UpperLuminance_OP_Peak*Lum_k,40,[64 192 192]/255,'o','filled','MarkerEdgeColor',[1 1 1],'MarkerFaceAlpha',0.8);hold on;
scatter(x,mean(Result_MB,2),40,Test_Chromaticity_sRGB,'o','filled','MarkerEdgeColor',[1 1 1],'MarkerFaceAlpha',0.8);hold on;

corCoeff_linear.OP(dN,cctN) = corr(mean(Result_MB,2),UpperLuminance_OP_GT*Lum_k);
corCoeff_linear.OP_Peak(dN,cctN) = corr(mean(Result_MB,2),UpperLuminance_OP_Peak*Lum_k);

corCoeff_log.OP(dN,cctN) = corr(log10(mean(Result_MB,2)),log10(UpperLuminance_OP_GT*Lum_k));
corCoeff_log.OP_Peak(dN,cctN) = corr(log10(mean(Result_MB,2)),log10(UpperLuminance_OP_Peak*Lum_k));

axis square;ax = gca;

if illList(cctN) == 3000
ax.XLim = [0.70 0.82];ax.XTick = [0.70 0.82];
ax.XTickLabel = ["0.70","0.82"];xlabel('L/(L+M)');
elseif illList(cctN) == 6500
ax.XLim = [0.66 0.78];ax.XTick = [0.66 0.78];
ax.XTickLabel = ["0.66","0.78"];xlabel('L/(L+M)');
elseif illList(cctN) == 20000
ax.XLim = [0.65 0.75];ax.XTick = [0.65 0.75];
ax.XTickLabel = ["0.65","0.75"];xlabel('L/(L+M)');
end

ax.YLim = [15 41];ax.YTick = [15 28 41];ax.YTickLabel = ["15.0","28.0","41.0"];

fig.PaperType       = 'a4';fig.PaperUnits = 'centimeters';
fig.Units           = 'centimeters';
fig.Color = [1 1 1];
fig.InvertHardcopy  = 'off';
fig.PaperPosition   = [0,10,9.5,8.45];
fig.Position = [0,10,twocolumn/4,twocolumn/4];

ylabel('Luminance [cd/m^2]');

ax.FontName = fontname;ax.FontSize = fontsize;
ax.LineWidth = 0.5;
ax.Units = 'centimeters';
axis square;
ax.Color  = [0.97 0.97 0.97];

ax.Position = [0.97 0.8 3.4 3.4];
box on

grid minor
ax.XMinorGrid = 'off';ax.YMinorGrid = 'on';

%exportgraphics(fig,[pwd,'/Figures/Enlarged_Results_Exp',num2str(Exp),'_',Key.distribution{dN},'_',Key.illuminant{cctN},'.pdf'],'ContentType','vector','BackgroundColor','current')
exportgraphics(fig,fullfile('Figs',['Figure9_',Key.distribution{dN},'.pdf']),'ContentType','vector')

end

end
end
%save(['CorCoeff_Exp',num2str(Exp)],'corCoeff_linear','corCoeff_log','RMSE_linear','RMSE_log')
end