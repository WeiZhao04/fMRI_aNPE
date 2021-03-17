function [Y] = f_NPE_OneGroup(fdir,opts)


%%
N = opts.num_subjects;
opts.initPOOL = false;
dist = opts.thres;

if isequal(opts.randomise,1)
    PIND = randperm(N);
else
    PIND = 1:N;
end

% if isequal(opts.num_dims,'auto_estimation')
%     DimeFlag = 0;
% else
%     DimeFlag = 1;
% end
%%


E.vecs = cell(1,N);
E.vals = cell(1,N);
E.coef = cell(1,N);
for ks = 1:N
    disp('svd decomposing')
    temp = load(fdir{PIND(ks)});
    temp = temp.Mdata;
    [p,n] = size(temp);
    % voxel by time for removing temporal baseline
    if p<n; temp = temp'; end  
    deAvg = temp - sum(temp,2)/n*ones(1,size(temp,2));
    [U,S,V] = svd(deAvg,'econ');
    E.vecs{ks} = U;
    E.vals{ks} = diag(S).^2/size(deAvg,1);
    E.coef{ks} = V;
end
% free the memory
clear temp deAvg
clear U S V
%%
disp('Applying zero-block diag matrix for adjacency graph')
rbook = f_blkdiagMask(E.vecs);
disp('NPE constructing')
[NH] = f_NHestablish(rbook,N,dist);
disp('GLS approximating')
[Y] = f_GSL_appr(NH,E);
Y.IND = PIND;
Y.Len = NH.Len;
%%
disp('adapted NPE finished ...')





%%

end





%%%%%%%%%%%%%%%%%%%%%%% THE OLD ONE %%%%%%%%%%%%%%%%%%%%%%%%%
% generate a zero block diag matrix and masked with it
% function rbook = f_blkdiagMask(Evecs)
% 
% [n,TP] = size(Evecs{1});
% N = size(Evecs,2);
% gEvec = [Evecs{:}];
% y = [];
% x = zeros(TP);
% for k = 1:N
%     [p1,m1] = size(y);
%     y = [y ones(p1,TP); ones(TP,m1) x];
% end
% 
% mE = bsxfun(@minus,gEvec,sum(gEvec,1)/n);
% coef = mE' * mE;
% d = sqrt(diag(coef));
% coef = bsxfun(@rdivide,coef,d);
% rbook = bsxfun(@rdivide,coef,d');
% rbook = rbook.*y;
% rbook(isnan(rbook)) = 0;
% rbook(isinf(rbook)) = 0;
% 
% end

%%%%%%%%%%%%%%%%%%%%%THE NEW ONE (memory effiveint for computation cost)%%%%%%%%%%%%%%%%%%%%%%%%%%%
% generate a zero block diag matrix and masked with it
function rbook = f_blkdiagMask(Evecs)

[n,TP] = size(Evecs{1});
N = size(Evecs,2);
rbook = cell(N,N);

for kr = 1:N
    refE = Evecs{kr};
    for kn = 1:N
        if kr <= kn
            rbook{kr,kn} = [];
        else
            loopE = Evecs{kn};
            
            mR = bsxfun(@minus,refE,sum(refE,1)/n);
            mL = bsxfun(@minus,loopE,sum(loopE,1)/n);
            
            coef = mR' * mL;
            dR = sqrt(sum(abs(mR).^2,1));
            dL = sqrt(sum(abs(mL).^2,1));
            coef = bsxfun(@rdivide,coef,dR');
            dist = bsxfun(@rdivide,coef,dL);
            
            rbook{kr,kn} = dist;
        end
       disp(['Ongoing progress of ' num2str(((N-1)*kr+kn)/(N*N)*100) '% ...']) 
    end
    
end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
