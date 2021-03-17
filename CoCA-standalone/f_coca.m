function Opt = f_coca(STdir,Comp)
% PURPOSE
% demo of CoCA process flow
%
% INPUTS
% STdir:        (string) the directory to keep rank-1 matrix
% Comp:         (vector) the model order to be selected    

% OUTPUTS
% Opt           (vector) the recommended model order range
% ver 1.0 120520 Weir Zhao
%%
disp('Initializing  the ergodic of spatial-temproal rank-1 martrix...');
stpath = [STdir filesep 'stcMaps'];
mkdir(stpath)
for k_SrcNum = Comp
    cMap = f_STcorr_ergodic(k_SrcNum,STdir,Comp);
    save([stpath '\cMap#' num2str(k_SrcNum)],'cMap');
end
disp('Indexing out the Iq for consistency index calculation...');
f_coca_RqIndexout(stpath,Comp,'save','off')

%%
disp('Indexing out the Iq for consistency index calculation...');
iqpath = [STdir filesep 'iqcMaps'];
mkdir(iqpath)
for k_SrcNum = Comp
    hcInd = load([stpath filesep 'hcInd#' num2str(k_SrcNum) '.mat']);
    [iqMap] = f_coca_IqIndexout(hcInd.hcInd,STdir,iqpath,Comp);
    save([iqpath '\iqcMap#' num2str(k_SrcNum)],'iqMap');
end

%%
disp('Cq, the consistency index calculating...');
for k_SrcNum = Comp
    Cqs = f_coca_CqIndex(stpath,k_SrcNum,'CC');
    MO_CqCC{k_SrcNum} = Cqs;
    saveas(gca,[stpath '\Cq#' num2str(k_SrcNum)],'fig');
    Cqs = f_coca_CqIndex(iqpath,k_SrcNum,'Iq');
    MO_CqIq{k_SrcNum} = Cqs;
    saveas(gca,[iqpath '\Cq#' num2str(k_SrcNum)],'fig');
end
disp('******************** Done! ********************');
%%
for k = Comp
    mCqCC = nanmean(MO_CqCC{k},1);
    mCqIq = nanmean(MO_CqIq{k},1);
    NoH = sum(mCqCC>=0.85) + sum(mCqIq>=0.85);
    NoL = sum(mCqCC<0.5) + sum(mCqIq<0.5);
    NoM = sum(mCqCC<0.85) + sum(mCqIq<0.85) - sum(mCqIq<0.65);
    OptN(k) = (NoH + 0.8*NoM - NoL)/(2*k);
end


Opt = find(max(OptN) == OptN);
