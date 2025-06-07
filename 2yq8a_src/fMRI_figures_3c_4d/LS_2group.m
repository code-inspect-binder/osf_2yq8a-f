function LS_2group(m)

name = strjoin(m.regressors); 
%m.outfolder = [m.outfolder name ' - ' m.epoch ' - ' m.group ' - ' m.comment '/'];
Ncon = m.Ncon + 1;
datafolder = m.datafolder;
outfolder = m.outfolder;
mask = m.mask;
regnames = m.regressors;regnames{end+1} = 'baseline';
subjects = m.Subj;

% SECOND LEVEL non-parametric group level model estimation

disp('POSITIVE MAPS...')
spm_jobman('initcfg');
 


% POSITIVE
parfor contrast = 1:Ncon
   
   
    job = np_analysis_2group_job_func(m,subjects,contrast,outfolder,mask,1);
    inputs = cell(0, 1);
    spm('defaults', 'FMRI');
    spm_jobman('run', job, inputs{:});
    savefig('results.fig')
    
    fg = [outfolder 'group2_np/' num2str(contrast) '/results.fig'];
    copyfile(fg,[outfolder regnames{contrast}  '+2.fig']);
    t_image = [outfolder 'group2_np/' num2str(contrast) '/snpmT+.img'];
    hdr_image = [outfolder 'group2_np/' num2str(contrast) '/snpmT+.hdr'];
    copyfile(t_image,[outfolder regnames{contrast}  '2.img']);
    copyfile(hdr_image,[outfolder regnames{contrast} '2.hdr']);
    
end

disp('NEGATIVE MAPS...')
spm_jobman('initcfg');

% NEGATIVE
parfor contrast = 1:Ncon
   
   
    job = np_analysis_2group_job_func(m,subjects,contrast,outfolder,mask,-1);
    inputs = cell(0, 1);
    spm('defaults', 'FMRI');
    spm_jobman('run', job, inputs{:});
    savefig('results.fig')
    
    fg = [outfolder 'group2_np/' num2str(contrast) '/results.fig'];
    copyfile(fg,[outfolder regnames{contrast}  '-2.fig']);
end


end