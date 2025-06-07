function betastr = LS_extract_betas(model)

% plot  fMRI B for a given ROI
%-------------------------------------------------------------------------
% requires MARSBAR
% Specify a ROI. Goes in the SPM.mat and extract beta.
% Beta's are then plotted over time with standard errors
%-------------------------------------------------------------------------


%specify data and roi path
roi_root_path = model.roifolder;
data_root_path = model.outfolder;

%Extract ROI names from the folder (mat files)
ROIlist = dir(fullfile(roi_root_path,'*.mat'));

ROI_spec = {ROIlist.name};
ROI_name = {ROIlist.name};


%initialize toolbox path and ROI dir
%-------------------------------------------------------------------------
spmpath=fileparts(which('spm.m'));
addpath([spmpath filesep 'toolbox']);
addpath([spmpath filesep 'toolbox' filesep 'marsbar']);
spm('defaults','fmri')
marsbar
%-------------------------------------------------------------------------

% Fetch the beta's of the last contrast
%-------------------------------------------------------------------------
beta = {};

parfor ROI = 1:size(ROIlist,1)
    
    roi_path = fullfile(roi_root_path, cell2mat(ROI_spec(ROI)));
    betastr = [];
         
        for i = 1:length(model.Subj)
            
            SUB = model.Subj(i);
            
            %Estimate and extract data
            %------------------------------------------------------------------------------------
            SPM_path = fullfile(data_root_path, ['sub-' num2str(SUB)], 'SPM.mat');
            % Make marsbar design object
            D  = mardo(SPM_path);
            % Make marsbar ROI object
            R  = maroi(roi_path);
            % Fetch data into marsbar data object
            Y  = get_marsy(R, D, 'wtmean');
            % Get contrasts from original design
            xCon = get_contrasts(D);
            % Estimate design on ROI data
            E = estimate(D, Y);
            % Put contrasts from original design back into design object
            E = set_contrasts(E, xCon);
            % get design betas
            b = betas(E);
            % get stats and stuff for all contrasts into statistics structure
            marsS = compute_contrasts(E, 1:length(xCon));
            %Select contrast
%             beta(i, ROI, :) = marsS.con;
%             beta(i, length(ROI_name)+1, :) = SUB;
            %------------------------------------------------------------------------------------
            
            betastr = [betastr; marsS.con SUB*ones(length(marsS.con),1) (1:length(marsS.con))' ROI*ones(length(marsS.con),1)];
    
    
        end
        
        beta{ROI} = betastr;
end
betas = [];
for i = 1:size(ROIlist,1)
    betas = [betas; beta{i}];
end

betastr = mat2dataset(betas,'VarNames',{'beta',...
'id','contrast', 'ROI'});


betastr.contrast = categorical(betastr.contrast,1:length(model.conditions.names),model.conditions.names);
betastr.ROI = categorical(betastr.ROI,1:length(ROI_name),ROI_name);

save([model.outfolder 'beta_results'],'betastr')
export(betastr,'File',[model.outfolder 'beta_results.csv'],'Delimiter',',');

end
