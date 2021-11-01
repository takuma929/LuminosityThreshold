clearvars
close all

% Change directory
cd('/Users/takuma/Documents/GitHub/LuminosityThreshold')

% Save all figures to Figures
savedir = [pwd,'/Figures/'];

load SOCSAllData % Load SOCS reflectance dataset

%
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
Type = {'A' 'B'}; % Type A: blackbody reflectance, Type B: reflectance on axis orthogonal to blackbody locus 

% Define color for each participants
temp = brewermap(6,'Spectral');
cmap_o.Exp1 = temp([1 6 5 2],:);
cmap_o.Exp1(3,:) = cmap_o.Exp1(3,:)*0.7;

temp = brewermap(10,'Spectral');
cmap_o.Exp2(1,:) = temp(10,:);
cmap_o.Exp2(2,:) = cmap_o.Exp1(1,:);
cmap_o.Exp2(3,:) = temp(5,:)*0.8;
cmap_o.Exp2(4,:) = cmap_o.Exp1(4,:);

cmap_o.Exp3(1,:) = cmap_o.Exp2(2,:);
cmap_o.Exp3(2,:) = cmap_o.Exp2(1,:);
cmap_o.Exp3(3,:) = cmap_o.Exp2(4,:);

for Exp = 3
    clear corCoeff_linear corCoeff_log UpperLuminance_MaxLum PeakCT_record UpperLuminance_OP_Peak UpperLuminance_Real_smoothed UpperLuminance_Real

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
        if cctN == 1 % Magenta illuminant
            typeN = 2;
            Lum_k = 9.9185;
        elseif cctN == 2 % Green illuminant
            typeN = 2;
            Lum_k = 15.4481;
        end
    else
        typeN = 1;
        Lum_k = 35; % Luminance of a perfect reflecting diffuser (100 % reflectance at all wavelength)
    end
    
for type = 1:typeN
    
% Get test chromaticity for this condition
if Exp == 3
    Test_Chromaticity = TestChromaticity.(Key.distribution{dN}).(Key.illuminant{cctN}).(Type{type});
    temp = Test_Chromaticity;temp(:,3) = 1;
    Stimuli_MB = Stimuli.(Key.distribution{dN}).(Key.illuminant{cctN}).('All');
    Result_MB = Results.(Key.distribution{dN}).(Key.illuminant{cctN}).(Type{type});
    SE = SE_Data.(Key.distribution{dN}).(Key.illuminant{cctN}).(Type{type});
elseif Exp == 1
    Test_Chromaticity = TestChromaticity.(Key.distribution{dN}).(Key.illuminant{cctN});
    temp = Test_Chromaticity;temp(:,3) = 1;
    Stimuli_MB = Stimuli.(Key.distribution{dN}).(Key.illuminant{cctN});
    Result_MB = Results.(Key.distribution{dN}).(Key.illuminant{cctN});
    SE = SE_Data.(Key.distribution{dN}).(Key.illuminant{cctN});
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
        TestMB = [TestMB;TestChromaticity.(Key.distribution{1}).(Key.illuminant{ii})];
    else
        TestMB = [TestMB;TestChromaticity.(Key.distribution{1}).(Key.illuminant{ii}).(Type{type})];
    end
end

% Find the luminance of optimal color and highest luminance in surrounding stimuli at test chromaticities
UpperLuminance_OP_GT = [];
UpperLuminance_MaxLum = [];
for N = 1:length(Test_Chromaticity)
    [~,Id] = min(sqrt((20*MB(:,1) - 20*Test_Chromaticity(N,1)).^2+(MB(:,2) - Test_Chromaticity(N,2)).^2));
    UpperLuminance_OP_GT(N,:) = MB(Id,3);
    
    %[~,Id] = min(sqrt((20*Stimuli_MB(:,1) - 20*Test_Chromaticity(N,1)).^2+(Stimuli_MB(:,2) - Test_Chromaticity(N,2)).^2));
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
%[~,Id] = min(sqrt(sum((PeakChromaticity(1)*10-MB_bbl_500to25000with500step(:,1)*10).^2,2)));
CT = 500:500:25000;
PeakCT = CT(Id);

if Exp == 1 || Exp == 2
    PeakCT_record(dN,cctN,observerN) = PeakCT;
end

if illList(cctN) == 6500 && dN == 1
    %PeakCT = 5500;
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

temp = GetBlackBodyspd(PeakCT,400:10:700);
ill = (temp(:,2)/max(temp(:,2)))';

% MacLeod-Boynton Chromaticity for all SOCS database
[MB_temp,~] = HSLightProbe_MultiSpectralVectortoMBandRGB_400to700(Reflectance.*repmat(ill,length(Reflectance),1));
MB_SOCS_Peak = MB_temp(1:end-1,:);
MB_SOCS_Peak(:,3) = MB_SOCS_Peak(:,3)/MB_temp(end,3);

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

if Exp == 1 || Exp == 2
    if illList(cctN) == 3000
        cmap = [0.9925    0.8325    0.6660];
    elseif illList(cctN) == 6500
        cmap = [0.8657    0.8657    0.8657];
    elseif illList(cctN) == 20000
        cmap = [0.7941    0.8679    0.9439];
    end
elseif strcmp(illList(cctN),'Magenta')
        cmap = [237 87 247]/255;
elseif strcmp(illList(cctN),'Green')
        cmap = [168 246 76]/255;
end

% Convert MB to meanLMS
Stimuli_meanLMS(1) = mean(Stimuli_MB(:,1).*Stimuli_MB(:,3));
Stimuli_meanLMS(3) = mean(Stimuli_MB(:,2).*Stimuli_MB(:,3));
Stimuli_meanLMS(2) = mean(Stimuli_MB(:,3)-Stimuli_meanLMS(1));

% Convert meanLMS to MB
Stimuli_meanLMS_MB(1) = Stimuli_meanLMS(1)./(Stimuli_meanLMS(1)+Stimuli_meanLMS(2));
Stimuli_meanLMS_MB(2) = Stimuli_meanLMS(3)./(Stimuli_meanLMS(1)+Stimuli_meanLMS(2));
Stimuli_meanLMS_MB(3) = Stimuli_meanLMS(1)+Stimuli_meanLMS(2);

fig = figure;

if Exp == 1
    load('OP_6500_MB');MB_6500 = MB(end,:);
    line([MB_6500(1) MB_6500(1)],[-100 100],'LineStyle','-','Color',[0 0 0],'LineWidth',0.5);hold on;
elseif Exp == 3
    load('OP_Magenta_MB');MB_Magenta = MB(end,:);
    load('OP_Green_MB');MB_Green = MB(end,:);

    line([MB_Magenta(1) MB_Magenta(1)],[-100 100],'LineStyle','-','Color',[237 87 247]/255,'LineWidth',0.5);hold on;
    line([MB_Green(1) MB_Green(1)],[-100 100],'LineStyle','-','Color',[120 255 89]/255*0.7,'LineWidth',0.5);hold on;
end

% Plot surrounding color distribution
Alpha = [0.2 0 0.1];
scatter(Stimuli_MB(:,1),Stimuli_MB(:,3),20,cmap,'o','filled','MarkerEdgeColor',[0.8 0.8 0.8],'MarkerFaceAlpha',Alpha(Exp));hold on;

if Exp == 1
    scatter(Stimuli_meanLMS_MB(1),Stimuli_meanLMS_MB(3),80,'kx','Linewidth',1.5)
elseif Exp == 3
    scatter(Stimuli_meanLMS_MB(1),Stimuli_meanLMS_MB(3),80,'kx','Linewidth',1.5)
end

bluegreen = [0 255 255]/255*0.80;
red = [236 93 87]/255;
blue = [78 86 246]/255;

Test_Chromaticity_sRGB = [0 0 0];

% Plot errorr bar (SEM)
for n = 1:size(Test_Chromaticity,1)
    %errorbar(Test_Chromaticity(n,1),mean(Result_MB(n,:),2),std(Result_MB(n,:),[],2)/sqrt(length(Key.observer)),'-','Color',Test_Chromaticity_sRGB,'LineWidth',0.5);hold on;
end

% Insert this
x = Test_Chromaticity(:,1);

if Exp == 1
    s = [30,50,30];
elseif Exp == 3
    s = [30,50,30];
end
o_cmap = cmap_o.(['Exp',num2str(Exp)]);

for observerN = 1:size(Result_MB,2)
    % plot individual observers data
    errorbar(x,Result_MB(:,observerN),SE(:,observerN),'-','Color',o_cmap(observerN,:),'LineWidth',0.5,'MarkerFaceColor','k');hold on;
    plot(x,Result_MB(:,observerN),'-','Color',o_cmap(observerN,:),'LineWidth',0.5,'MarkerFaceColor','k');hold on;
    scatter(x,Result_MB(:,observerN),s(Exp),o_cmap(observerN,:),'s','filled','MarkerFaceAlpha',0.8);hold on;
    %scatter(x,log10(Result_MB(:,observerN)),s(Exp),Test_Chromaticity_sRGB,'o','filled','MarkerEdgeColor',[1 1 1],'MarkerFaceAlpha',0.8);hold on;
end

plot(x,mean(Result_MB,2),'-','Color',[0 0 0],'LineWidth',1.5,'LineStyle','-','MarkerFaceColor','k');hold on;
plot(x,UpperLuminance_Real_smoothed*Lum_k,'-','Color',blue,'LineWidth',2);hold on;
plot(x,UpperLuminance_OP_GT*Lum_k,'-','Color','m','LineWidth',2,'MarkerFaceColor','b');hold on;

if Exp == 1
    scatter(x,mean(Result_MB,2),50,[0.7 0.7 0.7],'o','filled','MarkerFaceAlpha',1);hold on;
    scatter(x,UpperLuminance_Real_smoothed*Lum_k,50,[0.7 0.7 0.7],'o','filled','MarkerFaceAlpha',1);hold on;
    scatter(x,UpperLuminance_OP_GT*Lum_k,50,[0.7 0.7 0.7],'o','filled','MarkerFaceAlpha',1);hold on;
    scatter(x,UpperLuminance_Real_smoothed*Lum_k,40,blue,'o','filled','MarkerEdgeColor',[1 1 1],'MarkerFaceAlpha',0.8);hold on;
    scatter(x,UpperLuminance_OP_GT*Lum_k,40,'mo','filled','MarkerEdgeColor',[1 1 1],'MarkerFaceAlpha',0.8);hold on;
    scatter(x,mean(Result_MB,2),40,Test_Chromaticity_sRGB,'o','filled','MarkerEdgeColor',[1 1 1],'MarkerFaceAlpha',0.8);hold on;
elseif Exp == 3
    scatter(x,mean(Result_MB,2),50,[0.7 0.7 0.7],'o','filled','MarkerFaceAlpha',1);hold on;
    scatter(x,UpperLuminance_Real_smoothed*Lum_k,50,[0.7 0.7 0.7],'o','filled','MarkerFaceAlpha',1);hold on;
    scatter(x,UpperLuminance_OP_GT*Lum_k,50,[0.7 0.7 0.7],'o','filled','MarkerFaceAlpha',1);hold on;
    scatter(x,UpperLuminance_Real_smoothed*Lum_k,40,blue,'o','filled','MarkerEdgeColor',[1 1 1],'MarkerFaceAlpha',0.8);hold on;
    scatter(x,UpperLuminance_OP_GT*Lum_k,40,'mo','filled','MarkerEdgeColor',[1 1 1],'MarkerFaceAlpha',0.8);hold on;
    scatter(x,mean(Result_MB,2),40,Test_Chromaticity_sRGB,'o','filled','MarkerEdgeColor',[1 1 1],'MarkerFaceAlpha',0.8);hold on;
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

axis square;ax = gca;

if Exp == 1
    ax.XLim = [0.66 0.77];ax.XTick = [0.66 0.77];
    ax.XTickLabel = ["0.66","0.77"];
elseif Exp == 2
    if illList(cctN) == 3000
    ax.XLim = [0.70 0.82];ax.XTick = [0.70 0.82];
    ax.XTickLabel = ["0.70","0.82"];
    elseif illList(cctN) == 6500
    ax.XLim = [0.66 0.78];ax.XTick = [0.66 0.78];
    ax.XTickLabel = ["0.66","0.78"];
    elseif illList(cctN) == 20000
    ax.XLim = [0.65 0.75];ax.XTick = [0.65 0.75];
    ax.XTickLabel = ["0.65","0.75"];
    end    
elseif Exp == 3
    if strcmp(illList(cctN),'Magenta')
        ax.XLim = [0.71 0.84];ax.XTick = [0.71 0.84];
        ax.XTickLabel = ["0.71","0.84"];xlabel('L/(L+M)');  
    elseif strcmp(illList(cctN),'Green')
        ax.XLim = [0.65 0.72];ax.XTick = [0.65 0.72];
        ax.XTickLabel = ["0.65","0.72"];xlabel('L/(L+M)');
    end
end

if Exp == 1
    ax.YLim = [-2 65];ax.YTick = [0 30 60];ax.YTickLabel = ["0.00","30.0","60.0"];
elseif Exp == 2
    ax.YLim = [-2 60];ax.YTick = [0 30 60];ax.YTickLabel = ["0.00","30.0","60.0"];
elseif Exp == 3
    ax.YLim = [-2 28];ax.YTick = [0 14 28];ax.YTickLabel = ["0.00","14.0","28.0"];
end


fig.PaperType       = 'a4';fig.PaperUnits = 'centimeters';
fig.Units           = 'centimeters';fig.Color  = 'w';
fig.InvertHardcopy  = 'off';
fig.PaperPosition   = [0,10,9.5,8.45];

if Exp == 1
    %fig.Position = [0,10,twocolumn/3,twocolumn/3];
    fig.Position = [0,10,twocolumn/4,twocolumn/4];

elseif Exp == 3
    %fig.Position = [0,10,twocolumn/4,twocolumn/4];
    fig.Position = [0,10,twocolumn/4*0.95,twocolumn/4*0.95];
end
     
xlabel('L/(L+M)','FontSize',fontsize_axis);

if Exp == 1
    ylabel('Luminance [cd/m^2]','FontSize',fontsize_axis);
end

ax.FontName = fontname;ax.FontSize = fontsize;
ax.LineWidth = 0.5;
ax.Units = 'centimeters';
axis square;

ax.Color = ones(3,1)*0.97;

if Exp == 1
    ax.Position = [0.97 0.8 3.4 3.4];
elseif Exp == 3
    ax.Position = [0.62 0.8 3.5 3.5];
end
box on;grid minor
ax.MinorGridLineStyle = ':';
ax.XMinorGrid = 'off';ax.YMinorGrid = 'on';
ax.LineWidth = 0.5;

if Exp == 1
    exportgraphics(fig,fullfile('Figs',['Figure5_',Key.distribution{dN},'.pdf']),'ContentType','vector')
elseif Exp == 3
    exportgraphics(fig,fullfile('Figs',['Figure13_',Key.distribution{dN},'_',Key.illuminant{cctN},'_type',Type{type},'.pdf']),'ContentType','vector')
end

end
end
end
end

if Exp == 1 || Exp == 2
    %save(['CorCoeff_Exp',num2str(Exp)],'corCoeff_linear','PeakCT_record')
elseif Exp == 3
    %save(['CorCoeff_Exp',num2str(Exp)],'corCoeff_linear')
end