clear
A=importdata('moment.xlsx');
for i=2:length(A)
B(i-1,:)=strsplit(A{i},',');
end
C=str2double(B);
m2in=39.3701;
Nm2fpound=0.7375621493;
x=C(:,1)*m2in;
y=C(:,12)*Nm2fpound;
x2=x;
y2=y*4;
f=figure;
f.Position= [10 10 900 300];
plot(x,y,x2,y2);
hold on
title('Bending Moment');
xlabel('wingspan [in]');
ylabel('Bending Moment [lb-ft]');
grid minor;
legstr=['n = 1'; 'n = 4'];
legend(legstr);
axis([ -108 108 0 400])
saveas(f,'moment.jpg')