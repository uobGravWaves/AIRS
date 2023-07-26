
%Check this shit out
%Base world map plotter
%I am the one who plots
[bigLon, bigLat] = mapmake;

plottingST = nightBinned;
plottingST = fixM(plottingST);

mask = plottingST.mask;
ampcutoff = plottingST.A;

variable1 = plottingST.k;
variable2 = plottingST.l;

toplot = 1./((variable1.^2 + variable2.^2).^0.5);
% toplot = atan2(variable2, variable1);
% toplot = variable1;
temp1 = toplot;
temp2 = toplot;
%For the mask
temp1(mask == 0) = NaN;
%For the amp cutoff
temp2(ampcutoff<1.6) = NaN;

maskedVar = squeeze(mean(temp1, 1, 'omitnan'));
ampedVar = squeeze(mean(temp2, 1, 'omitnan'));


color = 'BuPu';
colim = [300 1300];
% colim = "auto";

fig = figure;
subplot = @(m,n,p) subtightplot (m, n, p, 0.01, 0.01, 0.1);

one = subplot(1, 2, 1);

m_proj('miller', 'lat', [-75, 75], 'lon', [-180, 180])
m_pcolor(bigLon, bigLat, ampedVar)
col1 = colormap(flipud(cbrewer2(color)));
hold on
[shape] = coasts_only([-180,180], [-78, 78]);
for icost = 1:1:numel(shape)
    if numel(shape(icost).Lon)<100
        continue
    end
    m_plot(shape(icost).Lon,shape(icost).Lat,'k-')

end
m_grid('axes', one, 'box', 'on', 'xtick', [-120 -60 0 60 120], 'backgroundcolor', [0.7 0.7 0.7], 'linewidth', 2)
clim(colim)
title('Amplitude Cutoff: 1.6k')

two = subplot(1, 2, 2);

m_proj('miller', 'lat', [-75, 75], 'lon', [-180, 180])
m_pcolor(bigLon, bigLat, maskedVar)
col2 = colormap(flipud(cbrewer2(color)));
hold on
[shape] = coasts_only([-180,180], [-90, 90]);

for icost = 1:1:numel(shape)
    if numel(shape(icost).Lon)<100
        continue
    end
    m_plot(shape(icost).Lon,shape(icost).Lat,'k-')

end
m_grid('axes', two, 'box', 'on', 'yticklabels', [], 'xtick', [-120 -60 0 60 120], 'backgroundcolor', [0.7 0.7 0.7], 'linewidth', 2)
clim(colim)
originalSize2 = get(two, 'Position');
title('Masked')
cb = colorbar;
cb.Position = [0.1, 0];
cb.Label.String  = 'km';
cb.Label.Rotation = 270;
cb.Label.Position = [3.8, range(cb.Limits)/2 + min(cb.Limits)];
cb.Label.FontSize = 15;
set(two, 'Position', originalSize2)
text(-4.2, 2.4, 'Wavelength', 'FontSize',30)
% tit = sgtitle('Amplitude');
% tit.FontSize = 30;


