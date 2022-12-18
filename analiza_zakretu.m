clc;
clear;
g=9.81;
vmin=12;
v=10:0.1:20;
fi=0:1:80;


[V,FI]=meshgrid(v,fi);
R=(V.^2)./(tand(FI).*g);

writematrix(R, "zakrety.xls");
f= figure;
f.Position = [10 10 800 400];
for i=0:5
    y=R(11+10*i,:);
    plt=plot(v,y);
    hold on
end
xline(vmin,":","LineWidth",3);

vx=vmin./sqrt(cosd(transpose(fi)));
Rg2=(vx.^2)./(tand(transpose(fi)).*g);

plt=plot(vx,Rg2,"LineWidth",2,"LineStyle","-.");
grid on
legend("10\circ", "20\circ", "30\circ", "40\circ", "50\circ", "60\circ", "V_{min}","R_{min}");
xlabel("V [m/s]")
ylabel("R [m]")
axis([10 20 0 250]);
hold off
saveas(plt,'turn_analysis_normal.png')

%% part for americans
metertofeet=3.28084;
mstokts= 1.94384;
vmin_USA=mstokts*vmin;
vx_USA=vx*mstokts;
v_USA=v*mstokts;
R_USA=R.*metertofeet;
Rg2_USA=Rg2.*metertofeet;
f_USA= figure;
f_USA.Position = [10 10 800 400];
for i=0:5
    y_USA=R_USA(11+10*i,:);
    plt_USA=plot(v_USA,y_USA);
    hold on
end
xline(vmin_USA,":","LineWidth",3);
plt=plot(vx_USA,Rg2_USA,"LineWidth",2,"LineStyle","-.");
grid on
legend("10\circ", "20\circ", "30\circ", "40\circ", "50\circ", "60\circ", "V_{min}","R_{min}");
xlabel("V [kts]")
ylabel("R [ft]")
axis([22 36 0 500]);
hold off
saveas(plt,'turn_analysis_USA.png')
