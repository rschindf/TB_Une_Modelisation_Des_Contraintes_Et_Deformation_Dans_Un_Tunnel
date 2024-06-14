% Argand number
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
% Argand Number
Ar = [0.01, 1, 2, 3, 5, 10];
for i = 1:size(Ar,2)
	clearvars -except Ar i
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
	% Initialization
	P           = zeros(nx,  ny);		% Pressure
	ETA         = eta_B*ones(nx, ny);	% Viscosity
	RHO_G       = rhog*ones(nx, ny);	% Gravity
	% Define Geometric situation
	[inside, beton, txt] = tunnel(1,0.314/2,X,Y,0,0,"non",0.014/2);
	if beton == 0; ETA(:,:) = eta_B; else ETA(beton) = etaBeton; end	% enveloppe de béton
	ETA(inside)		= etaTunnel;		% set viscosity value
	RHO_G(inside)   = rhog/1e3;			% set gravity value
	for smo=1:2; Iix  = [2:nx-1]; Iiy  = [2:ny-1];		% Smoothing of the initial viscosity field
        	ETA(Iix,:)    = ETA(Iix,:) + 0.4*(ETA(Iix+1,:)-2*ETA(Iix,:)+ETA(Iix-1,:));
        	ETA(:,Iiy)    = ETA(:,Iiy) + 0.4*(ETA(:,Iiy+1)-2*ETA(:,Iiy)+ETA(:,Iiy-1));
	end
	LAMBDA  = 3*ETA;
	% Boundary condition
	VX      = -D_B*X_vx;
	VY      =  D_B*Y_vy;
	ETA_L           = ETA;              ETA_XY          = n2c(ETA);
	RES_VX_relaxed  = zeros(nx-1,ny-2); RES_VY_relaxed  = zeros(nx-2,ny-1);
	% Parameters for pseudo-transient iterations
	tol             = 5e-6;             err_absolute    = 1;            err_relative = 1;
	% Numerical parameters for iterative solver 
	CFLV            = 1/1e1;
	dpt_Vx          = CFLV./(max(ETA(1:end-1,2:end-1),ETA(2:end,2:end-1))/dx^2 + max(ETA_XY(:,1:end-1),ETA_XY(:,2:end))/dx/dy);
	dpt_Vy          = CFLV./(max(ETA(2:end-1,1:end-1),ETA(2:end-1,2:end))/dy^2 + max(ETA_XY(1:end-1,:),ETA_XY(2:end,:))/dx/dy);
	dpt_V_dx2       = max(max(dpt_Vx(1:end-1,:),dpt_Vx(2:end,:))/dx^2, max(dpt_Vy(:,1:end-1),dpt_Vy(:,2:end))/dy^2);
	iter        = 0;
	while err_absolute(end)>tol||err_relative(end)>tol; iter = iter+1;  % START of iteration loop
    	DXX                 = diff(VX,1,1)/dx;                          % Eq (1)
    	DYY                 = diff(VY,1,2)/dy;                          % Eq (2)
    	DXY                 = 1/2*( diff(VX(2:end-1,:),1,2)/dy ...
                              	+ diff(VY(:,2:end-1),1,1)/dx );       % Eq (3)
    	TXX                 = 2.*ETA.*DXX + LAMBDA.*(DXX + DYY);        % Eq (5)
    	TYY                 = 2.*ETA.*DYY + LAMBDA.*(DXX + DYY);        % Eq (6)
    	TXY                 = 2.*n2c(ETA).*DXY;                         % Eq (7)
	
    	RES_VX              = diff(TXX(:,2:end-1),1,1)/dx + diff(TXY,1,2)/dy;      % Eq (8)
    	RES_VY              = diff(TYY(2:end-1,:),1,2)/dy + diff(TXY,1,1)/dx - xminus1(n2c(RHO_G));      % Eq (9)
    	RES_VX_relaxed      = RES_VX_relaxed*(1-6/nx) + RES_VX.*dpt_Vx; % Relaxation on residual
    	RES_VY_relaxed      = RES_VY_relaxed*(1-6/ny) + RES_VY.*dpt_Vy; % Relaxation on residual
    	P                   = (TXX + TYY)/2;       
    	VX(2:end-1,2:end-1) = VX(2:end-1,2:end-1) + RES_VX_relaxed;     
    	VY(2:end-1,2:end-1) = VY(2:end-1,2:end-1) + RES_VY_relaxed;     
    	VY(:,end)           = VY(:,end-1);								% Eq (12)
    	VY(:,1)             = 0*VY(:,2);								% Eq (13)
    	VY([1 end],:)       = VY([2 end-1],:);							% Eq (14)
    	VX(:,1)             = VX(:,2);									% Eq (15)
	
    	TII                 = sqrt(0.5*(TXX.^2 + TYY.^2 + 2*c2n(TXY).^2));	% Eq (10)
	
    	err_absolute(iter) = max([max(abs(RES_VX(:))), max(abs(RES_VY(:)))]);
    	err_relative(iter) = max([max(abs(RES_VX_relaxed)), max(abs(RES_VY_relaxed))]);    err_relative(iter) = max([max(abs(RES_VX_relaxed)), max(abs(RES_VY_relaxed))]);
 	
    	if iter > iter_max	% Break the loop if too long
        	break
		end
	
		if mod(iter,nout)
			clc, disp(['loading : ',num2str(iter/iter_max*100) '%'])
			disp(['fig : ',num2str(i),'/6'])
		end	

	end			% END of iteration loop ---------------------------------------

	% Visualisation
	figure(1); z = figure(1);
	subplot(2,3,i),pcolor(X,Y,TII/(2*eta_B*abs(D_B))),colormap('jet'), colorbar, shading interp, axis equal tight, hold on
	st = 15; VXC = (VX(1:end-1,:)+VX(2:end,:))/2; VYC = (VY(:,1:end-1)+VY(:,2:end))/2;
	quiver(X(1:st:end,1:st:end),Y(1:st:end,1:st:end),VXC(1:st:end,1:st:end),VYC(1:st:end,1:st:end),'k');
	c = colorbar; axis equal tight, axis([-Lx/2,Lx/2,-Ly/2,Ly/2]), 
	title(['Argand = ', num2str(Ar(i))], Position=[0 0.55]), 
	if i == 1, ylabel('Hauteur [ ]'), end; if i == 4; ylabel('Hauteur [ ]'), end
	if i == 4, xlabel('Largeur [ ]'), end; if i == 5; xlabel('Largeur [ ]'), end; if i == 6; xlabel('Largeur [ ]'), end
	if i == 6, ylabel(c,'2e contrainte invariante, T_{II} / (2\eta_BD_B) [ ]', 'FontSize', 20, Position=[4 12], VerticalAlignment='middle'), end
	hold off, fontsize(20,"points")
end

saveas(z,fullfile('C:\Users\schin\OneDrive\Documents\Travail de Bachelor\Figure','Fig4_Argand.tif'));

toc
% Additional functions perfoming interpolations on the numerical grid
function A1 = n2c(A0)			% Interpolation of nodal points to center points
A1      = (A0(2:end,:) + A0(1:end-1,:))/2;
A1      = (A1(:,2:end) + A1(:,1:end-1))/2;
end
function A1 = xminus1(A0)		% Interpolation node -> center along x-axis
A1      = (A0(2:end,:) + A0(1:end-1,:))/2;
end
function A1 = yminus1(A0)		% Interpolation node -> center along y-axis
A1      = (A0(:,2:end) + A0(:,1:end-1))/2;
end
function A2 = c2n(A0)			% Interpolation of center points to nodal points
A1    	= zeros(size(A0,1)+1,size(A0,2));
A1(:,:)	= [1.5*A0(1,:)-0.5*A0(2,:); (A0(2:end,:)+A0(1:end-1,:))/2; 1.5*A0(end,:)-0.5*A0(end-1,:)];
A2   	= zeros(size(A1,1),size(A1,2)+1);
A2(:,:)	= [1.5*A1(:,1)-0.5*A1(:,2), (A1(:,2:end)+A1(:,1:end-1))/2, 1.5*A1(:,end)-0.5*A1(:,end-1)];
end
function A1 = xplus1(A0)		% Interpolation center -> node along x-axis
A1    	= zeros(size(A0,1)+1,size(A0,2));
A1(:,:)	= [1.5*A0(1,:)-0.5*A0(2,:); (A0(2:end,:)+A0(1:end-1,:))/2; 1.5*A0(end,:)-0.5*A0(end-1,:)];
end
function A2 = yplus1(A1)		% Interpolation center -> node along y-axis
A2   	= zeros(size(A1,1),size(A1,2)+1);
A2(:,:)	= [1.5*A1(:,1)-0.5*A1(:,2), (A1(:,2:end)+A1(:,1:end-1))/2, 1.5*A1(:,end)-0.5*A1(:,end-1)];
end