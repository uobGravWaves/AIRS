function Mask = fifthMask(ST)

%Only use one frame of ST (for testing)
IN = ST;
%Use 2dp1 variables
% IN.k_2dp1 = IN.k_2dp1(:,:,10);
% IN.l_2dp1 = IN.l_2dp1(:,:,10);
IN.k_2dp1 = IN.F1;
IN.l_2dp1 = IN.F2;
Vars = {'k_2dp1', 'l_2dp1'};
Derivs = 2;
%Assign cutoffs
sumCutoff = 0.5;
sizeCutoff = 150;
SmoothSize = [5, 5];
blurCutoff = 0.3;
wavelengthCutoff = 100;

%First (binary) mask
%This still works pretty much perfectly
Sigma = zeros(size(IN.k_2dp1));
%now, for each variable used in the test...
for iVar=1:1:numel(Vars)
    %extract the variable from the input S-Transform structure and normalise it into the range -1 to 1
    V = IN.(Vars{iVar});
    V = ((V-min(V(:)))./range(V(:))).*2 -1;
    
    %compute the absolute value of the first NDerivs derivatives in each direction, and add this to the Sigma array
    for iDiff=1:1:Derivs
        for iDir=1:1:2
            if     iDir == 1; x = size(V,1)-iDiff; y = size(V,2);
            elseif iDir == 2; x = size(V,1);       y = size(V,2)-iDiff;
            end     
            Sigma(1:x,1:y,:) = Sigma(1:x,1:y,:) + abs(diff(V,iDiff,iDir));
        end
    end

end
clear iVar V iDiff iDir x y

%now, apply the cutoff to produce a binary mask
Mask = zeros(size(Sigma));
Mask(Sigma <= sumCutoff.*Derivs.*numel(Vars)) = 1;
% clear sumCutoff

%Get rid of anything smaller than sizeCutoff
Mask2 = zeros(size(Mask));
for iZ=1:1:size(Mask,3)
  pp = regionprops(logical(Mask(:,:,iZ)), 'area', 'PixelIdxList');
  stats = pp([pp.Area] > sizeCutoff);
  M3 = Mask2(:,:,iZ);
  M3(vertcat(stats.PixelIdxList)) = 1;
  Mask2(:,:,iZ) = M3;
end 
Mask = Mask2;

%Make the mask pretty
Mask = smoothn(Mask,SmoothSize);
Mask(Mask > blurCutoff) = true;
Mask(Mask~=1) = 0;