function Mask = thirdMask(strans, sumCutoff, sizeCutoff, blurCutoff, wavelengthCutoff,Vars,SmoothSize,Derivs)
%{
Creates a mask given an S-transform and a cutoff
Generally works by normalising the variables to between -1 and 1
Then takes the absolute difference between consecutive points
Sum these together for each variable (plus the second differential of each)
Anything less than the given cutoff is assumed to be a wave
Anything above the cutoff is noise

Then removes any small waves (this is slow feel free to comment out)
Does some smoothing and image wrangling then the mask is complete
%
%written by Peter Berthelemy, May 2023
%reformatted by Corwin Wright, June 2023 - no change to fundamental logic, but large syntactic changes
%}

%create an array we will use to sum all of the tests applied
Sigma = zeros(size(strans.k));

%now, for each variable used in the test...
for iVar=1:1:numel(Vars)

  %extract the variable from the input S-Transform structure and normalise it into the range -1 to 1
  V = strans.(Vars{iVar});
  V = ((V-min(V(:)))./range(V(:))) .*2 -1;
%   norm(:,:,:,iVar) = V;

  %compute the absolute value of the first NDerivs derivatives in each direction, and add this to the Sigma array
  for iDiff=1:1:Derivs(end)
    for iDir=1:1:2;
      if     iDir == 1; x = size(V,1)-iDiff; y = size(V,2);
      elseif iDir == 2; x = size(V,1);       y = size(V,2)-iDiff;
      end     
      Sigma(1:x,1:y,:) = Sigma(1:x,1:y,:) + abs(diff(V,iDiff,iDir));
    end
  end

end; clear iVar V iDiff iDir x y

%now, apply the cutoff to produce a binary mask
Mask = zeros(size(Sigma));
sumCutoff.*numel(Derivs).*numel(Vars);
Sigma = Sigma.^0.5;
Mask(Sigma <= sumCutoff.*numel(Derivs).*numel(Vars)) = 1;
clear sumCutoff

Mask2 = zeros(size(Mask));
for iZ=1:1:size(Mask,3)
  pp = regionprops(logical(Mask(:,:,iZ)), 'area', 'PixelIdxList');
  stats = pp([pp.Area] > sizeCutoff);
  M3 = Mask2(:,:,iZ);
  M3(vertcat(stats.PixelIdxList)) = 1;
  Mask2(:,:,iZ) = M3;
end 
Mask = Mask2;

Mask = smoothn(Mask,SmoothSize);
Mask(Mask > blurCutoff) = true;
Mask(Mask~=1) = 0;
% Mask = imclose(Mask, strel("disk",2));
% Mask = imfill(Mask, 'holes');
% bigshow(Mask)
Mask = imbinarize(Mask);
% figure;shat(Mask)
label = zeros(size(Mask));
twoedmask = zeros(size(Mask));
for s = 1:size(Mask, 3)
    wavelength = (1./(sqrt(strans.k.^2 + strans.l.^2)));

%     s
    Mask(:,:,s) = bwmorph(Mask(:,:,s), 'bridge', 1);
    Mask(:,:,s) = bwmorph(Mask(:,:,s), 'clean');
    Mask(:,:,s) = imdilate(Mask(:,:,s), strel([2 2]));
    Mask(:,:,s) = bwmorph(Mask(:,:,s), 'thin', 2);
    Mask(:,:,s) = bwperim(Mask(:,:,s), 4);


    [~, label(:,:,s)] = bwboundaries(Mask(:,:,s), 8);

    pesp = Mask(:,:,s).*100;
    peep = label(:,:,s) - pesp;
    peep(peep<0) =NaN;
    peep = fillmissing(peep, "nearest");
    peep(peep == 0) = 0;
%     figure;shat(label(:,:,s))
%     pop = zeros(size(peep));
    adj = isAdjacent(peep);
    for one = 1:size(adj, 1)
        wavelength(peep == one);
%         max(adj, [], 'all')
        one;
%         one
% max(peep, [], 'all')
        labloc = find(adj(one, :));
        for dwa = 1:length(labloc)
            two = labloc(dwa);
            abs(mean(wavelength(peep == one), 'all', 'omitnan') - mean(wavelength(peep == two), 'all', 'omitnan'));
            if (abs(mean(wavelength(peep == one), 'all', 'omitnan') - mean(wavelength(peep == two), 'all', 'omitnan')) < wavelengthCutoff)
                peep(peep == two) = one;
            end
            
%             for iVar=1:1:numel(Vars)
%                 V = squeeze(norm(:,:,:,iVar));
%                 if (abs(mean(V(peep, s) == one), 'all', 'omitnan') - mean(V(peep,s) == two), 'all', 'omitnan') < meanCutoff)
%                     labelCheck = labelCheck + 1;
%                 end
%             end
%             if labelCheck == iVar
%                 lab = label(:,:,s);
%                 lab(lab == two) = one;
%                 label(:,:,s) = lab;
%             else
%                 label(:,:,s) = label(:,:,s);
%             end
        end
    end
    twoedmask(:,:,s) = peep;
end

Mask = twoedmask;
%this mask is jumpy, which waves usually aren't. 
%to resolve this, first discard small unconnected regions at each height individually 
%(3D here is extremely computationally expensive and would give similar results)
% Mask2 = zeros(size(label));
% for iZ=1:1:size(label,3)
%   pp = regionprops(logical(twoedmask(:,:,iZ)), 'area', 'PixelIdxList');
%   stats = pp([pp.Area] > sizeCutoff);
%   M3 = Mask2(:,:,iZ);
%   M3(vertcat(stats.PixelIdxList)) = 1;
%   Mask2(:,:,iZ) = M3;
% end 
% Mask = Mask2;
% clear Mask2 iZ pp stats M3 sizeCutoff

% peip = twoedmask.*Mask;
% peip(peip == 0) = NaN;
% peip(peep == 0) = 0;
% Mask = fillmissing(peip, "nearest");
% 
% %finally, apply some smoothing to the end product and then filter the final product one last time
