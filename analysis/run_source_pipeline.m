%%
clear;

% Load data details
addpath('/project/3031004.01/meg-ahat/util')
addpath('/project/3031004.01/meg-ahat/analysis')
data_details_cfg = get_data_details();

% Define subjects, tasks, and conditions
subjects = data_details_cfg.new_trigger_subs; % Subjects correctly stimulated


data_dir = '/project/3031004.01/data/';
derivatives_dir = fullfile(data_dir, 'derivatives');
derivatives_group_dir = fullfile(derivatives_dir, 'group');
derivatives_img_dir = fullfile(derivatives_dir, 'img');
derivatives_img_dir_source = fullfile(derivatives_img_dir, 'source-level');

tasks = ["va" "wm"];
stim_conditions = ["con" "isf" "strobe"];

symmetry_constraint = false;
overwrite = true;

%%
for task = tasks
    for sub = subjects
        for stim_condition = stim_conditions
            % stim_condition = "con";
            estimate_sources(sub, task, stim_condition)
            % stim_condition = "strobe";
            % estimate_sources(sub, task, stim_condition)

            % Contrast
            source1_cfg = [];
            source1_cfg.sub = sub;
            source1_cfg.stim_condition = stim_condition;
            source1_cfg.task = task;

            source2_cfg = source1_cfg;
            switch task
                case "va"
                    source1_cfg.task_level = "left";
                    source2_cfg.task_level = "right";

                    % contrast_sources(source1_cfg, source2_cfg);
                    
                    % source1_cfg.stim_condition = "con";
                    % source2_cfg.stim_condition = "con";
                    % contrast_sources(source1_cfg, source2_cfg);
    
                case "wm"
    
                    % source1_cfg = [];
                    % source1_cfg.sub = sub;
                    % source1_cfg.stim_condition = "strobe";
                    % source1_cfg.task = task;
                    % 
                    % source2_cfg = source1_cfg;
                    source1_cfg.task_level = "low";
                    source2_cfg.task_level = "high";
            end
            contrast_sources(source1_cfg, source2_cfg);

        end
    end

end

%%
allsources_ga_filename = fullfile(derivatives_group_dir, 'allsources_contrast_grandaverage.mat');
load (allsources_ga_filename)
% stim_conditions = ["isf" "strobe"];

%
numrandomization = 1500;
% VA
close all

% stim_condition = ["isf"];
% tasks = ["wm"];

for task = tasks
    switch task
        case "va"
            levels = ["left", "right"];
        case "wm"
            levels = ["low", "high"];
    end

    for stim_condition = stim_conditions
        if not(stim_condition == "con")
            % Permute VA task levels across stim condtions
            permute_cfg = [];
            permute_cfg.overwrite = overwrite;
            permute_cfg.subs = subjects;
            permute_cfg.numrandomization = numrandomization;
            permute_cfg.task = task;
            permute_cfg.permute.factor = "stim_condition";
            permute_cfg.permute.levels = ["con", stim_condition];
            permute_cfg.contrast = levels;%["left", "right"];
            [stat, output_file] = permute_conditions(permute_cfg);
            anatomy = allsources_int_volnorm_ga.va.con.anatomy;
            stat.anatomy = anatomy;
            cfg = [];
            cfg.method        = 'slice';
            cfg.funparameter  = 'stat';
            cfg.maskparameter = 'mask';
            figure
            ft_sourceplot(cfg, stat);
            hc=colorbar;
            title(hc,'$t_{\hat{\beta}}$', 'interpreter', 'latex', 'FontSize', 16);
            %title("Permute VA task levels across stim condtions")
            output_file = extractBefore(output_file, '.');
            if not(symmetry_constraint)
                output_file = strcat(output_file, "nonsym");
            end
            output_file = fullfile(derivatives_img_dir_source, strcat(output_file, '.png'));
            saveas(gcf, output_file)
            
            
            
            % Permute VA stim conditions
            permute_cfg = [];
            permute_cfg.overwrite = overwrite;
            permute_cfg.subs = subjects;
            permute_cfg.numrandomization = numrandomization;
            permute_cfg.task = task;
            permute_cfg.permute.factor = "stim_condition";
            permute_cfg.permute.levels = ["con", stim_condition];
            [stat, output_file] = permute_conditions(permute_cfg);
            anatomy = allsources_int_volnorm_ga.va.con.anatomy;
            stat.anatomy = anatomy;
            cfg = [];
            cfg.method        = 'slice';
            cfg.funparameter  = 'stat';
            cfg.maskparameter = 'mask';
            figure
            ft_sourceplot(cfg, stat);
            hc=colorbar;
            title(hc,'$t_{\hat{\beta}}$', 'interpreter', 'latex', 'FontSize', 16);
            %title("Permute VA stim conditions")
            output_file = extractBefore(output_file, '.');
            if not(symmetry_constraint)
                output_file = strcat(output_file, "nonsym");
            end
            output_file = fullfile(derivatives_img_dir_source, strcat(output_file, '.png'));
            saveas(gcf, output_file)
        end
    
        % Permute VA task levels within stim conditions
        % Strobe
        permute_cfg = [];
        permute_cfg.overwrite = overwrite;
        permute_cfg.subs = subjects;
        permute_cfg.numrandomization = numrandomization;
        permute_cfg.task = task;
        permute_cfg.stim_condition = stim_condition;
        permute_cfg.permute.factor = "tasklevel";
        permute_cfg.permute.levels = levels;%["left", "right"];
        [stat, output_file] = permute_conditions(permute_cfg);
        anatomy = allsources_int_volnorm_ga.va.con.anatomy;
        stat.anatomy = anatomy;
        cfg = [];
        cfg.method        = 'slice';
        cfg.funparameter  = 'stat';
        cfg.maskparameter = 'mask';
        figure
        ft_sourceplot(cfg, stat);
        hc=colorbar;
        title(hc,'$t_{\hat{\beta}}$', 'interpreter', 'latex', 'FontSize', 16);
        %title("Permute VA task levels within stim conditions: Strobe")
        output_file = extractBefore(output_file, '.');
        if not(symmetry_constraint)
            output_file = strcat(output_file, "nonsym");
        end
        output_file = fullfile(derivatives_img_dir_source, strcat(output_file, '.png'));
        saveas(gcf, output_file)
        
        % % Con
        % permute_cfg = [];
        % permute_cfg.subs = subjects;
        % permute_cfg.numrandomization = numrandomization;
        % permute_cfg.task = task;
        % permute_cfg.stim_condition = "con";
        % permute_cfg.permute.factor = "tasklevel";
        % permute_cfg.permute.levels = ["left", "right"];
        % [stat, output_file] = permute_conditions(permute_cfg);
        % anatomy = allsources_int_volnorm_ga.va.con.anatomy;
        % stat.anatomy = anatomy;
        % cfg = [];
        % cfg.method        = 'slice';
        % cfg.funparameter  = 'stat';
        % cfg.maskparameter = 'mask';
        % figure
        % ft_sourceplot(cfg, stat);
        % hc=colorbar;
        % title(hc,'$t_{\hat{\beta}}$', 'interpreter', 'latex', 'FontSize', 16);
        % %title("Permute VA task levels within stim conditions: Con")
        % output_file = extractBefore(output_file, '.');
        % output_file = fullfile(derivatives_img_dir_source, strcat(output_file, '.png'));
        % saveas(gcf, output_file)
    end
end

%% WM
% task = "wm";
% % Permute WM task levels across stim condtions
% permute_cfg = [];
% permute_cfg.subs = subjects;
% permute_cfg.numrandomization = numrandomization;
% permute_cfg.task = task;
% permute_cfg.permute.factor = "stim_condition";
% permute_cfg.permute.levels = ["con", "strobe"];
% permute_cfg.contrast = ["low", "high"];
% [stat, output_file] = permute_conditions(permute_cfg);
% anatomy = allsources_int_volnorm_ga.va.con.anatomy;
% stat.anatomy = anatomy;
% cfg = [];
% cfg.method        = 'slice';
% cfg.funparameter  = 'stat';
% cfg.maskparameter = 'mask';
% figure
% ft_sourceplot(cfg, stat);
% hc=colorbar;
% title(hc,'$t_{\hat{\beta}}$', 'interpreter', 'latex', 'FontSize', 16);
% %title("Permute WM task levels across stim condtions")
% output_file = extractBefore(output_file, '.');
% output_file = fullfile(derivatives_img_dir_source, strcat(output_file, '.png'));
% saveas(gcf, output_file)
% 
% 
% % Permute WM stim conditions
% permute_cfg = [];
% permute_cfg.subs = subjects;
% permute_cfg.numrandomization = numrandomization;
% permute_cfg.task = task;
% permute_cfg.permute.factor = "stim_condition";
% permute_cfg.permute.levels = ["con", "strobe"];
% [stat, output_file] = permute_conditions(permute_cfg);
% anatomy = allsources_int_volnorm_ga.va.con.anatomy;
% stat.anatomy = anatomy;
% cfg = [];
% cfg.method        = 'slice';
% cfg.funparameter  = 'stat';
% cfg.maskparameter = 'mask';
% figure
% ft_sourceplot(cfg, stat);
% hc=colorbar;
% title(hc,'$t_{\hat{\beta}}$', 'interpreter', 'latex', 'FontSize', 16);
% %title("Permute WM stim conditions")
% output_file = extractBefore(output_file, '.');
% output_file = fullfile(derivatives_img_dir_source, strcat(output_file, '.png'));
% saveas(gcf, output_file)
% 
% % Permute WM task levels within stim conditions
% % Strobe
% permute_cfg = [];
% permute_cfg.subs = subjects;
% permute_cfg.numrandomization = numrandomization;
% permute_cfg.task = task;
% permute_cfg.stim_condition = "strobe";
% permute_cfg.permute.factor = "tasklevel";
% permute_cfg.permute.levels = ["low", "high"];
% [stat, output_file] = permute_conditions(permute_cfg);
% anatomy = allsources_int_volnorm_ga.va.con.anatomy;
% stat.anatomy = anatomy;
% cfg = [];
% cfg.method        = 'slice';
% cfg.funparameter  = 'stat';
% cfg.maskparameter = 'mask';
% figure
% ft_sourceplot(cfg, stat);
% hc=colorbar;
% title(hc,'$t_{\hat{\beta}}$', 'interpreter', 'latex', 'FontSize', 16);
% %title("Permute WM task levels within stim condition: Strobe")
% output_file = extractBefore(output_file, '.');
% output_file = fullfile(derivatives_img_dir_source, strcat(output_file, '.png'));
% saveas(gcf, output_file)
% 
% % Con
% permute_cfg = [];
% permute_cfg.subs = subjects;
% permute_cfg.numrandomization = numrandomization;
% permute_cfg.task = task;
% permute_cfg.stim_condition = "con";
% permute_cfg.permute.factor = "tasklevel";
% permute_cfg.permute.levels = ["low", "high"];
% [stat, output_file] = permute_conditions(permute_cfg);
% anatomy = allsources_int_volnorm_ga.va.con.anatomy;
% stat.anatomy = anatomy;
% cfg = [];
% cfg.method        = 'slice';
% cfg.funparameter  = 'stat';
% cfg.maskparameter = 'mask';
% figure
% ft_sourceplot(cfg, stat);
% hc=colorbar;
% title(hc,'$t_{\hat{\beta}}$', 'interpreter', 'latex', 'FontSize', 16);
% %title("Permute WM task levels within stim condition: Con")
% output_file = extractBefore(output_file, '.');
% output_file = fullfile(derivatives_img_dir_source, strcat(output_file, '.png'));
% saveas(gcf, output_file)
