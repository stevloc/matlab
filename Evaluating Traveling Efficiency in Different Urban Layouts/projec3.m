% Evaluating Traveling Efficiency in Different Urban Layouts
%
% Main
% sl9820
% Intro to Computer Simulation
% This MATLAB Code compares travel efficiency in Manhattan (grid) vs. Amsterdam (radial) street layouts
% by simulating 1000 trials of movement across each network. Efficiency is measured as the ratio
% of Euclidean to actual path distance, with results visualized using bar plots and error bars


num_trials = 1000;
block_length = 100; speed = 10;
rows = 6; cols = 6;
R = 4; S = 16;


manhattan_data = zeros(num_trials, 4); 
amsterdam_data = zeros(num_trials, 4);

for i = 1:num_trials
    [t, d, e, eff] = simulate_manhattan(rows, cols, block_length, speed);
    manhattan_data(i, :) = [t, d, e, eff];

    [t, d, e, eff] = simulate_amsterdam(R, S, block_length, speed);
    amsterdam_data(i, :) = [t, d, e, eff];
end

% Plot


mean_eff = [mean(manhattan_data(:,4)), mean(amsterdam_data(:,4))];
std_eff = [std(manhattan_data(:,4)), std(amsterdam_data(:,4))];

figure;
bar(mean_eff);
hold on;
errorbar(1:2, mean_eff, std_eff, 'k.', 'LineWidth', 1.5);
set(gca, 'XTickLabel', {'Manhattan', 'Amsterdam'});
ylabel('Mean Efficiency (Time / Euclidean)');
title('Efficiency Comparison with Standard Deviation');
grid on;


ylabel('Efficiency (Euclidean / Path)');
title('Efficiency Comparison');
grid on;




% Stats
fprintf('Manhattan Mean Efficiency: %.2f ± %.2f\n', mean(manhattan_data(:,4)), std(manhattan_data(:,4)));
fprintf('Amsterdam Mean Efficiency: %.2f ± %.2f\n', mean(amsterdam_data(:,4)), std(amsterdam_data(:,4)));
