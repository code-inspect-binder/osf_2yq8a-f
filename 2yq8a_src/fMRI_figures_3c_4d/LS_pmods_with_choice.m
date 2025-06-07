function m = LS_pmods(m)

subjects = m.Subj;
data = m.data;
regressors = m.regressors;
datafolder = m.datafolder;
runs = m.runs;
epoch = m.epoch;

varnames = data.Properties.VarNames;
m.validtrials = [];

for i = subjects
    
    pmod_task1 = struct('name',{''},'param',{},'poly',{});
    
    pmod_task2 = struct('name',{''},'param',{},'poly',{});
    
  
      
    sdata = data(data.idc==i ,:); % 
     
    valids = {};
    validtrials = 0;

    for run = 1:runs

        for r = 1:length(regressors)
            
            rname = regressors(r); % regressors name
            index = find(strcmp(varnames, rname));
            
            
            
            vec = double(sdata(sdata.run==run,index));
            
            if m.demean == 1
                vec = vec - mean(vec,'omitnan');
            end
            
            valids{run}(:,r) = 1 - isnan(vec);
            
            if range(vec) ~= 0
                pmod_task1(run).name{r}  = char(rname);
                pmod_task1(run).param{r} = vec;
                pmod_task1(run).poly{r}  = 1;
                
                pmod_task2(run).name{r}  = char(rname);
                pmod_task2(run).param{r} = vec;
                pmod_task2(run).poly{r}  = 1;

            end
        
        end
        
        
        valids{run} = min(valids{run},[],2);
        index = valids{run} == 1;
        validtrials = validtrials + sum(index);
        
        % Cleaning out missing data
        for r = 1:length(regressors)
            pmod_task1(run).param{r} = pmod_task1(run).param{r}(index);
            pmod_task2(run).param{r} = pmod_task2(run).param{r}(index);
        end
        
        names = {'parametric' 'parametric'};
        orth = {0 0};
        
        if strcmp(epoch,'choice') 
            ons = sdata.onset_choice(sdata.run==run,:);
        else
            ons = sdata.onset_feedback(sdata.run==run,:);
        end
        
        ons_choice = sdata.onset_choice(sdata.run==run,:);
        
        onsets = {ons(index) ons_choice(index)};
        
        if strcmp(epoch,'choice')
            durs = sdata.rt(sdata.run==run,:);
        else
            durs = 0.*sdata.rt(sdata.run==run,:);
        end
        
        durs_choice = sdata.rt(sdata.run==run,:);
        
        durations = {durs(index) durs_choice(index)};
        
       
        
        outfile = [datafolder 'derivatives/onsets/' num2str(i) '_run' num2str(run) '.mat'];
        pmod(1) = pmod_task1(run);
        pmod(2) = pmod_task2(run);
        save(outfile,'names', 'onsets','durations','pmod','orth');
        
        
        regnames = pmod_task1(run).name;
        outfile = [datafolder 'derivatives/regnames.mat'];
        save(outfile,'regnames');
        
        
    end
    
    % saving how many valid trials were there
    m.validtrials = [m.validtrials; i validtrials];
    
end


end