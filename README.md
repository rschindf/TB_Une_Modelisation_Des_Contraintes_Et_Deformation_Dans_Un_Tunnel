# A modelization of Stress and Strain in a tunnel

# Content

* [Objectives](#objectives)
* [About this repository](#about-this-repository)
* [Code description](#code-description)
* [Résultats](#résultats)

# Objectives
The objective of this program is to understand how stress and strain develop around a tunnel. This will be be based on a finite-difference MATLAB code using viscosity, velocity and pressure to compute the stress and strain in a two-dimension matrix. The goal is then to explore many variables and understand wich one of them as an influence.

# About this repository
In this repository you can find:
- the Matlab code base [TB_Une_Modelisation_Des_Contraintes_Et_Deformation_Dans_Un_Tunnel.m](TB_Une_Modelisation_Des_Contraintes_Et_Deformation_Dans_Un_Tunnel.m)
- a file with all the codes used to produce the different figures

# Code description
* [Equation of state](#Equation-of-state)
* [Equation of Mass Conservation](#Equation-of-Mass-Conservation)
* [Constitutive Equations](#Constitutive-Equations)
* [Equation of Conservation of Linear Momentum](#Equation-of-Conservation-of-Linear-Momentum)
* [Equation of Energy Conservation](#Equation-of-Energy-Conservation)
* [Effective viscosities](#Effective-viscosities)

## Equation of state
Local variations in density direct the flow of matter in the mantle. Depending on the temperature, the effective density multiplied by the gravitational acceleration can be calculated. The understanding of this equation is essential in this model because it is the changes in density which are at the origin of the convection of the mantle (Turcotte et al., 2002)

$\rho_{f}(T) = \rho_{0}(1-\alpha\Delta T + \beta\Delta P)$
```md
rhofg = rhog_v * (1 - alph * T + beta * P)
```
But we can ignore the pressure because our material is incompressible.

⤴️ [_back to content_](#content)

## Equation of Mass Conservation
we have a system where mass is conserved due to a fixed volume. This equation makes it possible to describe the distribution of the mass and its evolution over time. If mass is conserved throughout the system but density variation is observed, this is due to the divergence of mass flux across a certain surface (Gerya, 2019). 

The continuity equation:
$\frac{\delta\rho}{\delta t} + div(\rho\vec{v}) = 0,$

We can couple this continuity equation with the beta compressibility (1/bulk modulus):
$\beta = \frac{1}{\rho}\left(\frac{\delta\rho}{\delta p}\right)$

by combining these two equations we obtain:
$0 = \frac{d P}{d t}-\frac{1}{\beta}\nabla V$

```md
dPdt = -1/bet * divV
```
∇V corresponds to the divergence of velocities calculated by the expression: 

$\nabla V = \xi_{\varphi\varphi} + \xi_{rr}$

in which $\xi_{rr}$ and $\xi_{\varphi\varphi}$ are the deviatoric strain rate in the radial and angular direction defined by:

$\xi_{rr} = \frac{\delta V_{r}}{\delta r}$

$\xi_{\varphi\varphi} = \frac{1}{r}\frac{\delta V_{\varphi}}{\delta \varphi}+\frac{V_{r}}{r}$

The $\xi_{\varphi r}$ represents the deviatoric tensor of viscous stresses:

$\xi_{\varphi r} = \xi_{r \varphi} = \frac{1}{2}\left(\frac{\delta V_{r}}{\delta \varphi} + \frac{\delta V_{\varphi}}{\delta r}-\frac{V_{\varphi}}{r}\right)$

```md
Err = np.diff(Vr, axis=0)/np.diff(radr, axis=0)
Epp = (np.diff(Vp, axis=1)/np.diff(phip, axis=1) + avr(Vr)) / radn
Erp = ((np.diff(Vr[1:-1, :], axis=1)/np.diff(phir[1:-1, :], axis=1) - avr(Vp[:, 1:-1] )) / radc + np.diff(Vp[:, 1:-1], axis=0)/np.diff(radp[:, 1:-1], axis=0))/2
```

⤴️ [_back to code description_](#code-description)

## Constitutive Equations
The constitutive equation, or flow law, of a viscous material is given by a mathematical relationship between the deviatoric stress and the deviatoric strain rate (Halter et al., 2022). This describes how a material deforms under certain pressures and stresses. The values $\tau_{rr}$ and $\tau_{\varphi\varphi}$ describe the normal stress in the radial and angular directions, while $\tau_{r\varphi}$ describes the shear stress. These three values are determined by the following equations with $\eta$ which corresponds to the viscosity (Gerya, 2019).

$\tau_{rr} = 2\eta(\dot{\xi}_{rr}-\frac{1}{3}\nabla V)$

$\tau_{\varphi\varphi} = 2\eta(\dot{\xi}_{\varphi\varphi}-\frac{1}{3}\nabla V)$

$\tau_{r \varphi} = 2\eta\dot{\xi} _{r \varphi}$

```md 
taurr = 2 * Eta * (Err - 1/3 * divV)
taupp = 2 * Eta * (Epp - 1/3 * divV)
taurp = 2 * Eta_rp * Erp
```

⤴️ [_back to code description_](#code-description)

## Equation of Conservation of Linear Momentum 
The conservation of linear momentum equation is used to describe the change in velocity and pressure of a moving fluid. Due to the high viscosity of the mantle, we can here ignore inertial forces (Turcotte et al., 2002)

$\frac{dV_r}{dt}= \frac{1}{\rho}\left(\frac{\delta\sigma_{rr}}{\delta r} + \frac{1}{r}\frac{\delta\tau_{r\varphi}}{\delta\varphi} + \frac{\Delta\sigma}{r} -\rho fg\right)$

$\frac{dV_{\varphi}}{dt} = \frac{1}{\rho}\left(\frac{1}{r}\frac{\delta\sigma_{\varphi\varphi}}{\delta\varphi} + \frac{\delta\tau_{\varphi}}{\delta r} + 2\frac{\tau_{r\varphi}}{r}\right)$

```md
dVrdt = 1/rho * (np.diff(Srr, axis=0)/np.diff(radn[:, 1:-1], axis=0) +
                (np.diff(taurp, axis=1)/np.diff(phic, axis=1) + deltaS) / radr[1:-1, 1:-1] -
                (rhofg[:-1, 1:-1] + rhofg[1:, 1:-1])/2)
dVpdt = 1/rho * (np.diff(taurp, axis=0)/np.diff(radc, axis=0) +
                (np.diff(Spp, axis=1)/np.diff(phin[1:-1, :], axis=1) + 2 * avr(taurp)) / radp[1:-1, 1:-1])
```
where $\rho$ corresponds to the mechanical density, $\rho f$ corresponds to the effective density calculated in the equation of state.

the variables $\delta\sigma_{rr}$ and $\delta\sigma_{\varphi\varphi}$ define the difference between cells of radial and angular total stress.

⤴️ [_back to code description_](#code-description)

## Equation of Energy Conservation
According to Becker et al. (2013) mantle convection is a good example of a system where heat is transported by diffusion and advection. The degree of separation of these two effects is indicated globally by the Rayleigh number, and locally by the Peclet number. The energy equation makes it possible to determine the temporal evolution of the temperature on which the density and the rheology depend.

$\frac{dT}{dt} = \underbrace{-V_{r}\frac{\delta T}{\delta r}-\frac{V_{\varphi}}{r}\frac{\delta T}{\delta\varphi}}_a+\underbrace{\frac{1}{\rho C{p}}\left(\frac{\delta}{\delta r}\left(\lambda\left(\frac{\delta T}{\delta r}\right)+\frac{\lambda}{r}\frac{\delta T}{\delta r}+\frac{1}{r^2}\frac{\delta}{\delta\varphi}\left(\lambda\left(\frac{\delta T}{\delta\varphi}\right)\right)\right)\right)}_b$

This equation can be broken down into two parts. A first (a) corresponding to the heat flux due to the advection of the fluid and a second (b) representing the heat flux due to thermal diffusion.

```md
dTdt_1 = - np.maximum(0, Vr[1:-2, 1:-1]) * np.diff(T[:-1, 1:-1], axis=0) / drad 
dTdt_2 = - np.minimum(0, Vr[2:-1, 1:-1]) * np.diff(T[1:, 1:-1], axis=0) / drad 
dTdt_3 = - np.maximum(0, Vp[1:-1, 1:-2]) * np.diff(T[1:-1, :-1], axis=1) / dphi / radn[1:-1, 1:-1]
dTdt_4 = - np.minimum(0, Vp[1:-1, 2:-1]) * np.diff(T[1:-1, 1:], axis=1) / dphi / radn[1:-1, 1:-1]
dTdt_5 = (np.diff(lam * np.diff(T[:, 1:-1], axis=0) / drad, axis=0) / drad) / rhoCp
dTdt_6 = (lam * np.diff(avr(T[:, 1:-1]), axis=0) / drad / radn[1:-1, 1:-1]) / rhoCp
dTdt_7 = (np.diff(lam * np.diff(T[1:-1, :], axis=1) / dphi, axis=1) / dphi / radn[1:-1, 1:-1] ** 2) / rhoCp
dTdt = dTdt_1 + dTdt_2 + dTdt_3 + dTdt_4 + dTdt_5 + dTdt_6 + dTdt_7
```
⤴️ [_back to code description_](#code-description)

## Effective viscosities
Here we use the same approach as Halter et al. (2022) for the effective viscosity. The term effective viscosity in the case of flow laws means the ratio between the stress and the rate of strain. The effective viscosity, $\eta$, which is used in the equations above can define several types of viscous flow. In the original Matlab code, $\eta $ is constant and therefore represents linear (Newtonian) viscous flow. We call it here $\eta L$. This represents creep by diffusion. The improvement that we brought to this code consists in adding a non-linear viscous flow in power law. In this case, the effective viscosity depends on the strain rate. The combination of the two types of flow concerns ductile rocks. The effective viscosity of a power-law type viscous fluid, here called $\eta PL $, can be written as follows

$\eta PL = \eta L \left(\frac{T_{II}}{T_{R}}\right)\^{1-\eta}$

where $\eta L$ is the linear viscosity, $T_{R}$ is a constant reference stress, $\eta$ is the stress exponent, which for rocks is ≥1, and

$T_{II} = (0.5(T_{rr}^2+T{\varphi\varphi}^2)+(T_{r \varphi})^2)^{0.5}$

These two viscosities were averaged by a pseudo-harmonic mean:

$\eta C = \frac{1}{\frac{1}{\eta L}+\frac{1}{\eta PL}}$

```md
tau2 = (0.5*(taurr**2+taupp**2)+(c2n(taurp)**2))**0.5

if n_exp > 1:
    Eta_pl_it = Eta_pl
    Eta_pl    = Eta*((tau2/s_ref)**(1-n_exp))
    Eta_pl    = np.exp(np.log(Eta_pl*rel+np.log(Eta_pl_it)*rel))
    Eta       = 1/(1/Eta_l + 1/Eta_pl)
```
⤴️ [_back to code description_](#code-description)

# Résultats
* [Difference between Python and Matlab code](Difference-between-Python-and-Matlab-code)
* [Difference with and without power-law](Difference-with-and-without-power-law)

## Difference between Python and Matlab code

Here are some screenshots at different time steps of the Python (left) and Matlab (right) visualizations

<div style="display: flex;">
    <img src="images_Python\P_image_200.png" alt="Image 1" width="300" />
    <img src="images_Matlab\image_iteration_400.png" alt="Image 2" width="300" />
</div>

<div style="margin-top: 100px; display: flex;">
    <img src="images_Python\P_image_800.png" alt="Image 1" width="300" />
    <img src="images_Matlab\image_iteration_1000.png" alt="Image 2" width="300" />
</div>

<div style="margin-top: 100px; display: flex;">
    <img src="images_Python\P_image_1700.png" alt="Image 1" width="300" />
    <img src="images_Matlab\image_iteration_1900.png" alt="Image 2" width="300" />
</div>

<div style="display: flex;">
    <img src="videos\Sc_py_ss_Pl_1.gif" alt="Image 1" width="300" />
    <img src="videos\Sc_Matlab_3000_1.gif" alt="Image 2" width="300" />
</div>

## Difference with and without power-law

Here are some screenshots at different time steps of the Python without Power-law (left) and Python with Power-law (right) visualizations

<div style="display: flex;">
    <img src="images_Python\P_image_200.png" alt="Image 1" width="300" />
    <img src="images_Python_PL\image_200pl.png" alt="Image 2" width="300" />
</div>

<div style="display: flex;">
    <img src="images_Python\P_image_800.png" alt="Image 1" width="300" />
    <img src="images_Python_PL\image_800pl.png" alt="Image 2" width="300" />
</div>

<div style="display: flex;">
    <img src="images_Python\P_image_1700.png" alt="Image 1" width="300" />
    <img src="images_Python_PL\image_1700pl.png" alt="Image 2" width="300" />
</div>

<div style="display: flex;">
    <img src="videos\Sc_py_ss_Pl_1.gif" alt="Image 1" width="300" />
    <img src="videos\Sc_py_av_Pl_1.gif" alt="Image 2" width="300" />
</div>

⤴️ [_back to code description_](#code-description)




