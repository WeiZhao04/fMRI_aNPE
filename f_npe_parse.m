function opts = f_npe_parse(Files, varargin)

%% Set all options to sensible defaults. Note these shouldn't refer to the data YET.


opts.num_subjects = size(Files,2);
opts.initPOOL = false;
opts.PoolSize = 20;
opts.thres = 0.01;
opts.num_dims = 'auto_estimation';
opts.randomise = false;

if nargin==0
    disp 'No arguments given, displaying usage info instead instead!'
    clear opts; return
end

%% Convert arguments in a structure S:
if isempty(varargin)
    S = struct();
    
elseif length(varargin) == 1 && isstruct(varargin{1})
    S = varargin{1};
    
else % assume it's "'fieldname', value," pairs
    for i=1:2:length(varargin)
        if isfield(S, varargin{i}), 
            error('Duplicate option: %s', varargin{i}); 
        end
        S.(varargin{i}) = varargin{i+1};
    end
end

%% Apply these options to the default-options structure
fs = fieldnames(S);
for i = 1:length(fs)
    f = fs{i};
    if ~isfield(opts, f)
        error('Unrecognized option: %s', f)
    else
        opts.(f) = S.(f);
    end
end

opts.manually_set_options = S; 

%% Interpret any options that need to refer to the data:
if ~isequal(opts.num_subjects,size(Files,2))
    error('Unmathced subjects number: %i',opts.num_subjects)
% else
%     disp(['Total subjects number ' num2str(opts.num_subjects)])
end





%% Return opts!
return