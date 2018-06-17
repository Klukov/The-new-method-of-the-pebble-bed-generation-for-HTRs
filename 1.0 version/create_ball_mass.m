function mass_vector = create_ball_mass(BallMass, BallRadius, radius_vector)
% function is creating mass_vector

%for now very simple formula
mass_vector = (radius_vector ./ BallRadius).^3*BallMass;

