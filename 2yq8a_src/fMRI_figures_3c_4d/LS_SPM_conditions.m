
function model = LS_SPM_conditions(model)


% creating a results folder
% this creates a folder that contains all the output of the GLM named
% "condition1_condition2_condition3__conditions"
name = strjoin(model.conditions.names,'_'); model.outfolder = [model.outfolder name '_' model.comment '__conditions/'];
mkdir(model.outfolder);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  ANALYSES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp(['Running conditions: ' name])
 
LS_conditions(model); % first level analysis

%LS_conditions2(model); % second level analysis


end



