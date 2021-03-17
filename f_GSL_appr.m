function [Y] = f_GSL_appr(neighbors,Esvd)

%%

N = size(Esvd.vecs,2);
P = size(Esvd.vecs{1},1);
%%
% computing weights with neighbors
for kn = 1:N
    NHs = neighbors.INX(:,kn);
    KI = neighbors.KI{kn};
    NoK = neighbors.Len(kn);
    TP = size(Esvd.vecs{kn},2);
    Ytemp = zeros(P,NoK);
    Coef = zeros(TP,NoK);
    for kt = 1:NoK
        Ind = NHs{KI(kt)}-1;
        Rind = mod(Ind,TP)+1;
        Dind = fix(Ind/TP)+1;
        Lcomps = length(Ind);
        comps = zeros(P,Lcomps);
        for ks = 1:Lcomps %
            comps(:,ks) = Esvd.vecs{Dind(ks)}(:,Rind(ks));
        end
        centraComp = Esvd.vecs{kn}(:,KI(kt));
        w = mldivide(comps,centraComp);
        Ytemp(:,kt) = comps*w; % projection with weights
        Coef(:,kt) = Esvd.coef{kn}(:,KI(kt));
    end
    % projection with weights
    
    % reform the subject-specific Emaps
    Y.npe{kn} = Ytemp;
    Y.cof{kn} = Coef;
    % auto estimation by default
%     if flag
%     else
%         return
%     end
    
end



end


