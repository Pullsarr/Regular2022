clc;
clear;
%ustaw jakies fajne parametry
Lstart=25; %dlugosc startu
MFV=10; %Minimum Flight Velocity
MCV=1.5; %Minimum Climb Velocity
Rot1_angle=6; % rotacja 1 w stopniach
Rot2_angle=3; % rotacja 2 w stopniach
Rot1_time=0.5; % czas na 1 rotacje
Rot1B_time=1.5; % time for alignment
Rot2_time=2; % czas na rotacje w s
Lmax= 200; %maksymalna dlugosc od startu do konca wznoszenia
Hmin= 30; %minimalna wysokosc na ktora ma sie wzniesc
timeW= 60; %czas w sekundach calego startu
addpath('airfoils\')
Ciag= importdata('Ciagu char.xlsx');
geometric_data=importdata('geometric_data.xlsx');
filePattern = fullfile('airfoils',"./");
files = dir(filePattern);
names=  cell(1,1);
for i=33    :length(files)
    filename = files(i);
    names{i}=filename.name;
    a(i)=importdata(names{i});
    names{i}=erase(names{i},".txt");
    b(i)=takeOFF_functions.naming_data(a(i),names{i});
    c(i)=takeOFF_functions.geo_data(b(i),geometric_data,names{i});
    d(i)=takeOFF_functions.minimum_Rx(c(i));
    e(i)=takeOFF_functions.maxclimb(d(i),Ciag);
    f(i)=takeOFF_functions.start_anal(e(i),Ciag,timeW,Lstart,MFV,MCV,Rot1_angle,Rot2_angle,Rot1_time,Rot1B_time, Rot2_time,Hmin,Lmax);
    %g(i)=takeOFF_functions.pathing(f(i),Ciag,timeW,Lstart,MFV,MCV, Rot1_angle,Rot2_angle,Rot1_time,Rot1B_time, Rot2_time,Hmin,Lmax);
    %h(i)=takeOFF_functions.start_climb(g(i),Ciag,timeW,MFV, MCV,Rot2_angle, Rot2_time,Hmin,Lmax);
    FINAL(i)=takeOFF_functions.final_points(f(i));
    TBplot(i,1)=FINAL(i).geo.AR;
    TBplot(i,2)=FINAL(i).geo.B;
    TBplot(i,3)=FINAL(i).FS;
    TBplot(i,4)=FINAL(i).FFS;
    writematrix(TBplot,"wyniki.xlsx");
end

