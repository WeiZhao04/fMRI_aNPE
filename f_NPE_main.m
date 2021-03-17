function [Z,Y] = f_NPE_main(fdir,otdir,opts)


%% initial parse
opts = f_npe_parse(fdir,opts);
%% NPE-based dimensionality reduction
% the default mode taking all subjects as one homogeneous group

if ~isequal(opts.initPOOL,1)
    [Y] = f_NPE_OneGroup(fdir,opts);
else
    % [Y] = f_NPE_POOL(fdir,opts);
end
%% save the outputs
ndir = [otdir filesep 'NPE'];
if ~exist(ndir,'dir')
    mkdir(ndir)
end

for ks = 1:opts.num_subjects
    strs = strsplit(fdir{Y.IND(ks)},'\');
    name = ['npe_' strs{end}(1:end-4)];
    Ynpe = Y.npe{ks};
    save([ndir filesep name],'Ynpe')
end
%% temporal concatenate PCA
cY = cell2mat(Y.npe);
[coeff,score,latent] = pca(cY,'centered','off');
Z.score = score;
Z.coeff = coeff;
Z.latent = latent;
%% 

end

