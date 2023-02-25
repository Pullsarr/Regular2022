A1=importdata("MW01.202_Re0.350_M0.00_N9.0.csv");
A2=importdata("MW.01.203_Re0.350_M0.00_N9.0.csv");
A3=importdata("PP02_Re0.350_M0.00_N9.0.csv");
alfa1=A1.data(:,1);
alfa2=A2.data(:,1);
alfa3=A3.data(:,1);
Cl1=A1.data(:,2);
Cl2=A2.data(:,2);
Cl3=A3.data(:,2);
Cd1=A1.data(:,3);
Cd2=A2.data(:,3);
Cd3=A3.data(:,3);
dosk1=Cl1./Cd1;
dosk2=Cl2./Cd2;
dosk3=Cl3./Cd3;
legstr=["MW.01.202","MW.01.203","PP02"];
f=figure;
f.Position=[10 10 900 300];
f=tiledlayout(1,2,"TileSpacing","compact");
nexttile(f)
plot(alfa1,Cl1,alfa2,Cl2,alfa3,Cl3);
hold on
grid minor
title("C_l (\alpha)");
ylabel("C_l [-]");
xlabel("\alpha [\circ]");
nexttile(f)
plot(alfa1,dosk1(:,1),alfa2,dosk2(:,1),alfa3,dosk3(:,1));
hold on
grid minor
title("C_{l}/C_{d} (\alpha)");
xlabel("\alpha [\circ]");
ylabel("C_{l}/C_{d} [-]");
legend(legstr,Location="eastoutside");

saveas(f,"aero.jpg");