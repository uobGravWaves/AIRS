%%
folder = 'C:\Users\Peter\OneDrive - University of Bath\Desktop\BathBits\gitPROJECTS\';

[ST, AIRS] = quanalGoodGWs(folder, 2007, 1, 13, 122);
%%
axkm = linarray(1, ST.point_spacing(1), 90);
alkm = linarray(1, ST.point_spacing(2), 135);


% toplot = ST.k(:,:,10);
% toplot = 1./toplot;
lat = AIRS.l1_lat;
lon = AIRS.l1_lon;
temp = binfine.*ST.IN(:,:,10);
toplot = temp;

fig = figure;
ax = axes;
% ax2 = axes;

pcolor(ax, alkm, axkm, toplot);shading flat
% pcolor(ax2,alkm, axkm, fin);shading flat
hold on
scatter(yi-20, xi-10, 40, 'black', 'filled');


% linkaxes([ax, ax2])
% ax2.Visible = 'off';
% ax2.XTick = [];
% ax2.YTick = [];


grid on

ax.OuterPosition = [-0.02, 0, 1, 1];

ax.Layer = "top";
ax.LineWidth = 1.7;
ax.TickDir = "out";
ax.YAxisLocation = "left";
ax.YTick = 0:round((axkm(end)/3.5)/100)*100:axkm(end);
ax.XAxisLocation = "bottom";
ax.Box = 'off';  
xline(ax.XLim(2),'-k', 'linewidth',ax.LineWidth);  
yline(ax.YLim(2),'-k', 'linewidth',ax.LineWidth);
ax.Color = [0.2, 0.2, 0.7];

ax.FontSize = 20;
ax.TitleFontSizeMultiplier = 2;
ax.Title.FontWeight = "bold";
ax.LabelFontSizeMultiplier = 1.5;
ax.Title.String = 'Waves Masked and Marked';
% ax.Subtitle.String = 'Areas of Different Waves Marked';
ax.Subtitle.FontSize = 20;
ax.XLabel.String = 'km';
ax.YLabel.String = 'km';


% cm = colormap(cbrewer2('Set1', 4));
colormap(ax, CustomColormap);
% colormap(ax2, 'parula');
collims = [-7, 7];
% collims = 'auto';
clim(collims)
% tempToplot(toplot >= collims(2)) = collims(2);
% tempToplot(toplot <= collims(1)) = collims(1);
cb = colorbar;
% 
% % tickval = adaptive_ticks(toplot, "numticks", 3 ,"roundo",0.0005, 'zero', 0, 'short', 1);
% % cb.Ticks = tickval;
cb.Ticks = [-6, -3, 0, 3, 6];

cb.Ruler.Exponent = 0;
cb.TickLength = 0.01;
cb.LineWidth = 1.2;
cb.TickDirection = "out";
cb.FontSize = ax.FontSize;
cb.Label.String = '\DeltaK';
cb.Label.Position = [3.8 range(cb.Limits)/2 + min(cb.Limits)];
cb.Label.Rotation = 270;

% text(2600, 1250, 'Wave 1')
% wave = annotation("textbox");
% wave.Position = [0.9, 0.645, 0.02, 0.04];
% wave.BackgroundColor = 'yellow';
% wave.LineWidth = 1.2;
% 
% text(2600, 1100, 'Wave 2')
% wave = annotation("textbox");
% wave.Position = [0.9, 0.58, 0.02, 0.04];
% wave.BackgroundColor = [0.392156862745098, 0.831372549019608, 0.0745098039215686];
% wave.LineWidth = 1.2;
% 
% text(2600, 930, 'Wave 3')
% wave = annotation("textbox");
% wave.Position = [0.9, 0.5150, 0.02, 0.04];
% wave.BackgroundColor = [0.850980392156863, 0.325490196078431, 0.0980392156862745];
% wave.LineWidth = 1.2;
% 
% text(2600, 780, 'No Wave')
% wave = annotation("textbox");
% wave.Position = [0.9, 0.45, 0.02, 0.04];
% wave.BackgroundColor = 'blue';
% wave.LineWidth = 1.2;


% fine = fin;
% fine(84:end, 82:117) = 4;
% fine(81:end, 70:71) = 1;
% fine(79:81, 54:55) = 1;
% 
% iii = edge(fine, 'sobel');
% [xi, yi] = find(iii);
% xi = xi*ST.point_spacing(1);
% yi = yi*ST.point_spacing(2);
% 
% 
% 
% binfine = fine;
% binfine(binfine == 1) = NaN;
% binfine(binfine>1) = 1;