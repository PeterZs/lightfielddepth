function dispOut = weighted_median_filter_mask(dispIn, imgGuide, mask, vecDisps, r, epsilon)
%weighted_median_filter - Weighted median filter with guided filter weights
%
%   dispOut  = weighted_median_filter(dispIn, imgGuide, vecDisps, r, epsilon)
%
% INPUT:
%
%   dispIn   - Input 1-channel discrete disparity map, disparities must
%              come from vecDisps
%   imgGuide - Input guidance image, should be 3-channel RGB
%   vecDisps - Vector of disparities in consideration, must be intergers
%   r        - Local window radius for guided filter weights
%   epsilon  - Regularization parameter for guided filter weights
%

if ~exist('epsilon', 'var')
    epsilon = 0.01;
end

imgGuide = im2double(imgGuide);

dispOut  = zeros( size(dispIn) );
imgAccum = zeros( size(dispIn) );

gfObj = guidedfilter_color_precompute(imgGuide, r, epsilon);

I = zeros( size(dispOut, 1), size(dispOut, 2), length(vecDisps));

parfor d = 1:numel(vecDisps)
  img01 = guidedfilter_color_runfilter_mask(double(dispIn == vecDisps(d)), mask, gfObj);
  I(:, :, d) = img01;
end

for d = 1 : numel(vecDisps)
  %fprintf('%d of %d\n', d, numel(vecDisps));

    % apply guided filter to each slice
   % img01 = guidedfilter_color_runfilter(double(dispIn == vecDisps(d)));
    
    % accumulation to find median disp. for each pixel
    imgAccum = imgAccum + I(:, :, d); %img01;
    idxSelected = (imgAccum > 0.5) & (dispOut == 0);
    dispOut(idxSelected) = d;
end

dispOut = cast(dispOut, class(dispIn));

