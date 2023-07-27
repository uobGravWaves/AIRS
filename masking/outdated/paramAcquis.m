
function [bigParam] = paramAcquis(year, month, day)
%Program 1: Get all params per day
    %Number of granules in a day
    nograns = 240;

    %Just establishing the output structure
    base = NaN(90, 135, nograns);    
    bigParam = struct('lat', base, 'lon', base, 'height', NaN(14, 1, nograns), 'time', base, 'daynight', base, 'Bg', base, 'A', base, 'k', base, 'l', base, 'm', base, 'mask', base);
    
    for granule = 1:nograns
        granule
	%Some days don't work, which is why the try catch statement is there
	%Took me ages to figure out why I wasn't getting anything out
        try
	    %You know this bit
            [Airs] = prep_airs_3d(datenum(year, month, day), granule, 'DayNightFlag', true);
            [ST, Airs] = gwanalyse_airs_3d(Airs, 'MaxWaveLength', [500 500 99e99], 'TwoDPlusOne', true);
            %Finds the index for 39km up
	    [~, zidx] = min(abs(Airs.ret_z-39));
            kms = zidx(1);
	    %Set up new structure with just one altitude (39km) and renames the "_2dp1" bits
            nST = struct('A', ST.A_2dp1(:,:,kms), 'k', ST.k_2dp1(:,:,kms), 'l', ST.l_2dp1(:,:,kms), 'm', ST.m_2dp1(:,:,kms), 'WaveMask', ST.WaveMask(:,:,kms));
    	    
	    %Fill the structure granule by granule with the relevant bitties
            bigParam.height(:, :, granule) = Airs.ret_z;
            bigParam.lat(:, :, granule) = Airs.l1_lat;
            bigParam.lon(:, :, granule) = Airs.l1_lon;
            bigParam.time(:, :, granule) = Airs.l1_time;
            bigParam.daynight(:, :, granule) = Airs.DayNightFlag;
            bigParam.Bg(:, :, granule) = Airs.BG(:,:,kms);
            bigParam.A(:, :, granule) = nST.A;
            bigParam.k(:, :, granule) = nST.k;
            bigParam.l(:, :, granule) = nST.l;
            bigParam.m(:, :, granule) = nST.m;
            bigParam.mask(:, :, granule) = nST.WaveMask;
        catch
            continue
        end
    
    end

    %I got bored writing this so you'll have to go in and changes the years yourself
    %But this is where the saving occurs
    date = join(string([year, month, day]), '_');
    if year == 2011   
    	save(fullfile('/data2/peter/maskAIRS/2011/', date), 'bigParam')
    elseif year == 2012
	save(fullfile('/data2/peter/maskAIRS/2012/', date), 'bigParam')
    elseif year == 2013
	save(fullfile('/data2/peter/maskAIRS/2013/', date), 'bigParam')
    end


end


