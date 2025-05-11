% Urban Rat Simulation
% sl9820
% Intro to Computer Simulation
% This MATLAB script simulates urban rat, feral cat, and hawk populations in NYC using
% a seasonal Lotka-Volterra model with logistic growth and predator-prey interactions.
% Populations evolve over time using forward Euler integration with seasonal parameter
% adjustments to reflect environmental and ecological changes.


clear; close all;

years = 1;
totalSeasons = 4 * years;
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
    'catDeath', 0.18, ...
    'catBirthFromRats', 0.012, ...
    'hawkDeath', 0.1, ...
    'hawkBirthFromRats', 0.005);

ratPop = zeros(size(timePoints));
catPop = zeros(size(timePoints));
hawkPop = zeros(size(timePoints));
ratPop(1) = initialRat;
catPop(1) = initialCat;
hawkPop(1) = initialHawk;

eventLog = struct('time', {}, 'type', {});
hawkCap = 30; 
hawkCarryingCapacity = 30;  % Soft cap to prevent blow-up
carryingCapacity = 250;     % Rat cap

for t = 1:length(timePoints) - 1
    currentTime = timePoints(t);
    seasonIdx = mod(floor(currentTime), 4) + 1;
    season = seasons{seasonIdx};

    if mod(currentTime, 1) == 0
        eventLog(end+1) = struct('time', currentTime, 'type', 1);
    end

    p = getSeasonalParameters(base, seasonIdx);
    R = ratPop(t); C = catPop(t); H = hawkPop(t);

    % Growth equations
    dR = p.ratBirth * R * (1 - R / carryingCapacity) ...
       - p.ratDeath * R ...
       - p.ratPredCats * R * C ...
       - p.ratPredHawks * R * H;

    dC = -p.catDeath * C + p.catBirthFromRats * R * C;
    dH = -p.hawkDeath * H + p.hawkBirthFromRats * R * H;

    % Rat environmental boost
    dR = dR + 0.5;

    % Predator suppression when rats are too low
    if R < 20
        dC = -p.catDeath * C;
        dH = -p.hawkDeath * H;
    end

    % Soft logistic cap for hawks
    dH = dH * (1 - H / hawkCarryingCapacity);

    ratPop(t+1)  = max(5, R + dR * timeStep);      
    catPop(t+1)  = max(5, C + dC * timeStep);      
    hawkPop(t+1) = max(5, H + dH * timeStep);      
end

% Population Dynamics
figure('Position', [50, 50, 1000, 500]); hold on; grid on;
h1 = plot(timePoints, ratPop, 'r-', 'LineWidth', 1.5);
h2 = plot(timePoints, catPop, '-', 'Color', [0.929, 0.694, 0.125], 'LineWidth', 1.5);
h3 = plot(timePoints, hawkPop, 'b-', 'LineWidth', 1.5);
xlabel('Time (Seasons)');
ylabel('Population');
title({'NYC Urban Ecosystem Population Dynamics', sprintf('Simulated Over %d Year(s)', years)});
legend([h1 h2 h3], {'Rats', 'Feral Cats', 'Hawks'}, 'Location', 'best');

% Seasonal Averages
figure('Position', [100, 100, 700, 400]);
seasonOrder = {'Winter', 'Spring', 'Summer', 'Fall'};
seasonalAvg = zeros(4, 3);
for s = 1:4
    idx = find(mod(floor(timePoints), 4) + 1 == s);
    seasonalAvg(s, :) = [mean(ratPop(idx)), mean(catPop(idx)), mean(hawkPop(idx))];
end
b = bar(categorical(seasonOrder, seasonOrder), seasonalAvg, 'grouped');
b(1).FaceColor = 'r';
b(2).FaceColor = [0.929, 0.694, 0.125];
b(3).FaceColor = 'b';
title(sprintf('Simulated Over %d Year(s)', years));
ylabel('Average Population');
legend('Rats', 'Cats', 'Hawks');
grid on;

% Summary Output
fprintf('Initial populations - Rats: %d, Cats: %d, Hawks: %d\n', initialRat, initialCat, initialHawk);
fprintf('Final populations   - Rats: %.1f, Cats: %.1f, Hawks: %.1f\n', ratPop(end), catPop(end), hawkPop(end));
fprintf('\nSeasonal Averages:\n');
for s = 1:4
    fprintf('%s - Rats: %.1f, Cats: %.1f, Hawks: %.1f\n', ...
        seasonOrder{s}, seasonalAvg(s,1), seasonalAvg(s,2), seasonalAvg(s,3));
end

% Seasonal Parameters
function params = getSeasonalParameters(base, seasonIdx)
    params = base;
    switch seasonIdx
        case 1 % Winter
            params.ratBirth = base.ratBirth * 0.5;
            params.ratDeath = base.ratDeath * 1.4;
            params.ratPredCats = 0;
            params.ratPredHawks = 0;
            params.catBirthFromRats = 0;
            params.hawkBirthFromRats = 0;
            params.catDeath = base.catDeath * 1.2;
            params.hawkDeath = base.hawkDeath * 1.2;
        case 2 % Spring
            params.ratBirth = base.ratBirth * 2.0;
            params.ratDeath = base.ratDeath * 0.6;
            params.ratPredCats = base.ratPredCats * 0.8;
            params.ratPredHawks = base.ratPredHawks * 0.9;
            params.catBirthFromRats = base.catBirthFromRats * 0.9;
        case 3 % Summer
            params.ratBirth = base.ratBirth * 1.5;
            params.ratDeath = base.ratDeath * 0.8;
            params.ratPredCats = base.ratPredCats * 1.2;
            params.ratPredHawks = base.ratPredHawks * 1.3;
            params.catBirthFromRats = base.catBirthFromRats * 0.9;
        case 4 % Fall
            params.ratBirth = base.ratBirth * 0.9;
            params.ratDeath = base.ratDeath * 1.1;
            params.ratPredCats = base.ratPredCats * 1.3;
            params.ratPredHawks = base.ratPredHawks * 1.2;
    end
end
