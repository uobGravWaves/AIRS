%%
folder = 'C:\Users\Peter\OneDrive - University of Bath\Desktop\BathBits\gitPROJECTS\';

[ST, AIRS] = quanalGoodGWs(folder, 2007, 1, 13, 122);
%%
axkm = linarray(1, ST.point_spacing(1), 90);
alkm = linarray(1, ST.point_spacing(2), 135);


toplot = ST.IN(:,:,10);
lat = AIRS.l1_lat;
lon = AIRS.l1_lon;


fig = figure;
ax = axes;


pcolor(alkm, axkm, toplot);shading flat
hold on

grid on
ax.Layer = "top";
ax.LineWidth = 1.7;
ax.TickDir = "out";
ax.YAxisLocation = "left";
ax.YTick = 0:round((axkm(end)/3.5)/100)*100:axkm(end);
ax.XAxisLocation = "bottom";
ax.Box = 'off';  
xline(ax.XLim(2),'-k', 'linewidth',ax.LineWidth);  
yline(ax.YLim(2),'-k', 'linewidth',ax.LineWidth);

ax.FontSize = 20;
ax.TitleFontSizeMultiplier = 2;
ax.Title.FontWeight = "bold";
ax.LabelFontSizeMultiplier = 1.5;
ax.Title.String = 'Input AIRS Granule';
ax.XLabel.String = 'km';
ax.YLabel.String = 'km';


cm = colormap(cbrewer2('PuOr', 19));
colormap(CustomColormap);
cb = colorbar;

tickval = prctile(toplot(:), [5 95]);
tickval = linspace(tickval(1), tickval(2), 3);
tickval = [ceil(min(toplot, [], "all")), round(tickval), floor(max(toplot, [], "all"))];

tickval = [tickval(1), -3, 0, 3, tickval(end)];
clim([-7 7])
tickval = [-6, -3, 0, 3, 6];
cb.Ticks = tickval;
cb.TickLength = 0.01;
cb.LineWidth = 1.2;
cb.TickDirection = "out";
cb.FontSize = ax.FontSize;
cb.Label.String = '\DeltaK';
cb.Label.Position = [3.8 range(cb.Limits)/2 + min(cb.Limits)];
cb.Label.Rotation = 270;



