A= importdata("dataforplots.xlsx");

x=A.data(:, 1);

y=A.data(:,2);

z1=A.data(:,3);

z2=A.data(:,4);

xlin = linspace(min(x),max(x),50);

ylin = linspace(min(y),max(y),50);

[X,Y] = meshgrid(xlin,ylin);

f1 = scatteredInterpolant(x,y,z1,'natural');

Z1 = f1(X,Y);

Z3 = griddata(x,y,z1,X,Y,"cubic");

Z4 = griddata(x,y,z2,X,Y,"cubic");

f2 = scatteredInterpolant(x,y,z2,'natural');

Z2 = f2(X,Y);

tiledlayout(2,2);

nexttile

surf(X,Y,Z3);

grid on

title("Griddata Masa")

colorbar

xlabel('AR'), ylabel('B'), zlabel('MTOW')

nexttile

surf(X,Y,Z4);

grid on

title("Griddata Wynik")

colorbar

xlabel('AR'), ylabel('B'), zlabel('FFS')

nexttile    

surf(X,Y,Z1);

grid on

title("scatteredInterpolant Masa")

colorbar

xlabel('AR'), ylabel('B'), zlabel('MTOW')

nexttile    

surf(X,Y,Z2);

grid on

title("scatteredInterpolant Wynik punktowy")

colorbar

xlabel('AR'), ylabel('B'), zlabel('FFS')