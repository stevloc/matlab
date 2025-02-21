% Wildfire Simulation
% sl9820
% Intro to Computer Simulation

clc; clear; close all;

% Parameters
clockmax = 100;     % Max simulation steps (1 hour per step)
n = 100;            % Grid rows
m = 100;            % Grid columns
spread_prob = 0.75; % Fire spread probability
delta_t = 1;        % Time step duration (1 hour)
T_total = 0;        % Total elapsed time

% Initialize Forest Grid (0 = unburned, 1 = burning, 2 = burned)
Forest = zeros(n, m);

% Ignite fire at center
center_i = round(n / 2);
center_j = round(m / 2);
Forest(center_i, center_j) = 1;

% Define color map (green = unburned, red = burning, black = burned)
cmap = [0 0.5 0; 1 0 0; 0 0 0];
colormap(cmap);
caxis([0, 2]);
colorbar;

% Initial visualization
figure(1);
imagesc(Forest);
title('Initial Forest (Fire in Center)');
drawnow;
pause(1);

% Von Neumann Neighborhood (4 directions)
neighbor_offsets = [-1  0; 1  0;  0 -1;  0  1];

% Simulation Loop
for clock = 1:clockmax
    Forest_copy = Forest;
    
    % Find burning trees
    [iExcited, jExcited] = find(Forest == 1);
    
    for k = 1:length(iExcited)
        i = iExcited(k);
        j = jExcited(k);
        
        % Burn current tree
        Forest_copy(i, j) = 2;

        % Spread fire to neighbors probabilistically
        for t = 1:size(neighbor_offsets, 1)
            ni = i + neighbor_offsets(t, 1);
            nj = j + neighbor_offsets(t, 2);
            
            if ni >= 1 && ni <= n && nj >= 1 && nj <= m
                if Forest(ni, nj) == 0 && rand() < spread_prob 
                    Forest_copy(ni, nj) = 1; 
                end
            end
        end
    end
    
    % Update forest state
    Forest = Forest_copy;

    % Update total time
    T_total = clock * delta_t;

    % Count trees in each state
    num_unburned = sum(Forest(:) == 0);
    num_burning = sum(Forest(:) == 1);
    num_burned = sum(Forest(:) == 2);

    % Visualize progress
    imagesc(Forest);
    title({['Time Step: ', num2str(clock), ' hours elapsed (T_{total} = ', num2str(T_total), ' hours)']; ...
           ['Unburned: ', num2str(num_unburned), ...
           ' | Burning: ', num2str(num_burning), ...
           ' | Burned: ', num2str(num_burned)]});
    drawnow;
    pause(0.5);
    
    % Stop if no burning trees remain
    if num_burning == 0
        break;
    end
end

% Display final results
disp(['Simulation ended after ', num2str(T_total), ' hours.']);
disp(['Final counts - Unburned: ', num2str(num_unburned), ...
      ', Burning: ', num2str(num_burning), ...
      ', Burned: ', num2str(num_burned)]);