clear; clc;
A=importdata('ciągi.xlsx');
B=importdata('apc21.xlsx');
Ntolbf=2.20462;
y=A.data*Ntolbf;
x=categorical(A.textdata);
f=figure;
f.Position=[10 10 900 300];
f=tiledlayout(1,2,"TileSpacing","compact");

nexttile(f)
bar(x,y);
a1=legend('V = 0 kts','V = 23.33 kts');
a1.Location="northoutside";
a1.NumColumns=2;
ylabel('Thrust [lbf]')
nexttile(f)
ms2kts=1.94384;
V=B.data(:,1)*ms2kts;
T=B.data(:,2)*Ntolbf;
plot(V,T);
hold on
grid minor
title('APC 21x12');
xlabel('V [kts]');
ylabel('Thrust [lbf]');
title(f,'Thrust characteristics');
saveas(f,'ciaggg.jpg');