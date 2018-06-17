function [Ball1_new, Ball2_new] = calculate_balls_collision...
    (Ball1, Ball2, EnergyDissipation)
%each parameter is an array 1x9
%Balls is a matrix num_Balls x [x,y,z,Vx,Vy,Vz,R,M,E]
Ball1 = Ball1';
Ball2 = Ball2';
EnergyDissipation = EnergyDissipation';
Ball1_new = Ball1;
Ball2_new = Ball2;

normal_vector = [(Ball1(1)-Ball2(1));(Ball1(2)-Ball2(2));...
    (Ball1(3)-Ball2(3))];
m1 = Ball1(8);
m2 = Ball2(8);
p1 = Ball1(4:6).*m1;
p2 = Ball2(4:6).*m2;
p1n = (dot(p1,normal_vector))/(norm(normal_vector)^2)*normal_vector;
p2n = (dot(p2,normal_vector))/(norm(normal_vector)^2)*normal_vector;
p1p = p1 - p1n;
p2p = p2 - p2n;
module_p1n = norm(p1n);
module_p2n = norm(p2n);
%%
%{
if ((module_p1n < (0.1*module_p2n)) || (module_p1n < (0.1*module_p1n)))
    module_p1n_new = module_p1n;
    module_p2n_new = module_p1n;
else
    %normal physics
    module_p1n_new = module_p1n*((m1-m2)/(m1+m2)) + module_p2n*((2*m1) /(m1+m2));
    module_p2n_new = module_p1n*((2*m2) /(m1+m2)) + module_p2n*((m1-m2)/(m1+m2));
end
%}
%%
module_p1n_new = module_p1n;
module_p2n_new = module_p2n;
if norm(p1n) == 0
    p1n_new = p1n * (-1);
else
    p1n_new = p1n * (-1) * module_p1n_new / norm(p1n);
end
if norm(p2n) == 0
    p2n_new = p2n * (-1);
else
    p2n_new = p2n * (-1) * module_p2n_new / norm(p2n);
end
p1_new = p1n_new * EnergyDissipation(1) + p1p * EnergyDissipation(2);
p2_new = p2n_new * EnergyDissipation(1) + p2p * EnergyDissipation(2);
p1_new = vector_randomization(p1_new);
p2_new = vector_randomization(p2_new);
Ball1_new(4:6) = p1_new ./ m1;
Ball2_new(4:6) = p2_new ./ m2;
Ball1_new = Ball1_new';
Ball2_new = Ball2_new';


%% 