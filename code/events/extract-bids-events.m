function event_all = extract_bids_events(Data, Basics, Sets, pad_sub, run, ses, cond)
%% CONVERT DATASET TO TABLE AND GET THE VARIABLE NAMES:
% convert data table from dataset to table type:
data = dataset2table(Data(cond).data);
% get the variable names of the current data table:
var_names = data.Properties.VariableNames;
% get all events we want to convert:
all_events = var_names(contains(var_names, {'tFlip'}));
%% BASIC TASK STATS
% determine the number of study sessions:
num_ses = 2;
% determine the number of task runs per study session:
num_run = 4;
% get the indices of the current sessions (as booleans):
idx_session = Basics.runInfo.session == ses;
% get the indices of the current run (as booleans):
idx_run = Basics.runInfo.run == run;
% get the timestamp of of the first scanner trigger:
t_trigger = Basics.runInfo.tTrigger(idx_session & idx_run);
% get the data indices of the current session:
idx_data_ses = data.session == ses;
% get the data indices of the current run within session:
idx_data_run = data.run == run;
% combine the indices to get the correct data indices:
index = idx_data_ses & idx_data_run;
% create a 2d-array of run indices ordered by run (row) and sessions (col):
run_array = reshape(1:num_run * num_ses, num_run, num_ses);
% define the names of the four different task conditions:
task_names = {'oddball','sequence','repetition','repetition'};
%% DEFINE DICTIONAIRY FOR THE STIMULUS LABELS:
% define a cell array containing the stimulus labels in german:
keys_stim = {'Gesicht','Haus','Katze','Schuh','Stuhl'};
% define a cell array containing the stimulus labels in english:
value_stim = {'face','house','cat','shoe','chair'};
% create a dictionary that translates the stimulus labels:
dict_stim = containers.Map(keys_stim,value_stim);
%% DEFINE DICTIONAIRY FOR THE EVENTS:
% define a cell array containing the stimulus labels in german:
keys_type = {'tFlipCue','tFlipBlank','tFlipFix','tFlipStim','tFlipITI','tFlipDelay','tFlipResp','tResponse'};
% define a cell array containing the stimulus labels in english:
value_type = {'cue','blank','fixation','stimulus','interval','delay','choice','response'};
% create a dictionary that translates the stimulus labels:
dict_type = containers.Map(keys_type,value_type);
%% LOOP OVER ALL EVENTS AND GATHER THE EVENT INFORMATION
event_all = table;
for i = 1:length(all_events)
    % get the current event:
    event_type = all_events{i};
    % get the number of sequential stimuli of that event:
    num_seq_stim = size(data{:,event_type},2);
    % number of trials of cond in the current run and session:
    num_events = sum(index) * num_seq_stim;
    % initialize empty events struct
    event = struct;
    
    % onsets, in seconds from first trigger:
    event.onset = data{index, event_type} - t_trigger;
    event.onset = reshape(transpose(event.onset),[],1);
    
    % duration, in seconds
    if strcmp(event_type,'tFlipCue')
        event.duration = repmat(Basics.tTargetCue,num_events,1);
    elseif strcmp(event_type, 'tFlipBlank')
        event.duration = repmat(Basics.tPreFixation,num_events,1);
    elseif strcmp(event_type, 'tFlipFix')
        event.duration = repmat(Basics.tFixation,num_events,1);
    elseif strcmp(event_type, 'tFlipStim')
        event.duration = repmat(Sets(cond).set.tStim,num_events,1);
    elseif strcmp(event_type, 'tFlipStim')
        event.duration = repmat(Sets(cond).set.tStim,num_events,1);
    elseif strcmp(event_type, 'tFlipITI')
        event.duration = repelem(data.tITI(index,:),num_seq_stim,1);
    elseif strcmp(event_type, 'tFlipDelay')
        event.duration = (data{index, 'tFlipResp'} - t_trigger) - event.onset;
    elseif strcmp(event_type, 'tFlipResp')
        event.duration = repmat(Basics.tResponseLimit,num_events,1);
    end
    
    % participant id
    event.subject = repmat({pad_sub},num_events,1);
    % add column that contains the session identifier:
    event.session = repmat(ses,num_events,1);
    % run within session:
    event.run_session = repmat(run,num_events,1);
    % run across the entire experiment:
    event.run_study = repmat(run_array(run,ses),num_events,1);
    % add column that contains the trial counter
    if cond == 4
        trial_indices = 41:1:45;
        event.trial = repelem(trial_indices(index)',num_seq_stim,1);
    else
        event.trial = repelem(find(index),num_seq_stim,1);
    end
    % add column that contains the condition:
    event.condition = repmat(task_names(cond),num_events,1);
    % add column that contains the trial type:
    event.trial_type = (repmat({dict_type(event_type)},num_events,1));
    
    % initialize all other event information:
    event.serial_position = nan(num_events,1);
    event.interval_time = nan(num_events,1);
    event.stim_orient = nan(num_events,1);
    event.stim_index = nan(num_events,1);
    event.stim_label = event.trial_type;
    %event.stim_file = strcat('images/',event.stim_label,'.jpg');
    event.target = nan(num_events,1);
    event.nontarget = nan(num_events,1);
    event.key_down = nan(num_events,1);
    event.key_id = repmat({NaN},num_events,1);
    event.key_target = repmat({NaN},num_events,1);
    event.accuracy = nan(num_events,1);
    event.response_time = nan(num_events,1);
    
    if strcmp(event_type, 'tFlipStim')
        % add column that contains the sequential position:
        event.serial_position = repmat(1:num_seq_stim,1,sum(index))';
        % add column that contains the inter-stimulus interval:
        event.interval_time = repelem(data.tITI(index,:),num_seq_stim,1);
        % add column that contains the stimulus orientation:
        event.stim_orient = repelem(data.orient(index,:),num_seq_stim,1);
        % get stimulus labels of the current run:
        event.stim_index = data.stimIndex(index,:);
        event.stim_index = reshape(transpose(event.stim_index),[],1);
        % add column that contains the path to the stimulus folder:
        event.stim_label = transpose(value_stim(event.stim_index));
        %event.stim_file = strcat('images/',event.stim_label,'.jpg');
        % add column that indicates whether stimulus is a target:
        if cond == 1
            event.target = double(event.stim_orient == 180);
            event.nontarget = nan(sum(index) * num_seq_stim,1);
        elseif cond == 2 || cond == 3 || cond == 4
            A = data.stimIndex(index,:);
            V = data.targetPos(index,:);
            W = data.targetPosAlt(index,:);
            event.target = bsxfun(@eq, cumsum(ones(size(A)), 2), V);
            event.target = reshape(transpose(event.target),[],1);
            event.nontarget = bsxfun(@eq, cumsum(ones(size(A)), 2), W);
            event.nontarget = reshape(transpose(event.nontarget),[],1);
        end
    end
    
    % add participant responses:
    if (strcmp(event_type, 'tFlipStim') && strcmp(task_names{cond}, 'oddball')) || ...
        (strcmp(event_type, 'tFlipResp') && ~strcmp(task_names{cond}, 'oddball'))
        % key press
        event.key_down = repelem(data.keyIsDown(index,:),num_seq_stim,1);
        % key identity
        event.key_id = repelem(data.keyIndex(index,:),num_seq_stim,1);
        if ~isempty(event.key_id)
            event.key_id = cellstr(num2str(event.key_id));
            event.key_id(strcmp(strrep(event.key_id,' ',''),'90')) = {'left'};
            event.key_id(strcmp(strrep(event.key_id,' ',''),'71')) = {'right'};
            event.key_id(~strcmp(event.key_id,'left') & ...
                ~strcmp(event.key_id,'right')) = {NaN};
        end
        % key target
        if ismember('keyTarget',data.Properties.VariableNames)
            event.key_target = repelem(data.keyTarget(index,:),num_seq_stim,1);
        else
            event.key_target = repmat({NaN},sum(index) * num_seq_stim,1);
        end
        % accuracy
        event.accuracy = repelem(data.acc(index,:),num_seq_stim,1);
        % response time
        event.response_time = repelem(data.rt(index,:),num_seq_stim,1);

    end
    events = struct2table(event);
    event_all = [event_all;events];
end
% remove all events that have no onset:
event_all(isnan(event_all.onset),:) = [];
end

