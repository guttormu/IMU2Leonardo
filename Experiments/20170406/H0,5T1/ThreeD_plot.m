%Visualization of hull accelerations as function of time

temp = load('IMU1_raw.mat');
imu1_raw = temp.ans;
temp = load('IMU2_raw.mat');
imu2_raw = temp.ans;
temp = load('IMU3_raw.mat');
imu3_raw = temp.ans;
temp = load('IMU4_raw.mat');
imu4_raw = temp.ans;

%Rotating according to initial orientation of IMU
load('rotation_matrix.mat');
imu1_raw(2:7,:) = Rot.imu1*imu1_raw(2:7,:);
imu2_raw(2:7,:) = Rot.imu2*imu2_raw(2:7,:);
imu3_raw(2:7,:) = Rot.imu3*imu3_raw(2:7,:);
imu4_raw(2:7,:) = Rot.imu4*imu4_raw(2:7,:);

%Filtering with "Moving Average",
filtered1 = [];
filtered2 = [];
filtered3 = [];
filtered4 = [];
a = 1;
b = [1/3 1/3 1/3];
for i = 1:4
    raw = sprintf('imu%i_raw',i);
    filt = sprintf('filtered%i',i);
    eval(sprintf('%s(1,:) = filter(b,a,%s(2,:));', filt, raw));
    eval(sprintf('%s(2,:) = filter(b,a,%s(3,:));', filt, raw));
    eval(sprintf('%s(3,:) = filter(b,a,%s(4,:));', filt, raw));
    eval(sprintf('%s(4,:) = filter(b,a,%s(5,:));', filt, raw));
    eval(sprintf('%s(5,:) = filter(b,a,%s(6,:));', filt, raw));
    eval(sprintf('%s(6,:) = filter(b,a,%s(7,:));', filt, raw));
end

i = 1;
for t=0:0.01:imu1_raw(1,length(imu1_raw))
     if t == imu1_raw(1,i)
        [x, y] = meshgrid([0, 10],[0, 4]);
        z = [filtered2(6,i), filtered3(6,i); filtered1(6,i), filtered4(6,i)];
        i = i+1;
        c = [1 1; 1 1];
        surf(x,y,z,c)
        axis([-1 11 -1 5 900 1100]);
     end
    pause(0.01)
end