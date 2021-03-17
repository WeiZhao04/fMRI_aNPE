clc,clear
close all
% The demo code of CoCa, which is programed to serve the consisitency
% analysis for ICA decomposition results.  
% 
% ver 1.2 06/30/20 Weir Zhao

%% Parameters initialization
Comp = 10:30;
ROdir = 'H:\NPE-single\NPE-vivo\CoCA1-200\Ref';
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
% for k = Comp
%     mCqCC = nanmean(MO_CqCC{k},1);
%     mCqIq = nanmean(MO_CqIq{k},1);
%     NoH = sum(mCqCC>=0.85) + sum(mCqIq>=0.85);
%     NoL = sum(mCqCC<0.5) + sum(mCqIq<0.5);
%     NoM = sum(mCqCC<0.85) + sum(mCqIq<0.85) - sum(mCqIq<0.65);
%     OptN(k) = (NoH + 0.8*NoM - NoL)/(2*k);
% end
% 
% 
% Opt = find(max(OptN) == OptN);


