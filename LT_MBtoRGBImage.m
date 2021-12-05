% Fucntion to convert MacLeod-Boynton image to RGB image
function RGBImage = LT_MBtoRGBImage(MBImage)

% This i based on measurement of an experimental monitor
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
% Note: this gamma correction is approximation (not based on the monitor measurement).
RGBImage = power(RGBImage,1/2.2);
end
