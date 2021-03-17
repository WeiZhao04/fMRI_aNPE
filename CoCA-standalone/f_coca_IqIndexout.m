function  [ iqMap] = f_coca_IqIndexout(hcInd,STdir,iqPath,Comp)


%% select the stable source components
L_SrcRef = size(hcInd,1);
k_Src = size(hcInd,2);
%% Index out iq from hcInd
iqMap = zeros(size(hcInd));
for IndSource = Comp(1):k_Src
    Temp = load([STdir '\MO_' num2str(IndSource) '\Matrix_iq.mat']);
    iq = Temp.iq;
    for k = 1: size(hcInd,2)
        if hcInd(IndSource,k)           
            iqMap(IndSource,k) = iq(hcInd(IndSource,k));
        end
    end
    disp(['Calculating Iq in Phase One ' num2str(IndSource) '/' num2str(L_SrcRef)]);
end

for IndSource = k_Src+1:Comp(end)
    Temp = load([STdir '\MO_' num2str(IndSource) '\Matrix_iq.mat']);
    iq = Temp.iq;
    iqMap(IndSource,:) = iq(hcInd(IndSource,:));
    disp(['Calculating Iq in Phase Two ' num2str(IndSource) '/' num2str(L_SrcRef)]);
end
%%
iqMap = iqMap';

figure
set(gcf,'visible','off');
ssize = get(0,'screensize');
x = min(ssize(3:4));
y = max(ssize(3:4));
rect = floor([(y/2-x*3/8),(x*1/8),x*3/4,x*3/4 ]);
set(gcf,'OuterPosition',rect)
imagesc(iqMap),colorbar
hold on
line([k_Src,k_Src],[0,k_Src+1],'linewidth',2,'color',[ 0 0 0])
ylabel(['IC Number in MO ' num2str(k_Src)],'fontsize',16)
xlabel('Model Order','fontsize',16)
set(gca,'fontsize',16)
saveas(gcf,[iqPath filesep 'hcMap#' num2str(k_Src)],'png')
    
disp('******************** Done! ********************');
%% save the result
% save(['iqMap'],'iqMap')

