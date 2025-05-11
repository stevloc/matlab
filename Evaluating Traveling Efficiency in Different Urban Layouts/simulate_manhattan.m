% Evaluating Traveling Efficiency in Different Urban Layouts
%
% Simulate Manhattan Function
% sl9820
% Intro to Computer Simulation
% Simulates travel across a Manhattan-style grid using horizontal-then-vertical paths.
% Random start and goal locations are selected; total distance, travel time, Euclidean
% distance, and efficiency are computed. A grid plot visualizes the route.


function [time, distance, euclid, efficiency] = simulate_manhattan(rows, cols, block_length, speed)
    start = [randi(cols), randi(rows)];
    goal  = [randi(cols), randi(rows)];
    while isequal(start, goal)
        goal = [randi(cols), randi(rows)];
    end

    dx = abs(goal(1) - start(1));
    dy = abs(goal(2) - start(2));
    distance = (dx + dy) * block_length;
    time = distance / speed;
    euclid = norm((goal - start) * block_length);
    efficiency = euclid / distance;

    figure;
        hold on;

        % Draw grid
        for x = 1:cols
            plot([x x], [0.5 rows+0.5], 'k--');
        end
        for y = 1:rows
            plot([0.5 cols+0.5], [y y], 'k--');
        end

        % Plot start and goal
        plot(start(1), start(2), 'go', 'MarkerSize', 12, 'LineWidth', 2);
        text(start(1)+0.1, start(2), '', 'Color', 'g');

        plot(goal(1), goal(2), 'rx', 'MarkerSize', 12, 'LineWidth', 2);
        text(goal(1)+0.1, goal(2), '', 'Color', 'r');

        % Draw path: horizontal then vertical
        path = [start];
        intermediate = [goal(1), start(2)];
        path = [path; intermediate; goal];
        plot(path(:,1), path(:,2), 'b-', 'LineWidth', 2);

        % Labels
        title('Manhattan Grid Trip');
        axis([0.5 cols+0.5 0.5 rows+0.5]);
        axis square;
        grid on;

   fprintf('Path Distance       : %.2f meters\n', distance);
   fprintf('Eucledian Distance  : %.2f meters\n', euclid);
end
   
        

