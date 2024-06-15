function e = geol(roche)
% fonction pour assigner des valeur géologique
% 'calcaire','granite','shale'
% aussi béton et air
% remodifier e -> eta_geol
if roche == "calcaire"
	e = 1e16;
end
if roche == "air"
	e = 1.75e-5;
end
if roche == "béton"
	e = 2e15;
end
if roche == "acier";
	e = 1;
end
if roche == "granite"
	e = 1e20;
end
if roche == "schiste"
	e = 5e11;
end
if roche == "évaporites"
	e = 1e18;
end 
if roche == "quartzite"
	e = 1e19;
end
if roche == "gneiss"
	e = 7.5e20;
end
if roche == "bois"
	e = 1e7;
end
