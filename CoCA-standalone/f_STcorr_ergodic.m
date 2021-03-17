function  [ ncMap] = f_STcorr_ergodic(Opt_Num,STpath,MOrange)
% The correlation coefficient between optimal MO and the cther MOs will be
% calculated. The input parameters could be settd as follow£º
%
% Ref_Num [interger]: the optimal MO;
%
% STPath [dir]: the path contains the decomposed temperal-spatial
% components,originally it should be the resut folder of tensor clustering. 
%
% MOrange [vector]: the MO range around the optimal MO that could help to
% evaluate the consistence of ICs
%
% e.g
% Path = [Path filesep 'GroupICA_FastICA_Result'];
% Opt_Num = 20;
% MOrange = 3:40;
% 
%
% By Wei 190405
%% input check
if nargin < 3
    error('Not enough input argument')
elseif nargin >3 
    error('Too much input arguments')
end
%% check
if ~exist(STpath,'dir')
    error('Folder is not exist!');
end
%%
prefix = 'MO*';
MOs = dir([STpath filesep prefix]);
[~,~,~,match] = regexp(MOs(1).name,'\d+');

if length(match) > 1
    error('wrong model order number with prefix of MO')
end
LoN = num2str(length(match{1}));
S_Ref = load([STpath filesep 'MO_' sprintf(['%0.' LoN 'i'],Opt_Num) filesep  'SM.mat']);
T_Ref = load([STpath filesep 'MO_' sprintf(['%0.' LoN 'i'],Opt_Num) filesep  'TC.mat']);

Ref_sm = rownorm(S_Ref.SM); 
Ref_tc = rownorm(T_Ref.TC');
%% calculate the corelation coefficient
N = length(MOrange);
cMap = zeros(N,MOrange(end),Opt_Num);
ncMap = cMap;
for k_MO = 1:N
    SS = load([STpath filesep 'MO_' sprintf(['%0.' LoN 'i'],MOrange(k_MO)) filesep  'SM.mat']);
    TT = load([STpath filesep 'MO_' sprintf(['%0.' LoN 'i'],MOrange(k_MO)) filesep  'TC.mat']);
    S_Temp = rownorm(SS.SM);
    A_Temp = rownorm(TT.TC');
    L_Temp = size(S_Temp,1);

    SMcor = Ref_sm*S_Temp';
    TCcor = Ref_tc*A_Temp';
    STcor = SMcor.*TCcor;
    ncMap(k_MO,1:L_Temp,:) = SMcor';
    disp(['Calculating rank-1 matrix correlation coefficients for MO ' num2str(MOrange(k_MO)) '...'])
end
disp(['******************** Done! ********************']);
%%
function X=rownorm(X)
% normalize rows to unit length.
s=abs(sqrt(sum(X.^2,2)));

if any(s==0),
  warning('Contains zero vectors: can''t normalize them!');
end

X=X./repmat(s,1,size(X,2));








