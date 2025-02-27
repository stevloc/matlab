% Wildfire Simulation
% sl9820
% Intro to Computer Simulation
% This MATLAB script simulates wildfire spread using a cellular automaton 
% model, where fire propagates probabilistically to neighboring trees in a 
% 2D forest grid. The simulation runs dynamically, visualizing fire 
% progression and stopping when no trees are actively burning.

clc; clear; close all;

clockmax = 100;
n = 100;
m = 100;          
spread_prob = 0.52;
delta_t = 1;        
T_total = 0;      

Forest = zeros(n, m);

center_i = round(n / 2);
center_j = round(m / 2);
Forest(center_i, center_j) = 1;

cmap = [0 0.5 0; 1 0 0; 0 0 0];
colormap(cmap);
caxis([0, 2]);
colorbar;

figure(1);
imagesc(Forest);
title('Initial Forest (Fire in Center)');
drawnow;
pause(1);

neighbor_offsets = [-1  0; 1  0;  0 -1;  0  1];


for clock = 1:clockmax
    Forest_copy = Forest;

    [iExcited, jExcited] = find(Forest == 1);
    
    for k = 1:length(iExcited)
        i = iExcited(k);
        j = jExcited(k);
        
        Forest_copy(i, j) = 2;

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
    

    Forest = Forest_copy;

    T_total = clock * delta_t;

    num_unburned = sum(Forest(:) == 0);
    num_burning = sum(Forest(:) == 1);
    num_burned = sum(Forest(:) == 2);

    imagesc(Forest);
    title({['Time Step: ', num2str(clock), ' hours elapsed (T_{total} = ', num2str(T_total), ' hours)']; ...
           ['Unburned: ', num2str(num_unburned), ...
           ' | Burning: ', num2str(num_burning), ...
           ' | Burned: ', num2str(num_burned)]});
    drawnow;
    % pause(0.5);
    
    if num_burning == 0
        break;
    end
end

disp(['Simulation ended after ', num2str(T_total), ' hours.']);
disp(['Final counts - Unburned: ', num2str(num_unburned), ...
      ', Burning: ', num2str(num_burning), ...
      ', Burned: ', num2str(num_burned)]);