%% Makes .eng Files for Liquid Motors
%% Setup
clear; close all; clc;
% Inputs
motorName = "Nitron_I_55F";
oxMass = 3.386; % kg
fuelMass = 1.411; % kg
% Import the thrust curve as CSV
csvFilePath = "C:\nitron-I-flight-vehicle\Analysis\HalfCatSim\nitron1_55F.csv";
thrustData = importdata(csvFilePath);
%% Data processing
% Create duration vector from first column for timetable
RowTimes = duration(0, 0, thrustData(:,1));
RowTimes = duration(RowTimes, 'Format', 's');
% Setup table properties for .eng format
newMotor = timetable(RowTimes, thrustData(:,2));
newMotor.Properties.DimensionNames = {'Time' 'Variables'};
newMotor.Properties.VariableNames = {'Thrust'};
newMotor.Properties.VariableUnits = {'N'};
newMotor.Properties.StartTime = RowTimes(2);
% Setup metadata
newMotor.Properties.UserData.name = motorName;
newMotor.Properties.UserData.diameter_mm = 98;
newMotor.Properties.UserData.length_mm = 920;
newMotor.Properties.UserData.delays_sec = "P";
newMotor.Properties.UserData.propmass_kg = (oxMass + fuelMass);
newMotor.Properties.UserData.wetmass_kg = (oxMass + fuelMass);
newMotor.Properties.UserData.manufacturer = "RIT_Launch_Initiative";
% Define description
descStr = motorName + newline + "Created by Juno Afko 10 November 2025";
newMotor.Properties.Description = descStr;
% Export
outStr = "C:\nitron-I-flight-vehicle\Motor Files\" + motorName + ".eng";
export_motor_eng(outStr, newMotor)