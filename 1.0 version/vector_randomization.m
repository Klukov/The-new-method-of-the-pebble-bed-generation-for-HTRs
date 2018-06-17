function new_vector = vector_randomization(vector)
%little vector randomization

rand_factor = 0.9;
new_a = vector(1)*(rand_factor + rand/10);
new_b = vector(2)*(rand_factor + rand/10);
new_c = vector(3)*(rand_factor + rand/10);

new_vector = [new_a; new_b; new_c];

if norm(new_vector) ~= 0
    new_vector = new_vector .* (norm(vector)/norm(new_vector));
end

