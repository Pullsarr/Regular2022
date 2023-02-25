clc;
clear;
%ustaw jakies fajne parametry
Lland=100; %dlugosc startu
Vstart=10;
MDV=2; %Maximum descent velocity
Hstart= 40; %minimalna wysokosc na ktora ma sie wzniesc
addpath('airfoils\')
Ciag= importdata('Ciagu char.xlsx');
geometric_data=importdata('geometric_data.xlsx');
filePattern = fullfile('airfoils','./', '*AR*');
files = dir(filePattern);
names=  cell(1,1);
for i=1:length(files)
    filename = files(i);
    names{i}=filename.name;
    a(i)=importdata(names{i});
    names{i}=erase(names{i},".txt");
    b(i)=takeOFF_functions.naming_data(a(i),names{i});
    c(i)=takeOFF_functions.geo_data(b(i),geometric_data,names{i});
    d(i)=landing_functions.landing(c(i),Ciag);
end
x=d(1).path(:,7);
y=d(1).path(:,8);
y=y*3.28084;
plot(x,y);
hold on
title('Landing analysis');
ylabel('Altitude [ft]');
xlabel('Distance [ft]');
grid minor