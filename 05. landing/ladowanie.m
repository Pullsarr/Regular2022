A=importdata('dataplot.xlsx');
x=A(:,1);
y=A(:,2)*3.28084;
f=figure;
f.Position= [10 10 900 300];
plot(x,y);
hold on
title('Landing analysis');
ylabel('Altitude [ft]');
xlabel('Distance [ft]');
grid minor
plot(118.71,2*3.28084,"d");
plot(188.71,0.48,"d");
text(150,6,'Flare','FontSize',14);
xline(208.426,'--k','Linewidth',1.4);
xline(398.423,'--k','Linewidth',1.4);
x = [0.77 0.90];
y = [0.5 0.5];
Xadj = 1.44; 
str={'Landing ',' Distance'};
annotation('textarrow',x,y,'String',str,'FontSize',14,'Linewidth',2)
annotation('textarrow',-x+Xadj,y,'String','','FontSize',14,'Linewidth',2)
saveas(f,'landinganal.png');