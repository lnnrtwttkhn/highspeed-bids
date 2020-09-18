%% SCRIPT: CREATE EVENT.TSV FILES FROM THE BEHAVIORAL DATA FOR BIDS
% =========================================================================
% PROJECT: HIGHSPEED
% WRITTEN BY LENNART WITTKUHN 2018 - 2020
% CONTACT: WITTKUHN AT MPIB HYPHEN BERLIN DOT MPG DOT DE
% MAX PLANCK RESEARCH GROUP NEUROCODE
% MAX PLANCK INSTITUTE FOR HUMAN DEVELOPMENT
% MAX PLANCK UCL CENTRE FOR COMPUTATIONAL PSYCHIATRY AND AGEING RESEARCH
% LENTZEALLEE 94, 14195 BERLIN, GERMANY
% =========================================================================
%% DEFINE PATHS AND IMPORTANT VARIABLES:
% clear the workspace and command window:
clear variables; clc;
% define the data root path
path_root = strsplit(pwd, 'code');
path_root = path_root{1};
% define the input path:
path_input = fullfile(path_root, 'input', 'behavior', 'main');
% define the output path:
path_output = path_root;
% get the contents of the output directory:
path_output_dir = dir(path_output);
% check how many subjects are in the root directory:
num_subs_found = sum(contains({path_output_dir.name},'sub'));
% extended output path used to check for old files:
path_old_files = fullfile(path_output,'*','*','func');
% find all existing events.tsv files in the output directory:
prev_files = dir(fullfile(path_old_files,'*events.tsv'));
% delete all previous events files:
for old_file = 1:length(prev_files)
      delete(fullfile(prev_files(old_file).folder,prev_files(old_file).name))
end
% define the script path:
path_script = fullfile(path_root, 'code');
% read the text file containing a list of subject ids:
sub_list = dlmread(fullfile(path_script, 'heudiconv', 'highspeed-participant-list.txt'));
% turn the array with ids into a strings in a cell array:
sub_list = cellstr(num2str(sub_list));
%check if the number of subjects in the list matches the target directory
if numel(sub_list) ~= num_subs_found
    warning(['Number of subjects in the data dir does not match ' ...
        'number of subjects in the subject text file!']);
    sub_alt_list = cellfun(@num2str,num2cell(1:length(sub_list)),'un',0);
else
    sub_alt_list = sub_list;
    sub_alt_list = cellfun(@num2str,num2cell(1:num_subs_found),'un',0);
end
% determine the number of study sessions:
num_ses = 2;
% determine the number of task runs per study session:
num_run = 4;
% define a cell array containing the stimulus labels in german:
key_set = {'Gesicht','Haus','Katze','Schuh','Stuhl'};
% define a cell array containing the stimulus labels in english:
value_set = {'Face','House','Cat','Shoe','Chair'};
% create a dictionary that translates the stimulus labels:
label_dict = containers.Map(key_set,value_set);
% create a 2d-array of run indices ordered by run (row) and sessions (col):
run_array = reshape(1:num_run * num_ses, num_run, num_ses);
% define the names of the four different task conditions:
task_names = {'oddball','sequence','repetition','repetition'};
%%
for sub = 1:length(sub_alt_list)
%for sub = 1:1
    % initialize the maximum repetition trial index:
    max_rep = 0;
    % get the current subject id:
    sub_id = sub_list{sub};
    % print progress:
    fprintf('Running sub %d of %d\n', sub, length(sub_alt_list))
    % define a template string that takes subject, session and run id:
    template_string = '*sub_%s_session_%d*run_%d*';
    % put in the current subject, session and run id:
    file_string = sprintf(template_string,sub_id,num_ses,num_run);
    % read behavioral data files of all participants:
    path_file = dir(fullfile(path_input,file_string));
    % load the behavioral data into the workspace:
    load(fullfile(path_input,path_file.name));
    for session = 1:num_ses
        % create a subject identifier (in bids format):
        pad_sub = sprintf('sub-%02d',str2double(sub_alt_list{sub}));
        % create a session identififer (in bids format):
        pad_ses = ['ses-0', num2str(session)];
        % combine the two identifiers as the first part of file names:
        sub_file_name = strcat(pad_sub,'_',pad_ses);
        % create the subject output path:
        path_output_sub = (fullfile(path_output,pad_sub,pad_ses,'func'));
        % create the subject directory if it does not exist yet:
        if ~exist(path_output_sub,'dir')
            system(sprintf('mkdir -p %s',path_output_sub));
        end
        for run = 1:num_run
            events = table;
            for cond = 1:4                
                event_all = extract_bids_events(Data, Basics, Sets, pad_sub, run, session, cond);
                events = [events;event_all];
                
            end
            % sort by event onset (i.e., in chronological order):
            events = sortrows(events,{'onset'});
            % make two copies of the repetition trials:
            rep_trials_old = events.trial(contains(events.condition, 'repetition'));
            rep_trials_new = rep_trials_old;
            % get the old trial indices while maintaining their order:
            trial_old = unique(rep_trials_old, 'stable');
            % get the number of repetition trials in the current run:
            n_rep_trials = length(trial_old);
            % create new trial indices depending on the running number of
            % repetition trials:
            trial_new = max_rep+1:max_rep+n_rep_trials;
            % change the old trial indices
            for i = 1:n_rep_trials
                rep_trials_new(rep_trials_old == trial_old(i)) = trial_new(i);
            end
            % update the repetition trials of the events files:
            events.trial(contains(events.condition, 'repetition')) = rep_trials_new;
            % update the counter of the maximum repetition trial index:
            max_rep = max(unique(events.trial(contains(events.condition, 'repetition'))));
            % create template string file for data output (tsv format):
            string_template = '_task-highspeed_rec-prenorm_run-0%d_events';
            % write conditon and run information into the string:
            string_written = sprintf(string_template,run);
            % create the full filenames:
            outfile_name = strcat(sub_file_name,string_written);
            % create paths of the tsv and csv files:
            path_tsv = fullfile(path_output_sub,strcat(outfile_name,'.tsv'));
            path_csv = fullfile(path_output_sub,strcat(outfile_name,'.csv'));
            % write the events table as csv file:
            writetable(events,path_csv,'Delimiter','\t');
            % copy the created file from csv to tsv file:
            copyfile(path_csv,path_tsv)
            % delete the csv file:
            delete(path_csv);
        end
    end
end

