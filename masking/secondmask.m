figure

cmon = ST;
mask = cmon.WaveMask(:,:,10);
% plotter = atan2(cmon.l(:,:,10),cmon.k(:,:,10)).*mask(:,:,10);
plotter = cmon.l(:,:,10).*mask;
% plot2 = ST12.IN(:,:,10).*ST12.WaveMask(:,:,10);

% plotter(plotter == 0) = NaN;
% plotter= filloutliers(plotter, "spline", 'movmean', [3 3]);
% plotter = abs(plotter);
plooter = ((plotter-min(plotter(:)))./range(plotter(:)));
plooter(plotter == 0) = 2;
Sigma = zeros(size(plooter));
for iDiff=1:1:1
    for iDir=1:1:2
        if     iDir == 1; x = size(plooter,1)-iDiff; y = size(plooter,2);
        elseif iDir == 2; x = size(plooter,1);       y = size(plooter,2)-iDiff;
        end     
        Sigma(1:x,1:y,:) = Sigma(1:x,1:y,:) + abs(diff(plooter,iDiff,iDir));
    end
end



plask = zeros(size(Sigma));
Sigma = Sigma.^0.5;
plask(Sigma >= 0.2) = 1;
plask = imbinarize(plask);
plask = bwmorph(plask, 'bridge', 1);
plask = bwmorph(plask, 'clean');
plask = imdilate(plask, strel([2 2]));
plask = bwmorph(plask, 'thin', 2);
plask = bwperim(plask, 4);
% plask(1, 218:230) = 1;

[B, label] = bwboundaries(plask, 8);

adj = isAdjacent(label);
for one = 1:size(adj, 1)
    labloc = find(adj(one, :));
    for dwa = 1:length(labloc)
        two = labloc(dwa);
        if (abs(mean(plotter(label == one), 'all', 'omitnan') - mean(plotter(label == two), 'all', 'omitnan')) < 0.7*std(plotter(label == one), 0, "all", 'omitnan'))
            label(label == two) = one;
        end
    end
end

pesp = plask.*100;
peep = label - pesp;
peep(peep<0) =NaN;
peep = fillmissing(peep, "nearest");
peep(peep == 0) = 0;

Mask2 = zeros(size(peep));
for iZ=1:1:size(peep,3)
  pp = regionprops(peep(:,:,iZ), 'area', 'PixelIdxList');
  stats = pp([pp.Area] > 100);
  M3 = Mask2(:,:,iZ);
  M3(vertcat(stats.PixelIdxList)) = 1;
  Mask2(:,:,iZ) = M3;
end
peip = peep.*Mask2;
peip(peip == 0) = NaN;
peip(peep == 0) = 0;
peip = fillmissing(peip, "nearest");
% figure
pcolor(double(peip(:, :))); shading flat


