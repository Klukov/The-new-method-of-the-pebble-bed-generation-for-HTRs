%% HTR Pebble Bed reactor creator 
% balls bouncing model
% by Piotr Klukowski, Warsaw Univesity of Technology
% metric in meters
% time in seconds
% weight in kg

%% Inicialize world
% user settings only in this part

% MAIN FEATURES
BallRadius = 30*10^(-3);
BallMass = 1; % mean value
TimeStep = 5*10^(-3);
Gravity = 9.81;
EnergyDissipation = [0.6 0.9 ; 0.5 0.8];
% dissipation: first row consider dissipation rate of collisions between
% balls, and the second collisions with reactor walls. First column is
% connected to normal vector and the second to perpendicular vector

% GEOMETRY
ReactorDiameter = 1.8;
CylinderHeight = 1.97;
ConeHeight = 0.52;
geometry = [ReactorDiameter;CylinderHeight;ConeHeight];
if DataCheck(BallRadius, BallMass, TimeStep, geometry, Gravity) ~= 1
    error('Error with DATA !!!');
end

%% Algoritm initialization
time = 0;
creation_completed = false;
Balls = [];
Balls = create_balls(Balls, BallRadius, BallMass, time, geometry, Gravity);
LayerSize = size(Balls,1);
quantity_of_balls = size(Balls,1);
%scatter3(Balls(:,1),Balls(:,2), Balls(:,3))

% convergence factors
Energy_Dissipation_ratio = (LayerSize-2)/LayerSize;
Iterations_rest = 1000;
iteration = 0;
MaxEnergy = max(abs(Balls(:,9)));
AvEnergy = mean(abs(Balls(:,9)));
disp('time: ');
disp(time);

fprintf('Program paused. Press enter to continue.\n');
pause;

tic
%% LOOP
while (creation_completed ~= true)
    time = time + TimeStep;
    if ((MaxEnergy < BallMass * Gravity * TimeStep) && (AvEnergy < ...
            BallMass * Gravity * TimeStep * Energy_Dissipation_ratio) )
        if (max(Balls(:,3)) < (CylinderHeight-BallRadius))
            [Balls] = create_balls(Balls, BallRadius, BallMass, ...
                time, geometry, Gravity);
            iteration = 0;
        else
            if (iteration < Iterations_rest)
                iteration = iteration + 1;
            else
                creation_completed = true;
                break;
            end
        end
    end
    Balls(:,6) = Balls(:,6) - Gravity*TimeStep;
    Balls = BoucingBalls(Balls, TimeStep, geometry, EnergyDissipation);
    MaxEnergy = max(abs(Balls(:,9)));
    AvEnergy = mean(abs(Balls((end-LayerSize+1):end,9)));
    disp(' ');
    Display = ['time: ', num2str(time)];
    disp(Display);
end
%fprintf ('Total time: %d \n\n', time);
toc
fprintf ('Pebble Bed created !!! \n\n');


%% 