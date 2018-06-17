%% SET THE DATA FROM AN EXAMPLE
% currently data of HTR-10
ReactorDiameter = 1.8;
ConeHeight = 0.52;
CylinderHeight = 1.97;
BallRadius = 0.03;
%data = [];

fprintf('SET DATA MATRIX !\n');
fprintf('Program paused. Press enter to continue.\n\n');
pause;

%data = Balls;

%% BOUNCES CHECK
bounces = 0;
m = size(data,1);
diamter = 2*BallRadius;
min = BallRadius;
for i = 1:(m-1)
    for j = (i+1):m
        ballZ = abs(data(i,3)-data(j,3));
        if (ballZ > diamter)
            continue;
        end
        ballX = abs(data(i,1)-data(j,1));
        if (ballX > diamter)
            continue;
        end
        ballY = abs(data(i,2)-data(j,2));
        if (ballY > diamter)
            continue;
        end
        distance = (ballX.^2+ballY.^2+ballZ.^2).^(1/2);
        if (diamter >= distance)
            bounces = bounces + 1;
        end
        check = distance - diamter;
        if (check < min)
            min = check;
        end
    end
end

if (bounces == 0)
    fprintf('Pebble bed is correct.\n\n');
else
    error('Balls overriding each other');
end


%% diagram
amountOfIntersections = 1000;
z = linspace((-1)*ConeHeight,CylinderHeight,amountOfIntersections);
VF = zeros(amountOfIntersections);
circleSurface = pi *BallRadius*BallRadius;

for i = 1:amountOfIntersections
    field = 0;
    for j = 1:m
        if (abs(z(i)-data(j,3)) < BallRadius)
            field = field + circleSurface * cos((z(i)-data(j,3))/BallRadius*pi/2);
        end
    end
    if (z(i) > 0)
        reactorIntersection = pi*(ReactorDiameter^2)/4;
    else
        reactorIntersection = pi*((ReactorDiameter/2/ConeHeight)^2)*(z(i)+ConeHeight)^2;
    end
    VF(i) = 1 - field/reactorIntersection;
end

plot(VF,z) 
title("Void fraction of fuel pebbles inside the HTR-10")
xlabel("void fraction")
ylabel("vertical axis of the reactor")

%%    