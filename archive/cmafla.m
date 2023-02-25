A=importdata("T1-12_0 m_s-VLM2.csv");
alfa=A.data(:,1);
alfal=linspace(-5,20,101);
cm=A.data(:,9);
cml=interp1(alfa,cm,alfal,"linear","extrap");
f=figure;
f.Position=[10 10 500 300];
plot(alfal,cml/2.);
hold on
yline(0);
grid minor
ylabel("Pitching moment coeff. [-]");
xlabel("AoA [\circ]");
saveas(f,"Cm2.jpg");