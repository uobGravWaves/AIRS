
%Param Acquisition for Nimbus
%This will take AIRS data, apply a 2d+1 s transform, and save the required
%outputs
%This will be better than before, and will be made for nimbus

month = 1;

for year = 2010:1:2023
    for day = 1:365
        date = join(string([year, month, day]), '_');
        savelocation = fullfile('/data2/peter/maskAIRS/', num2str(year), date);
        
        dayParams = fullAquis(year, month, day);

        save(savelocation, 'dayParams')
    end
end

function [bigParam] = fullAquis(year, month, day)

    nograns = 239;
    base = NaN(90, 135, nograns);    
    bigParam = struct('lat', base, 'lon', base, 'height', 39, 'time', base, 'daynight', base, 'Bg', base, 'Tp', base, 'A', base, 'k', base, 'l', base, 'm', base, 'mask', base);
    
   
    for granule = 1:nograns
        dayofyear = sprintf("%03d",day);
        file = strcat('/data3/AIRS/3d_airs/',string(year),"/",dayofyear,"/airs_", string(year), "_", dayofyear, "_", sprintf("%03d",granule),".nc");
        file2 = strcat('/data3/AIRS/3d_airs/',string(year),"/",dayofyear,"/airs_", string(year), "_", dayofyear, "_", sprintf("%03d",granule+1),".nc");
        if exist(file) ~= 0
            if exist(file2) ~= 0

                [AirOne] = prep_airs_3d(datenum(year, month, day), granule, 'DayNightFlag', true);
                

                [AirTwo] = prep_airs_3d(datenum(year, month, day), granule+1, 'DayNightFlag', true);
                AirBoth = cat_struct(AirOne, AirTwo, 2, {'MetaData', 'Source', 'ret_z'});
%                 AirBoth.ret_z = AirTwo.ret_z;
                [ST, Airs] = gwanalyse_airs_3d(AirBoth, 'MaxWaveLength', [500 500 99e99], 'TwoDPlusOne', true);
                
                [~, zidx] = min(abs(Airs.ret_z-39));
                kms = zidx(1);
	            %Set up new structure with just one altitude (39km) and renames the "_2dp1" bits
                nST = struct('A', ST.A_2dp1(:,:,kms), 'k', ST.k_2dp1(:,:,kms), 'l', ST.l_2dp1(:,:,kms), 'm', ST.m_2dp1(:,:,kms), 'WaveMask', ST.WaveMask(:,:,kms));
        
%                 bigParam.height(:, :, granule) = Airs.ret_z;
                bigParam.lat(:, :, granule) = Airs.l1_lat(:, 67:201);
                bigParam.lon(:, :, granule) = Airs.l1_lon(:, 67:201);
                bigParam.time(:, :, granule) = Airs.l1_time(:, 67:201);
                bigParam.daynight(:, :, granule) = Airs.DayNightFlag(:, 67:201);
                bigParam.Bg(:, :, granule) = Airs.BG(:, 67:201,kms);
                bigParam.Tp(:, :, granule) = Airs.Tp(:, 67:201,kms);
                bigParam.A(:, :, granule) = nST.A(:, 67:201);
                bigParam.k(:, :, granule) = nST.k(:, 67:201);
                bigParam.l(:, :, granule) = nST.l(:, 67:201);
                bigParam.m(:, :, granule) = nST.m(:, 67:201);
                bigParam.mask(:, :, granule) = nST.WaveMask(:, 67:201);
                bigParam = cell2struct(cellfun(@single,struct2cell(bigParam),'uni',false),fieldnames(bigParam),1);
        
            else
                continue
            end
        else
            continue
        end
    end
end













