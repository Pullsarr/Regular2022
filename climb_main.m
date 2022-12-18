clear;
clc;
%Kalkulator prędkości wznoszenia
%Jednostki SI
masamin=1; %masa od której zaczynamy
masamax=10; %górna granica dla której sprawdzamy
krokmasowy=0.1; %co ile zmnieniamy masę
m=20;
g=9.81; %przyśpieszenie ziemskie
S=2; %pole powierzchni płata
ro=1.16; %gęstość powietrza
w_min=2; % minimum vertical velocity
Varnames={'angle','E','V','w','Nn','Nr','Nr-Nn'};
addpath('airfoils\')
Ciag= importdata('Ciagu char.xlsx');
geometric_data=importdata('geometric_data.xlsx');
filePattern = fullfile('airfoils','./', '*AR*');
files = dir(filePattern);
for i=1:length(files)
    filename = files(i);
    names{i}=filename.name;
    a(i)=importdata(names{i});

    kat=a(i).data(:, 1);

    Cz=a(i).data(:,3);

    Cx=a(i).data(:,6);

    E=Cz.^3./Cx.^2;

    for l=min(find(Cz>0.2)):length(a(i).data)
            V=sqrt(2*m*g/ro/S/Cz(l));
            Nr=interp1(Ciag.data(:,1),Ciag.data(:,2),V,"linear",'extrap')*g*V;
            Nn=m*g*sqrt((2/ro)*(m*g/S)/E(l));
            w=(Nr-Nn)/(m*g);
            b(i).wyniki(l,1)=kat(l);
            b(i).wyniki(l,2)=E(l);
            b(i).wyniki(l,3)=V;
            b(i).wyniki(l,4)=w;
            b(i).wyniki(l,5)=Nn;
            b(i).wyniki(l,6)=Nr;
            b(i).wyniki(l,7)=Nr-Nn;
            b(i).wynikiTAB=array2table(b(i).wyniki,"VariableNames",Varnames);
    end %koniec pętli dla jednego kąta
    plot(b(i).wyniki(min(find(Cz>0.2)):length(a(i).data),3),b(i).wyniki(min(find(Cz>0.2)):length(a(i).data),4));
    hold on
end %koniec pętli po plikach

