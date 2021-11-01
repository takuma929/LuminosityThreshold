%% Generate Figure 3
clearvars;close all;clc % standard clean up

load LT_Data

rng(1); % freeze the seed for reproduciability

circleN = 10000;
circleSize = 1420;

Exp = 1;
Key = LT_Data.Exp1.Key;
illList = LT_Data.Exp1.illList;
TestChromaticity = LT_Data.Exp1.TestChromaticity;

%% Plot example of stimulus presentation for natural distribution, 6500K for Experiment 1
fig = figure;ax = gca;

Stimuli = LT_Data.Exp1.Stimuli;

Stimuli_MB = Stimuli.(Key.distribution{1}).(Key.illuminant{1});
Test_Chromaticity = TestChromaticity.(Key.distribution{1}).(Key.illuminant{1});

temp = Test_Chromaticity;temp(:,3) = 1;
Test_Chromaticity_sRGB = HSLightProbe_MBtoRGBImage(temp);

Stimuli_sRGB = (HSLightProbe_MBtoRGBImage(Stimuli_MB)*0.8)';

scatter(rand(circleN,1),rand(circleN,1),circleSize,Stimuli_sRGB(randi(size(Stimuli_sRGB,1),1,circleN),:),'o','filled');hold on 
scatter(0.5,0.5,circleSize,[0.8 0.8 0.8],'o','filled') 

axis square
ax.XLim = [0 1];ax.XTick = [];
ax.XTickLabel = [];xlabel('');

ax.YLim = [0 1];ax.YTick = [];
ax.YTickLabel = [];ylabel('');

fig.PaperType       = 'a4';fig.PaperUnits = 'centimeters';
fig.Units           = 'centimeters';fig.Color  = 'w';
fig.InvertHardcopy  = 'off';
fig.PaperPosition   = [0,10,10,10];
fig.Position = [0,10,10,10];

ax.FontName = 'Arial';ax.FontSize = 18;
ax.LineWidth = 0.5;
ax.Units = 'centimeters';
axis square;
ax.Color  = [0 0 0];
ax.Position = [0 0 10 10];
box on
    
print(fig,'-painters','-r600',fullfile('Figs','Figure3.png'),'-dpng')
