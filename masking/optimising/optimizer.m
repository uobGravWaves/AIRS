
% load(fullfile(cd, 'drawnTrue/2010_1_4_85_11.mat'))
% load(fullfile(cd, 'testWaves/2010_1_4_85.mat'))

a = dir('C:\Users\Peter\OneDrive - University of Bath\Desktop\BathBits\gitPROJECTS\AIRS\masking\optimising\drawnTrue');
b = dir('C:\Users\Peter\OneDrive - University of Bath\Desktop\BathBits\gitPROJECTS\AIRS\masking\optimising\testWaves');
for num = 3:numel(a)
    load(fullfile(a(num).folder, a(num).name));
    load(fullfile(b(num).folder, b(num).name));
end
strans = struct('k', ST.k(:,:,10), 'l', ST.l(:,:,10), 'kh', ST.kh(:,:,10));
true = mask;
results = struct('sum', [], 'size', [], 'blur', [], 'wavelength', [], 'ratio', []);
for sumCutoff = 0.3:0.02:0.8
    sumCutoff
    for sizeCutoff = 50:5:300
        for blurCutoff = 0.1:0.05:0.5
            for wavelengthCutoff = 0:2:40

                mask = fifthMask(strans, sumCutoff, sizeCutoff, [5, 5], blurCutoff, wavelengthCutoff, {'k', 'l'}, 2);
                results.sum(end+1) = sumCutoff;
                results.size(end+1) = sizeCutoff;
                results.blur(end+1)= blurCutoff;
                results.wavelength(end+1) = wavelengthCutoff;
                results.ratio(end+1) = nnz(mask)/nnz(true);
            end
        end
    end
end

