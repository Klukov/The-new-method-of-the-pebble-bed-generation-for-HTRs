function Balls_new = BoucingBalls...
    (Balls, TimeStep, geometry, EnergyDissipation)
% geometry = [ReactorDiameter; CylinderHeight; ConeHeight]
% Balls is a matrix num_Balls x [x,y,z,Vx,Vy,Vz,R,M,E]
m = size(Balls,1);
Balls_new = Balls;  %zeros(size(Balls))
number_of_collisions = 1;
a = geometry(1)/geometry(3)/2;
delta_z_ratio = 2*((geometry(3).^2 + ...
    (geometry(1).^2)/4).^(1/2))/geometry(1);
iteration = 0;

while number_of_collisions ~= 0
    %% Caclulate Balls position after TimeStep
    Balls_new(:,1) = Balls(:,1) + Balls(:,4) .* TimeStep;
    Balls_new(:,2) = Balls(:,2) + Balls(:,5) .* TimeStep;
    Balls_new(:,3) = Balls(:,3) + Balls(:,6) .* TimeStep;

    %% check collisions with geometry
    %geometry = [ReactorDiameter; CylinderHeight; ConeHeight]
    geometry_bounces = zeros(m,1);
    
    for i = 1:m
        %check bounce with cylinder and cone
        if ((((((Balls_new(i,1)).^2) + ((Balls_new(i,2)).^2)).^(1/2)) >=...
                (geometry(1)/2 - Balls_new(i,7))) || ...
        ((((Balls_new(i,3) + geometry(3) - ...
        Balls_new(i,7).*delta_z_ratio).^2).*((a).^2)) <= ...
        (((Balls_new(i,1)).^2) + ((Balls_new(i,2)).^2))) || ...
        ((Balls_new(i,3) + geometry(3) - ...
        Balls_new(i,7).*delta_z_ratio) <= 0))   
            geometry_bounces (i,1) = 1;
            Balls_new(i,:) = calculate_geometry_collision(Balls(i,:), ...
                Balls_new(i,:), geometry, EnergyDissipation(2,:));
        end
    end
    
    %% check for collisions with other balls
    distance = zeros(m,m);
    bounces = zeros(m,m);
    for i = 1:m
        for j = 1:m
            if j > i
                distance(i,j) = (sum(((Balls_new(i,1:3) - ...
                    Balls_new(j,1:3)).^2),2)).^(1/2);
                if ((Balls(i,7) + Balls(j,7)) >= distance(i,j))
                    bounces(i,j) = 1;
                    [Balls_new(i,:), Balls_new(j,:)] = ...
                        calculate_balls_collision(Balls(i,:), ...
                        Balls(j,:), EnergyDissipation(1,:));
                end
            end
        end
    end

    %% last part
    number_of_collisions = sum(sum(bounces)) + sum(geometry_bounces);
    Balls(:,4:6) = Balls_new(:,4:6);
    iteration = iteration + 1;
    
end
Display = ['Iterations: ', num2str(iteration)];
disp(Display);
disp(' ');
%% additional calculations 
% energy of each Balls_new
Balls_new (:,9) = sum((Balls_new(:,4:6).^2),2)/2 .* Balls_new(:,8);

%%