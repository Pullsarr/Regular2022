clc;
clear;
%ustaw jakies fajne parametry
Lstart=20; %dlugosc startu
MFV=10; %Minimum Flight Velocity
MCV=2; %Minimum Climb Velocity
Rot1_angle=9; % rotacja 1 w stopniach
Rot2_angle=9; % rotacja 2 w stopniach
Rot1_time=0.5; % czas na 1 rotacje
Rot1B_time=1.5; % time for alignment 
Rot2_time=2; % czas na rotacje w s
Lmax= 150; %maksymalna dlugosc od startu do konca wznoszenia
Hmin= 30; %minimalna wysokosc na ktora ma sie wzniesc
timeW= 60; %czas w sekundach calego startu
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
    d(i)=takeOFF_functions.minimum_Rx(c(i));
    e(i)=takeOFF_functions.start_anal(d(i),Ciag,timeW,Lstart,MFV,MCV,Rot1_angle,Rot2_angle,Rot1_time,Rot1B_time, Rot2_time,Hmin,Lmax);
    f(i)=takeOFF_functions.pathing(e(i),Ciag,timeW,Lstart,MFV,MCV, Rot1_angle,Rot2_angle,Rot1_time,Rot1B_time, Rot2_time,Hmin,Lmax);
    FINAL(i)=takeOFF_functions.final_points(f(i));
    temp(i,1)=FINAL(i).geo.AR;
    temp(i,2)=FINAL(i).FFS;
    temp(i,3)=FINAL(i).geo.Mo+FINAL(i).PAYLOAD;
    temp(i,4)=FINAL(i).geo.B;
end


