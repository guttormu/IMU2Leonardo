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
    eval(sprintf('subplot(3,1,1); plot(%s(1,:),%s(2,:),%s(1,:),%s(2,:));', name, name, name, raw));
    eval(sprintf('subplot(3,1,2); plot(%s(1,:),%s(3,:),%s(1,:),%s(3,:));', name, name, name, raw));
    eval(sprintf('subplot(3,1,3); plot(%s(1,:),%s(4,:),%s(1,:),%s(4,:));', name, name, name, raw));
    fignum = fignum+1;
    figure(fignum)
    eval(sprintf('subplot(3,1,1); plot(%s(1,:),%s(8,:),%s(1,:),%s(5,:));', name, name, name, raw));
    eval(sprintf('subplot(3,1,2); plot(%s(1,:),%s(9,:),%s(1,:),%s(6,:));', name, name, name, raw));
    eval(sprintf('subplot(3,1,3); plot(%s(1,:),%s(10,:),%s(1,:),%s(7,:));', name, name, name, raw));
    fignum = fignum+1;
end
    