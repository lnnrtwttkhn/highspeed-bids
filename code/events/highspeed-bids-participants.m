%% HIGHSPEED: GET DATA OF THE HIGHSPEED TASK
clear variables; clc; % clear workspace and command window

path_base = '/Volumes/MPRG-Neurocode/Data/highspeed/main_mri/rawdata/';
path_input = fullfile(path_base, 'behav_main');
path_tardis = fullfile('/Users/wittkuhn/Volumes/tardis/highspeed');
path_output = fullfile(path_tardis, 'bids');
path_digitspan = fullfile(path_base, 'digit_span');
allID = dlmread('/Users/wittkuhn/highspeed/highspeed_analysis/code/parameters/highspeed_participant_list.txt');
num_subs = length(allID);

% get data
dirData = dir(path_input);
dirData = {dirData.name};
dataFiles = dirData(contains(dirData,'session_1_run_4') & contains(dirData,cellstr(num2str(allID)))); % search for matching files

covariates = table;
covariates.participant_id = cell(num_subs,1);
covariates.age = nan(num_subs,1);
covariates.sex = cell(num_subs,1);
covariates.handedness = cell(num_subs,1);
covariates.digit_span = nan(num_subs,1);
covariates.randomization = nan(num_subs,1);
covariates.session_interval = nan(num_subs,1);

% study intervals, ordered by participant ids:
intervals = {
    1, 13, 4, 4, 17, 8, 14, 6, 7, 10, ...
    7, 6, 18, 4, 8, 5, 23, 3, 1, 12, ...
    9, 8, 24, 21, 17, 21, 14, 4, 4, 9, ...
    7, 7, 11, 7, 14, 2, 1, 5, 3, 3};
% create a dictionary that maps IDs to intervals:
interval_dict = containers.Map(allID,intervals);

filetemplate = 'highspeed_task_mri_sub_%d_session_%d_run_%d.mat';
fprintf('List of missing data:\n')
for sub = 1:num_subs
    % get correct ids:
    id_orig = allID(sub);
    id_new = sprintf('sub-%02d', sub);
    % load task statistics
    session = 1; run = 4;
    filename = sprintf(filetemplate,allID(sub),session,run);
    dataframe = dirData(contains(dirData,filename));
    if ~isempty(dataframe)
        load(fullfile(path_input,filename));
        covariates.participant_id{sub} = id_new;
        covariates.age(sub) = Parameters.subjectInfo.age;
        covariates.sex{sub} = Parameters.subjectInfo.gender;
        covariates.handedness{sub} = 'right';
        covariates.randomization(sub) = Parameters.subjectInfo.cbal;
        covariates.session_interval(sub) = interval_dict(id_orig);
    else
        str = strcat(str,'- all behavioral data\n');
    end
    % digit span
    digitspan_file = sprintf('DigitSpan_%d.mat',allID(sub));
    digitspan_dir = dir(fullfile(path_digitspan));
    if any(contains({digitspan_dir.name},digitspan_file))
        load(fullfile(path_digitspan,digitspan_file))
        covariates.digit_span(sub) = nansum(Data.acc);
    end
end

% WRITE  DATA
writetable(covariates,fullfile(path_output,'participants.csv'),'Delimiter','\t','WriteRowNames',true,...
    'QuoteStrings',true,'WriteVariableNames',true)
copyfile(fullfile(path_output,'participants.csv'), fullfile(path_output,'participants.tsv'));
delete(fullfile(path_output,'participants.csv'));


