function Balls_new = BoucingBalls(Balls, TimeStep, geometry, EnergyDissipation)
% geometry = [ReactorDiameter; CylinderHeight; ConeHeight]
% Balls is a matrix num_Balls x [x,y,z,Vx,Vy,Vz,R,M,E]
m = size(Balls,1);
Balls_new = Balls;  %zeros(size(Balls))
number_of_collisions = 1;
a = geometry(1)/geometry(3)/2;
delta_z_ratio = 2*((geometry(3).^2 + (geometry(1).^2)/4).^(1/2))/geometry(1);
reactorDiameter = geometry(1);
coneHeight = geometry(3);
iteration = 0;

while number_of_collisions ~= 0
    %% Caclulate Balls position after TimeStep
    Balls_new(:,1) = Balls(:,1) + Balls(:,4) .* TimeStep;
    Balls_new(:,2) = Balls(:,2) + Balls(:,5) .* TimeStep;
    Balls_new(:,3) = Balls(:,3) + Balls(:,6) .* TimeStep;

    %% check collisions with geometry
    %geometry = [ReactorDiameter; CylinderHeight; ConeHeight]
    geometry_bounces = 0;
    for i = 1:m
        %check bounce with cylinder and cone
        ballX = Balls_new(i,1);
        ballY = Balls_new(i,2);
        ballZ = Balls_new(i,3);
        ballDist = ((ballX).^2) + ((ballY).^2);
        ballR = Balls_new(i,7);
        if ((((ballDist).^(1/2)) >= (reactorDiameter/2 - ballR)) || ...
        ((((ballZ + coneHeight - ballR.*delta_z_ratio).^2).*((a).^2)) <= (ballDist)) || ...
        ((ballZ + coneHeight - ballR.*delta_z_ratio) <= 0))   
            geometry_bounces = geometry_bounces+ 1;
            Balls_new(i,:) = calculate_geometry_collision(Balls(i,:), ...
                Balls_new(i,:), geometry, EnergyDissipation(2,:));
        end
    end
    %% check for collisions with other balls
    bounces = 0;
    for i = 1:(m-1)
        for j = (i+1):m
            sumRadius = (Balls(i,7) + Balls(j,7));
            ballZ = abs(Balls_new(i,3)-Balls_new(j,3));
            if (ballZ > sumRadius)
                continue;
            end
            ballX = abs(Balls_new(i,1)-Balls_new(j,1));
            if (ballX > sumRadius)
                continue;
            end
            ballY = abs(Balls_new(i,2)-Balls_new(j,2));
            if (ballY > sumRadius)
                continue;
            end
            %{
            if ((ballX > sumRadius) || (ballY > sumRadius) || (ballZ > sumRadius))
                continue;
            end
            %}
            distance = (ballX.^2+ballY.^2+ballZ.^2).^(1/2);
            if (sumRadius >= distance)
                bounces = bounces + 1;
                [Balls_new(i,:), Balls_new(j,:)] = calculate_balls_collision(Balls(i,:),Balls(j,:), EnergyDissipation(1,:));
            end
        end
    end
    %% last part
    number_of_collisions = bounces + geometry_bounces;
    Balls(:,4:6) = Balls_new(:,4:6);
    iteration = iteration + 1;
end
Display = ['Iterations: ', num2str(iteration)];
disp(Display);
disp(' ');
%% additional calculations 
% energy of each Balls_new
Balls_new (:,9) = sum((Balls_new(:,4:6).^2),2)/2 .* Balls_new(:,8);

