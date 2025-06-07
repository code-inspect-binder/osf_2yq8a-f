function LS_conditions(model)

subjects = model.Subj;

% FIRST LEVEL (individual) estimations
% 
N = size(subjects,2);


% LOOP OVER ALL SUBJECTS
parfor i = 1:N
    
    id = subjects(i); %selecting subject id
    
    path = [model.outfolder 'sub-' num2str(id)]; % specifying an individual subject folder 
   
    modelfile = [path '/SPM.mat'];
    delete(modelfile); % deleting SPM model file in case it exists (otherwise there will be a warning)
    
    if model.byruns == 1
        job = LS_conditions_job_func_runs(id,model); % creating the job for SPM
    else 
        job = LS_conditions_job_func(id,model); % creating the job for SPM
    end
       
    spm('defaults', 'FMRI'); % starting SPM
    
    spm_jobman('run', job); % running analysis for the subject
    
end

end