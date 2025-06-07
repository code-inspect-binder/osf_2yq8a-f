function batch = np_analysis_2group_job_func(m,subjects,contrast,outfolder,mask,sign)

%-----------------------------------------------------------------------
% Job saved on 27-Feb-2018 13:44:53 by cfg_util (rev $Rev: 6460 $)
% spm SPM - SPM12 (6906)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
batch{1}.spm.tools.snpm.des.TwoSampT.DesignName = '2 Groups: Two Sample T test; 1 scan per subject';
batch{1}.spm.tools.snpm.des.TwoSampT.DesignFile = 'snpm_bch_ui_TwoSampT';
batch{1}.spm.tools.snpm.des.TwoSampT.dir = {[outfolder 'group2_np/' num2str(contrast)]};

scans = {};
for i = subjects{1}
    path = [outfolder 'sub-' num2str(i) '/'];
    if contrast < 10
        scans = [scans {[path 'con_000' num2str(contrast) '.nii,1']}];
    end
    if contrast >= 10
        scans = [scans {[path 'con_00' num2str(contrast) '.nii,1']}];
    end
end
batch{1}.spm.tools.snpm.des.TwoSampT.scans1 = scans';


scans = {};
for i = subjects{2}
    path = [outfolder 'sub-' num2str(i) '/'];
    if contrast < 10
        scans = [scans {[path 'con_000' num2str(contrast) '.nii,1']}];
    end
    if contrast >= 10
        scans = [scans {[path 'con_00' num2str(contrast) '.nii,1']}];
    end
end

batch{1}.spm.tools.snpm.des.TwoSampT.scans2 = scans';



batch{1}.spm.tools.snpm.des.TwoSampT.cov = m.covariates;
batch{1}.spm.tools.snpm.des.TwoSampT.nPerm = m.nPerm;
batch{1}.spm.tools.snpm.des.TwoSampT.vFWHM = [0 0 0];
batch{1}.spm.tools.snpm.des.TwoSampT.bVolm = 1;
batch{1}.spm.tools.snpm.des.TwoSampT.ST.ST_later = -1;
batch{1}.spm.tools.snpm.des.TwoSampT.masking.tm.tm_none = 1;
batch{1}.spm.tools.snpm.des.TwoSampT.masking.im = 1;
batch{1}.spm.tools.snpm.des.TwoSampT.masking.em = {mask};
batch{1}.spm.tools.snpm.des.TwoSampT.globalc.g_omit = 1;
batch{1}.spm.tools.snpm.des.TwoSampT.globalm.gmsca.gmsca_no = 1;
batch{1}.spm.tools.snpm.des.TwoSampT.globalm.glonorm = 1;

batch{2}.spm.tools.snpm.cp.snpmcfg(1) = cfg_dep('2 Groups: Two Sample T test; 1 scan per subject: SnPMcfg.mat configuration file', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','SnPMcfg'));

batch{3}.spm.tools.snpm.inference.SnPMmat(1) = cfg_dep('Compute: SnPM.mat results file', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','SnPM'));
batch{3}.spm.tools.snpm.inference.Thr.Clus.ClusSize.CFth = m.clusTh;
batch{3}.spm.tools.snpm.inference.Thr.Clus.ClusSize.ClusSig.FWEthC = m.FWETh;
batch{3}.spm.tools.snpm.inference.Tsign = sign;
batch{3}.spm.tools.snpm.inference.WriteFiltImg.WF_no = 0;
batch{3}.spm.tools.snpm.inference.Report = 'MIPtable';



end