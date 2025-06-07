clear all; clc

disp('Setting up...')

cd '/Users/chill/Desktop/Arkady/source'
codefolder = '/Users/chill/Desktop/Arkady/source/';

% this specifies the folders where all the data and processed data is stored
datafolder = GetFullPath('../data/');
niifolder =  GetFullPath('/Users/chill/Desktop/SA_project/fMRI_data/Preprocessing/'); 

% path to spm 12
spmfolder = '/Users/chill/Documents/MATLAB/spm12';
addpath(spmfolder);

% ROI masks folder
roifolder = '/Users/chill/Desktop/Arkady/roi_for_conn_weight/';

% path to CONN
connfolder = '/Users/chill/Documents/MATLAB/spm12/toolbox/conn17';
addpath(connfolder);

% subjects ids list
% big cuts: 10 22 104 126
removed = [5 16 30 115 127 130];
subjects = setdiff([1:32 101:134],removed); %ALL


disp('Loading behavioral data...')
% script that converts main task data into a single dataframe
load([ GetFullPath('../data/fitdata.mat')]);
data.id = data.idc-100;
data = data(data.payoff >= 0,:);

% writing out conditions onsets
disp('Writing out onsets...')
LS_conn_prepare_conditions(data,codefolder);
        

N = size(subjects,2);

disp('Configuring SPM...')
spm_jobman('initcfg');

disp('Starting multiple cores...')
% runnning CONN analysis
parfor (i = 1:N, N)
    id = subjects(i);
    LS_conn_batch(id,codefolder,roifolder,niifolder);
end

social = [0 0 1 1 1 1 1 1 1 1 1 0 1 1 1 1 1 1 1 1 1 0 1 1 1 1 1 1 1 1 1 0 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
nonsocial = [1 1 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 1 0 0 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1];