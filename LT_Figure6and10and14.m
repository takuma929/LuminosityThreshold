clearvars
close all

load LT_Data

% Note: MaxLum model corresponds to surrounding color model in manuscript
ModelName = {'OP_GT','Real_GT','Real_smoothed_GT',...
    'OP_Peak','Real_Peak','Real_smoothed_Peak','MaxLum'};

cmap = [234 60 247;97 107 225;248 214 252;196 198 230;128 128 128]/255;

load colormap_observers % Load color for each participants

for Exp = 1:3
% load precomputed coefficients
load(['CorCoeff_Exp',num2str(Exp),'_new'])
clear list

Key = LT_Data.(['Exp',num2str(Exp)]).Key;
Results = LT_Data.(['Exp',num2str(Exp)]).Results;
Stimuli = LT_Data.(['Exp',num2str(Exp)]).Stimuli;
TestChromaticity = LT_Data.(['Exp',num2str(Exp)]).TestChromaticity;
illList = LT_Data.(['Exp',num2str(Exp)]).illList;
    
if Exp == 3
    typeN = 2;
    o_cmap = cmap_o.Exp3;
elseif Exp == 1
    typeN = 1;
    o_cmap = cmap_o.Exp1;
elseif Exp == 2
    typeN = 1;
    o_cmap = cmap_o.Exp2;
end

for type = 1:typeN
for cctN = 1:size(corCoeff_linear.OP_GT,2)
for dN = 1:size(corCoeff_linear.OP_GT,1)
 
if Exp == 1
    order = [1 4 3 2];
    list(1,:) = corCoeff_linear.OP_GT(dN,cctN,order);
    list(2,:) = corCoeff_linear.Real_smoothed_GT(dN,cctN,order);
    list(3,:) = corCoeff_linear.MaxLum(dN,cctN,order);
elseif Exp == 2
    order = [2 1 3 4];
    list(1,:) = corCoeff_linear.OP_GT(dN,cctN,order);
    list(2,:) = corCoeff_linear.Real_smoothed_GT(dN,cctN,order);
    list(3,:) = corCoeff_linear.OP_Peak(dN,cctN,order);
    list(4,:) = corCoeff_linear.Real_smoothed_Peak(dN,cctN,order);
    list(5,:) = corCoeff_linear.MaxLum(dN,cctN,order);
elseif Exp == 3
    list(1,:) = corCoeff_linear.OP_GT(dN,cctN,type,:);
    list(2,:) = corCoeff_linear.Real_smoothed_GT(dN,cctN,type,:);
    list(3,:) = corCoeff_linear.MaxLum(dN,cctN,type,:);
end


%% Heatmap
if Exp == 1
    filename = fullfile('Figs',['Figure6_',Key.distribution{dN},'.pdf']);
    DrawdHeatMapMatrix(list',filename,Exp);
elseif Exp == 2
    filename = fullfile('Figs',['Figure10_',Key.distribution{dN},'_',Key.illuminant{cctN},'.pdf']);
    DrawdHeatMapMatrix(list',filename,Exp);
elseif Exp == 3
    filename = fullfile('Figs',['Figure14_',Key.distribution{dN},'_',Key.illuminant{cctN},'_type',num2str(type),'.pdf']);
	DrawdHeatMapMatrix(list',filename,Exp);
end

end
end
end
end

function [fig,ax] = DrawdHeatMapMatrix(M,filename,Exp)
fig = figure;
cdepth = 1024;
c = brewermap(cdepth,'*RdBu');

M_max = zeros(size(M));
[~,Id] = max(M,[],2);
[M_sorted,Id_sort] = sort(M,2,'descend');

for o = 1:size(M,1)
    M_max(o,Id_sort(o,1)) = 1;
    if abs(M_sorted(o,1) - M_sorted(o,2)) < 10^-3
        M_max(o,Id_sort(o,2)) = 1;
    end
end

if Exp == 1
    s = 16;
    shift = 0.35;
elseif Exp == 2
    s = 10;
    shift = 0.3;
elseif Exp == 3
    s = 9;
    shift = 0.36;
end

FontSize = 7;

vMatrix = round((M+1)/2*cdepth+0.51);
vMatrix = max(vMatrix,0);
vMatrix = min(vMatrix,cdepth);

for n = 1:size(M,1)
    for m = 1:size(M,2)
        for k = 1:3
            cval = vMatrix(n,m);
            Out((n-1)*s+1:n*s,(m-1)*s+1:m*s,k) = repmat(c(cval,k),s);
        end
    end
end

imshow(Out);
for n = 1:size(M,2)
    for m = 1:size(M,1)
        if abs(M(m,n)) > 0.5
            text((n-1)*s+1+s/2*shift,(m-1)*s+1+s/2.1,num2str(M(m,n),'%#1.2f'),'FontSize',FontSize,'FontName','Arial','Color',[1 1 1])
        else
            text((n-1)*s+1+s/2*shift,(m-1)*s+1+s/2.1,num2str(M(m,n),'%#1.2f'),'FontSize',FontSize,'FontName','Arial','Color',[0 0 0])
        end
        if M_max(m,n) == 1
            text((n-1)*s+1+s/20.45,(m-1)*s+1+s/2*0.45,'*','FontSize',12,'FontName','Arial','Color',[0 1 1])
        end
    end
end

fig.InvertHardcopy = 'off';
fig.Color = 'w';

ax = gca;
ax.FontName = 'Arial';

set(gcf,'color','w');
ax.Position = [0 0.02 0.97 0.97];

exportgraphics(fig,filename,'ContentType','vector','BackgroundColor','current')
end