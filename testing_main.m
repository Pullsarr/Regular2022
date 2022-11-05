clc;
clear;
%ustaw jakies fajne parametry
mi=0.04; %opor toczny
Lstart=24.5; %dlugosc startu
MFV=10; %Minimum Flight Velocity 
Rot_angle=8; % rotacja w stopniach
Rot_time=2; % czas na rotacje w s
Lmax= 150; %maksymalna dlugosc od startu do konca wznoszenia
Hmin= 15; %minimalna wysokosc na ktora ma sie wzniesc
timeW= 60; %czas w sekundach calego startu
wspKOWAL=1.3; % współczynnik oporu
addpath('airfoils\')
Ciag= importdata('Charakterystyki ciagu.xlsx');
geometric_data=importdata('geometric_data.xlsx');
filePattern = fullfile('airfoils','./','*_TX*');
files = dir(filePattern);
names=  cell(1,1);
for i=1:length(files)
    filename = files(i);
    names{i}=filename.name;
    a(i)=importdata(names{i});
    names{i}=erase(names{i},".txt");
    b(i)=testing.naming_data(a(i),names{i});
    c(i)=testing.geo_data(b(i),geometric_data,names{i});
    d(i)=testing.minimum_Rx(c(i),mi);
    e(i)=testing.start_anal(d(i),Ciag,mi,timeW,Lstart,MFV,Rot_angle,Rot_time,Hmin,Lmax,wspKOWAL);
end
