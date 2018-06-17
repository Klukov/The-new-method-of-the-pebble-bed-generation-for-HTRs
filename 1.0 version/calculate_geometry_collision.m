function Ball_new = calculate_geometry_collision...
    (Ball, FakeNewBall, geometry, EnergyDissipation)
% each parameter is an array 1x9
% geometry is an vector 3 x 1
% geometry = [ReactorDiameter; CylinderHeight; ConeHeight]
% Balls is a matrix num_Balls x [x,y,z,Vx,Vy,Vz,R,M,E]

%% We looking for new velocity vector - ONLY!
Ball = ((Ball)');
Ball_new = Ball;
FakeNewBall = FakeNewBall';
EnergyDissipation = EnergyDissipation';

R = Ball(7);
a = geometry(1)./geometry(3)./2;
delta_z_ratio = 2*((geometry(3).^2 + ...
    (geometry(1).^2)/4).^(1/2))./geometry(1);
geometry_bend_z = (geometry(1)./2 - R)/a - ...
    geometry(3) + delta_z_ratio .* R;

% normal vector calculation with normalization
if ( ((Ball(3)) > (geometry_bend_z)) && ...
        ((FakeNewBall(3)) > (geometry_bend_z)) )
    %bounce with cylinder
    normal_vector = ([Ball(1) Ball(2) 0]);
    normal_vector = normal_vector ./ norm(normal_vector);
elseif ( ( ((FakeNewBall(1).^2 + FakeNewBall(2).^2).^(1/2)) < ...
        (geometry(1)/2 - R) ) || ( ((Ball(3)) < (geometry_bend_z)) && ...
        ((FakeNewBall(3)) < (geometry_bend_z)) ) )
    %bounce with cone
    if ((Ball(1) == 0 && Ball(2) == 0))
        %only z velocity - different gradient
        normal_vector = [0 0 -1];
    else
        z = (Ball(1).^2 + Ball(2).^ 2).^(1/2).*(1/a); % + geometry(3)
        grad_z = (-1).*a.*a.*z;
        normal_vector = ([Ball(1) Ball(2) grad_z]);
        normal_vector = normal_vector ./ norm(normal_vector);
    end
else
    %bounce with cylinder or cone
    vect = FakeNewBall(1:3) - Ball(1:3);
    qe_factors = [(vect(1).^2 + vect(2).^2);...
        (2*(Ball(1).*vect(1) + Ball(2).*vect(2)) );...
        (Ball(1).^2 + Ball(2).^2 - (geometry(1)/2-R).^2)];
    qe_delta = qe_factors(2)^2 - 4.*qe_factors(1).*qe_factors(3);
    
    %caclulating cross_z
    if qe_delta < 0
        error('Error with geometry collision #1');
    elseif qe_delta == 0
        line_factor = (-1)*qe_factors(2)/2/qe_factors(1);
        if ((line_factor > 1) || (line_factor < 0))
            error('Error with geometry collision #2');
        end
        cross_z = Ball(3) + vect(3)*line_factor;
    else %qe_delta > 0
        line_factor = ((-1)*qe_factors(2) + ...
            qe_delta^(1/2))/2/qe_factors(1);
        if ((line_factor > 1) || (line_factor < 0))
            line_factor = ((-1)*qe_factors(2) - ...
                qe_delta^(1/2))/2/qe_factors(1);
            if ((line_factor > 1) || (line_factor < 0))
                error('Error with geometry collision #3');
            end
        end
        cross_z = Ball(3) + vect(3).*line_factor;
    end
    
    %checking cross_z
    if cross_z > geometry_bend_z
        % bounce with cylinder
        normal_vector = ([Ball(1) Ball(2) 0]);
        normal_vector = normal_vector ./ norm(normal_vector);
    elseif cross_z < geometry_bend_z
        % bounce with cone
        if ((Ball(1) == 0 && Ball(2) == 0) && ...
                (Ball(4) == 0 && Ball(5) == 0))
            %only z velocity - different gradient
            normal_vector = [0 0 -1];
        else
            z = (Ball(1).^2 + Ball(2).^2).^(1/2).*(1/a); % + geometry(3)
            grad_z = (-1).*a.*a.*z;
            normal_vector = ([Ball(1) Ball(2) grad_z]);
            normal_vector = normal_vector ./ norm(normal_vector);
        end
    else
        %bounce with both cylinder and cone
        %cone normal vector + cylinder normal vector
        cylinder_normal_vector = ([Ball(1) Ball(2) 0]);
        cylinder_normal_vector = cylinder_normal_vector ./ ...
            norm(cylinder_normal_vector);
        z = (Ball(1).^2 + Ball(2).^2).^(1/2).*(1/a); %+ geometry(3)
        grad_z = (-1).*a.*a.*z;
        cone_normal_vector = ([Ball(1) Ball(2) grad_z]);
        cone_normal_vector = cone_normal_vector ./ ...
            norm(cone_normal_vector);
        normal_vector = cylinder_normal_vector + cone_normal_vector;
    end
end

normal_vector = normal_vector';
p = Ball(4:6).*Ball(8);
pn = normal_vector.*(dot(p,normal_vector))./(norm(normal_vector));
pp = p - pn;
pn_new = pn.*(-1) .* EnergyDissipation(1);
pp_new = pp .* EnergyDissipation(2);
p_new = pn_new + pp_new;
p_new = vector_randomization(p_new);
Ball_new(4:6) = p_new./Ball(8);
Ball_new = Ball_new';


%%