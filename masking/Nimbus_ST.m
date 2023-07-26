%Param Acquisition for Nimbus OOF
%%branchy branch..
%This will take AIRS data, apply a 2d+1 s transform, and save the required
%outputs
%This will be better than before, and will be made for nimbus

month = 1;

for year = 2012:1:2012
    for day = 183:183
        date = join(string([year, month, day]), '_');
        savelocation = fullfile(LocalDataDir, 'peter',num2str(year));
        filename = fullfile(savelocation, date);
        
        dayParams = fullAquis(year, month, day);
        
        if exist(savelocation) == 0
            mkdir(savelocation);
        end

        save(filename, 'dayParams')
    end
end

function [bigParam] = fullAquis(year, month, day)

    nograns = 240;
    base = NaN(90, 135, nograns);    
    bigParam = struct('lat', base, 'lon', base, 'height', 39, 'time', base, 'daynight', base, 'Bg', base, 'Tp', base, 'A', base, 'k', base, 'l', base, 'm', base, 'mask', base);
    
   
    for granule = 1:nograns
    % for granule = 240
        granule

        dayofyear = sprintf("%03d",day);

        if granule == 240
            file = strcat(LocalDataDir,'/AIRS/3d_airs/',string(year),"/",dayofyear,"/airs_", string(year), "_", dayofyear, "_", sprintf("%03d",granule),".nc");
            file2 = strcat(LocalDataDir,'/AIRS/3d_airs/',string(year),"/",sprintf("%03d", day+1),"/airs_", string(year), "_", sprintf("%03d", day+1), "_", sprintf("%03d",1),".nc");
            
        else
    
            file = strcat(LocalDataDir,'/AIRS/3d_airs/',string(year),"/",dayofyear,"/airs_", string(year), "_", dayofyear, "_", sprintf("%03d",granule),".nc");
            file2 = strcat(LocalDataDir,'/AIRS/3d_airs/',string(year),"/",dayofyear,"/airs_", string(year), "_", dayofyear, "_", sprintf("%03d",granule+1),".nc");
        end % if granule = 240

        if exist(file) 
            if exist(file2) 

                [AirOne] = prep_airs_3d(datenum(year, month, day), granule, 'DayNightFlag', true);
                
                [AirTwo] = prep_airs_3d(datenum(year, month, day), granule+1, 'DayNightFlag', true);

                AirBoth = cat_struct(AirOne, AirTwo, 2, {'MetaData', 'Source', 'ret_z'});
%                 AirBoth.ret_z = AirTwo.ret_z;
                [ST, Airs] = gwanalyse_airs_3d(AirBoth, 'MaxWaveLength', [500 500 99e99], 'TwoDPlusOne', true);
                
                %Adding the "second mask" here so I dont fuck up gwanalyse
                %If it doesn't work (because it hates me), comment it out
                %and change the nST line back to "ST.WaveMask" instead of
                %"mask"
                mask = thirdMask(ST, 0.8, 150, 0.5, 50, {'k', 'l'}, [5, 5, 1], 2);

                [~, zidx] = min(abs(Airs.ret_z-39));
                kms = zidx(1);
                 %Set up new structure with just one altitude (39km) and renames the "_2dp1" bits
                nST = struct('A', ST.A_2dp1(:,:,kms), 'k', ST.k_2dp1(:,:,kms), 'l', ST.l_2dp1(:,:,kms), 'm', ST.m_2dp1(:,:,kms), 'WaveMask', mask(:,:,kms));
        
                % bigParam.height(:, :, granule) = Airs.ret_z;
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
                disp(strcat('File not found', file2));
                continue
            end
        else
            disp(strcat('File not found', file1));
            continue
        end
    end
end





