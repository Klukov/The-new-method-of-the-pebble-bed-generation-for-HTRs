function New_Balls = create_balls(Balls, BallRadius, BallMass, ...
    time, geometry, Gravity)
% ball creation algorithm
% this will be first algorithm of ball creation
% Balls is a matrix num_Balls x [x,y,z,Vx,Vy,Vz,R,M,E]

radius_ratio = 1.2;
height_variance = 4; %times radius
Rcircle = radius_ratio * BallRadius; %initial value
D = geometry(1);

%additional layers, except centre
num_layers = fix((D/2-Rcircle)/(2*Rcircle)); 
if num_layers == 0
    error('Problem with BallCreation #1');
end

Rcircle = D/4/(num_layers+1); %new 
Temporary_Balls = zeros(3*(num_layers+1)*num_layers, 9);
RadiusVariation = Rcircle - BallRadius;

%checking z0
if time == 0
    z0 = BallRadius;
else
    height = max(Balls(:,3)) + 2*BallRadius;
    if height < BallRadius
        z0 = BallRadius;
    else
        z0 = height;
    end
end

%create balls in circle
ball_number = 1;
for i = 1:num_layers
    balls_in_layer = i*6;
    twist_of_balls = rand()*2*pi;
    for j=1:balls_in_layer
        angle = 2*pi/balls_in_layer*(j-1) + twist_of_balls;
        x0 = (2*Rcircle*i)*cos(angle);
        y0 = (2*Rcircle*i)*sin(angle);
        module = 0.9 * RadiusVariation*(rand()*2 - 1);
        %randim position in circle
        phi = 2*pi*rand();
        x = x0 + module*cos(phi);
        y = y0 + module*sin(phi);
        z = z0 + height_variance*BallRadius*rand();
        %setting up Velocity
        Velocity_randomization_factor = 2;
        Vz = (-1)*((2*Gravity*(BallRadius))^(1/2));
        % phi = 2*pi*rand();
        if x ~= 0
            Vx = (-1)*abs(Vz)*Velocity_randomization_factor*cos(angle);
        else
            Vx = 0;
        end
        if y ~= 0
            Vy = (-1)*abs(Vz)*Velocity_randomization_factor*sin(angle);
        else
            Vy = 0;
        end
        %ball creation
        Radius = create_ball_radius(BallRadius, 1);
        Mass = create_ball_mass(BallMass, BallRadius, Radius);
        Energy = (1+2*Velocity_randomization_factor.^2).*...
            (Vz.^2)./2 .* Mass;
        Temporary_Balls(ball_number,:) = ...
            [x y z Vx Vy Vz Radius Mass Energy];
        ball_number = ball_number + 1;
    end
end

New_Balls = [Balls ; Temporary_Balls];


