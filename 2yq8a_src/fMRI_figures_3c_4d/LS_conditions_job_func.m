
function batch = LS_conditions_job_func(id,model)
%-----------------------------------------------------------------------
% Job saved on 27-Jun-2016 14:18:15 by cfg_util (rev $Rev: 6460 $)
% spm SPM - SPM12 (6470)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------

datafolder = model.datafolder;
niifolder = model.niifolder;
mask = model.mask;
runs = model.runs;
Ncond = length(model.conditions.names);
data = model.data;
sdata = data(data.idc == id ,:);
varnames = sdata.Properties.VarNames; % extracting all the variable names from the dataset

batch{1}.spm.stats.fmri_spec.dir = cellstr([model.outfolder 'sub-' num2str(id)]); % subject folder
batch{1}.spm.stats.fmri_spec.timing.units = 'secs'; % timing units: seconds
batch{1}.spm.stats.fmri_spec.timing.RT = model.TR;  % TR
batch{1}.spm.stats.fmri_spec.timing.fmri_t = model.Nslices; % number of slice
batch{1}.spm.stats.fmri_spec.timing.fmri_t0 = model.reference; % reference slice
%%
if round(id/100) == 0
    path = [niifolder 'fMRI_Cards/' model.prefix{1} num2str(id)];
else
    path = [niifolder 'fMRI_Humans/' model.prefix{2} num2str(id-100)];
end

% LOADING THE SCANS NAMES
scans={};
for n=1:runs
    scans{n} = cellstr(spm_select('ExtFPList',path,['^swausn.*\.*.run' num2str(n)],1:300)); 
end

% SPECIFYING THE SCANS, CONDITIONS, AND MULTIREG FILES
for n = 1:runs
    batch{1}.spm.stats.fmri_spec.sess(n).scans = scans{1,n};
    
    for c = 1:Ncond
        %names
        namecell = model.conditions.names(c);
        batch{1}.spm.stats.fmri_spec.sess(n).cond(c).name = namecell{1};
        
        %onsets
        onset = model.conditions.onsets(c);
        index = find(strcmp(varnames, onset));
        vec = double(sdata(sdata.run==n,index));
        valid = isnan(vec)==0;
        batch{1}.spm.stats.fmri_spec.sess(n).cond(c).onset = vec(valid);
        
        %durations
        onset = model.conditions.durations(c);
        index = find(strcmp(varnames, onset));
        vec = double(sdata(sdata.run==n,index));
        batch{1}.spm.stats.fmri_spec.sess(n).cond(c).duration = vec(valid);
        
        batch{1}.spm.stats.fmri_spec.sess(n).cond(c).tmod = 0;
        
        %pmods
        batch{1}.spm.stats.fmri_spec.sess(n).cond(c).pmod = struct('name', {}, 'param', {}, 'poly', {});
        for i = 1:size(model.conditions.pmods,2)
            pmods = model.conditions.pmods{1,i};
            if isempty(pmods{c}) == 0
                pmod = pmods(c);
                index = find(strcmp(varnames, pmod));
                vec = double(sdata(sdata.run==n,index));
                namecell = pmod; 

                batch{1}.spm.stats.fmri_spec.sess(n).cond(c).pmod(1,i) = struct('name', namecell{1}, 'param', {vec(valid)}, 'poly', {1});
            end
        end

        batch{1}.spm.stats.fmri_spec.sess(n).cond(c).orth = 0;
    end
    
       
    batch{1}.spm.stats.fmri_spec.sess(n).multi =  {''};
    batch{1}.spm.stats.fmri_spec.sess(n).regress = struct('name', {}, 'val', {});
  
   
    if ismember(id,model.multiregissues(:))
        mregprefix = ['^rp_sn.*\.*.run' num2str(n)];
        batch{1}.spm.stats.fmri_spec.sess(n).multi_reg = cellstr(spm_select('FPList', path, mregprefix));
    else
        batch{1}.spm.stats.fmri_spec.sess(n).multi_reg = {[path '/Physio/r' num2str(n) '/multireg.txt']};
    end
    
    batch{1}.spm.stats.fmri_spec.sess(n).hpf = 128; % high pass filter
end

batch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
batch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0]; % HRF derivatives
batch{1}.spm.stats.fmri_spec.volt = 1;
batch{1}.spm.stats.fmri_spec.global = 'None';
batch{1}.spm.stats.fmri_spec.mthresh = 0.8;
batch{1}.spm.stats.fmri_spec.mask = {mask}; % mask
batch{1}.spm.stats.fmri_spec.cvi = 'AR(1)'; % AR-1 correction
batch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
batch{2}.spm.stats.fmri_est.write_residuals = 0;
batch{2}.spm.stats.fmri_est.method.Classical = 1;
batch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));

%  SPECIFYING CONTRASTS

N = length(model.conditions.pmods);
weights = zeros(1,Ncond*N); % creating a vector of 0 (for each condition)
names = model.conditions.names; % extracting regressors' names

% LOOP OVER CONTRASTS
counter = 1;
for c = 1:Ncond
    % extracting the regressor name
    namecell = names(c);
    batch{3}.spm.stats.con.consess{c}.tcon.name = namecell{1};
    
    
    temp_weights = weights; temp_weights(counter) = 1; % assigning 1 to the regressor in interest
    counter = counter + 1 + length(batch{1}.spm.stats.fmri_spec.sess(1).cond(c).pmod);
    
    batch{3}.spm.stats.con.consess{c}.tcon.weights = temp_weights; % save
    batch{3}.spm.stats.con.consess{c}.tcon.sessrep = 'repl'; % replicate for each run
    
end

batch{3}.spm.stats.con.delete = 0;

end