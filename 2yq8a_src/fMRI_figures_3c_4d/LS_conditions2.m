function LS_conditions2(m)

Ncon = m.Ncon;
datafolder = m.datafolder;
outfolder = m.outfolder;
mask = m.mask;
regnames = m.conditions.names;
subjects = m.Subj;

% SECOND LEVEL non-parametric group level model estimation

disp('POSITIVE MAPS...')
spm_jobman('initcfg');
 


% POSITIVE
parfor contrast = 1:Ncon
   
   
    job = np_analysis_job_func(m,subjects,contrast,outfolder,mask,1);
    inputs = cell(0, 1);
    spm('defaults', 'FMRI');
    spm_jobman('run', job, inputs{:});
    savefig('results.fig')
    
    fg = [outfolder 'group_np/' num2str(contrast) '/results.fig'];
    copyfile(fg,[outfolder regnames{contrast}  '+.fig']);
    t_image = [outfolder 'group_np/' num2str(contrast) '/snpmT+.img'];
    hdr_image = [outfolder 'group_np/' num2str(contrast) '/snpmT+.hdr'];
    copyfile(t_image,[outfolder regnames{contrast}  '.img']);
    copyfile(hdr_image,[outfolder regnames{contrast} '.hdr']);
    
end

disp('NEGATIVE MAPS...')
spm_jobman('initcfg');

% NEGATIVE
parfor contrast = 1:Ncon
   
   
    job = np_analysis_job_func(m,subjects,contrast,outfolder,mask,-1);
    inputs = cell(0, 1);
    spm('defaults', 'FMRI');
    spm_jobman('run', job, inputs{:});
    savefig('results.fig')
    
    fg = [outfolder 'group_np/' num2str(contrast) '/results.fig'];
    copyfile(fg,[outfolder regnames{contrast}  '-.fig']);
end


end