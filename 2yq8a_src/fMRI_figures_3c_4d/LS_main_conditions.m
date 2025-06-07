close all;clear variables;clc

%-------------------------------------------------
% SPM model config
%-------------------------------------------------

% adding paths to spm 12 and snpm 13
spmfolder = '/Users/chill/Documents/MATLAB/spm12';
addpath(spmfolder);
% snpmfolder = '/Users/arkadykonovalov/Documents/spm12/toolbox/snpm13';
% addpath(snpmfolder);

model.codefolder = pwd; % scripts folder
addpath(model.codefolder);
model.datafolder = GetFullPath('../data/'); % data
model.niifolder =  GetFullPath('/Users/chill/Desktop/SA_project/fMRI_data/Preprocessing/'); 
model.outfolder =  GetFullPath('../data/derivatives/');  % output
model.roifolder = '/Users/chill/Desktop/Arkady/roi/'; % ROIs


% DATA
load([ GetFullPath('../data/fitdata.mat')]);
data.idc = data.idc - 100;
%data = data(data.rt >= 0,:); % selecting only valid trials (dataset-specific)
data.choicetime = zeros(size(data,1),1);
data.feedbacktime = zeros(size(data,1),1);
data.zeros = zeros(size(data,1),1);

data.onset_learnerF = data.onset_feedback.*data.opponent; 
data.onset_learnerF(data.onset_learnerF==0) = NaN;
data.onset_sequencerF = data.onset_feedback.*(1-data.opponent);
data.onset_sequencerF(data.onset_sequencerF==0) = NaN;

data.onset_learnerC = data.onset_choice.*data.opponent.*(1-data.blank); 
data.onset_learnerC(data.onset_learnerC==0) = NaN;
data.onset_sequencerC = data.onset_choice.*(1-data.opponent).*(1-data.blank);
data.onset_sequencerC(data.onset_sequencerC==0) = NaN;

data.onset_blank = data.onset_choice.*data.blank;
data.onset_blank(data.onset_blank==0) = NaN;

data.onset_missing = data.onset_choice.*data.missing;
data.onset_missing(data.onset_missing==0) = NaN;

data.rt(data.rt < 0) = 0;

data.payoff(data.payoff == -Inf) = -2;

model.data = data;

% select subjects
model.group = 'all'; % 'all', 'social', 'non-social'
model.comment = 'all';

% big cuts: 10 22 104 126
model.removed = [5 16 30 115 127 130];

if strcmp(model.group,'all')
    model.Subj = setdiff([1:32 101:134],model.removed); %ALL
elseif strcmp(model.group,'non-social')
    model.Subj = setdiff([1:32],model.removed); %ALL
elseif strcmp(model.group,'social')
    model.Subj = setdiff([101:134],model.removed); %ALL
end
%model.Subj = 1;

model.multiregissues = 113;

model.prefix = {'C_0','S_0'};

% regressors
model.conditions.names = {'learnerF','sequencerF','learnerC','sequencerC','blank'}; % specifying regressors in the GLM, names must correspond to specific columns in the dataframe
model.conditions.onsets = {'onset_learnerF','onset_sequencerF','onset_learnerC','onset_sequencerC','onset_blank'}; % specifying which variable in the dataset is the onset timings (relative to the run start)
model.conditions.durations = {'zeros','zeros','rt','rt','zeros'}; % specifying which variable in the dataset is the durations
model.conditions.pmods{1} = {'missing','missing','missing','missing',''};
model.conditions.pmods{2} = {'','','','',''};
 
model.mask = ''; % mask?

% SNPM Setup
model.clusTh = 0.001;
model.FWETh = 0.05;
model.nPerm = 5000;

model.runs = 3;  % how many runs?

model.TR = 2.624; % TR
model.Nslices = 40;
model.reference = 20;

model.Ncon = length(model.conditions.names); % how many first regressors to output?

model.paralSPM = 0; % parallelize?
model.Ncores = 2;


%-------------------------------------------------
% RUNNING THE SCRIPT
%-------------------------------------------------

% the scipt adds an dataframe and a model fit array to the "model"
% structure
model = LS_SPM_conditions(model);


%-------------------------------------------------
% EXTRACT BETAS
%-------------------------------------------------

beta = LS_extract_betas(model);