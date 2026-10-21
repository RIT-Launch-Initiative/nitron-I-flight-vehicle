%% Adjusted simulation tool
% Liquid Propulsion Aerostructures
% Last updated 20 October 2065
%% Setup
clear; close all; clc;
% Retrieve openrocket
filepath = "C:\nitron-I-flight-vehicle\Nitron I.ork";
N1FV = openrocket(filepath);
rocket = N1FV.rocket();
fins = N1FV.component(class="FinSet");
% Reference simulation
sim1 = N1FV.sims("15mph_80F");
global L D;
%% Inputs
% N1FV parameters
L = rocket.getLength();
[D, ~] = N1FV.refdims();

%% Simulate!!
simData = N1FV.simulate(sim, outputs = "ALL");
% [simData1, times1, summary1] = simulateVerbose(N1FV, sim1, fins);


% %% Text output
% apogees = ["Apogee [ft]:", summary1.apogee];
% 
% rodExits = ["Rod Exit Velocity [ft/s]:", summary1.rodExit];
% 
% stabs1 = ["Rod Exit Stability [%]:", summary1.stabLaunch];
% 
% stabs2 = ["Maximum Stability [%]:", summary1.stabMax];
% 
% flutter = ["Fin Flutter FOS:", summary1.flutterFOS];
% 
% fprintf("%24s%12s\n", apogees(1), apogees(2));
% fprintf("%24s%12s\n", rodExits(1), rodExits(2));
% fprintf("%24s%12s\n", stabs1(1), stabs1(2));
% fprintf("%24s%12s\n", stabs2(1), stabs2(2));
% fprintf("%24s%12s\n", flutter(1), flutter(2));
% 
% %% Other Plots
% plotStabPercent(simData1)
% plotBasic(simData1);
% 
% close all;

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
    ylabel("Altitude [ft]")
    hold on;
    % Right side
    yyaxis("right")
    plot(simData, "Time", "Total velocity", "Color", "r");
    hold off;
    ylabel("Velocity [ft/s]")
    % Other plot related things
    xlabel("Time [s]")
    title("Vehicle Motion")
    legend("Altitude", "Velocity", "location", "northeast")
end

function data = addReport(data)
    global L D;
    R = 0.287; % Specific gas constant for air
    data.("Air density") = data.("Air pressure")./(1000*R*data.("Air temperature"));
    data.("Dynamic pressure") = 0.5*data.("Air density").*data.("Total velocity").^2;
    data.("Stability percent") = 100*data.("Stability margin")*D/L;
    % ft conversions
    data.("Total velocity") = data.("Total velocity")*3.28084;
    data.("Altitude") = data.("Altitude")*3.28084;
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

    summary.maxVel = max(data.("Total velocity"));
    
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
