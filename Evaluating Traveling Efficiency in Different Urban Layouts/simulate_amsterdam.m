% Evaluating Traveling Efficiency in Different Urban Layouts
%
% Simulate Amsterdam Function
% sl9820
% Intro to Computer Simulation
% Simulates travel in a radial Amsterdam-style city layout with R rings and S spokes.
% Random start and goal points are chosen; the shortest of three path types (radial-first,
% angular-first, or through-center) is computed. Outputs travel time, total distance,
% Euclidean distance, and path efficiency, with optional path visualization.


function [time, distance, euclid, efficiency] = simulate_amsterdam(R, S_half, block_length, speed)

    S = S_half * 2;

    % Random start and goal
    start = [randi(R), randi(S_half)];
    goal  = [randi(R), randi(S_half)];
    while isequal(start, goal)
        goal = [randi(R), randi(S_half)];
    end

    % Angles for spokes
    angles = linspace(-pi/2, pi/2, S_half);
    theta1 = angles(start(2));
    theta2 = angles(goal(2));
    
    r1 = start(1) * block_length;
    r2 = goal(1) * block_length;

    % === PATH OPTIONS ===

    % 1. Radial then Arc (at r2)
    dist_A = abs(r2 - r1) + abs(theta2 - theta1) * r2;

    % 2. Arc then Radial (at r1)
    dist_B = abs(theta2 - theta1) * r1 + abs(r2 - r1);

    % 3. Through center
    dist_C = r1 + r2;

    % === CHOOSE BEST PATH ===
    [distance, option] = min([dist_A, dist_B, dist_C]);
    path_types = ["radial_first", "angular_first", "through_center"];
    path_type = path_types(option);

    % Time & Efficiency
    time = distance / speed;
    [x1, y1] = pol2cart(theta1, r1);
    [x2, y2] = pol2cart(theta2, r2);
    euclid = norm([x2 - x1, y2 - y1]);
    efficiency = euclid / distance;

    % === GRAPH ===
    figure; hold on; axis equal;
    
    switch path_type
    case "radial_first"
        nice_name = "Radial First";
    case "angular_first"
        nice_name = "Angular First";
    case "through_center"
        nice_name = "Through Center";
    end

    title(['Chosen path: ', nice_name]);

    % Draw rings
    for r = 1:R
        ang = linspace(-pi/2, pi/2, 200);
        [x, y] = pol2cart(ang, r * block_length);
        plot(x, y, 'k--');
    end

    % Draw spokes
    for s = 1:S_half
        ang = angles(s);
        [x, y] = pol2cart(ang, [0 R] * block_length);
        plot(x, y, 'k--');
    end

    % Plot start and goal
    plot(x1, y1, 'go', 'MarkerSize', 12, 'LineWidth', 2);
    plot(x2, y2, 'rx', 'MarkerSize', 12, 'LineWidth', 2);

    % === PLOT CHOSEN PATH ===
    switch path_type
        case "radial_first"
            [xr, yr] = pol2cart(theta1, r2);
            plot([x1 xr], [y1 yr], 'b-', 'LineWidth', 2); % radial
            % draw_arrow(x1, y1, xr, yr);
            theta_arc = linspace(theta1, theta2, 100);
            [xa, ya] = pol2cart(theta_arc, r2);
            plot(xa, ya, 'b-', 'LineWidth', 2); % arc
            % draw_arrow(xa(1), ya(1), xa(end), ya(end));

        case "angular_first"
            theta_arc = linspace(theta1, theta2, 100);
            [xa, ya] = pol2cart(theta_arc, r1);
            plot(xa, ya, 'b-', 'LineWidth', 2); % arc
            % draw_arrow(xa(1), ya(1), xa(end), ya(end));
            [xr, yr] = pol2cart(theta2, r2);
            plot([xa(end) xr], [ya(end) yr], 'b-', 'LineWidth', 2); % radial
            % draw_arrow(xa(end), ya(end), xr, yr);

        case "through_center"
            plot([x1 0], [y1 0], 'b-', 'LineWidth', 2); % to center
            % draw_arrow(x1, y1, 0, 0);
            plot([0 x2], [0 y2], 'b-', 'LineWidth', 2); % out from center
            % draw_arrow(0, 0, x2, y2);
    end

    fprintf('\n=== Path Options ===\n');
    fprintf('1. Radial then Arc     : %.2f meters\n', dist_A);
    fprintf('2. Arc then Radial     : %.2f meters\n', dist_B);
    fprintf('3. Through Center      : %.2f meters\n', dist_C);
    fprintf('→ Chosen Path: %s (%.2f meters)\n', nice_name, distance);
    fprintf('Eucledian Distance     : %.2f meters\n', euclid);
end


