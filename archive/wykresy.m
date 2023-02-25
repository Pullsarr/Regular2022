clear;
clc;
A=importdata('dane_start.xlsx');
Atable= array2table(A.data,"VariableNames",A.textdata);
mstokts=1.94384;
mtofeet=3.28084;
mstofeets=3.28084;
B=A.data;
B(:,4:5)=B(:,4:5)*mstokts;
B(:,6)=B(:,6)*mstofeets;
B(:,7:8)=B(:,7:8)*mtofeet;
t=B(:,1);
V=B(:,4);
w=B(:,6);
Lx=B(:,7);
Ly=B(:,8);
wyk1=figure;
wyk1.Position=[10 10 800 600];
wyk1=tiledlayout(2,1,"TileSpacing","compact");
title(wyk1,"Take-off analysis");
wyk11=nexttile(wyk1);
hold on
grid minor
plot(Lx,Ly);
axis([0 500 0 100]);
xlabel('Distance [ft]');
ylabel('Altitude [ft]');
wyk12=nexttile(wyk1);
plot(t,V,t,w);
hold on
grid minor
xlabel('time [s]');
ylabel('Airspeed [kts], Rate of climb [ft/s]')
leg_text=["Airspeed","Rate of climb"];
leger=legend(wyk12,leg_text);
leger.NumColumns=2;
leger.Location="southeast";
saveas(wyk1,"take_off.jpeg");

