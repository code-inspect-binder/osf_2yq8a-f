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
load([ GetFullPath('../data/fitdata_simple.mat')]);


data.idc = data.idc - 100;
data.rt(data.rt < 0) = 0;

data = data(data.payoff >= 0,:);

%data.signPExopponent = data.signPE.*data.opponent;
data.PEselfxopponent = data.PEself.*data.opponent;
data.absPE = abs(data.signPE);

model.data = data;

% select subjects
model.group = 'all'; % 'all', 'social', 'non-social'
model.comment = 'fullmodel-tomIPS';

% big cuts: 10 22 104 126
model.removed = [5 16 30 115 127 130];
model.removed = [5 16 30 115 127 130];

if strcmp(model.group,'all')
    model.Subj = setdiff([1:32 101:134],model.removed); %ALL
elseif strcmp(model.group,'non-social')
    model.Subj = setdiff([1:32],model.removed); %ALL
elseif strcmp(model.group,'social')
    model.Subj = setdiff([101:134],model.removed); %ALL
end

% 2nd level covariates: payoffs
pseq = []; pler = [];
for i = model.Subj
    temp = data(data.idc == i & data.opponent == 0,:);
    pseq = [pseq; mean(temp.payoff)];
    
    temp = data(data.idc == i & data.opponent == 1,:);
    pler = [pler; mean(temp.payoff)];
end
model.covariates =  struct('c', {pseq,pler}, 'cname', {'pseq','pler'});

model.multiregissues = 113;

model.prefix = {'C_0','S_0'};

% regressors
model.regressors = {'react','PE','value_dif2','signPE','payoff'}; 
model.conditions.names = model.regressors;
model.epoch = 'feedback';
model.demean = 1;

model.mask = '/Users/chill/Desktop/Arkady/source/tom_IPS.nii'; % mask?
% /Users/chill/Desktop/Arkady/source/tom_IPS.nii

% SNPM Setup
model.clusTh = 0.001;
model.FWETh = 0.05;
model.nPerm = 5000;

model.runs = 3;  % how many runs?

model.TR = 2.624; % TR
model.Nslices = 40;
model.reference = 20;

model.Ncon = length(model.regressors); % how many first regressors to output?

model.paralSPM = 0; % parallelize?
model.Ncores = 4;


%-------------------------------------------------
% RUNNING THE SCRIPT
%-------------------------------------------------

% the scipt adds an dataframe and a model fit array to the "model"
% structure
model = LS_SPM(model);


%-------------------------------------------------
% EXTRACT BETAS
%-------------------------------------------------
% 
beta = LS_extract_betas(model);


% -------------------------------------------------
% BETWEEN GROUPS
% -------------------------------------------------

model.Subj = {};
model.Subj{1} = setdiff([1:32],model.removed);
model.Subj{2} = setdiff([101:134],model.removed);
LS_2group(model);
