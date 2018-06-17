function good = energy_check(Energy, prev_Energy, Energy_Dissipation_ratio)

if prev_Energy == 0
    good = 1;
    return;
elseif Energy == 0
    error('Error with energy check');
end

if (Energy/prev_Energy) < Energy_Dissipation_ratio
    good = 0;
else
    good = 1;
end
