clc;
clear;
%ustaw jakies fajne parametry
mi=0.04; %opor toczny
Lstart=24.5; %dlugosc startu
Lmax= 150; %maksymalna dlugosc od startu do konca wznoszenia
Hmin= 15; %minimalna wysokosc na ktora ma sie wzniesc
timeW= 60; %czas w sekundach calego startu
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
    b(i)=PROfunctions.naming_data(a(i),names{i});
    c(i)=PROfunctions.geo_data(b(i),geometric_data,names{i});
    d(i)=PROfunctions.minimum_Rx(c(i),table2array(c(i).data),mi);
    e(i)=PROfunctions.optimum(d(i),table2array(d(i).data),Ciag);
    f(i)=PROfunctions.start_anal(d(i),table2array(d(i).data),Ciag,mi,timeW,Lstart,Hmin,Lmax);
    FINAL(i)=PROfunctions.final_points(f(i));
    x(i)=FINAL(i).B;
    y(i)=FINAL(i).AR;
    z1(i)=FINAL(i).PAYLOAD;
    z2(i)=FINAL(i).FFS;
    zMatrix(i,i)=z1(i);
 end



