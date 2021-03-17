clc;clear;
close all;
%%
profile on
addpath('./CoCA-standalone')
pwd = 'G:\NPE-Group\NPE-simu';
%% files
subsdir = 'Mdata';
prefix = 'Mdata*';

SUB = [pwd filesep subsdir filesep];
files = dir([SUB prefix]);
filedir = strcat(SUB,{files.name});

%% parameters setting
opts.num_subjects = 5;
opts.thres = 0.1;
%% NPE
outdir = [pwd filesep 'result'];
mkdir(outdir);

[Znpe,sY] = f_NPE_main(filedir,outdir,opts);

save([outdir filesep 'Znpe'],'Znpe')
%% Fast ICA from ICASSO
% model order and other paras
Num_IC = 25:30;
runs = 3;
MaxIteration = 500;
% output dirs
ICAdir = [outdir filesep 'ICA_results'];
if ~exist(ICAdir,'dir')
    mkdir(ICAdir)
end
%% Run ICA
for NoC = Num_IC
    [sR,step]=icassoEst('both', Znpe.score(:,1:NoC)',runs, 'g','tanh', ...
        'approach', 'symm','maxNumIterations',MaxIteration);
    sR=icassoExp(sR);
    [iq,A,W,SM] = icassoResult(sR,NoC);
    % save ICs
    subdir = [ICAdir filesep 'MO_' sprintf('%0.3i',NoC)];
    mkdir(subdir)
    save([subdir filesep 'SM'],'SM')
    C = mat2cell(Znpe.coeff(:,1:NoC)*A,sY.Len);
    TCs = cell(1,opts.num_subjects);
    for k = 1:opts.num_subjects
        TCs{k} = rownorm(sY.cof{k}*C{k});
    end
    TC = cell2mat(TCs');
    save([subdir filesep 'TC'],'TC')
end
%% CoCA
Comp = Num_IC;
COCAdir = [outdir filesep 'CoCA_results'];
%%
STdir = [ROdir filesep 'stcMaps-SM30'];
mkdir(STdir)
for k_SrcNum = Comp
    cMap = f_STcorr_ergodic(k_SrcNum,ROdir,Comp);
    save([STdir '\cMap#' num2str(k_SrcNum)],'cMap');
end
disp('Indexing out the Rq for consistency index calculation...');
f_coca_RqIndexout(STdir,Comp,'save','off')
%% 

%%
disp('Cq, the consistency index calculating...');
cnt = 1;
for k_SrcNum = Comp
    Cqs = f_coca_CqIndex(STdir,k_SrcNum,Comp,'CC');
    MO_CqCC{cnt} = Cqs;
    saveas(gca,[STdir '\Cq#' num2str(k_SrcNum)],'tiff');
    cnt = cnt+1;
end
disp('******************** Done! ********************');
save([STdir '\CqCC'],'MO_CqCC')
%%
% 
% 
% 
