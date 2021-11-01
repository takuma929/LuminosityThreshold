close all;clearvars;clc

% Set column size
twocolumn = 18.5;
onecolumn = twocolumn/2;

% Set font size for general use and axis
fontsize = 7;
fontsize_axis = 8;
fontname = 'Arial';

%% Panel (a) Spectrum 3000K, 6500K, 20000K
load LT_Data
load('MB_bbl_500to30000with500step')

c_magenta = [237 87 247]/255;
c_green = [168 246 76]/255*0.8;
    
ill6500K = GetBlackBodyspd(6500,400:10:700);

Magenta = LT_Data.Exp3.Filter.Magenta.*ill6500K(:,2);Magenta = Magenta/max(Magenta);
Green = LT_Data.Exp3.Filter.Green.*ill6500K(:,2);Green = Green/max(Green);

fig = figure;
plot(smooth(Magenta),'Color',c_magenta,'LineWidth',1.5);hold on;
plot(smooth(Green),'Color',c_green,'LineWidth',1.5)

ax = gca;axis square;
ax.XLim = [1 31];ax.YLim = [0.0 1.05];
ax.XTick = [1 16 31];ax.YTick = [0.0 0.5 1];

ax.XTickLabel = char('400','550','700');
ax.YTickLabel = char('0.00','0.50','1.00');

fig.PaperType       = 'a4';fig.PaperUnits = 'centimeters';
fig.Units           = 'centimeters';fig.Color  = 'w';
fig.InvertHardcopy  = 'off';
fig.PaperPosition   = [0,10,8.45,8.45];
fig.Position = [0,10,twocolumn/4,twocolumn/4];

xlabel('wavelength [nm]','FontSize',fontsize_axis);
ylabel('Relative energy','FontSize',fontsize_axis);

ax.FontName = fontname;ax.FontSize = fontsize;

ax.Color = ones(3,1)*0.97;
ax.LineWidth = 0.5;
ax.Units = 'centimeters';
axis square;
ax.Position = [1.1 0.8 3.2 3.2];
box off
%grid on
grid minor
ax.XMinorGrid = 'off';ax.YMinorGrid = 'on';
exportgraphics(fig,fullfile('Figs','Figure11a.pdf'),'ContentType','vector')

%% Distribution of chromaticity 
c.magenta = HSLightProbe_MultiSpectralVectortoMBandRGB_400to700(Magenta');
c.green = HSLightProbe_MultiSpectralVectortoMBandRGB_400to700(Green');
c.ill6500K = HSLightProbe_MultiSpectralVectortoMBandRGB_400to700(ill6500K(:,2)');

fig = figure;
plot(MB_bbl_500to30000with500step(:,1),log10(MB_bbl_500to30000with500step(:,2)),'Color','r','LineWidth',0.5);hold on;
scatter(c.magenta(1),log10(c.magenta(2)),100,c_magenta,'x','LineWidth',2);hold on;
scatter(c.green(1),log10(c.green(2)),100,c_green,'x','LineWidth',2);hold on;
scatter(c.ill6500K(1),log10(c.ill6500K(2)),100,[0.5 0.5 0.5],'x','LineWidth',2);hold on;

ax = gca;axis square;

ax.XLim = [0.66 0.78];ax.YLim = [-0.7 0.4];
ax.XTick = [0.66 0.72 0.78];ax.YTick = [-0.7 0.4];

ax.XTickLabel = char('0.66','0.72','0.78');
ax.YTickLabel = char('-0.70','0.40');

fig.PaperType       = 'a4';fig.PaperUnits = 'centimeters';
fig.Units           = 'centimeters';fig.Color  = 'w';
fig.InvertHardcopy  = 'off';
fig.PaperPosition   = [0,10,8.45,8.45];
fig.Position = [0,10,twocolumn/4,twocolumn/4];

xlabel('L/(L+M)','FontSize',fontsize_axis);
ylabel('log_1_0S/(L+M)','FontSize',fontsize_axis);

ax.FontName = fontname;ax.FontSize = fontsize;

ax.LineWidth = 0.5;
ax.Units = 'centimeters';
axis square;
ax.Color = ones(3,1)*0.97;
ax.Position = [1.1 0.8 3.2 3.2];
box off
%grid on
ax.XMinorGrid = 'on';ax.YMinorGrid = 'on';
exportgraphics(fig,fullfile('Figs','Figure11b.pdf'),'ContentType','vector')
