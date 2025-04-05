% Urban Rat Simulation
% sl9820
% Intro to Computer Simulation
% This MATLAB script simulates the population dynamics of rats, feral cats,
% and hawks in an urban ecosystem over the course of one year. The model
% uses Lotka-Volterra equations with seasonal modifiers and human 
% interventions (e.g., TNR programs and hawk migration). Populations are 
% updated using the forward Euler method, and the simulation visualizes 
% species interactions and seasonal effects in a simplified NYC environment.

clear; close all;

totalSeasons = 4;
timeStep = 0.2;
timePoints = 0:timeStep:totalSeasons;
seasons = {'Winter', 'Spring', 'Summer', 'Fall'};

initialRat = 100;
initialCat = 40;
initialHawk = 20;

base = struct( ...
    'ratBirth', 0.4, ...
    'ratDeath', 0.1, ...
    'ratPredCats', 0.01, ...
    'ratPredHawks', 0.005, ...
    'catDeath', 0.2, ...
    'catBirthFromRats', 0.008, ...
    'hawkDeath', 0.1, ...
    'hawkBirthFromRats', 0.005);

ratPop = zeros(size(timePoints));
catPop = zeros(size(timePoints));
hawkPop = zeros(size(timePoints));
ratPop(1) = initialRat;
catPop(1) = initialCat;
hawkPop(1) = initialHawk;

eventLog = struct('time', {}, 'type', {});

for t = 1:length(timePoints) - 1
    currentTime = timePoints(t);
    seasonIdx = min(floor(currentTime) + 1, 4);
    season = seasons{seasonIdx};

    if mod(currentTime, 1) == 0


        if strcmp(season, 'Winter')
            ratPop(t) = ratPop(t) * 0.55;  
        else
            ratPop(t) = ratPop(t) * 1.30; 
        end

        eventLog(end+1) = struct('time', currentTime, 'type', 1); 

        if strcmp(season, 'Spring')
            hawkPop(t) = hawkPop(t) * 1.5;
            catPop(t) = catPop(t) * 0.75;
            eventLog(end+1) = struct('time', currentTime, 'type', 2); 
            eventLog(end+1) = struct('time', currentTime, 'type', 3);
        elseif strcmp(season, 'Fall')
            hawkPop(t) = hawkPop(t) * 0.5;
            eventLog(end+1) = struct('time', currentTime, 'type', 2);
        end

        if strcmp(season, 'Summer')
            catPop(t) = catPop(t) * 0.75;
            eventLog(end+1) = struct('time', currentTime, 'type', 3); 
        end
    end

    p = getSeasonalParameters(base, seasonIdx);

    % Lotka-Volterra
    R = ratPop(t); C = catPop(t); H = hawkPop(t);
    dR = p.ratBirth * R - p.ratDeath * R - p.ratPredCats * R * C - p.ratPredHawks * R * H;
    dC = -p.catDeath * C + p.catBirthFromRats * R * C;
    dH = -p.hawkDeath * H + p.hawkBirthFromRats * R * H;

    ratPop(t+1) = max(0, R + dR * timeStep);
    catPop(t+1) = max(0, C + dC * timeStep);
    hawkPop(t+1) = max(0, H + dH * timeStep);
end

% Plotting 
figure('Position', [50, 50, 900, 500]);
hold on; grid on;

h1 = plot(timePoints, ratPop, 'r-', 'LineWidth', 2);
h2 = plot(timePoints, catPop, 'Color', [0.929, 0.694, 0.125], 'LineWidth', 2);
h3 = plot(timePoints, hawkPop, 'b-', 'LineWidth', 2);

for s = 0:3
    line([s s], ylim, 'Color', [0.6 0.6 0.6], 'LineStyle', '--');
    text(s + 0.5, max(ratPop)*0.95, seasons{s+1}, 'HorizontalAlignment', 'center');
end

hEvent1 = plot(NaN, NaN, 'r*', 'MarkerSize', 8); 
hEvent2 = plot(NaN, NaN, 'b^', 'MarkerSize', 8); 
hEvent3 = plot(NaN, NaN, 'ko', 'MarkerSize', 8); 

for e = 1:length(eventLog)
    eventTime = eventLog(e).time;
    idx = find(timePoints >= eventTime, 1);
    switch eventLog(e).type
        case 1, plot(eventTime, ratPop(idx), 'r*', 'MarkerSize', 8);
        case 2, plot(eventTime, hawkPop(idx), 'b^', 'MarkerSize', 8);
        case 3, plot(eventTime, catPop(idx), 'ko', 'MarkerSize', 8);
    end
end

title('NYC Urban Ecosystem Population Dynamics');
xlabel('Time (Seasons)');
ylabel('Population');
legend([h1 h2 h3 hEvent1 hEvent2 hEvent3], ...
    {'Rats', 'Feral Cats', 'Hawks', ...
     'Rat seasonal change', ...
     'Hawk migration', ...
     'Cat TNR program'}, ...
    'Location', 'best');

figure('Position', [100, 100, 600, 400]);

seasonOrder = {'Winter', 'Spring', 'Summer', 'Fall'};
seasonalAvg = zeros(4, 3);

for s = 1:4
    idx = find(floor(timePoints) + 1 == s);
    seasonalAvg(s, :) = [mean(ratPop(idx)), mean(catPop(idx)), mean(hawkPop(idx))];
end

b = bar(categorical(seasonOrder, seasonOrder), seasonalAvg);
b(1).FaceColor = 'r';
b(2).FaceColor = [0.929, 0.694, 0.125];
b(3).FaceColor = 'b';
title('Average Seasonal Populations');
ylabel('Average Population');
legend('Rats', 'Cats', 'Hawks');
grid on;


seasonOrder = {'Winter', 'Spring', 'Summer', 'Fall'};
seasonalAvg = zeros(4, 3);

for s = 1:4
    idx = find(floor(timePoints) + 1 == s);
    seasonalAvg(s, :) = [mean(ratPop(idx)), mean(catPop(idx)), mean(hawkPop(idx))];
end

subplot(1,2,2);
b = bar(categorical(seasonOrder, seasonOrder), seasonalAvg);
b(1).FaceColor = 'r';
b(2).FaceColor = [0.929, 0.694, 0.125];
b(3).FaceColor = 'b';
title('Average Seasonal Populations');
ylabel('Average Population');
legend('Rats', 'Cats', 'Hawks');
grid on;

% Summary
fprintf('NYC Urban Ecosystem Simulation Summary:\n');
fprintf('Initial populations - Rats: %d, Cats: %d, Hawks: %d\n', initialRat, initialCat, initialHawk);
fprintf('Final populations - Rats: %.1f, Cats: %.1f, Hawks: %.1f\n', ratPop(end), catPop(end), hawkPop(end));

fprintf('\nSeasonal Averages:\n');
for s = 1:4
    fprintf('%s - Rats: %.1f, Cats: %.1f, Hawks: %.1f\n', ...
        seasonOrder{s}, seasonalAvg(s,1), seasonalAvg(s,2), seasonalAvg(s,3));
end

% Helper Function
function params = getSeasonalParameters(base, seasonIdx)
    params = base;
    switch seasonIdx
        case 1 % Winter
            params.ratBirth = base.ratBirth * 0.7;
            params.ratDeath = base.ratDeath * 1.5;
            params.ratPredCats = base.ratPredCats * 0.7;
            params.ratPredHawks = 0;
            params.catDeath = base.catDeath * 1.3;
        case 2 % Spring
            params.ratBirth = base.ratBirth * 1.3;
            params.ratPredCats = base.ratPredCats * 1.1;
            params.ratPredHawks = base.ratPredHawks * 1.2;
            params.catBirthFromRats = base.catBirthFromRats * 1.2;
        case 3 % Summer
            params.ratBirth = base.ratBirth * 1.5;
            params.ratDeath = base.ratDeath * 1.1;
            params.ratPredCats = base.ratPredCats * 1.3;
            params.ratPredHawks = base.ratPredHawks * 1.4;
            params.catBirthFromRats = base.catBirthFromRats * 1.3;
        case 4 % Fall
            params.ratBirth = base.ratBirth * 1.2;
            params.ratPredCats = base.ratPredCats * 1.2;
            params.ratPredHawks = base.ratPredHawks * 0.8;
            params.catBirthFromRats = base.catBirthFromRats * 0.9;
    end
end

