
load(fullfile(cd, 'drawnTrue/2010_1_4_85_11.mat'))
load(fullfile(cd, 'testWaves/2010_1_4_85.mat'))
strans = struct('k', ST.k(:,:,11), 'l', ST.l(:,:,11));
true = BW;
results = struct('sum', [], 'size', [], 'blur', [], 'wavelength', [], 'ratio', []);
for sumCutoff = 0.1:0.005:0.5
    sumCutoff
    for sizeCutoff = 50:5:300
        for blurCutoff = 0.1:0.5:0.5
            for wavelengthCutoff = 0:0.2:20

                mask = thirdMask(strans, sumCutoff, sizeCutoff, blurCutoff, wavelengthCutoff, {'k', 'l'}, [5, 5], 2);
                results.sum(end+1) = sumCutoff;
                results.size(end+1) = sizeCutoff;
                results.blur(end+1)= blurCutoff;
                results.wavelength(end+1) = wavelengthCutoff;
                results.ratio(end+1) = nnz(mask)/nnz(true);
            end
        end
    end
end

