clc;
clear;
%ustaw jakies fajne parametry
mi=0.04; %opor toczny
Lstart=27.43; %dlugosc startu
Lmax= 150; %maksymalna dlugosc od startu do konca wznoszenia
Hmin= 10; %minimalna wysokosc na ktora ma sie wzniesc
timeW= 60; %czas w sekundach calego startu
Ciag= importdata('Charakterystyki ciagu.xlsx');
geometric_data=importdata('geometric_data.xlsx');
filePattern = fullfile('./', '*.txt');
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
    f(i)=PROfunctions.start_anal(e(i),table2array(e(i).data),Ciag,mi,timeW,Lstart,Hmin,Lmax);
    FINAL(i)=PROfunctions.final_points(f(i));
    x(i)=FINAL(i).B;
    y(i)=FINAL(i).AR;
    z1(i)=FINAL(i).PAYLOAD;
    z2(i)=FINAL(i).FFS;
    zMatrix(i,i)=z1(i);
 end
 a=figure;
 subplot(2,2,1)
wyk1=plot3(x,y,z1);
grid on
wyk1=xlabel('wingspan');
wyk1=ylabel('AR');
wyk1=zlabel('PAYLOAD');
wyk1=title('Najpierw masa');
 subplot(2,2,2)
wyk2=plot3(x,y,z2);
grid on
wyk2=xlabel('wingspan');
wyk2=ylabel('AR');
wyk2=zlabel('Final Flight Score');
wyk2=title('potem punkty');
saveas(a,"OBRAZZZKI.jpg");
subplot(2,2,3)
wyk3=plot(x,y,zMatrix);
wyk3=xlabel('wingspan');
wyk3=ylabel('AR');
wyk3=zlabel('PAYLOAD');
wyk3=title('poyebany');


