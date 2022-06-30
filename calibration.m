% Offline regression of velocity from EOG
clear; close all; clc;
hordat=cell(1,5);verdat=cell(1,5);
for i=1:5
    hordat{i}=readtable(['data/hor',num2str(i),'.txt']);
    verdat{i}=readtable(['data/ver',num2str(i),'.txt']);
end

for i=1:5
    trial = hordat{i};
    hordat{i} = table2array(trial(8:end,[2, 4, 17]));
    trial = verdat{i}; 
    verdat{i} = table2array(trial(8:end,[2, 4, 17]));
end

hor_data = [];
ver_data = [];

for dir = 1:2 
    for i = 1
        if dir == 1
            trial = hordat{i}; 
            locs = repmat([-1 -2/3 -1/3 0 1/3 2/3 1], 1, 5);
        elseif dir == 2
            trial = verdat{i}; 
            locs = repmat([-1 -1/2 0 1/2 1], 1, 7); 
        end
        
        trial_times = []; 
        for t = 2:length(trial) 
            try
            if trial(t+1, 3) == 1 && trial(t, 3) == 1 && trial(t-1, 3) == 0 && trial(t-2, 3) == 0 && trial(t-3, 3)== 0
                trial_times = [trial_times t]; 
            end
            catch
   
            end
        end
        
        if length(trial_times) ~= 35
            disp(dir) 
            disp(i)
            disp(length(trial_times))
        end
        
        for t = 1:length(trial_times)  % t = 1:35
            if (dir == 1 && t >= 15 && t <= 21) || (dir == 2 && t >= 16 && t <= 20)  % uncomment if using centered targets only for calibration.
                trial(:, 1:2) = highpass(trial(:, 1:2), 0.175, 250);
                trial(:, 1:2) = zscore(trial(:, 1:2)); 
                start = trial_times(t);
                finish = trial_times(t) + 250; 
                ch1 = trial(start:finish,1); 
                ch2 = trial(start:finish,2); 

                baseline_ch1 = trial(1:1000,1); 
                baseline_ch2 = trial(1:1000,2); 

                mean_ch1 = mean(ch1) - mean(baseline_ch1)/std(baseline_ch1); 
                mean_ch2 = mean(ch2) - mean(baseline_ch2)/std(baseline_ch2); 
                location = locs(t); 

                add = [mean_ch1, mean_ch2, location]; 
                if dir == 1
                    hor_data = [hor_data; add]; 
                elseif dir == 2
                    ver_data = [ver_data; add]; 
                end
           end
        end
    end
end

%% Regression
figure; y = hor_data(:,3); X = [ones(size(hor_data(:,1))) hor_data(:,1),hor_data(:,2)];
scatter3(X(:,2),X(:,3),y,'filled'); title('Horizontal'); 
xlabel('CH1'); ylabel('CH2'); zlabel('Gaze location (% of screen space)')

[bx,bintx,rx,rintx,statsx] = regress(y,X);

figure; y = ver_data(:,3); X = [ones(size(ver_data(:,1))) ver_data(:,1),ver_data(:,2)];
scatter3(X(:,2),X(:,3),y,'filled'); title('Vertical'); 
xlabel('CH1'); ylabel('CH2'); zlabel('Gaze location (% of screen space)');
[by,binty,ry,rinty,statsy] = regress(y,X);