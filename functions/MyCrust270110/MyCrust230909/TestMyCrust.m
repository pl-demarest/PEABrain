

%WARNING WORKSPACE WILL BE CLEARED !!!!!
clc
clearvars
close all

%Instructions :

%just uncomment one of the following line and run


%% Points cloud :

% load cervellotac.mat
% load Block.mat
% load Skull.mat
% load Standford_Bunny.mat
% load Horse.mat
% load hippo.mat
% load Elephant.mat
% load Chair.mat
% load Gargo50k.mat
% load OilPump.mat
% load Knot.mat
% load Beethoven.mat;p=V;clear V F;
% load Vertebra1.mat
% load cactus.mat

load points.mat





%% Run  program




[t,tnorm]=MyRobustCrust(p);

% profile report;profile off;
%% plot the points cloud
figure(1);
set(gcf,'position',[0,0,1280,800]);
subplot(1,2,1)
hold on
axis equal
title('Points Cloud','fontsize',14)
plot3(p(:,1),p(:,2),p(:,3),'g.')
view(3);
axis vis3d


%% plot of the output triangulation
figure;
hold on
title('Output Triangulation','fontsize',14)
axis equal
trisurf(t,p(:,1),p(:,2),p(:,3),'facecolor','c','edgecolor','b')%plot della superficie trattata
axis equal



