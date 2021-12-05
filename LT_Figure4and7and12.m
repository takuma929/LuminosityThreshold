close all;clearvars;clc % clean up

load LT_Data % load various Data

Key.illuminant = {'ill3000K','ill6500K','ill20000K'};
Key.distribution = {'Natural','Reverse','Flat'};
illList = [3000 6500 20000];

Type = {'A','B'};

% Set column size
twocolumn = 18.5;
onecolumn = twocolumn/2;

% Set font size for general use and axis
fontsize = 7;
fontsize_axis = 8;
fontname = 'Arial';

%% Plot surrounding color distributions
for Exp = 1:3
    Key = LT_Data.(['Exp',num2str(Exp)]).Key;
    illList = LT_Data.(['Exp',num2str(Exp)]).illList;
    TestChromaticity = LT_Data.(['Exp',num2str(Exp)]).TestChromaticity;

for dN = 1:length(Key.distribution)
for cctN = 1:length(Key.illuminant)

    Stimuli = LT_Data.(['Exp',num2str(Exp)]).Stimuli;
    if Exp == 3
        Stimuli_MB = Stimuli.(Key.distribution{dN}).(Key.illuminant{cctN}).('All');
        Test_Chromaticity = TestChromaticity.(Key.distribution{dN}).(Key.illuminant{cctN}).('All');
    else
        Stimuli_MB = Stimuli.(Key.distribution{dN}).(Key.illuminant{cctN});
        Test_Chromaticity = TestChromaticity.(Key.distribution{dN}).(Key.illuminant{cctN});
    end
    
    temp = Test_Chromaticity;temp(:,3) = 1;
    Test_Chromaticity_sRGB = LT_MBtoRGBImage(temp);
    Stimuli_sRGB = (LT_MBtoRGBImage(Stimuli_MB)*0.8)';
    
%% Plot color distribution
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

fig = figure;
load(['OP_',num2str(illList(cctN)),'_MB']);
line([MB(end,1) MB(end,1)],[-100 100],'LineStyle','-','Color',[0 0 0],'Linewidth',0.5);hold on;

if Exp == 1 || Exp == 2
    scatter(Stimuli_MB(:,1),Stimuli_MB(:,3),30,cmap,'o','filled','MarkerEdgeColor',[0.8 0.8 0.8],'MarkerFaceAlpha',0.4);hold on;
else
    scatter(Stimuli_MB(:,1),Stimuli_MB(:,3),30,cmap,'o','filled','MarkerEdgeColor',[0.8 0.8 0.8],'MarkerFaceAlpha',0.15);hold on;
end

% Convert MB to meanLMS
Stimuli_meanLMS(1) = mean(Stimuli_MB(:,1).*Stimuli_MB(:,3));
Stimuli_meanLMS(3) = mean(Stimuli_MB(:,2).*Stimuli_MB(:,3));
Stimuli_meanLMS(2) = mean(Stimuli_MB(:,3)-Stimuli_meanLMS(1));

% Convert back meanLMS to MB
Stimuli_meanLMS_MB(1) = Stimuli_meanLMS(1)./(Stimuli_meanLMS(1)+Stimuli_meanLMS(2));
Stimuli_meanLMS_MB(2) = Stimuli_meanLMS(3)./(Stimuli_meanLMS(1)+Stimuli_meanLMS(2));
Stimuli_meanLMS_MB(3) = Stimuli_meanLMS(1)+Stimuli_meanLMS(2);

scatter(Stimuli_meanLMS_MB(1),Stimuli_meanLMS_MB(3),80,'kx','Linewidth',1.5)

axis square;ax = gca;

% Adjust x-axis
if Exp == 1
    ax.XLim = [0.66 0.77];ax.XTick = [0.66 0.77];
    ax.XTickLabel = ["0.66","0.77"];xlabel('L/(L+M)');
elseif Exp == 2
    ax.XLim = [0.63 0.85];ax.XTick = [0.630 0.735 0.850];
    ax.XTickLabel = ["0.63","0.74","0.85"];xlabel('L/(L+M)');
elseif Exp == 3
    if strcmp(illList(cctN),'Magenta')
        ax.XLim = [0.71 0.84];ax.XTick = [0.71 0.84];
        ax.XTickLabel = ["0.71","0.84"];xlabel('L/(L+M)');  
    elseif strcmp(illList(cctN),'Green')
        ax.XLim = [0.65 0.72];ax.XTick = [0.65 0.72];
        ax.XTickLabel = ["0.65","0.72"];xlabel('L/(L+M)');
    end
end

% Adjust y-axis
if Exp == 1 || Exp == 2
    ax.YLim = [-1 30];ax.YTick = [0 15 30];ax.YTickLabel = ["0.00","15.0","30.0"];
elseif Exp == 3
    ax.YLim = [-0.3 10];ax.YTick = [0 5 10];ax.YTickLabel = ["0.0","5.0","10.0"];
end

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
ax.Color = ones(3,1)*0.97;
ax.Position = [0.97 0.8 3.4 3.4];
box on

grid minor
ax.XMinorGrid = 'off';ax.YMinorGrid = 'on';
switch Exp
    case 1
    exportgraphics(fig,fullfile('Figs',['Figure4a_',Key.distribution{dN},'.pdf']),'ContentType','vector')
    case 2 
    exportgraphics(fig,fullfile('Figs',['Figure7a_',Key.distribution{dN},'_',Key.illuminant{cctN},'.pdf']),'ContentType','vector')
    case 3
    exportgraphics(fig,fullfile('Figs',['Figure12a_',Key.distribution{dN},'_',Key.illuminant{cctN},'.pdf']),'ContentType','vector')
end

end
end
end

%% Plot test chromaticity
for Exp = 1:3
    Key = LT_Data.(['Exp',num2str(Exp)]).Key;
    illList = LT_Data.(['Exp',num2str(Exp)]).illList;
    TestChromaticity = LT_Data.(['Exp',num2str(Exp)]).TestChromaticity;

    if Exp == 3
        typeN = 2;
    else
        typeN = 1;
    end
    
    dN = 1;

for cctN = 1:length(Key.illuminant)
fig = figure;

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

    Stimuli = LT_Data.(['Exp',num2str(Exp)]).Stimuli;
    if Exp == 3
        Stimuli_MB = Stimuli.(Key.distribution{dN}).(Key.illuminant{cctN}).('All');
        Test_Chromaticity = TestChromaticity.(Key.distribution{dN}).(Key.illuminant{cctN}).('All');
    else
        Stimuli_MB = Stimuli.(Key.distribution{dN}).(Key.illuminant{cctN});
        Test_Chromaticity = TestChromaticity.(Key.distribution{dN}).(Key.illuminant{cctN});
    end
    
    temp = Test_Chromaticity;temp(:,3) = 1;
    Test_Chromaticity_sRGB = LT_MBtoRGBImage(temp);
    
    load MB_bbl_500to25000with500step
    scatter(Stimuli_MB(:,1),log10(Stimuli_MB(:,2)),40,cmap,'o','filled','MarkerEdgeColor',[0.85 0.85 0.85],'MarkerFaceAlpha',0.1);hold on;
    plot(MB_bbl_500to25000with500step(:,1),log10(MB_bbl_500to25000with500step(:,2)),'LineWidth',1,'Color',[0.9 0.1 0.1])
    
    if Exp == 1 || Exp == 2
        scatter(Test_Chromaticity(:,1),log10(Test_Chromaticity(:,2)),40,Test_Chromaticity_sRGB'*1.1,'o','filled','LineWidth',0.2,'MarkerEdgeColor',[0 0 0],'MarkerFaceAlpha',1);hold on
    elseif Exp == 3
        scatter(Test_Chromaticity([1:2 4:7],1),log10(Test_Chromaticity([1:2 4:7],2)),40,[0 0 0],'o','filled','LineWidth',0.5,'MarkerEdgeColor',[1 1 1],'MarkerFaceAlpha',1);hold on
        scatter(Test_Chromaticity([8:9 11:14],1),log10(Test_Chromaticity([8:9 11:14],2)),40,[0 0 0],'^','filled','LineWidth',0.5,'MarkerEdgeColor',[1 1 1],'MarkerFaceAlpha',1);hold on
        if cctN == 1
            scatter(Test_Chromaticity([8 11 12 13 14],1),log10(Test_Chromaticity([8 11 12 13 14],2)),30,[0 0 0],'^','filled','LineWidth',0.5,'MarkerEdgeColor',[1 0 0],'MarkerFaceAlpha',1);hold on
        elseif cctN == 2
            scatter(Test_Chromaticity([8 9 12 13 14],1),log10(Test_Chromaticity([8 9 12 13 14],2)),30,[0 0 0],'^','filled','LineWidth',0.5,'MarkerEdgeColor',[1 0 0],'MarkerFaceAlpha',1);hold on
        end
        scatter(Test_Chromaticity(3,1),log10(Test_Chromaticity(3,2)),50,[0 0 0],'s','filled','LineWidth',0.2,'MarkerEdgeColor',[1 1 1],'MarkerFaceAlpha',1);hold on
    end
    axis square;ax = gca;

    % Adjust x-axis
    if Exp == 1
        ax.XLim = [0.66 0.77];ax.XTick = [0.66 0.77];
        ax.XTickLabel = ["0.66","0.77"];xlabel('L/(L+M)');
        ax.YLim = [-1 1];ax.YTick = [-1 0 1];
        ax.YTickLabel = ["-1.0","0.0","1.0"];ylabel('log_1_0S/(L+M)');
    elseif Exp == 2
        ax.XLim = [0.63 0.84];ax.XTick = [0.63 0.84];
        ax.XTickLabel = ["0.63","0.84"];xlabel('L/(L+M)');
        ax.YLim = [-1 1];ax.YTick = [-1 0 1];
        ax.YTickLabel = ["-1.0","0.0","1.0"];ylabel('log_1_0S/(L+M)');
    elseif Exp == 3
        if strcmp(illList(cctN),'Magenta')
            ax.XLim = [0.72 0.84];ax.XTick = [0.72 0.84];
            ax.XTickLabel = ["0.63","0.84"];xlabel('L/(L+M)');
            ax.YLim = [-0.3 0.8];ax.YTick = [-0.3 0.8];
            ax.YTickLabel = ["-0.3","0.8"];ylabel('log_1_0S/(L+M)');
        elseif strcmp(illList(cctN),'Green')
            ax.XLim = [0.65 0.72];ax.XTick = [0.65 0.72];
            ax.XTickLabel = ["0.65","0.72"];xlabel('L/(L+M)');
            ax.YLim = [-0.9 -0.3];ax.YTick = [-0.9 -0.3];
            ax.YTickLabel = ["-1.0","0.0"];ylabel('log_1_0S/(L+M)');
        end
    end

    fig.PaperType       = 'a4';fig.PaperUnits = 'centimeters';
    fig.Units           = 'centimeters';fig.Color  = 'w';
    fig.InvertHardcopy  = 'off';
    fig.PaperPosition   = [0,10,9.5,8.45];
    fig.Position = [0,10,twocolumn/4,twocolumn/4];

    ax.FontName = fontname;ax.FontSize = fontsize;
    ax.LineWidth = 0.5;
    ax.Units = 'centimeters';
    axis square;
    ax.Color = ones(3,1)*0.97;
    ax.Position = [0.97 0.8 3.4 3.4];
    box on
    grid minor
    ax.XMinorGrid = 'on';ax.YMinorGrid = 'on';
    
    switch Exp 
        case 1
        exportgraphics(fig,fullfile('Figs','Figure4b.pdf'),'ContentType','vector')
        case 2 
        exportgraphics(fig,fullfile('Figs',['Figure7b_',Key.illuminant{cctN},'.pdf']),'ContentType','vector')
        case 3
        exportgraphics(fig,fullfile('Figs',['Figure12b_',Key.illuminant{cctN},'.pdf']),'ContentType','vector')
    end
end
end

