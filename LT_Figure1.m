%% Generate Figure 1

clearvars;close all;clc % standard clean up

% Make a directory to save figures if it does not exist
if ~isfolder('Figs')
    mkdir Figs
end

% Set column size
twocolumn = 18.5;
onecolumn = twocolumn/2;

% Set font size for general use and axis
fontsize = 7;
fontsize_axis = 8;
fontname = 'Arial';

% Load SOCS Data
load('SOCSAllData');
SOCS_Id.Natural = [SOCS_Id.Face,SOCS_Id.Flowers,SOCS_Id.Leaves,SOCS_Id.Krinov];
SOCS_Id.Artificial = [SOCS_Id.Photo,SOCS_Id.Graphic,SOCS_Id.Printer,SOCS_Id.Paints];

SOCSAll.Natural = Reflectance(SOCS_Id.Natural,:);
Artificial.Ref = Reflectance(SOCS_Id.Artificial,:);
SOCSAll.Ref = Reflectance;

SOCSAll.Natural(:,32:33) = 0;
C = HSLightProbe_MultiSpectralImagetoTristimulusValue_400to720(SOCSAll.Natural);

% Exclude complete white included in the dataset for some reason
PRD_Natural = find(sum(SOCSAll.Ref,2)==31);
PRD_Artificial = find(sum(Artificial.Ref,2)==31);
PRD_SOCSAll = find(sum(SOCSAll.Ref,2)==31);

SOCSAll.Ref(PRD_Natural,:) = [];
Artificial.Ref(PRD_Artificial,:) = [];
SOCSAll.Ref(PRD_SOCSAll,:) = [];

SOCSAll.Ref(end+1,:) = ones(1,31);
Artificial.Ref(end+1,:) = ones(1,31);
SOCSAll.Ref(end+1,:) = ones(1,31);

bandpass = zeros(33,1);bandpass(11:21) = 1;
bandstop = ones(33,1);bandstop(11:21) = 0;
sRGB_bandpass = HSLightProbe_MultiSpectralImagetosRGB_400to720(bandpass');
sRGB_bandstop = HSLightProbe_MultiSpectralImagetosRGB_400to720(bandstop');

CCT = [3000 6500 20000];
CCT_RGB =  [0.8000 0.6082 0.4025;0.6927 0.6974 0.8000;0.4693 0.5219 0.8000];

%% Plot panel (a) Band-pass optimal color
fig = figure;fig.Color = 'w';

% Draw the spectral reflectance function of a band-pass optimal color
line([400,500],[0 0],'LineWidth',1.5,'Color',sRGB_bandpass*0.7)
line([500,500],[0 1],'LineWidth',1.5,'Color',sRGB_bandpass*0.7)
line([500,600],[1 1],'LineWidth',1.5,'Color',sRGB_bandpass*0.7)
line([600,600],[1 0],'LineWidth',1.5,'Color',sRGB_bandpass*0.7)
line([600,700],[0 0],'LineWidth',1.5,'Color',sRGB_bandpass*0.7)
text(491,1.08,'λ_1','FontSize',fontsize,'FontName',fontname);
text(591,1.08,'λ_2','FontSize',fontsize,'FontName',fontname);

ax = gca;axis square;
ax.XLim = [400 700];ax.YLim = [-0.05 1.05];
ax.XTick = [400 500 600 700];ax.YTick = [0.0 0.5 1.0];

ax.XTickLabel = char('400','500','600','700');
ax.YTickLabel = char('0.00','0.50','1.00');
    
fig.PaperType       = 'a4';fig.PaperUnits = 'centimeters';
fig.Units           = 'centimeters';fig.Color  = 'w';
fig.InvertHardcopy  = 'off';
fig.PaperPosition   = [0,10,8.45,8.45];
fig.Position = [0,10,twocolumn/4*0.95,twocolumn/4*0.95];

ax.FontName = fontname;ax.FontSize = fontsize;
ax.Color = ones(3,1)*0.97;
ax.Units = 'centimeters';

xlabel('Wavelength [nm]','FontSize',fontsize_axis);ylabel('Reflectance','FontSize',fontsize_axis);

axis square;
ax.Position = [0.88 0.8 3.3 3.3];
box off;grid minor
ax.MinorGridLineStyle = ':';
ax.XMinorGrid = 'off';ax.YMinorGrid = 'on';
ax.LineWidth = 0.5;
exportgraphics(fig,fullfile('Figs','Figure1a.pdf'),'ContentType','vector')

%% Plot panel (b) Band-stop optimal color
fig = figure;fig.Color = 'w';

% Draw the spectral reflectance function of a band-pass optimal color
line([400,500],[1 1],'LineWidth',1.5,'Color',sRGB_bandstop*0.8)
line([500,500],[1 0],'LineWidth',1.5,'Color',sRGB_bandstop*0.8)
line([500,600],[0 0],'LineWidth',1.5,'Color',sRGB_bandstop*0.8)
line([600,600],[0 1],'LineWidth',1.5,'Color',sRGB_bandstop*0.8)
line([600,700],[1 1],'LineWidth',1.5,'Color',sRGB_bandstop*0.8)
text(491,1.08,'λ_1','FontSize',fontsize,'FontName',fontname);
text(591,1.08,'λ_2','FontSize',fontsize,'FontName',fontname);

ax = gca;axis square;
ax.XLim = [400 700];ax.YLim = [-0.05 1.05];
ax.XTick = [400 500 600 700];ax.YTick = [0.0 0.5 1.0];

ax.XTickLabel = char('400','500','600','700');
ax.YTickLabel = char('0.00','0.50','1.00');

fig.PaperType       = 'a4';fig.PaperUnits = 'centimeters';
fig.Units           = 'centimeters';fig.Color  = 'w';
fig.InvertHardcopy  = 'off';
fig.PaperPosition   = [0,10,8.45,8.45];
fig.Position = [0,10,twocolumn/4*0.95,twocolumn/4*0.95];

ax.FontName = fontname;ax.FontSize = fontsize;
ax.Color = ones(3,1)*0.97;

xlabel('Wavelength [nm]','FontSize',fontsize_axis);ylabel('Reflectance','FontSize',fontsize_axis);

ax.LineWidth = 0.8;
ax.Units = 'centimeters';
ticklengthcm(ax,0.1)
axis square;
ax.Position = [0.88 0.8 3.3 3.3];
box off;grid minor
ax.MinorGridLineStyle = ':';
ax.XMinorGrid = 'off';ax.YMinorGrid = 'on';
ax.LineWidth = 0.5;
exportgraphics(fig,fullfile('Figs','Figure1b.pdf'),'ContentType','vector')

%% Plot panel (c) illuminnt spectra 3000K, 6500K and 20000K
% temp = LT_GetBlackBodyspd(3000,400:10:700);spd.ill3000K = temp(:,2)/temp(16,2);
% temp = LT_GetBlackBodyspd(6500,400:10:700);spd.ill6500K = temp(:,2)/temp(16,2);
% temp = LT_GetBlackBodyspd(20000,400:10:700);spd.ill20000K = temp(:,2)/temp(16,2);
% 
% fig = figure;
% plot(spd.ill3000K,'Color',CCT_RGB(1,:),'LineWidth',1.5);hold on;
% plot(spd.ill6500K,'Color',CCT_RGB(2,:),'LineWidth',1.5)
% plot(spd.ill20000K,'Color',CCT_RGB(3,:),'LineWidth',1.5)
% scatter(16,1,30,[0.5 0.5 0.5],'o','filled','MarkerFaceAlpha',1)
% 
% ax = gca;axis square;
% ax.XLim = [1 31];ax.YLim = [0.0 2.8];
% ax.XTick = [1 16 31];ax.YTick = [0.0 1.4 2.8];
% 
% ax.XTickLabel = char('400','550','700');
% ax.YTickLabel = char('0.00','1.40','2.80');
% 
% fig.PaperType       = 'a4';fig.PaperUnits = 'centimeters';
% fig.Units           = 'centimeters';fig.Color  = 'w';
% fig.InvertHardcopy  = 'off';
% fig.PaperPosition   = [0,10,8.45,8.45];
% fig.Position = [0,10,twocolumn/3,twocolumn/3];
% 
% ax.FontName = fontname;ax.FontSize = fontsize;
% ax.Color = ones(3,1)*0.97;
% 
% xlabel('Wavelength [nm]','FontSize',fontsize_axis);ylabel('Relative energy','FontSize',fontsize_axis);
% 
% ax.LineWidth = 0.8;
% ax.Units = 'centimeters';
% axis square;
% ax.Position = [1.15 1 4.7 4.7];
% box off;grid minor
% ax.MinorGridLineStyle = ':';
% ax.LineWidth = 0.5;
% exportgraphics(fig,fullfile('Figs','Figure1c.pdf'),'ContentType','vector')
% 
%% Panel (d) L/(L+M) vs. Luminance
fig = figure;
for n = 1:length(CCT)
    ill_pre = LT_GetBlackBodyspd(CCT(n),400:10:720);
    ill = ill_pre(:,2);ill = ill/max(ill);
    
    [temp_SOCSAll,SOCSAll.RGB] = HSLightProbe_MultiSpectralVectortoMBandRGB_400to700(SOCSAll.Ref(:,1:31).*repmat(ill(1:31),1,size(SOCSAll.Ref,1))');
    temp_SOCSAll(:,3) = temp_SOCSAll(:,3)/temp_SOCSAll(end,3);SOCSAll.MB = temp_SOCSAll(1:end-1,:);
    
    % Plot optimal colors every 5 data points
    scatter(SOCSAll.MB(:,1),SOCSAll.MB(:,3),4,CCT_RGB(n,:),'o','filled','MarkerFaceAlpha',1);hold on;

    load(['OptimalColour_MB_bbl_',num2str(CCT(n)),'K'])
    % Plot optimal colors every 5 data points
    scatter(MB(1:5:end,1),MB(1:5:end,3),0.2,CCT_RGB(n,:),'o','filled','MarkerFaceAlpha',0.5);hold on;
end

ax = gca;axis square;
ax.XLim = [0.54 0.94];ax.YLim = [0.0 1.05];
ax.XTick = [0.540 0.74 0.94];ax.YTick = [0.0 0.5 1.0];

ax.XTickLabel = char('0.54','0.74','0.94');
ax.YTickLabel = char('0.00','0.50','1.00');

fig.PaperType       = 'a4';fig.PaperUnits = 'centimeters';
fig.Units           = 'centimeters';fig.Color  = 'w';
fig.InvertHardcopy  = 'off';
fig.PaperPosition   = [0,10,8.45,8.45];
fig.Position = [0,10,twocolumn/4*0.95,twocolumn/4*0.95];

ax.FontName = fontname;ax.FontSize = fontsize;
ax.Color = ones(3,1)*0.97;

xlabel('L/(L+M)','FontSize',fontsize_axis);ylabel('Luminance','FontSize',fontsize_axis);

ax.Units = 'centimeters';
axis square;
ax.Position = [0.88 0.8 3.3 3.3];
box off;grid minor
ax.XMinorGrid = 'off';ax.YMinorGrid = 'on';
ax.LineWidth = 0.5;
exportgraphics(fig,fullfile('Figs','Figure1d.pdf'),'ContentType','vector')

%% Panel (e) log S/(L+M) vs. Luminance
fig = figure;
for n = 1:length(CCT)    
    ill_pre = LT_GetBlackBodyspd(CCT(n),400:10:720);
    ill = ill_pre(:,2);ill = ill/max(ill);
    
    [temp_SOCSAll,SOCSAll.RGB] = HSLightProbe_MultiSpectralVectortoMBandRGB_400to700(SOCSAll.Ref(:,1:31).*repmat(ill(1:31),1,size(SOCSAll.Ref,1))');
    temp_SOCSAll(:,3) = temp_SOCSAll(:,3)/temp_SOCSAll(end,3);SOCSAll.MB = temp_SOCSAll(1:end-1,:);
    scatter(log10(SOCSAll.MB(:,2)),SOCSAll.MB(:,3),4,CCT_RGB(n,:),'o','filled','MarkerFaceAlpha',1);hold on;
    
    load(['OptimalColour_MB_bbl_',num2str(CCT(n)),'K'])
    scatter(log10(MB(1:5:end,2)),MB(1:5:end,3),0.2,CCT_RGB(n,:),'o','filled','MarkerFaceAlpha',0.5);hold on;
end

ax = gca;axis square;

ax.XLim = [-3 2];ax.YLim = [0.0 1.05];
ax.XTick = [-3 2];ax.YTick = [0.0 0.5 1.0];

ax.XTickLabel = char('-3.00','2.00');
ax.YTickLabel = char('0.00','0.50','1.00');

fig.PaperType       = 'a4';fig.PaperUnits = 'centimeters';
fig.Units           = 'centimeters';fig.Color  = 'w';
fig.InvertHardcopy  = 'off';
fig.PaperPosition   = [0,10,8.45,8.45];
fig.Position = [0,10,twocolumn/4*0.95,twocolumn/4*0.95];

ax.FontName = fontname;ax.FontSize = fontsize;
ax.Color = ones(3,1)*0.97;

xlabel('log_1_0 S/(L+M)','FontSize',fontsize_axis);ylabel('Luminance','FontSize',fontsize_axis);

ax.LineWidth = 0.8;
ax.Units = 'centimeters';
ticklengthcm(ax,0.0)
axis square;
ax.Position = [0.88 0.8 3.3 3.3];
box off;grid minor
ax.XMinorGrid = 'off';ax.YMinorGrid = 'on';
ax.LineWidth = 0.5;
exportgraphics(fig,fullfile('Figs','Figure1e.pdf'),'ContentType','vector')
