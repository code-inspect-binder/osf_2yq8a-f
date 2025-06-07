
function m = LS_SPM(model)

m = model;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  SPECIFYING THE GLM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% writing out parameteric modulators based on regressors in SPM format
disp('Writing out pmods...');
pmodfolder = [m.datafolder 'derivatives/onsets']; mkdir(pmodfolder); % creating folder for pmods
m = LS_pmods(m);

% creating a results folder
name = strjoin(m.regressors); m.outfolder = [m.outfolder name ' - ' m.epoch ' - ' m.group ' - ' m.comment '/'];
mkdir(m.outfolder);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  ANALYSES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp(['Running GLM: ' name])
 

LS_glm1(m); % first level

LS_glm2(m); % second level


end



