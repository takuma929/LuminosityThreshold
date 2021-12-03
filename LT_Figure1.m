%% Generate Figure 1

clearvars;close all;clc % clean up

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

% Load SOCS Data (MacLeod-Boynton chromaticity coordinates)
load('SOCS_MB');

bandpass = zeros(33,1);bandpass(11:21) = 1;
bandstop = ones(33,1);bandstop(11:21) = 0;
sRGB_bandpass = [0.6270 1 0];
sRGB_bandstop = [0.9361 0 1];

% list of correlated color temperatures
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
axis square;
ax.Position = [0.88 0.8 3.3 3.3];
box off;grid minor
ax.MinorGridLineStyle = ':';
ax.XMinorGrid = 'off';ax.YMinorGrid = 'on';
ax.LineWidth = 0.5;
exportgraphics(fig,fullfile('Figs','Figure1b.pdf'),'ContentType','vector')
    
%% Panel (c) L/(L+M) vs. Luminance
fig = figure;
for n = 1:length(CCT)

    % Plot L/(L+M) and relative luminance of SOCS datasets 
    scatter(SOCS_MB.(['ill',num2str(CCT(n))])(:,1),SOCS_MB.(['ill',num2str(CCT(n))])(:,3),4,CCT_RGB(n,:),'o','filled','MarkerFaceAlpha',1);hold on;
    
    % Load optimal colors (MacLeod-Boynton chromaticity diagram)
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
% Save in png because it takes a long time to save in pdf
exportgraphics(fig,fullfile('Figs','Figure1c.png'),'Resolution',600)

%% Panel (d) log S/(L+M) vs. Luminance
fig = figure;
for n = 1:length(CCT)    
    scatter(log10(SOCS_MB.(['ill',num2str(CCT(n))])(:,2)),SOCS_MB.(['ill',num2str(CCT(n))])(:,3),4,CCT_RGB(n,:),'o','filled','MarkerFaceAlpha',1);hold on;
    
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
axis square;
ax.Position = [0.88 0.8 3.3 3.3];
box off;grid minor
ax.XMinorGrid = 'off';ax.YMinorGrid = 'on';
ax.LineWidth = 0.5;
% Save in png because it takes a long time to save in pdf
exportgraphics(fig,fullfile('Figs','Figure1d.png'),'Resolution',600)
