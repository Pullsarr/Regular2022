clc;
clear;
runIDs = Simulink.sdi.getAllRunIDs;
runID = runIDs(end);
dataset = Simulink.sdi.exportRun(runID);
time=dataset{1}.Values.Time;
y(:)=dataset{1}.Values.Data(:,:,:); % razy 100 bo procent
f= figure;
f.Position = [10 10 550 400];
wyk=plot(time,y);
hold on
title('awaria LVDT')
xlabel('czas [s]')
grid minor
ylabel('\alpha_{VG} [\circ]')
saveas(wyk,'emer2.png')
dataset.getElementNames