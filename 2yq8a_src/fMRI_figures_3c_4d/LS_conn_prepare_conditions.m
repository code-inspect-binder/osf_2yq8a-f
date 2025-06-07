function LS_conn_prepare_conditions(data,codefolder)

subjects = unique(data.id)';

for i = subjects
    
    sdata = data(data.id==i,:);
    
    
    for run = 1:3
        
        
        onsets1 = sdata.onset_feedback(sdata.run == run & sdata.opponent == 0 & sdata.payoff == 0);
        onsets2 = sdata.onset_feedback(sdata.run == run & sdata.opponent == 0 & sdata.payoff == 1);
        onsets3 = sdata.onset_feedback(sdata.run == run & sdata.opponent == 1 & sdata.payoff == 0);
        onsets4 = sdata.onset_feedback(sdata.run == run & sdata.opponent == 1 & sdata.payoff == 1);
        
        durations1 = 2.5*ones(numel(onsets1),1);
        durations2 = 2.5*ones(numel(onsets2),1);
        durations3 = 2.5*ones(numel(onsets3),1);
        durations4 = 2.5*ones(numel(onsets4),1);
        
        onsets = [onsets1];
        durations = [durations1];
        outfile = [codefolder '/conn_onsets/sub_' num2str(i) '_onsets1_run' num2str(run) '.mat'];
        save(outfile,'onsets','durations');
        
        onsets = [onsets2];
        durations = [durations2];
         outfile = [codefolder '/conn_onsets/sub_' num2str(i) '_onsets2_run' num2str(run) '.mat'];
        save(outfile,'onsets','durations');
        
        onsets = [onsets3];
        durations = [durations3];
         outfile = [codefolder '/conn_onsets/sub_' num2str(i) '_onsets3_run' num2str(run) '.mat'];
        save(outfile,'onsets','durations');
        
        onsets = [onsets4];
        durations = [durations4];
         outfile = [codefolder '/conn_onsets/sub_' num2str(i) '_onsets4_run' num2str(run) '.mat'];
        save(outfile,'onsets','durations');
    end
          
end

end