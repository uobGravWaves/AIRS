%Code to run the goodGWs and analyse easily

clear

%Where you store (locally) the goodGWs
folder = 'C:\Users\Peter\OneDrive - University of Bath\Desktop\BathBits\gitPROJECTS\AIRS\goodGWs\granules\';

%Date and granule you want
year = 2008;
month = 1;
days = 127;
granule = 57;

%Just to convert for the day of the year, if months are being used
x = datetime([year, month, days]);
days = day(x, 'dayofyear');

%This will create a folder structure such that prep_airs_3d can use it
string = {'airs', num2str(year), sprintf('%03i',days), sprintf('%03i',granule)};
string = join(string, "_");
string = [string{1}, '.nc'];
file = fullfile(folder, string);
newFolder = fullfile(folder, str(year), sprintf('%03i',days));
mkdir(newFolder);
%Copy in the new granule
copyfile(file, newFolder)
AIRS = prep_airs_3d(datenum(year, month, days), granule, 'fulldatadir', folder);%, 'DayNightFlag', true
aa = dir(newFolder);
%This removes the granule and deletes the folders, should leave things as
%they were
delete(fullfile(newFolder, aa(3).name));
rehash();
rmdir(fullfile(folder, str(year), sprintf('%03i',days)))
rmdir(fullfile(folder, str(year)))

%The classic S-Transform, use whatever params you want
[ST, Airs] = gwanalyse_airs_3d(AIRS, 'MaxWaveLength', [10000 10000 100], 'MinWaveLength', [25 25 6], 'TwoDPlusOne', true, 'NScales', 300);


