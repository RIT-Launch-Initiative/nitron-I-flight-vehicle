%% Adjusted simulation tool
% Liquid Propulsion Aerostructures
% Last updated 8 November 2025
% 
%% Setup
clear; close all; clc;
% Retrieve openrocket
filepath = "C:\nitron-I-flight-vehicle\Nitron I.ork";
N1FV = openrocket(filepath);
rocket = N1FV.rocket();
fins = N1FV.component(class="FinSet");
% Reference simulation
sim1 = N1FV.sims("15mph_30F");
sim2 = N1FV.sims("15mph_35F");
sim3 = N1FV.sims("15mph_45F");
sim4 = N1FV.sims("15mph_55F"); % BASELINE
sim5 = N1FV.sims("15mph_65F");
sim6 = N1FV.sims("15mph_75F");
sim7 = N1FV.sims("15mph_80F");
global L D;
%% Inputs
% N1FV parameters
L = rocket.getLength();
[D, ~] = N1FV.refdims();

% Atmosphere data
%airDataFilePath = "";

% Rasaero drag curve
%dragFilePath = "";

%% Get atmosphere
% airdata = importdata(airDataFilePath);
% airdata.TMP = airdata.TMP + 273.15; % conv Celcius to Kelvin
%% Get drag curve
% rasDrag = import_rasaero_aerodata(dragFilePath);
% rasDrag = rasDrag.align("mach");
% rasDrag = table(rasDrag.mach, rasDrag.pick{"aoa", 0, "field", "CD"}, ...
%     VariableNames = ["MACH", "DRAG"]);
% rasDrag.MACH(1) = 0;

%% Simulate!!
% simData = N1FV.simulate(sim, outputs = "ALL", atmos = airdata(:, ["HGT", "PRES", "TMP"]),...
%     wind = airdata, drag = rasDrag);
[simData1, times1, summary1] = simulateVerbose(N1FV, sim1, fins);
[simData2, times2, summary2] = simulateVerbose(N1FV, sim2, fins);
[simData3, times3, summary3] = simulateVerbose(N1FV, sim3, fins);
[simData4, times4, summary4] = simulateVerbose(N1FV, sim4, fins);
[simData5, times5, summary5] = simulateVerbose(N1FV, sim5, fins);
[simData6, times6, summary6] = simulateVerbose(N1FV, sim6, fins);
[simData7, times7, summary7] = simulateVerbose(N1FV, sim7, fins);

%% Text output
header = ["", "440 psi", "472 psi", "543 psi", "620 psi", "705 psi", "800 psi", "850 psi"];
apogees = ["Apogee [m]:", summary1.apogee, summary2.apogee, summary3.apogee,...
    summary4.apogee, summary5.apogee, summary6.apogee, summary7.apogee];

rodExits = ["Rod Exit Velocity [m/s]:", summary1.rodExit, summary2.rodExit,...
    summary3.rodExit, summary4.rodExit, summary5.rodExit, summary6.rodExit, summary7.rodExit];

stabs1 = ["Rod Exit Stability [%]:", summary1.stabLaunch, summary2.stabLaunch,...
    summary3.stabLaunch, summary4.stabLaunch, summary5.stabLaunch, summary6.stabLaunch, summary7.stabLaunch];

stabs2 = ["Maximum Stability [%]:", summary1.stabMax, summary2.stabMax,...
    summary3.stabMax, summary4.stabMax, summary5.stabMax, summary6.stabMax, summary7.stabMax];

flutter = ["Fin Flutter FOS:", summary1.flutterFOS, summary2.flutterFOS,...
    summary3.flutterFOS, summary4.flutterFOS, summary5.flutterFOS, summary6.flutterFOS, summary7.flutterFOS];

fprintf("%24s%12s%12s%12s%12s%12s%12s%12s \n", header(1), header(2), header(3), header(4), header(5), header(6), header(7), header(8));
fprintf("                        ------------------------------------------------------------------------------------\n")
fprintf("%24s%12s%12s%12s%12s%12s%12s%12s\n", apogees(1), apogees(2), apogees(3), apogees(4), apogees(5), apogees(6), apogees(7), apogees(8));
fprintf("%24s%12s%12s%12s%12s%12s%12s%12s\n", rodExits(1), rodExits(2), rodExits(3), rodExits(4), rodExits(5), rodExits(6), rodExits(7), rodExits(8));
fprintf("%24s%12s%12s%12s%12s%12s%12s%12s\n", stabs1(1), stabs1(2), stabs1(3), stabs1(4), stabs1(5), stabs1(6), stabs1(7), stabs1(8));
fprintf("%24s%12s%12s%12s%12s%12s%12s%12s\n", stabs2(1), stabs2(2), stabs2(3), stabs2(4), stabs2(5), stabs2(6), stabs2(7), stabs2(8));
fprintf("%24s%12s%12s%12s%12s%12s%12s%12s\n", flutter(1), flutter(2), flutter(3), flutter(4), flutter(5), flutter(6), flutter(7), flutter(8));

%% Plot rod exit stab vs pressure
pressures = [440, 472, 543, 620, 705, 800, 850];
stabsVec = [summary1.stabLaunch, summary2.stabLaunch, summary3.stabLaunch, summary4.stabLaunch,...
    summary5.stabLaunch, summary6.stabLaunch, summary7.stabLaunch];
figure(name = "Stability vs Tank Pressure")
plot(pressures, stabsVec);
title("Rod Exit Stability vs Tank Pressure");
xlabel("Tank Pressure [psi]")
xlim([430 860])
ylabel("Rod Exit Stability [%]")
ylim([6 10])

%% Other Plots
plotStabPercent(simData4)
plotBasic(simData4);

%% Functions
function plotStabPercent(simData)
    % Trim data
    ascentRange = timerange(eventfilter("LAUNCHROD"), eventfilter("APOGEE"), "openleft");
    stabData = simData(ascentRange, ["Stability percent", "Angle of attack"]);
    % Plot the data
    figure(name = "Stability")
    hold on;
    % Left side
    yyaxis("left")
    plot(stabData, "Time", "Stability percent", "Color", "b");
    ylabel("Stability [%]")
    % Right side
    yyaxis("right")
    plot(stabData, "Time", "Angle of attack", "Color", "r");
    ylabel("Angle of Attack [degrees]")
    ylim([0 1])
    hold off;
    % Finish plot
    xlabel("Time [s]")
    title("Stability")
end
function plotBasic(simData)
    % Plot altitudes
    figure(name = "Vehicle Motion")
    % Left side
    yMax = max(simData.("Altitude"))*1.1;
    yyaxis("left")
    plot(simData, "Time", "Altitude", "Color","b");
    ylim([0,yMax])
    ylabel("Altitude [m]")
    hold on;
    % Right side
    yyaxis("right")
    plot(simData, "Time", "Total velocity", "Color", "r");
    hold off;
    ylabel("Velocity [m/s]")
    % Other plot related things
    xlabel("Time [s]")
    title("Vehicle Motion")
    legend("Altitude", "Velocity", "location", "northeast")
end
function plotAltitudeError(simData)
    % Adjust data for plotting
    ascentRange = timerange(eventfilter("LAUNCHROD"), eventfilter("APOGEE"), "openleft");
    altData = simData(ascentRange, ["Altitude", "Indicated altitude", "Altitude error"]);
    yMax = max(altData.("Altitude"))*1.1;
    % Plot altitudes
    figure(name = "Altitude comparison")
    % Left side
    yyaxis("left")
    plot(altData, "Time", "Altitude", "Color","b");
    ylim([0,yMax])
    ylabel("Altitude [m]")
    hold on;
    plot(altData, "Time", "Indicated altitude", "Color", "g");
    % Right side
    yyaxis("right")
    plot(altData, "Time", "Altitude error", "Color", "r");
    hold off;
    ylabel("Altitude error [m]")
    % Other plot related things
    xlabel("Time [s]")
    legend("Altitude", "Indicated altitude", "Error", "location", "northeast")
end
function plotErrorVAltitude(simData)
    % Adjust data for plotting
    ascentRange = timerange(eventfilter("LAUNCHROD"), eventfilter("MAIN"), "openleft");
    altData = simData(ascentRange, ["Altitude", "Indicated altitude", "Altitude error"]);
    yMax = max(altData.("Altitude"))*1.1;
    % Plot altitudes
    figure(name = "Altitude comparison")
    % Left side
    yyaxis("left")
    plot(altData, "Time", "Altitude", "Color","b");
    ylim([0,yMax])
    ylabel("Altitude [m]")
    hold on;
    plot(altData, "Time", "Indicated altitude", "Color", "g");
    % Right side
    yyaxis("right")
    plot(altData, "Time", "Altitude error", "Color", "r");
    hold off;
    ylabel("Altitude error [m]")
    % Other plot related things
    xlabel("Time [s]")
    legend("Altitude", "Indicated altitude", "Error", "location", "northeast")
end

function data = addReport(data)
    global L D;
    R = 0.287; % Specific gas constant for air
    data.("Air density") = data.("Air pressure")./(1000*R*data.("Air temperature"));
    data.("Dynamic pressure") = 0.5*data.("Air density").*data.("Total velocity").^2;
    data.("Stability percent") = 100*data.("Stability margin")*D/L;
end

function summary = summaryGen(data, fins, times)
    ascentRange = timerange(eventfilter("LAUNCHROD"), eventfilter("APOGEE"));
    summary.apogee = max(data.Altitude);

    % Rod exit
    velData = data(ascentRange, "Total velocity").("Total velocity");
    summary.rodExit = velData(2);

    % Stability
    stabData = data(ascentRange, "Stability percent").("Stability percent");
    summary.stabLaunch = stabData(2);
    summary.stabMax = max(data.("Stability percent"));

    % Flutter
    summary.flutterFOS = FOS_finflutter(data, fins);
    
    % Dynamic pressure
    qData = data(ascentRange, "Dynamic pressure").("Dynamic pressure");
    max_q = [0 0];
    for i = 1 : length(qData)
        if qData(i) > max_q(2)
            max_q = [seconds(times(i)) qData(i)];
        end
    end
    summary.qMax = max_q;
end

function [data, times, summary] = simulateVerbose(OR, sim, fins)
    data = OR.simulate(sim, outputs = "ALL");
    data = addReport(data);
    times = data.Time;
    summary = summaryGen(data, fins, times);
end
