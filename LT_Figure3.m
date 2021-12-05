%% Generate Figure 3
clearvars;close all;clc % standard clean up

% loading data 
load LT_Data

rng(1); % freeze the seed for reproduciability

circleN = 10000; % number of circles to draw
circleSize = 1420; % size of each circle

Exp = 1;
Key = LT_Data.Exp1.Key;
illList = LT_Data.Exp1.illList;
TestChromaticity = LT_Data.Exp1.TestChromaticity;

%% Plot example of stimulus configuration for natural distribution, 6500K for Experiment 1
fig = figure;ax = gca;

Stimuli = LT_Data.Exp1.Stimuli;

Stimuli_MB = Stimuli.(Key.distribution{1}).(Key.illuminant{1});
Test_Chromaticity = TestChromaticity.(Key.distribution{1}).(Key.illuminant{1});

temp = Test_Chromaticity;temp(:,3) = 1;
Test_Chromaticity_sRGB = LT_MBtoRGBImage(temp);

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
    
exportgraphics(fig,fullfile('Figs','Figure3.png'),'Resolution',600)

% Fucntion to convert MacLeod-Boynton image to RGB image
function RGBImage = LT_MBtoRGBImage(MBImage)

% This is generated from spectral measurement of an experimental monitor
Matrix_LMS2RGB = [0.071311	-0.138524	0.001967
    -0.013737	0.078581	-0.002962
    -0.000745	-0.004354	0.014493];

imagesize = size(MBImage);

if length(imagesize) == 3
    MBImage_reshaped = reshape(MBImage,size(MBImage,1)*size(MBImage,2),size(MBImage,3));
elseif length(imagesize) == 2
    MBImage_reshaped = MBImage;
end
Luminance = MBImage_reshaped(:,3);
Redness = MBImage_reshaped(:,1);
Blueness = MBImage_reshaped(:,2);

Rlms_reshaped(:,1) = Luminance.*Redness;
Rlms_reshaped(:,3) = Luminance.*Blueness;
Rlms_reshaped(:,2) = Luminance-Rlms_reshaped(:,1);

RGBImage_reshaped = Matrix_LMS2RGB*Rlms_reshaped';

if length(imagesize) == 3
    RGBImage = reshape(RGBImage_reshaped',imagesize(1),imagesize(2),3);
elseif length(imagesize) == 2
    RGBImage = RGBImage_reshaped;
end

RGBImage= RGBImage/max(max(RGBImage(:)));
RGBImage = max(RGBImage,0);
RGBImage = power(RGBImage,1/2.2);
end
