%% Compare 2 or more activities - wrist in 3D


clear all
close all
clc

exercise_sub1 = readtable('/Users/jialinhe1/Desktop/Tesi/Kinect/data/dryrun/free_exp1_noexo.csv', 'NumHeaderLines',1);
exercise_sub2 = readtable('/Users/jialinhe1/Desktop/Tesi/Kinect/data/dryrun/free_exp1_exo.csv', 'NumHeaderLines',1);

% pt1 = readtable('/Users/jialinhe1/Desktop/Tesi/Kinect/data/new/pt1_exo.csv', 'NumHeaderLines',1);
% pt2 = readtable('/Users/jialinhe1/Desktop/Tesi/Kinect/data/new/pt2_exo.csv', 'NumHeaderLines',1);
%exercise_sub2 = vertcat(pt1,pt2);

%% Kinect data acquisition accuracy

accuracy1=data_acquisition_accuracy(exercise_sub1);
accuracy2=data_acquisition_accuracy(exercise_sub2);

%% Change reference system, filter and get time reference in seconds

% rotation of 90º around X axis 
theta1=1.5708;
% rotation1 of 180º around Z axis 
theta2=3.14159;         % since the kinect see in opposite way
% filter: zero-lag-4th-order Butterworth low pass filter with cut off 6Hz
fc=6;           % cut off frequency
fs=1/(33*0.001);      % sample frequency (∂t≈33ms)
[b,a] = butter(5,fc/(fs/2), 'low');     % 5th order

[exercise_sub1_wrist,exercise_sub1_elbow,exercise_sub1_shoulder,exercise_sub1_hip,exercise_sub1_spine,right_wrist,right_wrist_filt,right_elbow,right_elbow_filt,right_shoulder,right_shoulder_filt,L1,time1,tot_time1]=newref_and_filter(exercise_sub1,b,a,theta1,theta2);
[exercise_sub2_wrist,exercise_sub2_elbow,exercise_sub2_shoulder,exercise_sub2_hip,exercise_sub2_spine,right_wrist2,right_wrist2_filt,right_elbow2,right_elbow2_filt,right_shoulder2,right_shoulder2_filt,L2,time2,tot_time2]=newref_and_filter(exercise_sub2, b, a, theta1, theta2);

clear a; clear b; clear theta1; clear theta2; clear fc; clear fs;

%% Plot movement distribution in 3D 

figure
plotMan(right_shoulder_filt); 
hold on
p1=scatter3(exercise_sub1_wrist(:,1), exercise_sub1_wrist(:,2),exercise_sub1_wrist(:,3),2,'MarkerEdgeColor','k','MarkerFaceColor','b');
hold on
p2=scatter3(exercise_sub2_wrist(:,1), exercise_sub2_wrist(:,2),exercise_sub2_wrist(:,3),2,'MarkerEdgeColor','k','MarkerFaceColor','r'); 
axis equal
xlabel('Horizontal plane [m]');
ylabel('Sagittal plane [m]');
zlabel('Frontal plane [m]');
legend([p1 p2],'With ExoNET','No ExoNET')
title('Free exploration - wrist motion in 3D space with respect to Kinect reference system')
hold off

%% Calculate velocity, acceleration and jerk

% wrist1_norm = cycle(exercise_sub1_wrist,time1,L1,precision);
% wrist2_norm = cycle(exercise_sub2_wrist,time2,L2,precision);

[vel_wrist1,acc_wrist1,jerk_wrist1]=calc_vel_acc_jerk(wrist1_norm(:,1),time1);
[vel_wrist2,acc_wrist2,jerk_wrist2]=calc_vel_acc_jerk(wrist2_norm(:,1),time2);
%[Rsquared,Rsquared_adj]= cod_comparison(vel_wrist1,vel_wrist2);

%% Plot velocity, acceleration, jerk in frontal plane in time

figure
subplot(2,1,1);
plot(time1(1:L1-1),vel_wrist1(:,1))
xlabel('Time [s]');
ylabel('Velocity [m/s]');
title('Wrist movement velocity frontal plane in time CONTROL')
subplot(2,1,2);
plot(time2(1:L2-1),vel_wrist2(:,1))
xlabel('Time [s]');
ylabel('Velocity [m/s]');
title('Wrist movement velocity frontal plane in time EXO')

figure
subplot(2,1,1);
plot(time1(1:L1-2),acc_wrist1(:,1))
xlabel('Time [s]');
ylabel('Acceleration [m/s^2]');
title('Wrist movement acceleration frontal plane in time CONTROL')
subplot(2,1,2);
plot(time2(1:L2-2),acc_wrist2(:,1))
xlabel('Time [s]');
ylabel('Acceleration [m/s^2]');
title('Wrist movement acceleration frontal plane in time EXO')

figure
subplot(2,1,1);
plot(time1(1:L1-3),jerk_wrist1(:,1))
xlabel('Time [s]');
ylabel('Jerk [m/s^3]');
title('Wrist movement jerk frontal plane in time CONTROL')
subplot(2,1,2);
plot(time2(1:L2-3),jerk_wrist2(:,1))
xlabel('Time [s]');
ylabel('Jerk [m/s^3]');
title('Wrist movement jerk frontal plane in time EXO')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% COMPARISON
%% See Pearson correlation and coefficient of determination between 2 activities

nBins=4;
[Rsquared,Rsquared_adj,pearson_corr,mov1,mov2]=find_Pcorr_and_COD(exercise_sub1_wrist, exercise_sub2_wrist, nBins, L1, L2);
fprintf('\n Pearson correlation is %d', pearson_corr);
fprintf('\n Coefficient of determination is %d', Rsquared);

%% Kullback-Leibler Divergence
% 
% temp_zeros = zeros(size(mov1,1),1);
% %mov1_Label = [mov1, temp_zeros];
% temp_ones = ones(size(mov2,1),1);
% %mov2_Label = [mov2, temp_ones];
% movForEntropy = cat(1, mov1, mov2);
% labelsForEntropy = cat(1, temp_zeros, temp_ones);
% labelsForEntropy_log=logical(labelsForEntropy);
% %writematrix(mov1,'mov1.csv')
% %writematrix(mov2,'mov2.csv')
% Z = relativeEntropy(movForEntropy,labelsForEntropy_log)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% JOINT ANGLES
%% Calculate elbow-shoulder, shoulder-spine, shoulder-hip, wrist-elbow segments and shoulder (A/A and F/E) elbow (F/E) angles

[joint_angles1]=calc_jointangles(exercise_sub1_wrist,exercise_sub1_elbow,exercise_sub1_shoulder,exercise_sub1_hip,exercise_sub1_spine);
[joint_angles2]=calc_jointangles(exercise_sub2_wrist,exercise_sub2_elbow,exercise_sub2_shoulder,exercise_sub2_hip,exercise_sub2_spine);

precision=0.1;
ja1= cycle(joint_angles1,time1,L1,precision);
ja2 = cycle(joint_angles2,time2,L2,precision);

%% Correlation between vel,acc,jerk of the two

figure
subplot(2,1,1);
plot(ja1(:,4),ja1(:,1))
xlabel('Cycle [%]');
ylabel('Adduction/abduction [degree]');
title('Shoulder adduction/abduction angles in time ')
subplot(2,1,2);
plot(ja2(:,4),ja2(:,1))
xlabel('Cycle [%]');
ylabel('Adduction/abduction [degree]');
title('Shoulder adduction/abduction angles in time ')

figure
subplot(2,1,1);
plot(ja1(:,4),ja1(:,2))
xlabel('Cycle [%]');
ylabel('Flexion/extension [degree]');
title('Shoulder flexion/extension angles in time ')
subplot(2,1,2);
plot(ja2(:,4),ja2(:,2))
xlabel('Cycle [%]');
ylabel('Flexion/extension [degree]');
title('Shoulder flexion/extension angles in time ')

figure
subplot(2,1,1);
plot(ja1(:,4),ja1(:,3))
xlabel('Cycle [%]');
ylabel('Flexion/extension [degree]');
title('Elbow flexion/extension angles in time ')
subplot(2,1,2);
plot(ja2(:,4),ja2(:,3))
xlabel('Cycle [%]');
ylabel('Flexion/extension [degree]');
title('Elbow flexion/extension angles in time ')

%% Correlation

nBins=4;
[ja_Rsquared,ja_Rsquared_adj,ja_correlation,ja1,ja2]=find_Pcorr_and_COD(joint_angles1,joint_angles2, nBins, L1, L2);
fprintf('\n Pearson correlation is %d', ja_correlation);
fprintf('\n Coefficient of determination is %d', ja_Rsquared);
