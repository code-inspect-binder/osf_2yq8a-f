
function batch = LS_conditions_job_func_runs(id,model)
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

if id == 113
    positions = [1 3 5 7 20 22 24 26 39 41 43 45 9 11 28 30 47 49];
    names = {'WS1', 'LS1', 'WL1', 'LL1','WS2', 'LS2', 'WL2', 'LL2','WS3', 'LS3', 'WL3', 'LL3', 'CL1', 'CS1', 'CL2', 'CS2', 'CL3', 'CS3'};


    for c = 1:length(positions)
        % extracting the regressor name
        namecell = names(c);
        batch{3}.spm.stats.con.consess{c}.tcon.name = namecell{1};
        temp_weights = zeros(1,60); temp_weights(positions(c)) = 1; % assigning 1 to the regressor in interest   
        batch{3}.spm.stats.con.consess{c}.tcon.weights = temp_weights; % save
        batch{3}.spm.stats.con.consess{c}.tcon.sessrep = 'none'; % replicate for each run

    end
elseif id == 25
    positions = [1 3 5 7 28 30 32 24 55 57 59 61 9 11 36 38 63 65];
    names = {'WS1', 'LS1', 'WL1', 'LL1','WS2', 'LS2', 'WL2', 'LL2','WS3', 'LS3', 'WL3', 'LL3', 'CL1', 'CS1', 'CL2', 'CS2', 'CL3', 'CS3'};


    for c = 1:length(positions)
        % extracting the regressor name
        namecell = names(c);
        batch{3}.spm.stats.con.consess{c}.tcon.name = namecell{1};
        temp_weights = zeros(1,84); temp_weights(positions(c)) = 1; % assigning 1 to the regressor in interest   
        batch{3}.spm.stats.con.consess{c}.tcon.weights = temp_weights; % save
        batch{3}.spm.stats.con.consess{c}.tcon.sessrep = 'none'; % replicate for each run

    end
elseif id == 105 || id == 107
    positions = [1 3 5 7 38 40 42 44 75 77 79 81 9 11 46 48 83 85];
    names = {'WS1', 'LS1', 'WL1', 'LL1','WS2', 'LS2', 'WL2', 'LL2','WS3', 'LS3', 'WL3', 'LL3', 'CL1', 'CS1', 'CL2', 'CS2', 'CL3', 'CS3'};


    for c = 1:length(positions)
        % extracting the regressor name
        namecell = names(c);
        batch{3}.spm.stats.con.consess{c}.tcon.name = namecell{1};
        temp_weights = zeros(1,96); temp_weights(positions(c)) = 1; % assigning 1 to the regressor in interest   
        batch{3}.spm.stats.con.consess{c}.tcon.weights = temp_weights; % save
        batch{3}.spm.stats.con.consess{c}.tcon.sessrep = 'none'; % replicate for each run

    end
else
    positions = [1 3 5 7 38 40 42 44 75 77 79 81 9 11 46 48 83 85];
    names = {'WS1', 'LS1', 'WL1', 'LL1','WS2', 'LS2', 'WL2', 'LL2','WS3', 'LS3', 'WL3', 'LL3', 'CL1', 'CS1', 'CL2', 'CS2', 'CL3', 'CS3'};


    for c = 1:length(positions)
        % extracting the regressor name
        namecell = names(c);
        batch{3}.spm.stats.con.consess{c}.tcon.name = namecell{1};
        temp_weights = zeros(1,114); temp_weights(positions(c)) = 1; % assigning 1 to the regressor in interest   
        batch{3}.spm.stats.con.consess{c}.tcon.weights = temp_weights; % save
        batch{3}.spm.stats.con.consess{c}.tcon.sessrep = 'none'; % replicate for each run

    end
  
end

batch{3}.spm.stats.con.delete = 0;

end