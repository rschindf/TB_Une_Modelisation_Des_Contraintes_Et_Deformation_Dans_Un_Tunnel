function [inside,inside_beton, txt] = tunnel(style,sze,X,Y, x, y,beton,epaisseur)
% function to import a specific tunnel shape, with or without a protective
% concrete layer : 
% style = shape of the tunnel
% size = rayon
% X = coordinates x
% Y = coordinates y
% x = offset x from center
% y = offset y from center
% beton = "oui" or "non" depending
% epaisseur = width of the concrete layer
if style == 1 	
	txt = '1 - Simple cercle';
	inside = ((X-x).^2 + (Y-y).^2) < sze^2;
	if	beton == "oui"; inside_beton = ((X-x).^2 + (Y-y).^2) < (sze+epaisseur)^2;
	else, inside_beton = 0;	
	end
end
if style == 2
	txt = '2 - Rectangulaire';
	sze = 1.5*sze;
	bornes = [-sze,sze;-sze/2,sze/2]; 
	inside = (((X-x)>bornes(1,1) & ((X-x)<bornes(1,2)) & ((Y-y)>bornes(2,1)) & ((Y-y)<bornes(2,2))));
	if beton == "oui", inside_beton = (((X-x)>bornes(1,1)-epaisseur & ((X-x)<bornes(1,2)+epaisseur) & ((Y-y)>bornes(2,1)-epaisseur) & ((Y-y)<bornes(2,2)+epaisseur)));
	else, inside_beton = 0; end 
end
if style == 3	
	txt = '3 - Demi-arc'; fit = 0.000;
	inside = ((((X-x).^2 + (Y-y).^2) < (sze^2 ) & ((Y-y) >= 0)) | (((X-x) < sze-fit) & ((X-x) > -sze+fit) & ((Y-y) < 0) & ((Y-y) > -0.15))); 
	if beton == "oui"; inside_beton = ((((X-x).^2 + (Y-y).^2) < ((sze+epaisseur)^2 ) & ((Y-y) >= 0)) | (((X-x) < sze-fit+epaisseur) & ((X-x) > -sze+fit-epaisseur) & ((Y-y) < 0) & ((Y-y) > -0.15-epaisseur))); 
	else, inside_beton = 0; end 
end
if style == 4
	txt = '4 - Lötschberg (TBM)';
	inside = (((X-x).^2 + (Y-y).^2) < (sze)^2 & (Y-y>-(0.57*sze)));
	if beton == "oui", inside_beton = ((X-x).^2 + (Y-y).^2) < (sze+epaisseur)^2;
	else, inside_beton = 0; end
end
if style == 5
	txt = '5 - Galerie minière';
	a_interf = [80 -80]; taille_bois = 0.02; pos = 0.2; 
	inside = (X-pos+taille_bois + Y*tand(90-a_interf(1))) < 0 ...
		& (X+pos-taille_bois + Y*tand(90-a_interf(2))) > 0 ...
		& Y+taille_bois < pos & Y > -0.1;
	if beton == "oui"; 		inside_beton = ((X-pos-taille_bois + Y*tand(90-a_interf(1))) < 0 & (X-pos+taille_bois + Y*tand(90-a_interf(1))) > 0 ...
		| (X+pos-taille_bois + Y*tand(90-a_interf(2))) < 0 & (X+pos+taille_bois + Y*tand(90-a_interf(2))) > 0 ...
		| (Y-taille_bois) < pos & (Y+taille_bois) > pos & X > -pos-0.01 & X < pos+0.01) ...
		& Y < 0.242 & Y > -0.122;
	else, inside_beton = 0; end 
end
if style == 6
	txt = '6 - Lötschberg (explosif)';
	b = 1.5*sze;		
	inside = (((X-x).^2/sze^2) + ((Y-y).^2/b^2) < 1) & ((Y-y) > -sze+epaisseur);
	if beton == "oui"; inside_beton = (((X-x).^2/sze^2) + ((Y-y).^2/b^2) < 1+sqrt(epaisseur)) & ((Y-y) > -sze-2*epaisseur);
	else, inside_beton = 0; end 
end
if style == 7
	txt = '7 - En ogive';
	ecart = 0.1; sze = 1.5*sze;	
	inside = ((((X-x)-ecart).^2 + ((Y-y)+0.07).^2) < sze^2) & ((((X-x)+ecart).^2 + ((Y-y)+0.07).^2) < sze^2) & ((Y-y) > -0.1);
	if beton == "oui"; inside_beton = ((((X-x)-ecart).^2 + ((Y-y)+0.07).^2) < (sze+epaisseur)^2) & ((((X-x)+ecart).^2 + ((Y-y)+0.07).^2) < (sze+epaisseur)^2) & ((Y-y) > -0.1-epaisseur);
	else, inside_beton = 0; end 
end
if style == 8
	txt = '8 - Sondages environnants';
	angle = -45:15:45;
	inside = ( (X-epaisseur + Y*tand(90-angle(1))) < 0 & (X+epaisseur + Y*tand(90-angle(1))) > 0 ...
	| (X-1.5*epaisseur + Y*tand(90-angle(2))) < 0 & (X+2*epaisseur + Y*tand(90-angle(2))) > 0 ...
	| (X-3*epaisseur + Y*tand(90-angle(3))) < 0 & (X+3*epaisseur + Y*tand(90-angle(3))) > 0 ...
	| (X-3*epaisseur + Y*tand(90-angle(5))) < 0 & (X+3*epaisseur + Y*tand(90-angle(5))) > 0 ...
	| (X-1.5*epaisseur + Y*tand(90-angle(6))) < 0 & (X+2*epaisseur + Y*tand(90-angle(6))) > 0 ...
	| (X-epaisseur + Y*tand(90-angle(7))) < 0 & (X+epaisseur + Y*tand(90-angle(7))) > 0 ...
	| Y<1.6*epaisseur/2 & Y>1.6*-epaisseur/2	) & ((X-x).^2 + (Y-y).^2) < (2*sze)^2 | ((X-x).^2 + (Y-y).^2) < (sze)^2	;
	if beton == "oui"
	inside_beton = ((X-x).^2 + (Y-y).^2) < (sze+epaisseur)^2	;
	else, inside_beton = 0; end 
end
if style == 9
	txt = '9 - Jonction ferroviaire'; %Gotthard ferroviaire, au niveau d''une jonction';
	sze = 0.35; ecart = 0.18;
	inside = ((((X-x)-ecart).^2 + (Y-y).^2) < (sze/2)^2 | (((X-x)+ecart).^2 + (Y-y).^2) < (sze/2)^2 ) ...
		& ((Y-y) > -0.12);
	sze = sze/1.4; b = 1.5*sze;	
	if beton == "oui", inside_beton = ((X-x).^2/b^2) + ((Y-y).^2/sze^2) < 1 & ((Y-y) > -0.15-epaisseur);
	else, inside_beton = 0;	end
end

if style == 10
	txt = '10 - gunite';
	epaisseur = epaisseur/3;
	inside = (((X-x).^2 + (Y-y).^2) < (sze)^2 & (Y-y>-(0.57*sze)));
	if beton == "oui", inside_beton = ((X-x).^2 + (Y-y).^2) < (sze+epaisseur)^2 & (Y-y>-(0.57*sze));
	else, inside_beton = 0; end
end
if style == 11
	txt = '11 - paroi clouée';
	angle = -30:15:30;
	inside = (((X-x).^2 + (Y-y).^2) < (sze)^2 & (Y-y>-(0.57*sze)));
	if beton == "oui"
		inside_beton = ...
		((X-1.5*epaisseur + Y*tand(90-angle(1))) < 0 & (X+2*epaisseur + Y*tand(90-angle(1))) > 0 ...
		| (X-3*epaisseur + Y*tand(90-angle(2))) < 0 & (X+3*epaisseur + Y*tand(90-angle(2))) > 0 ...
		| (X-3*epaisseur + Y*tand(90-angle(4))) < 0 & (X+3*epaisseur + Y*tand(90-angle(4))) > 0 ...
		| (X-1.5*epaisseur + Y*tand(90-angle(5))) < 0 & (X+2*epaisseur + Y*tand(90-angle(5))) > 0 ...
		| Y<1.6*epaisseur/2 & Y>1.6*-epaisseur/2 ) & ((X-x).^2 + (Y-y).^2) < (2*sze)^2 ...
		| ((X-x).^2 + (Y-y).^2) < (sze+2*epaisseur)^2& (Y-y>-(0.57*sze));
	else, inside_beton = 0; end 
end
if style == 12
	txt = '12 - arcs de soutènement';
	inside = (((X-x).^2 + (Y-y).^2) < (sze)^2 & (Y-y>-(0.57*sze)));
	if beton == "oui", inside_beton = ((X-x).^2 + (Y-y).^2) < (sze+2*epaisseur)^2 & (Y-y>-(0.57*sze));
	else, inside_beton = 0; end
end

if style == 13
	txt = '13 - parapluie';
	alpha = 10:10:170;	a = 0.27; xa = a*cosd(alpha); ya = a*sind(alpha);
	inside = (((X-x).^2 + (Y-y).^2) < (sze)^2 & (Y-y>-(0.57*sze)));
	if beton == "oui"; inside_beton = ((X-x).^2 + (Y-y).^2) < (sze+epaisseur)^2;	
		for i = 1:size(alpha,2)
			insidei = ((X-xa(i)).^2 + (Y-ya(i)).^2) < (sze/10)^2;
			inside_beton = inside_beton + insidei;
		end
	else, inside_beton = 0; end
end

if style == 14 
	txt = '14 - conduite secondaire';
	inside = ((X-x).^2 + (Y-y).^2) < (sze)^2 & (Y-y>-(0.57*sze)) ...
		| ((X-x-0.23).^2 + (Y-y+0.23).^2) < (sze/5)^2;
	if beton == "oui", inside_beton = ((X-x).^2 + (Y-y).^2) < (sze+epaisseur)^2 ...
			| ((X-x-0.23).^2 + (Y-y+0.23).^2) < ((sze/5)+epaisseur)^2;
	else, inside_beton = 0; end
end

if style == 15
	txt = '15 - puit d''aération';
	inside = (((X-x).^2 + (Y-y).^2) < (sze)^2 & (Y-y>-(0.57*sze))) ...
		| ((X-x) > -sze/3 & (X-x) < sze/3 & (Y-y) > 0);
	if beton == "oui", inside_beton = ((X-x).^2 + (Y-y).^2) < (sze+epaisseur)^2 ...
		| (((X-x) > (-sze/3)-epaisseur & (X-x) < (sze/3)+epaisseur) & (Y-y) > 0);
	else, inside_beton = 0; end
end

if style == 16
	txt = '16 - sortie de secours';
	inside = (((X-x-0.2).^2 + (Y-y).^2) < (sze/1.5)^2 & (Y-y>-(0.38*sze))) ...
		| (((X-x+0.2).^2 + (Y-y).^2) < (sze/2.1)^2 & (Y-y>-(0.57/2*sze))) ...
		| ((Y-x) > -sze/3.5 & (Y-y) < sze/3.5 & (X-x) < 0.2 & (X-x) > -0.2);
	if beton == "oui", inside_beton = ((X-x-0.2).^2 + (Y-y).^2) < (sze/1.5+epaisseur)^2 ...
		| ((X-x+0.2).^2 + (Y-y).^2) < (sze/2.1+epaisseur)^2 ...
		| ((Y-y) > (-sze/3.5)-epaisseur & ((Y-y) < (sze/3.5)+epaisseur) & (X-x) < 0.2 & (X-x) > -0.2);
	else, inside_beton = 0; end
end


% --------------------
% i = 1;	
% if style(i) == 71
% 		txt = '7 - large';
% 		b = 1.5*sze;		
% 		inside = (((X-x).^2/b^2) + ((Y-y).^2/sze^2) < 1) & ((Y-y) > -0.1);
% 		if beton == "oui"; inside_beton = 0; 
% 		else, inside_beton = 0; end 
% 	end
% 
% 	if style(i) == 21
% 		txt = '2 - cercle tronqué';
% 		inside = ((((X-x).^2 + (Y-y).^2) < sze^2 ) & ((Y-y) > -0.1));
% 		if beton == "oui"; inside_beton = 0; else inside_beton = 0; end 
% 	end
% 
% 	if style(i) == 82
% 		txt = '8 - tunnel naturel en demi-arc';
% 		inside = ((((((X-(rand-0.5)/10)-x).^2 + ((Y-(rand-0.5)/10)-y).^2) < (sze-(rand-0.5)/10)^2 ) & ((Y-y) >= 0)) | ...
% 			(((((X-(rand-0.5)/10)-x).^2 + ((Y-(rand-0.5)/10)-y).^2) < (sze-(rand-0.5)/10)^2 ) & ((Y-y) >= 0)) |...
% 			(((((X-(rand-0.5)/10)-x).^2 + ((Y-(rand-0.5)/10)-y).^2) < (sze-(rand-0.5)/10)^2 ) & ((Y-y) >= 0)) |...
% 			(((((X-(rand-0.5)/10)-x).^2 + ((Y-(rand-0.5)/10)-y).^2) < (sze-(rand-0.5)/10)^2 ) & ((Y-y) >= 0)) |...
% 			(((((X-(rand-0.5)/10)-x).^2 + ((Y-(rand-0.5)/10)-y).^2) < (sze-(rand-0.5)/10)^2 ) & ((Y-y) >= 0)) |...
% 			(((((X-(rand-0.5)/10)-x).^2 + ((Y-(rand-0.5)/10)-y).^2) < (sze-(rand-0.5)/10)^2 ) & ((Y-y) >= 0)) |...
% 			(((((X-(rand-0.5)/10)-x).^2 + ((Y-(rand-0.5)/10)-y).^2) < (sze-(rand-0.5)/10)^2 ) & ((Y-y) >= 0)) |...
% 			(((((X-(rand-0.5)/10)-x).^2 + ((Y-(rand-0.5)/10)-y).^2) < (sze-(rand-0.5)/10)^2 ) & ((Y-y) >= 0)) |...
% 			(((((X-(rand-0.5)/10)-x).^2 + ((Y-(rand-0.5)/10)-y).^2) < (sze-(rand-0.5)/10)^2 ) & ((Y-y) >= 0)));%| (((X-x) < a-fit) & ((X-x) > -a+fit) & ((Y-y) < 0) & ((Y-y) > -0.2))); 
% 		if beton == "oui"; inside_beton = 0; else inside_beton = 0; end 
% 	end
% 
% 
% 
% 
% 	if style(i) == 10
% 		txt = '10 - Gotthard routier';
% 		sze = sze/1.1;
% 		inside = (((((X-x).^2 + (Y-y).^2) < sze^2 ) & ((Y-y) >= 0)) | (((X-x) < sze-fit) & ((X-x) > -sze+fit) & ((Y-y) < 0) & ((Y-y) > -sze/2))); 
% 		if beton == "oui"; inside_beton = 0; else inside_beton = 0; end 
% 
	% end
	% 
	% 
	% 
	% 
% if style(i) == 9,	txt = '9 - Gotthard routier';
% 	a = 0.1;		ETA(((X-0.35).^2 + (Y).^2) < (a)^2) = etaTunnel;		% petit cercle
% 	fit = 0.001; 	ETA((((((X+0.35).^2 + Y.^2) < a^2 ) & (Y >= 0)) | ((X + 0.35 < a-fit) & (X + 0.35 > -a+fit) & (Y < 0) & (Y > -0.1)))) = etaTunnel;
% 	fit = 0.001; a = 0.05;	ETA(((((X.^2 + Y.^2) < (a)^2 ) & (Y >= 0)) | ((X < a-fit) & (X > -a+fit) & (Y < 0) & (Y > -0.05)))) = etaTunnel;
% end
%i = i+1;
% possible d'additionner, mais 1+1 = 2 donc trouver un moyen de ramener 2 à 1.