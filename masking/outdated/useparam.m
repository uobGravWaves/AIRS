
% function [] = useparam(inFolder)

%Take the saved params and bin them (i.e. put them in the bin don't like it)
%     inFolder = '/data2/peter/maskAIRS'
    %addpath(inFolder)
    inFolder = 'C:\Users\Peter\OneDrive - University of Bath\Desktop\BathBits\airsMask\mjjatest';

    a = dir(fullfile(inFolder, '*.mat'));
    n = numel(a);


    bigLon = linspace(-180, 180, 721);
    bigLat = linspace(-90, 90, 361);
    [xq, yq] = ndgrid(bigLat, bigLon);

    

%     b = bin2mat(bigParam.lon(bigParam.daynight==0), bigParam.lat(bigParam.daynight==0), bigParam.A(bigParam.daynight==0), yq, xq, '@nanmean');
    
    finalADay = NaN([n, size(xq)]);
    finalBgDay = NaN([n, size(xq)]);
    finalKDay = NaN([n, size(xq)]);
    finalLDay = NaN([n, size(xq)]);
    finalMDay = NaN([n, size(xq)]);
    finalMaskDay = NaN([n, size(xq)]);

    finalANight = NaN([n, size(xq)]);
    finalBgNight = NaN([n, size(xq)]);
    finalKNight = NaN([n, size(xq)]);
    finalLNight = NaN([n, size(xq)]);
    finalMNight = NaN([n, size(xq)]);
    finalMaskNight = NaN([n, size(xq)]);


    for days = 1:n
        days
        load(fullfile(inFolder, a(days).name))
        idxD = bigParam.daynight==1;
        idxN = bigParam.daynight==0;

        finalADay(days, :, :) = bin2mat(bigParam.lon(idxD), bigParam.lat(idxD), bigParam.A(idxD), yq, xq, '@nanmean');
        finalBgDay(days, :, :) = bin2mat(bigParam.lon(idxD), bigParam.lat(idxD), bigParam.Bg(idxD), yq, xq, '@nanmean');
        finalKDay(days, :, :) = bin2mat(bigParam.lon(idxD), bigParam.lat(idxD), bigParam.k(idxD), yq, xq, '@nanmean');
        finalLDay(days, :, :) = bin2mat(bigParam.lon(idxD), bigParam.lat(idxD), bigParam.l(idxD), yq, xq, '@nanmean');
        finalMDay(days, :, :) = bin2mat(bigParam.lon(idxD), bigParam.lat(idxD), bigParam.m(idxD), yq, xq, '@nanmean');
        finalMaskDay(days, :, :) = bin2mat(bigParam.lon(idxD), bigParam.lat(idxD), bigParam.mask(idxD), yq, xq, '@nanmean');

        finalANight(days, :, :) = bin2mat(bigParam.lon(idxN), bigParam.lat(idxN), bigParam.A(idxN), yq, xq, '@nanmean');
        finalBgNight(days, :, :) = bin2mat(bigParam.lon(idxN), bigParam.lat(idxN), bigParam.Bg(idxN), yq, xq, '@nanmean');
        finalKNight(days, :, :) = bin2mat(bigParam.lon(idxN), bigParam.lat(idxN), bigParam.k(idxN), yq, xq, '@nanmean');
        finalLNight(days, :, :) = bin2mat(bigParam.lon(idxN), bigParam.lat(idxN), bigParam.l(idxN), yq, xq, '@nanmean');
        finalMNight(days, :, :) = bin2mat(bigParam.lon(idxN), bigParam.lat(idxN), bigParam.m(idxN), yq, xq, '@nanmean');
        finalMaskNight(days, :, :) = bin2mat(bigParam.lon(idxN), bigParam.lat(idxN), bigParam.mask(idxN), yq, xq, '@nanmean');
    end

    dayBinned = struct('A', single(finalADay), 'Bg', single(finalBgDay), 'k', single(finalKDay), 'l', single(finalLDay), 'm', single(finalMDay), 'mask', single(finalMaskDay));
    nightBinned = struct('A', single(finalANight), 'Bg', single(finalBgNight), 'k', single(finalKNight), 'l', single(finalLNight), 'm', single(finalMNight), 'mask', single(finalMaskNight));

    save dayBinnedTest dayBinned
    save nightBinnedTest nightBinned
%     avgADay = squeeze(nanmean(finalADay, 1));
%     avgBgDay = squeeze(nanmean(finalBgDay, 1));
%     avgKDay = squeeze(nanmean(finalKDay, 1));
%     avgLDay = squeeze(nanmean(finalLDay, 1));
%     avgMDay = squeeze(nanmean(finalMDay, 1));
%     avgMaskDay = squeeze(nanmean(finalMaskDay, 1));
% 
%     avgANight = squeeze(nanmean(finalANight, 1));
%     avgBgNight = squeeze(nanmean(finalBgNight, 1));
%     avgKNight = squeeze(nanmean(finalKNight, 1));
%     avgLNight = squeeze(nanmean(finalLNight, 1));
%     avgMNight = squeeze(nanmean(finalMNight, 1));
%     avgMaskNight = squeeze(nanmean(finalMaskNight, 1));
% 
%     avgMaskDay(avgMaskDay>0) = 1;
%     avgMaskNight(avgMaskNight>0) = 1;

%     save seasonAVGDay avgADay avgBgDay avgKDay avgLDay avgMDay avgMaskDay
%     save seasonAVGNight avgANight avgBgNight avgKNight avgLNight avgMNight avgMaskNight
