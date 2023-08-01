%Fourth mask
% clearvars -except ST

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

%Start of second mask
maskFill = imfill(Mask, 4, 'holes');

%Cleaning things (only really useful for testing but its cleaner)
penulti = Sigma.*Mask;
% penulti(penulti<0.7*sumCutoff) = 0;
% penulti(penulti~=0) = 1;

plask = imbinarize(penulti);
wavelength = (1./(sqrt(IN.k_2dp1.^2 + IN.l_2dp1.^2)));

%Can't do the bwmorphs on 3d things
for d = 1:size(plask, 3)

    %This tidies and finds the perimiters between regions
    %*a region is an area with slightly different wave parameters*
    %Not just the perimiter of the entire object
    plask(:,:,d) = bwmorph(plask(:,:,d), 'majority');
    plask(:,:,d) = bwmorph(plask(:,:,d), 'thin', 2);
    plask(:,:,d) = bwperim(plask(:,:,d), 4);
    %(funky funky function)
    plask(:,:,d) = edge_linking(plask(:,:,d));
    plask(:,:,d) = bwmorph(plask(:,:,d), 'thin', 2);

    %Labelling each region
    [B, label] = bwboundaries(plask(:,:,d), 8);
    plaplap = zeros(size(plask));
    %Getting rid of the borders between regions
    pesp = plask(:,:,d).*100;
    peep = label - pesp;
    peep(peep<0) = NaN;
    peep = fillmissing(peep, "nearest");
    peep(peep == 0) = 0;

    %Find which regions are next to each other
    adj = isAdjacent(peep);
    %Just for testing, to see what regions have what wavelengths
    pip = downer(peep);
    for f = 1:max(pip, [], 'all')
        pip(pip == f) = mean(wavelength(pip == f), 'all', 'omitnan');
    end
    %Uses the adjacency matrix to find which regions are next to each other
    for one = 1:size(adj, 1)
        labloc = find(adj(one, :));
        for dwa = 1:length(labloc)
            two = labloc(dwa);
            %See if the difference in wavelength between adjacent regions
            %is less than the cutoff
            %If it is, set the label of the second region to be the same as
            %the first region, thereby making a larger region
            %Stuff goes wrong here
            if (abs(mean(wavelength(peep == one), 'all', 'omitnan') - mean(wavelength(peep == two), 'all', 'omitnan')) < wavelengthCutoff)
%                 disp('found')
%                 abs(mean(wavelength(peep == one), 'all', 'omitnan') - mean(wavelength(peep == two), 'all', 'omitnan'))
                plaplap(peep == two) = one;                
            end
        end
    end
    pop(:,:,d) = plaplap;
end

%See how many regions are left, should be around 3 for this example
max(pop, [], 'all')






