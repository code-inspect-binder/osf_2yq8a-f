
function batch = LS_analysis_job_func(id,model)
%-----------------------------------------------------------------------
% Job saved on 27-Jun-2016 14:18:15 by cfg_util (rev $Rev: 6460 $)
% spm SPM - SPM12 (6470)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------

datafolder = model.datafolder;
niifolder = model.niifolder;
mask = model.mask;
Ncon = model.Ncon;
runs = model.runs;

matlabbatch{1}.spm.stats.fmri_spec.dir = cellstr([model.outfolder 'sub-' num2str(id)]);
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = model.TR;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = model.Nslices;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = model.reference;
%%
if round(id/100) == 0
    path = [niifolder 'fMRI_Cards/' model.prefix{1} num2str(id)];
else
    path = [niifolder 'fMRI_Humans/' model.prefix{2} num2str(id-100)];
end


scans={};
for n=1:runs
    scans{n} = cellstr(spm_select('ExtFPList',path,['^swausn.*\.*.run' num2str(n)],1:300)); 
end

for n = 1:runs
    matlabbatch{1}.spm.stats.fmri_spec.sess(n).scans = scans{1,n};
    matlabbatch{1}.spm.stats.fmri_spec.sess(n).cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(n).multi = {[datafolder 'derivatives/onsets/' num2str(id) '_run' num2str(n) '.mat']};
    matlabbatch{1}.spm.stats.fmri_spec.sess(n).regress = struct('name', {}, 'val', {});
    
    if ismember(id,model.multiregissues(:))
        mregprefix = ['^rp_sn.*\.*.run' num2str(n)];
        matlabbatch{1}.spm.stats.fmri_spec.sess(n).multi_reg = cellstr(spm_select('FPList', path, mregprefix));
    else
        matlabbatch{1}.spm.stats.fmri_spec.sess(n).multi_reg = {[path '/Physio/r' num2str(n) '/multireg.txt']};
    end
    
    matlabbatch{1}.spm.stats.fmri_spec.sess(n).hpf = 128;
end

matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
matlabbatch{1}.spm.stats.fmri_spec.mask = {mask};
matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));


temp = load([datafolder 'derivatives/onsets/' num2str(id) '_run1.mat']);

num_regressors = size(temp.pmod(1).name,2);
weights = zeros(1,num_regressors+1);
names = [temp.pmod(1).name];

for n = 1:Ncon
    namecell = names(n);
    matlabbatch{3}.spm.stats.con.consess{n}.tcon.name = namecell{1};
    temp_weights = weights;
    temp_weights(n+1) = 1;
    matlabbatch{3}.spm.stats.con.consess{n}.tcon.weights = temp_weights;
    matlabbatch{3}.spm.stats.con.consess{n}.tcon.sessrep = 'repl';
    
end

matlabbatch{3}.spm.stats.con.consess{Ncon+1}.tcon.name = 'baseline';
temp_weights = weights;
temp_weights(1) = 1;
matlabbatch{3}.spm.stats.con.consess{Ncon+1}.tcon.weights = temp_weights;
matlabbatch{3}.spm.stats.con.consess{Ncon+1}.tcon.sessrep = 'repl';


matlabbatch{3}.spm.stats.con.delete = 0;

batch = matlabbatch;
end