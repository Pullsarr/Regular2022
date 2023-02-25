A=importdata('toplot.xlsx');
x=A(:, 1);
y=A(:,2);
z1=A(:,3);
z2=A(:,4);
xspace=linspace(min(x),max(x),50);
yspace=linspace(min(y),max(y),50);
[X Y]= meshgrid(xspace,yspace);
f1 = scatteredInterpolant(x,y,z1,'natural');
Z1 = f1(X,Y);
f2 = scatteredInterpolant(x,y,z2,'natural');
Z2 = f2(X,Y);
figure('Renderer', 'painters', 'Position', [0 0 600 450])
tiledlayout(1,1);
nexttile
surf(X,Y,Z2);
grid on
shading interp
title("Final Flight Score")
colorbar
xlabel('Aspect Ratio [-]'), ylabel('wingspan [in]'), zlabel('FFS [-]')
saveas(gcf,'TakeoffPlot.jpg');