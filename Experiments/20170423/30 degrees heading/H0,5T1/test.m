%Calculates the orientation of each sensor
temp = load('IMU1_raw.mat');
imu1_raw = temp.ans;
temp = load('IMU2_raw.mat');
imu2_raw = temp.ans;
temp = load('IMU3_raw.mat');
imu3_raw = temp.ans;
temp = load('IMU4_raw.mat');
imu4_raw = temp.ans;
temp = load('oqus_measured.mat');
oqus = temp.ans;
load('rotation_matrix.mat')

old1 = imu1_raw;
old2 = imu2_raw;
old3 = imu3_raw;
old4 = imu4_raw;

imu1_raw(5:7,:) = -1.*imu1_raw(5:7,:);
imu2_raw(5:7,:) = -1.*imu2_raw(5:7,:);
imu3_raw(5:7,:) = -1.*imu3_raw(5:7,:);
imu4_raw(5:7,:) = -1.*imu4_raw(5:7,:);

imu1_raw(2:7,:) = Rot.imu1*imu1_raw(2:7,:);
imu2_raw(2:7,:) = Rot.imu2*imu2_raw(2:7,:);
imu3_raw(2:7,:) = Rot.imu3*imu3_raw(2:7,:);
imu4_raw(2:7,:) = Rot.imu4*imu4_raw(2:7,:);

for i = 1:4
    figure(i)
    eval(sprintf('subplot(3,2,1); plot(old%i(2,:)); hold on; plot(imu%i_raw(2,:));',i,i))
    eval(sprintf('subplot(3,2,3); plot(old%i(3,:)); hold on; plot(imu%i_raw(3,:));',i,i))
    eval(sprintf('subplot(3,2,5); plot(old%i(4,:)); hold on; plot(imu%i_raw(4,:));',i,i))
    eval(sprintf('subplot(3,2,2); plot(old%i(5,:)); hold on; plot(imu%i_raw(5,:));',i,i))
    eval(sprintf('subplot(3,2,4); plot(old%i(6,:)); hold on; plot(imu%i_raw(6,:));',i,i))
    eval(sprintf('subplot(3,2,6); plot(old%i(7,:)); hold on; plot(imu%i_raw(7,:));',i,i))
end