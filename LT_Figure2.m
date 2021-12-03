%% Generate Figure 2
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

% load SOCS dataset (MacLeod-Boynton)
load SOCS_MB

convWindow = 3; % Window size for smoothing based on 2-D convolution

% Define color map for heatmap
cmap = brewermap(100000,'*Greys');
cmap(1,:) = [0.6322 0.6902 0.6919]; % Color for no data

%% Plot panel (a) left - drawing a grid on MacLeod-Boynton chromaticity diagram
load SpectrumLocus_MB

fig = figure;fig.Color = 'w';
scatter(SOCS_MB.ill6500(:,1),log10(SOCS_MB.ill6500(:,2)),20,[0.5 0.5 0.5],'o','filled','MarkerFaceAlpha',0.05);hold on

fig.PaperType       = 'a4';
fig.PaperUnits      = 'centimeters';
fig.PaperPosition   = [0,10,8.45,8.45];
fig.Units           = 'centimeters';
fig.Position = [0,10,twocolumn/4,twocolumn/4];
fig.Color           = 'w';
fig.InvertHardcopy  = 'off';

ax = gca;
ax.XTick = [0.56 0.73 0.90];ax.XLim = [0.56 0.90];
ax.YTick = [-1.62,0,1.22];ax.YLim = [-1.62 1.22];
ax.XTickLabel = char('0.56','0.73','0.90');
ax.YTickLabel = char('-1.62','0.00','1.22');
ax.FontName = fontname;ax.FontSize = fontsize;
xlabel('L/(L+M)','FontSize',fontsize_axis);ylabel('log_1_0 S/(L+M)','FontSize',fontsize_axis);

ax.Units = 'centimeters';
axis square;


% number of grid lines (25 by 25 grid)
res = 25;

r_range = linspace(0.56,0.90,res+1);
b_range = linspace(-1.62,1.22,res+1);

% Draw grid lines
for r = r_range
    l = line([r,r],[-2 2]);l.LineWidth = 0.5;
    l.Color = [0.7 0.7 0.7];
end

for b = b_range
    l = line([0 1],[b b]);l.LineWidth = 0.5;
    l.Color = [0.7 0.7 0.7];
end

% Draw a magenta square
id = 16;
l = line([r_range(id+3) r_range(id+4)],[b_range(id) b_range(id)]);l.LineWidth = 1;l.Color = [1 0.5 1];
l = line([r_range(id+3) r_range(id+4)],[b_range(id+1) b_range(id+1)]);l.LineWidth = 1;l.Color = [1 0.5 1];
l = line([r_range(id+3) r_range(id+3)],[b_range(id) b_range(id+1)]);l.LineWidth = 1;l.Color = [1 0.5 1];
l = line([r_range(id+4) r_range(id+4)],[b_range(id) b_range(id+1)]);l.LineWidth = 1;l.Color = [1 0.5 1];

% Plot spectrum locus
plot(SpectrumLocus_MB(:,2),smoothdata(log10(SpectrumLocus_MB(:,3))),'Color',[0 0 0],'LineWidth',1);

ax.Position = [1.1 0.8 3.28 3.28];
box on;grid off
ax.MinorGridLineStyle = ':';
ax.LineWidth = 0.5;
exportgraphics(fig,fullfile('Figs','Figure2a_1.png'),'Resolution',600)

%% Plot panel (a) - finding highest luminance in a grid cell
Id = find(SOCS_MB.ill6500(:,1)>r_range(id)&SOCS_MB.ill6500(:,1)<r_range(id+1) &...
    SOCS_MB.ill6500(:,2)>b_range(id)&SOCS_MB.ill6500(:,2)<b_range(id+1));

Colors_box = SOCS_MB.ill6500(Id,:);

Colors_box(:,3) = Colors_box(:,3)/max(Colors_box(:,3))*0.8;

[~,maxId] = max(Colors_box(:,3));

fig = figure;fig.Color = 'w';
scatter3(Colors_box(:,1),Colors_box(:,2),Colors_box(:,3),40,[0.5 0.5 0.5],'o','filled','MarkerFaceAlpha',0.1);hold on
scatter3(Colors_box(maxId,1),Colors_box(maxId,2),Colors_box(maxId,3),20,[1 0.5 1]*0.9,'o','filled');hold on
l = line([r_range(id) r_range(id+1)],[b_range(id) b_range(id)],[0 0]);l.LineWidth = 1;l.Color = [1 0.5 1]*0.9;
l = line([r_range(id) r_range(id+1)],[b_range(id+1) b_range(id+1)],[0 0]);l.LineWidth = 1;l.Color = [1 0.5 1]*0.9;
l = line([r_range(id) r_range(id)],[b_range(id) b_range(id+1)],[0 0]);l.LineWidth = 1;l.Color = [1 0.5 1]*0.9;
l = line([r_range(id+1) r_range(id+1)],[b_range(id) b_range(id+1)],[0 0]);l.LineWidth = 1;l.Color = [1 0.5 1]*0.9;

l = line([r_range(id) r_range(id+1)],[b_range(id) b_range(id)],[1 1]);l.LineWidth = 1;l.Color = [1 0.5 1]*0.9;
l = line([r_range(id) r_range(id+1)],[b_range(id+1) b_range(id+1)],[1 1]);l.LineWidth = 1;l.Color = [1 0.5 1]*0.9;
l = line([r_range(id) r_range(id)],[b_range(id) b_range(id+1)],[1 1]);l.LineWidth = 1;l.Color = [1 0.5 1]*0.9;
l = line([r_range(id+1) r_range(id+1)],[b_range(id) b_range(id+1)],[1 1]);l.LineWidth = 1;l.Color = [1 0.5 1]*0.9;

l = line([r_range(id) r_range(id)],[b_range(id) b_range(id)],[0 1]);l.LineWidth = 1;l.Color = [1 0.5 1]*0.9;
l = line([r_range(id+1) r_range(id+1)],[b_range(id) b_range(id)],[0 1]);l.LineWidth = 1;l.Color = [1 0.5 1]*0.9;
l = line([r_range(id) r_range(id)],[b_range(id+1) b_range(id+1)],[0 1]);l.LineWidth = 1;l.Color = [1 0.5 1]*0.9;
l = line([r_range(id+1) r_range(id+1)],[b_range(id+1) b_range(id+1)],[0 1]);l.LineWidth = 1;l.Color = [1 0.5 1]*0.9;

ax = gca;

fig.PaperType       = 'a4';
fig.PaperUnits      = 'centimeters';
fig.PaperPosition   = [0,10,10.45,8.45];
fig.Units           = 'centimeters';
fig.Position = [0,10,twocolumn/4,twocolumn/4];

fig.Color           = 'w';
fig.InvertHardcopy  = 'off';

ax.XTick = [r_range(id) r_range(id+1)];ax.XLim = [r_range(id)-0.001 r_range(id+1)+0.001];
ax.YTick = [b_range(id) b_range(id+1)];ax.YLim = [b_range(id)-0.01 b_range(id+1)+0.01];
ax.ZTick = [0 1.0];ax.ZLim = [0 1];

ax.XTickLabel = char('0.764','0.778');
ax.YTickLabel = char('0.0840','0.198');
ax.ZTickLabel = char('0.00','1.00');

ax.FontName = fontname;
ax.FontSize = fontsize;

xlabel('','FontSize',fontsize_axis);
ylabel('','FontSize',fontsize_axis);
zlabel('Relative Luminance','FontSize',fontsize_axis);

ax.Units = 'centimeters';

axis square;
ax.Position = [0.92 0.8 3.1 3.1];
view([-30 18])
grid off
box off

exportgraphics(fig,fullfile('Figs','Figure2a_2.pdf'),'ContentType','vector')

%% Plot panel (b) - Upper limit luminance for optimal colors under 6500K
rmin = 0.56;rmax = 0.90;
bmin = -1.62;bmax = 1.22;

load('OP_6500_MB');
resolution = 26;

MB_ill = [0.6997 1.1213]; % chromaticity of 6500K

[Z_OP,r,b] = LT_GetUpperBoundary_MB(MB,resolution,rmin,rmax,bmin,bmax);

% Find which cell does the illuminnat chromaticity belong to
Id_r = find(r.range-MB_ill(1)>0);
Id_b = find(b.range-log10(MB_ill(2))>0);
r_ill = Id_r(1) - 1;b_ill = Id_b(1) - 1;

fig = figure;imagesc(Z_OP);hold on;colormap(cmap);axis square;ax = gca;
scatter(r_ill,resolution-b_ill,45,'rx');
ax.XLim = [0.5 resolution-0.5];ax.XTick = [0.5 resolution-0.5];ax.XTickLabel = char('0.56','0.90');
ax.YLim = [0.5 resolution-0.5];ax.YTick = [0.5 resolution-0.5];ax.YTickLabel = char(num2str(round(b.max*100)/100),num2str(round(b.min*100)/100));
caxis([0 1])

fig.PaperType       = 'a4';fig.PaperUnits = 'centimeters';
fig.Units           = 'centimeters';fig.Color  = 'w';
fig.InvertHardcopy  = 'off';
fig.PaperPosition   = [0,10,9.5,8.45];
fig.Position = [0,10,twocolumn/4*0.95,twocolumn/4*0.95];

xlabel('L/(L+M)');ylabel('log_1_0 S/(L+M)');
ax.FontName = fontname;ax.FontSize = fontsize;
ax.LineWidth = 0.8;
ax.Units = 'centimeters';
axis square;
ax.Position = [1.07 0.9 3.1 3.1];
box off;grid off
ax.LineWidth = 0.5;
exportgraphics(fig,fullfile('Figs','Figure2b_1.pdf'),'ContentType','vector')

%% Plot panel (b) - Upper limit luminance for SOCS dataset

[Z_SOCS,~,~] = LT_GetUpperBoundary_MB(SOCS_MB.ill6500,resolution,rmin,rmax,bmin,bmax);

% Smoothing 0 means no-smoothing, 1 means smoothing
for smoothing = 0:1
    fig = figure;

    if smoothing == 0
        I = Z_SOCS;
    elseif smoothing == 1
        I = conv2(Z_SOCS, ones(convWindow,convWindow)/convWindow^2, 'same');
    end
    
    I(Z_SOCS==0) = 0;

    imagesc(I/max(I(:)));hold on;
    colormap(cmap);axis square;ax = gca;
    scatter(r_ill,resolution-b_ill,45,'rx');
    ax.XLim = [0.5 resolution-0.5];ax.XTick = [0.5 resolution-0.5];ax.XTickLabel = char('0.56','0.90');
    ax.YLim = [0.5 resolution-0.5];ax.YTick = [0.5 resolution-0.5];ax.YTickLabel = char('-1.62','0.00','1.22');

    caxis([0 1])

    fig.PaperType       = 'a4';fig.PaperUnits = 'centimeters';
    fig.Units           = 'centimeters';fig.Color  = 'w';
    fig.InvertHardcopy  = 'off';
    fig.PaperPosition   = [0,10,9.5,8.45];
    fig.Position = [0,10,twocolumn/4*0.95,twocolumn/4*0.95];

    xlabel('L/(L+M)','FontSize',fontsize_axis);
    ylabel('log_1_0 S/(L+M)','FontSize',fontsize_axis);
    ax.FontName = fontname;ax.FontSize = fontsize;
    ax.Units = 'centimeters';

    axis square;
    ax.Position = [1.07 0.9 3.1 3.1];
    box off;grid off
    ax.MinorGridLineStyle = ':';
    ax.LineWidth = 0.5;
    if smoothing == 0
        exportgraphics(fig,fullfile('Figs','Figure2b_2.pdf'),'ContentType','vector')
    elseif smoothing == 1
        exportgraphics(fig,fullfile('Figs','Figure2b_3.pdf'),'ContentType','vector')
    end
end

%% Custom function to get upper boundary for each cell
function [Z,r,b] = LT_GetUpperBoundary_MB(MB,res,rmin,rmax,bmin,bmax)

MB(:,2) = log10(MB(:,2));

r.min = rmin;r.max = rmax;
b.min = bmin;b.max = bmax;

r.res = res;b.res = res;
r.range = linspace(r.min,r.max,r.res);
b.range = linspace(b.min,b.max,b.res);

for x = 1:length(r.range)-1
    for y = 1:length(b.range)-1
        r.lower = r.range(x);r.upper = r.range(x+1);
        b.lower = b.range(y);b.upper = b.range(y+1);
        Id_range = find(MB(1:end-1,1)>r.lower & MB(1:end-1,1)<r.upper & MB(1:end-1,2)>b.lower & MB(1:end-1,2)<b.upper);
        Colors = MB(Id_range,:);
        [Lum,Id] = max(Colors(:,3));
        if length(Id_range)
            Z(x,y) = Lum;
        else
            Z(x,y) = 0;
        end
    end
end

Z = imrotate(Z,90);

end