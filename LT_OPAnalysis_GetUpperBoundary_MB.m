function [MBOut,Z,r,b] = LT_OPAnalysis_GetUpperBoundary_MB(MB,res,interpolation,rmin,rmax,bmin,bmax)

MB(:,2) = log10(MB(:,2));

r.min = rmin;r.max = rmax;
b.min = bmin;b.max = bmax;

r.res = res;b.res = res;
r.range =  linspace(r.min,r.max,r.res);
b.range =  linspace(b.min,b.max,b.res);

MBOut = [];
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
        MBOut = vertcat(MBOut,MB(Id_range(Id),:)); 
    end
end

Z = imrotate(Z,90);
%Z = Z/MB(end,3);

if interpolation
    Z_boolean = boolean(Z);
    Z_boolean_filtered = imfilter(Z_boolean,ones(3,3));
    Z_double_filtered = double(Z_boolean_filtered);
    Z_double_filtered(find(Z_double_filtered==0)) = 100;

    Z(find(Z_double_filtered==100)) = 100;
    Z(find(Z==0)) = NaN;
    Z(find(Z==100)) = 0;
    Z = fillmissing(Z,'linear');
end

end