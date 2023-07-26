
[d, i] = min(abs(results.ratio-1));
strans = struct('k', ST.k(:,:,11), 'l', ST.l(:,:,11));
mask = thirdMask(strans, results.sum(i), results.size(i), results.blur(i), results.wavelength(i), {'k', 'l'}, [5, 5], 2);


mask = thirdMask(strans, 0.8, 150, 0.5, 50, {'k', 'l'}, [5, 5], 2);
[m, mm] = ssim(mask, ST.WaveMask(:,:,11));

figure;shat(ST.k(:,:,11))
figure;shat(mask)
x = 1:length(results.ratio);
figure

scatter(x, res2005.results.ratio, 'magenta')
hold on
scatter(x, res2007.results.ratio, 'red')
scatter(x, res2008.results.ratio, 'green')
legend
% title('2007')