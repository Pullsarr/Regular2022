clear; clc;
Clmax=2.18;
rho=1.16;
S=2.05;
m=12.5;
g=9.81;
cg=0.3736;
Clmin=-1;
nmax=4;
a=5.14;
nmin=-1;
Q=m*g;
ms2kts=1.94384;
Vsdot=sqrt((2*Q)/(rho*S*Clmax));
Va=Vsdot*sqrt(nmax);
Vsmin=sqrt((2*Q)/(rho*S*abs(Clmin)));
Vlinsmall=linspace(0,Vsdot,101);
Vlinminsmall=linspace(0,Vsmin,101);
ngrdotsmall=rho*Vlinsmall.^2*S*Clmax/(2*Q);
ngrminsmall=rho*Vlinminsmall.^2*S*Clmin/(2*Q);
Vlinbig=linspace(Vsdot,Va,101);
ngrdotbig=rho*Vlinbig.^2*S*Clmax/(2*Q);



Vc=12;
Vd=1.5*Vc;
f=figure;
f.Position=[10 10 1200 600];
hold on
%% przeliczniki:
Vsdot=Vsdot*ms2kts;
Vsmin=Vsmin*ms2kts;
Va=Va*ms2kts;
Vc=Vc*ms2kts;
Vd=Vd*ms2kts;
Vlinbig=Vlinbig*ms2kts;
Vlinminsmall=Vlinminsmall*ms2kts;
Vlinsmall=Vlinsmall*ms2kts;
%% plot Vs line
plot([Vsdot Vsdot],0:1,Color="black",LineWidth=2);
plot([Vsmin Vsmin],nmin:0,Color="black",LineWidth=2);
plot([Vc Vc],nmin:0,Color="black",LineStyle="-.");
plot([Va Va],[0 nmax],Color="black",LineStyle="-.");
plot([Vd Vd],[0 nmax],Color="black",LineWidth=2);
plot(Vlinsmall, ngrdotsmall,Color="black",LineStyle=":");
plot(Vlinbig,ngrdotbig,Color="black",LineWidth=2);
plot(Vlinminsmall, ngrminsmall,Color="black",LineStyle=":");
plot([Va Vd],[nmax nmax],Color="black",LineWidth=2);
plot([Vsmin Vc],[nmin nmin],Color="black",LineWidth=2);
plot([Vc Vd],[nmin 0],Color="black",LineWidth=2);
plot([0 Vd],[0 0],Color="black");
plot([0 Va],[nmax nmax],Color="black",LineStyle="-.");
plot([0 Vc],[nmin nmin],Color="black",LineStyle="-.");
grid minor

%% obwiednia od podmuchów
kg2pd=2.20462;
m2tof2=10.7639;
W=m*kg2pd;
S2=S*m2tof2;
skal=W/S2;
mug=2*skal/(rho*cg*a*g);
kg=0.535;
Uc= 6.68778; %13 kts
Ud=13.3756; % 26 kts
ncdot=1+1.15;
ncmin=1-1.15;
nddot=1+0.85;
ndmin=1-0.85;
plot([0 Vc],[1 ncdot],Color="black",LineStyle="--");
plot([0 Vc], [1 ncmin],Color="black",LineStyle="--");
plot([0 Vd],[1 nddot],Color="black",LineStyle="--");
plot([0 Vd],[1 ndmin],Color="black",LineStyle="--");
plot([Vc Vc],[0 ncdot],Color="black",LineStyle="-.");
plot([Vc Vd],[ncdot nddot],Color="black",LineStyle="-.");
plot([Vc Vd],[ncmin ndmin],Color="black",LineStyle="-.");

%% texts
text(Vsdot*0.98,-0.2,"Vs","FontSize",14);
text(Vsmin*0.98,0.2,"Vs'",FontSize=14)
text(Vc*0.98,0.2,"Vc","FontSize",14);
text(Vd*1.02,0.2,"Vd",FontSize=14);
text(Va*0.98,0.2,"Va",FontSize=14);
text(10,1.62,"+V_c gust line (+26 ft/s)", Rotation=10);
text(10,1.42,"+V_d gust line (+13 ft/s)", Rotation=5);
text(7.5,0.95,"-V_d gust line (-13 ft/s)", Rotation=-7);
text(7.5,0.5,"-V_c gust line (-26 ft/s)", Rotation=-10);
title("Flight Envelope");
xlabel("V [kts]");
ylabel("Load factor n [-]");
axis([0 40 -1.5 4.5]);
saveas(f,"obwiednia.jpg");