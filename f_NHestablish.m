function [NH] = f_NHestablish(distbook,Gs,dist)

distbook = cellfun(@abs,distbook,'UniformOutput',false);
TP = size(distbook{Gs},1);
L = TP*Gs;
%%

nh_index = cell(1,TP);
nh_weigh = zeros(1,TP);
for ks = 1:Gs
    tempbook = cell(Gs,1);
    for kk = 1:Gs
        if isempty(tempbook{kk})
            tempbook{kk} = distbook{kk,ks}; %tril
        end
    end
    for kk = 1:Gs
        if isempty(tempbook{kk})
            tempbook{kk} = distbook{ks,kk}'; % triu 
        end
    end
    for kk = 1:Gs
        if isempty(tempbook{kk})
            tempbook{kk} = zeros(TP,TP); % add up zeros
        end
    end
    tempbook = cell2mat(tempbook);
    tempbook(tempbook<dist) = 0;
    [tempbook,sInd] = sort(tempbook,'descend');
    
    for kt = 1:TP
        % neigborhood ruling out 
        NHtemp = tempbook(1:10*Gs,kt);
        cutoff = find(NHtemp>0,1,'last');
        NHtemp = NHtemp(1:cutoff);
        if sum(NHtemp)>Gs && cutoff >  floor(Gs*0.5)
            NumNH = sInd(1:cutoff,kt);
        else
            cutoff = f_assemNH(NHtemp,Gs);
            NumNH = sInd(1:cutoff,kt);
        end
        nh_index{kt} = sort(NumNH);
        nh_weigh(kt) = sum(NHtemp(1:length(NumNH)));
    end
    NH.INX(:,ks) = nh_index;
    NH.SOW(:,ks) = nh_weigh;
end
% reshape and reorder 

for kr = 1:Gs
    NH.KI{kr} = find(cellfun(@isempty,NH.INX(:,kr))==0);
    NH.Len(kr) = length(NH.KI{kr});
end
% [NH.Len,rind] = sort(NH.Len,'descend');
% NH.INX = NH.INX(:,rind);
% NH.KI = NH.KI(:,rind);

end




%%
% search NH size with criterion of group size and sum-of-dist

function sumK = f_assemNH(D,Gs)
sumK = 0;
cutoff = find(D>0,1,'last');
D = D(1:cutoff);
if ~isempty(cutoff)
    if cutoff>floor(Gs*0.5) && sum(D)>1
        sumK = cutoff;
    else
        return
    end
end



end











