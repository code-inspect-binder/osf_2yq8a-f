function LS_conn_batch(id,codefolder,roifolder,niifolder)

%% batch preprocessing for single-subject single-session data 

% Selects MASKS
masks = dir(fullfile(roifolder,'*.nii')); masks = {masks.name};

% Selects TR (seconds)
TR = 2.624;

%% CONN New experiment
batch.filename=[codefolder 'conn_onsets/conn_task_' num2str(id) '.mat'];

%% CONN Setup
batch.Setup.nsubjects=1;

batch.Setup.RT=TR;
batch.Setup.rois.names=masks;

for i = 1:size(masks,2)
 batch.Setup.rois.files{i} =fullfile(roifolder,masks{i});
 batch.Setup.rois.dimensions{i} = 0;
end


batch.Setup.conditions.names{1}='sequencer loss';   
batch.Setup.conditions.names{2}='sequencer win'; 
batch.Setup.conditions.names{3}='learner loss';   
batch.Setup.conditions.names{4}='learner win';   
%batch.Setup.preprocessing.steps={'default_mni'}; 
%batch.Setup.preprocessing.sliceorder={'interleaved (Siemens)'};
batch.Setup.isnew=1;
batch.Setup.done=1;
%batch.Setup.overwrite='Yes'; 

prefix = {'C_0','S_0'};
if round(id/100) == 0
    path = [niifolder 'fMRI_Cards/' prefix{1} num2str(id)];
else
    path = [niifolder 'fMRI_Humans/' prefix{2} num2str(id-100)];
end

   
for j = 1:3
        batch.Setup.functionals{1}{j} = cellstr(spm_select('ExtFPList',path,['^swausn.*\.*.run' num2str(j)],1:300)); 
        
        load([codefolder '/conn_onsets/sub_' num2str(id) '_onsets1_run' num2str(j) '.mat']);
        batch.Setup.conditions.onsets{1}{1}{j} = onsets;
        batch.Setup.conditions.durations{1}{1}{j}=durations; 
        
        load([codefolder '/conn_onsets/sub_' num2str(id) '_onsets2_run' num2str(j) '.mat']);
        batch.Setup.conditions.onsets{2}{1}{j}=onsets;
        batch.Setup.conditions.durations{2}{1}{j}=durations; 
        
        load([codefolder '/conn_onsets/sub_' num2str(id) '_onsets3_run' num2str(j) '.mat']);
        batch.Setup.conditions.onsets{3}{1}{j}=onsets;
        batch.Setup.conditions.durations{3}{1}{j}=durations; 
        
        load([codefolder '/conn_onsets/sub_' num2str(id) '_onsets4_run' num2str(j) '.mat']);
        batch.Setup.conditions.onsets{4}{1}{j}=onsets;
        batch.Setup.conditions.durations{4}{1}{j}=durations; 
end
    
%batch.Setup.structurals{1} ={[path '/wBrain.nii']};
     
    


%% CONN Denoising
batch.Denoising.filter=[0.01, 0.1];          % frequency filter (band-pass values, in Hz)
batch.Denoising.done=1;

%% CONN Analysis
batch.Analysis.measure=1;               % connectivity measure used {1 = 'correlation (bivariate)', 2 = 'correlation (semipartial)', 3 = 'regression (bivariate)', 4 = 'regression (multivariate)';
batch.Analysis.weight=2;                % within-condition weight used {1 = 'none', 2 = 'hrf', 3 = 'hanning';
batch.Analysis.sources={};              % (defaults to all ROIs)
batch.Analysis.done=1;
batch.Setup.overwrite='Yes'; 

conn_batch(batch);

%% CONN Display
% launches conn gui to explore results
% conn
% conn('load',batch.filename);
% conn gui_results


end