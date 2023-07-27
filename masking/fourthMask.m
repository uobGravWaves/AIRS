%Fourth mask
clearvars -except ST
IN = ST;
IN.k_2dp1 = IN.k_2dp1(:,:,10);
IN.l_2dp1 = IN.l_2dp1(:,:,10);
Vars = {'k_2dp1', 'l_2dp1'};
Derivs = 2;
sumCutoff = 0.5;
sizeCutoff = 150;
SmoothSize = [5, 5];
blurCutoff = 0.3;
wavelengthCutoff = 50;

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

%Start of second mask

maskFill = imfill(Mask, 4, 'holes');

penulti = Sigma.*Mask;
% penulti(penulti<0.7*sumCutoff) = 0;
% penulti(penulti~=0) = 1;

plask = imbinarize(penulti);
wavelength = (1./(sqrt(IN.k_2dp1.^2 + IN.l_2dp1.^2)));

for d = 1:size(plask, 3)
    plask(:,:,d) = bwmorph(plask(:,:,d), 'majority');
    plask(:,:,d) = bwmorph(plask(:,:,d), 'thin', 2);
%     maskEdge = edge(maskFill(:,:,d));
%     plask(:,:,d) = plask(:,:,d)+maskEdge;
    plask(:,:,d) = bwperim(plask(:,:,d), 4);
    plask(:,:,d) = edge_linking(plask(:,:,d));
    plask(:,:,d) = bwmorph(plask(:,:,d), 'thin', 2);

%     plask(:,:,d) = bwmorph(plask(:,:,d), 'clean');
%     plask(:,:,d) = bwmorph(plask(:,:,d), 'diag');

%     plask(:,:,d) = bwmorph(plask(:,:,d), 'bridge', 2);
%     
%     plask(:,:,d) = bwperim(plask(:,:,d), 4);
%     
%     plask(1,:, d) = 1; plask(end,:, d) = 1; plask(:,1, d) = 1; plask(:,end, d) = 1;
    [B, label] = bwboundaries(plask(:,:,d), 8);
    plaplap = zeros(size(plask));
    pesp = plask(:,:,d).*100;
    peep = label - pesp;
    peep(peep<0) = NaN;
    peep = fillmissing(peep, "nearest");
    peep(peep == 0) = 0;
%     peep(1,:) = 0; peep(end,:) = 0; peep(:,1) = 0; peep(:,end) = 0;
    adj = isAdjacent(peep);
    pip = downer(peep);
    for f = 1:max(pip, [], 'all')
        pip(pip == f) = mean(wavelength(pip == f), 'all', 'omitnan');
    end
    for one = 1:size(adj, 1)
        labloc = find(adj(one, :));
        for dwa = 1:length(labloc)
            two = labloc(dwa);
%             lol(end+1) = abs(mean(wavelength(peep == one), 'all', 'omitnan') - mean(wavelength(peep == two), 'all', 'omitnan'));
            if (abs(mean(wavelength(peep == one), 'all', 'omitnan') - mean(wavelength(peep == two), 'all', 'omitnan')) < wavelengthCutoff)
%              if (abs(mean(wavelength(peep == one), 'all', 'omitnan') - mean(wavelength(peep == two), 'all', 'omitnan')) < 0.5*mean(wavelength(peep == one), 'all', 'omitnan'))
%                 disp('found')
%                 abs(mean(wavelength(peep == one), 'all', 'omitnan') - mean(wavelength(peep == two), 'all', 'omitnan'))
                plaplap(peep == two) = one;
                
            end
        end
    end
    pop(:,:,d) = plaplap;
end
max(pop, [], 'all')

% pop(Mask == 0) = NaN;






