function LS_glm1(m)

subjects = m.Subj;

% FIRST LEVEL (individual) estimations
% 
N = size(subjects,2);


parfor i = 1:N
    
    id = subjects(i);
    path = [m.outfolder 'sub-' num2str(id)];
    modelfile = [path '/SPM.mat'];
    delete(modelfile);
    job = LS_analysis_job_func(id,m);
    inputs = cell(0,1);
    
    spm('defaults', 'FMRI');
    spm_jobman('run', job, inputs{:});
    
end

end