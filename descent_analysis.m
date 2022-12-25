clear;close all;clc;
%prompt = "Insert plane weight ";
%m = input(prompt);
%DECLARE INPUT
A=readtable("MassTable.xlsx");
B=readmatrix("MassTable.xlsx");
addpath('airfoils\');
geometric_data=importdata('geometric_data.xlsx');
filePattern = fullfile('airfoils','./', '*AR*');
files = dir(filePattern);
vMAX = 13;                      % MAX prędkość samolotu m/s
vEND = 1.2*vMAX;
g = 9.81 ;                      % Przyspieszenie grawitacyjne
rho = 1.16 ;
f1= figure;
f1.Position = [10 10 1200 600];


for i=1:length(files)
    filename = files(i);
    names{i}=filename.name;
    a(i)=importdata(names{i});
    names{i}=erase(names{i},".txt");
    [col row] = find(contains(geometric_data.textdata,names{i}),1,"first");
    S=geometric_data.data(3,row-1);
    [col]=find(contains(A{:,1},names{i}),1,"first");
    Mo=B(col+1,2);
    MTOW=B(col+1,3);
    alpha=flip(a(i).data(:, 1));
    Cz=flip(a(i).data(:,3));
    Cx=flip(a(i).data(:,6));
    for j=1:length(a(i).data)
        b(i).aero(j,1)=alpha(j);
        b(i).aero(j,2)=Cz(j);
        b(i).aero(j,3)=Cx(j);
        b(i).aero(j,4)=sqrt(1/sqrt((Cz(j)^2) + (Cx(j)^2)));
        b(i).aero(j,5)=sqrt(Cx(j)^2/sqrt((Cz(j)^2) + (Cx(j)^2)));
        b(i).aero(j,6)=atand(Cx(j)/Cz(j));
        b(i).Mo(j,1)=sqrt((2*Mo*g)/(rho*S));
        b(i).Mo(j,2)=b(i).aero(j,4)*b(i).Mo(j,1);
        b(i).Mo(j,3)=-b(i).aero(j,5)*b(i).Mo(j,1);
        b(i).MTOW(j,1)=sqrt(2*MTOW*g/(rho*S));
        b(i).MTOW(j,2)=b(i).aero(j,4)*b(i).MTOW(j,1);
        b(i).MTOW(j,3)=-b(i).aero(j,5)*b(i).MTOW(j,1);
        if (b(i).Mo(j,2)>vMAX) || (b(i).MTOW(j,2)>vMAX)
            break
        end
    end
    plot(b(i).Mo(:,2),b(i).Mo(:,3),'-x');
    hold on
    plot(b(i).MTOW(:,2),b(i).MTOW(:,3),'-o');
    hold on
    mingamma(i)=min(b(i).aero(:,6));
end
MINgamma=min(mingamma);
X=[0 50];
Y=[0 -50*tand(MINgamma)];
plot(X,Y);
grid on;
xlabel('V [m/s]');
ylabel('w [m/s]');
axis([0 15 -1.2 0]);
legend("Mo","MTOW");
saveas(f1,'descent_normal.png')
%% plot for gringos
mpstokts=1.94384;
mptofpmin=196.85;
f2= figure;
f2.Position = [10 10 1200 600];
for i=1:length(b)
    b(i).MoUSA(:,2)= mpstokts*b(i).Mo(:,2);
    b(i).MoUSA(:,3)=mptofpmin*b(i).Mo(:,3);
    b(i).MTOWUSA(:,2)=mpstokts*b(i).MTOW(:,2);
    b(i).MTOWUSA(:,3)=mptofpmin*b(i).MTOW(:,3);
    plot(b(i).MoUSA(:,2),b(i).MoUSA(:,3),'-x');
    hold on
    plot(b(i).MTOWUSA(:,2),b(i).MTOWUSA(:,3),'-o');
    hold on
    mingamma(i)=min(b(i).aero(:,6));
end
XUSA=X.*mpstokts;
YUSA=Y.*mptofpmin;
plot(XUSA,YUSA);
grid on;
xlabel('V [kts]');
ylabel('w [ft/min]');
axis([0 30 -240 0]);
legend("Mo","MTOW");
saveas(f2,'descent_USA.png');


