function [Cqs] = f_coca_CqIndex(MapPath,NoC,MORange,Cq_base)
% MapPath:     (string)   the folder of hcMaps ro iqMaps
% NoC:         (interger) the model order to be selected
% Cq_base:     (string)   it should be either 'Iq' or 'CC', to match with the
%                         folder chosen
%
%By wei 19/11/05

%%
if nargin < 2
    error('Not enough input arguments');
elseif nargin > 5
    error('Too much input arguments');
elseif nargin == 4
    switch lower(Cq_base)
        case 'cc'
            load([MapPath filesep 'hcMap#' num2str(NoC) '.mat'])
            cMap = hcMap';
        case 'iq'
            load([MapPath filesep 'iqcMap#' num2str(NoC) '.mat'])
            cMap = iqMap';
        otherwise
            error('Input argument does not exsist');
    end
end

%%
%% phase 1
 NoMO = find(MORange == NoC);
if NoMO > 1
   
    svIND = cMap(1:NoMO-1,:)>0;
    delta = diff(svIND,1,1);
    piece = sum(delta == -1,1);
    flagOne = 1;
else
    flagOne = 0;
end
%% punish and reward lenght
if flagOne
    for col = 1:NoC
        markN = 0;
        markP = 0;
        brokenLs = 0;
        for row = 1:NoMO-2
            if delta(row,col) == -1
                markN = row;
            end
            if markN > 0 && delta(row,col) == 1
                markP = row;
                brokenL = markP - markN;
                markN = 0;
                markP = 0;
                brokenLs = brokenLs + brokenL;
                brokenL = 0;
            elseif markN > 0 && row == NoMO-2
                brokenL = 1;
                brokenLs = brokenLs + brokenL;
                brokenL = 0;
            end
            
        end
        BLs(col) = brokenLs;
    end
    RLs = sum(svIND,1);
    wBLs = BLs.*piece;
    for k = 1:NoC
        if BLs(k) == 0
            ph1_rp(k) = 1;
        else
            lamda = 1 - wBLs(k)/(NoMO-1)^2;
            ph1_rp(k) = lamda;
        end
    end
    ph1 = sum(cMap(1:NoMO-1,:),1)./sum(svIND,1);
    ph1_crt = ph1.*ph1_rp;
else
    ph1_crt = ones(size(cMap(1:NoMO,:)))*NaN;
end

%%

%% phase 2
if size(cMap(NoMO:end,:),1) ~= 1
    ph2 = mean(cMap(NoMO:end,:));
    ph2_rp = std(abs(diff(cMap(NoMO:end,:))));
    ph2_crt = ph2 - ph2_rp;
else
    ph2_crt = ones(size(cMap(NoMO:end,:)))*NaN;
end
%%
Cqs = [ph1_crt;ph2_crt]';
%%
figure('visible','off')
plot(ph1_crt,'r*','linewidth',2), hold on
plot(ph2_crt,'b*','linewidth',2),hold on
plot((ph2_crt + ph1_crt)/2,'ko-','linewidth',2),hold on
if size(ph1_crt) == size(ph2_crt)
    for k = 1:NoC
        line([k,k],[ph1_crt(k),ph2_crt(k)],'linewidth',2)
    end
end
set(gca,'fontsize',14);
grid on
xlabel('Number of Components');
ylabel('Coefficient of Consistence')
xlim([1 NoC])
ylim([0 1.1])
legend('Phase One','Phase Two','Mean','location','best')


%%
end




