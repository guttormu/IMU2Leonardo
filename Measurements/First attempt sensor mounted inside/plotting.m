%Plotting raw data vs. filtered
temp = load('IMU1.mat');
imu1 = temp.ans;
temp = load('IMU1_raw.mat');
imu1_raw = temp.ans;
temp = load('IMU2.mat');
imu2 = temp.ans;
temp = load('IMU2_raw.mat');
imu2_raw = temp.ans;
temp = load('IMU3.mat');
imu3 = temp.ans;
temp = load('IMU3_raw.mat');
imu3_raw = temp.ans;
temp = load('IMU4.mat');
imu4 = temp.ans;
temp = load('IMU4_raw.mat');
imu4_raw = temp.ans;
fignum = 1;

for i = 1:4
    figure(fignum)
    name = sprintf('imu%i',i);
    raw = sprintf('imu%i_raw',i);
    eval(sprintf('subplot(3,1,1); plot(%s(1,:),%s(2,:),%s(1,:),%s(2,:));title(''Gyro X IMU%i'');', name, name, name, raw, i));
    eval(sprintf('subplot(3,1,2); plot(%s(1,:),%s(3,:),%s(1,:),%s(3,:));title(''Gyro Y IMU%i'');', name, name, name, raw, i));
    eval(sprintf('subplot(3,1,3); plot(%s(1,:),%s(4,:),%s(1,:),%s(4,:));title(''Gyro Z IMU%i'');', name, name, name, raw, i));
    fignum = fignum+1;
    figure(fignum)
    eval(sprintf('subplot(3,1,1); plot(%s(1,:),%s(5,:),%s(1,:),%s(5,:));title(''Accelerations X IMU%i'');', name, name, name, raw, i));
    eval(sprintf('subplot(3,1,2); plot(%s(1,:),%s(6,:),%s(1,:),%s(6,:));title(''Accelerations Y IMU%i'');', name, name, name, raw, i));
    eval(sprintf('subplot(3,1,3); plot(%s(1,:),%s(7,:),%s(1,:),%s(7,:));title(''Accelerations Z IMU%i'');', name, name, name, raw, i));
    fignum = fignum+1;
end

g = [];
for i = 1:450
    g(i) = sum([abs(imu1_raw(5,i))^2, abs(imu1_raw(6,i))^2, abs(imu1_raw(7,i))^2])^(1/2);
end
mean(g)
plot(g)