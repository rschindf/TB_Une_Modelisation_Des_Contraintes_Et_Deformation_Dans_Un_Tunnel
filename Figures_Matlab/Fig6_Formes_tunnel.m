% Formes de tunnel
clear, close, clc, tic
etaRatio    = 1000;		% Viscosity ratio (matrix/inclusion)
nout        = 2e3;		% Parameter for the visualisation 
iter_max	= 5e7;		% Parameter to break
% Numerical parameters
nx          = 251;              ny          = nx;                   % Numerical resolution
Lx          = 1;                Ly          = Lx;                   % Model dimension
dx          = Lx/(nx-1);        dy          = Ly/(ny-1);            % Grid spacing
x           = (-Lx/2:dx:Lx/2);	y           = (-Ly/2:dy:Ly/2);		% Coordinate vectors
x_vx        = [x(1)-dx/2,( x(1:end-1) + x(2:end) )/2,x(end)+dx/2];  % Horizontal vector for Vx which is one more than basic grid
y_vy        = [y(1)-dy/2,( y(1:end-1) + y(2:end) )/2,y(end)+dy/2];  % Vertical   vector for Vy which is one more than basic grid
% 3 numerical grids due to staggered grid
[X,Y]       = ndgrid(x,y);      [X_vx,Y_vx] = ndgrid(x_vx,y); [X_vy,Y_vy] = ndgrid(x,y_vy);
% Physical parameters
eta_B		= 1;					% viscosity of the matrix [] (reference) 
eta_B		= 1e16;					% viscosity of limestone matrix
etaBeton	= eta_B/etaRatio;		% viscosity of the concrete
etaTunnel	= 1.75e-5;				% viscosity of free air (inside the tunnel)
D_B			= 1;					% strain rate of background []
Ar          = 1;					% ratio of Gravity to Elastic stress
rhog		= Ar/Ly*(2*eta_B*D_B);	% facteur de gravité [], Eq (18) 
sze			= 0.214;				% size of the tunnel []

style = 1:9;
for i = 1:size(style,2)
	% Initialization
	P           = zeros(nx,  ny);		% Pressure
	ETA         = eta_B*ones(nx, ny);	% Viscosity
	RHO_G       = rhog*ones(nx, ny);	% Gravity

	[inside, beton, txt] = tunnel(style(i),sze,X,Y,0,0,"oui",0.014);

	if beton == 0; ETA(:,:) = eta_B; else ETA(beton) = etaBeton; end	% enveloppe de béton
	ETA(inside)		= etaTunnel;		% set viscosity value
	RHO_G(inside)   = rhog/1e3;			% set gravity value
	for smo=1:2; Iix  = [2:nx-1]; Iiy  = [2:ny-1];		% Smoothing of the initial viscosity field
        	ETA(Iix,:)    = ETA(Iix,:) + 0.4*(ETA(Iix+1,:)-2*ETA(Iix,:)+ETA(Iix-1,:));
        	ETA(:,Iiy)    = ETA(:,Iiy) + 0.4*(ETA(:,Iiy+1)-2*ETA(:,Iiy)+ETA(:,Iiy-1));
	end
% visualisation
figure(1), z = figure(1);
subplot(3,3,i), hold on
title(txt,Position=[0 0.53])
pcolor(X,Y,log10(ETA/eta_B)), shading interp
c=colorbar; colormap('jet'),
if i == 6, ylabel(c,'Log_{10} de la viscosité, \eta / \eta_B [ ]'), end
if i == 1, ylabel('Hauteur [ ]'), end, if i == 4, ylabel('Hauteur [ ]'), end, if i == 7, ylabel('Hauteur [ ]'), end
if i >= 7, xlabel('Largeur [ ]'), end
fontsize(20,"points"), axis equal tight, axis([-Lx/2,Lx/2,-Ly/2,Ly/2])
end

saveas(z,fullfile('C:\Users\schin\OneDrive\Documents\Travail de Bachelor\Figure','Fig6_Formes_tunnel.tif'));

toc
% Additional functions perfoming interpolations on the numerical grid
function A1 = n2c(A0)			% Interpolation of nodal points to center points
A1      = (A0(2:end,:) + A0(1:end-1,:))/2;
A1      = (A1(:,2:end) + A1(:,1:end-1))/2;
end
function A1 = xminus1(A0)		% interpolation node -> center along x-axis
A1      = (A0(2:end,:) + A0(1:end-1,:))/2;
end
function A1 = yminus1(A0)		% interpolation node -> center along y-axis
A1      = (A0(:,2:end) + A0(:,1:end-1))/2;
end
function A2 = c2n(A0)			% Interpolation of center points to nodal points
A1    	= zeros(size(A0,1)+1,size(A0,2));
A1(:,:)	= [1.5*A0(1,:)-0.5*A0(2,:); (A0(2:end,:)+A0(1:end-1,:))/2; 1.5*A0(end,:)-0.5*A0(end-1,:)];
A2   	= zeros(size(A1,1),size(A1,2)+1);
A2(:,:)	= [1.5*A1(:,1)-0.5*A1(:,2), (A1(:,2:end)+A1(:,1:end-1))/2, 1.5*A1(:,end)-0.5*A1(:,end-1)];
end
function A1 = xplus1(A0)		% interpolation center -> node along x-axis
A1    	= zeros(size(A0,1)+1,size(A0,2));
A1(:,:)	= [1.5*A0(1,:)-0.5*A0(2,:); (A0(2:end,:)+A0(1:end-1,:))/2; 1.5*A0(end,:)-0.5*A0(end-1,:)];
end
function A2 = yplus1(A1)		% interpolation center -> node along y-axis
A2   	= zeros(size(A1,1),size(A1,2)+1);
A2(:,:)	= [1.5*A1(:,1)-0.5*A1(:,2), (A1(:,2:end)+A1(:,1:end-1))/2, 1.5*A1(:,end)-0.5*A1(:,end-1)];
end