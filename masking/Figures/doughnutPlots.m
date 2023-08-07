
%%
[bigLon, bigLat] = mapmake;
plottingST = nightBinned;
%Fix whatever's up with m, k, and l
plottingST = fixM(plottingST);
mask = plottingST.mask;
ampcutoff = plottingST.A;
variable1 = plottingST.A;
variable2 = plottingST.l;
% toplot = 1./((variable1.^2 + variable2.^2).^0.5);
% toplot = atan2(variable2, variable1);
toplot = variable1;
temp1 = toplot;
temp2 = toplot;
%For the mask
temp1(mask == 0) = NaN;
%For the amp cutoff
temp2(ampcutoff<1.6) = NaN;

maskedVar = squeeze(mean(temp1, 1, 'omitnan'));
ampedVar = squeeze(mean(temp2, 1, 'omitnan'));

toplot = ampedVar;

toplot = imgaussfilt(toplot,[2 2]);
% toplot = log(toplot);
%%
% figure
toplot(toplot<2) = NaN;
m_proj('stereographic','lat',-90,'long',30,'radius',70);
ax1 = axes;
ax2 = axes;
ax3 = axes;
grid off
hold on
axes(ax1)
s = m_surf(bigLon, bigLat, toplot);shading flat

% alfa = abs(toplot);
% alfa = (alfa ./ 2);
% alfa(alfa >= 1) = 1;
% s.AlphaData = alfa;
% s.EdgeColor = 'none';
s.FaceAlpha = 'flat';
s.FaceColor = 'flat';

s.AlphaData = s.CData;
s.AlphaDataMapping = 'scaled';
clim(ax1, [1.6, 5])

s.ZData = s.ZData - mean(toplot, 'all', 'omitnan');
% s.ZData = s.ZData - 2;
colormap(ax1, 'parula');


axes(ax2)
[cs, j] = m_elev('contourf',[-7000:1000:0 500:500:3000],'edgecolor','none');
% [cs, j] = m_elev('image');
% j.ZData = j.ZData + 3;
colormap(ax2,[m_colmap('blues',70);m_colmap('gland',30)]);  
clim(ax2,[-7000 3000]);   

% set(ax2 ,'Layer', 'Top')
% set(ax ,'Layer', 'Bottom')

% m_grid('linestyle','none','tickdir','out','linewidth',3);

axes(ax3)
hold on
[ch, c] = m_contour3(bigLon,bigLat,toplot,[2.5, 3, 3.5, 4, 4.5]);
c.ZData = c.ZData - mean(toplot, 'all', 'omitnan');
% c.ZData = c.ZData - 2;
c.LineWidth = 1;
c.EdgeColor = 'black';
clabel(ch,c,'labelspacing',500,'fontsize',10,'color','black','fontweight','normal');



h = get(gcf, 'Children');
set(gcf, 'Children', [h(3), h(2), h(1)])
axes(ax1)
% ax1.ZLim = [2, 7];
% ax2.ZLim = [2, 7];
% ax3.ZLim = [2, 7];
ax1.Color = 'none';
ax2.Color = 'none';
ax3.Color = 'none';
[~] = connectaxes2();
view([0 18]);
%     camzoom(2.5);
%     drawnow;
material dull

set(gca,...
    'xcolor','none','ycolor','none','zcolor','none',...
    'projection','perspective',...
    'clipping','off')

camlight
camlight('left')

ax1.Visible = "off";
ax2.Visible = "off";
ax3.Visible = "off";

%%