clear;
clc;
%Kalkulator prędkości wznoszenia
%Jednostki SI
g=9.81; %przyśpieszenie ziemskie
S=2; %pole powierzchni płata
ro=1.16; %gęstość powietrza
w_min=2; % minimum vertical velocity
Varnames={'angle','E','V','w','gamma'};
A=readtable("MassTable.xlsx");
B=readmatrix("MassTable.xlsx");
addpath('airfoils\')
Ciag= importdata('Ciagu char.xlsx');
geometric_data=importdata('geometric_data.xlsx');
filePattern = fullfile('airfoils','./', '*AR*');
f1= figure;
f1.Position = [10 10 800 600];
files = dir(filePattern);
Mostr="Mo";
MTOWstr="MTOW";
for i=1:length(files)
    filename = files(i);
    names{i}=filename.name;
    a(i)=importdata(names{i});
    names{i}=erase(names{i},".txt");
    [col]=find(contains(A{:,1},names{i}),1,"first");
    m(1)=B(col+1,2);
    m(2)=B(col+1,3);
    kat=a(i).data(:, 1);
    Cz=a(i).data(:,3);
    Cx=a(i).data(:,6);
    E=Cz.^3./Cx.^2;
    Czindex=find(Cz>0.1,1,"first");
    for l=Czindex:length(a(i).data)
        for k=1:2
            V(k)=sqrt(2*m(k)*g/ro/S/Cz(l));
            Nr=interp1(Ciag.data(:,1),Ciag.data(:,2),V(k),"linear",'extrap')*g*V(k);
            Nn(k)=m(k)*g*sqrt((2/ro)*(m(k)*g/S)/E(l));
            w(k)=(Nr-Nn(k))/(m(k)*g);
            gamma(k)=asind(w(k)/V(k));
        end
        b(i).Mo(l,1)=kat(l);
        b(i).Mo(l,2)=E(l);
        b(i).Mo(l,3)=V(1);
        b(i).Mo(l,4)=w(1);
        b(i).Mo(l,5)=gamma(1);
        b(i).MoTAB=array2table(b(i).Mo,"VariableNames",Varnames);
        b(i).MTOW(l,1)=kat(l);
        b(i).MTOW(l,2)=E(l);
        b(i).MTOW(l,3)=V(2);
        b(i).MTOW(l,4)=w(2);
        b(i).MTOW(l,5)=gamma(2);
        b(i).MTOWTAB=array2table(b(i).MTOW,"VariableNames",Varnames);
    end %koniec pętli dla jednego kąta
    VarNames(2*i-1)=append(Mostr,names{i});
    VarNames(2*i)=append(MTOWstr,names{i});
    subplot(2,1,1)
    plot(b(i).Mo(Czindex:length(a(i).data),3),b(i).Mo(Czindex:length(a(i).data),4),'--');
    hold on
    plot(b(i).MTOW(Czindex:length(a(i).data),3),b(i).MTOW(Czindex:length(a(i).data),4));
    hold on
    xlabel('V [m/s]');
    ylabel('w [m/s]');
    legend(VarNames);
    grid on

    subplot(2,1,2)
    plot(b(i).Mo(Czindex:length(a(i).data),3),b(i).Mo(Czindex:length(a(i).data),5),'--');
    hold on
    plot(b(i).MTOW(Czindex:length(a(i).data),3),b(i).MTOW(Czindex:length(a(i).data),5));
    hold on
    xlabel('V [m/s]');
    ylabel('\gamma [\circ]');
    legend(VarNames);
    grid on
end %koniec pętli po plikach

saveas(f1,'climb_normal.png');

%% version for gringos
meter2kts=1.94384449;
mstofts=3.28084;
f2= figure;
f2.Position = [10 10 900 300];
for i=1:length(b)
    b(i).MoUSA(:,1)=meter2kts.*b(i).Mo(:,3);
    b(i).MoUSA(:,2)=mstofts.*b(i).Mo(:,4);
    b(i).MoUSA(:,3)=b(i).Mo(:,5);
    b(i).MTOWUSA(:,1)=meter2kts.*b(i).MTOW(:,3);
    b(i).MTOWUSA(:,2)=mstofts.*b(i).MTOW(:,4);
    b(i).MTOWUSA(:,3)=b(i).MTOW(:,5);
        VarNames(2*i-1)=Mostr;
    VarNames(2*i)=MTOWstr;
    plot(b(i).MoUSA(Czindex:length(a(i).data),1),b(i).MoUSA(Czindex:length(a(i).data),2),'--');
    hold on
    plot(b(i).MTOWUSA(Czindex:length(a(i).data),1),b(i).MTOWUSA(Czindex:length(a(i).data),2));
    hold on
    xlabel('V [kts]');
    ylabel('w [ft/s]');
    title('Climb rate analysis');
    legend(VarNames);
    grid on
    
end
saveas(f2,'climb_USA.png');

