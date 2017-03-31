imu1 = load('IMU1_raw.mat');
imu2 = load('IMU2_raw.mat');
imu3 = load('IMU3_raw.mat');
imu4 = load('IMU4_raw.mat');
vec = [];
count = 1;
for i=1:length(imu1.ans(1,:))-1
    if isequal(imu1.ans(2:8,i), imu1.ans(2:8,i+1)) == 0
        vec(1,count) = imu1.ans(1,i+1);
        count = count + 1;
    end
end
count = 1;
for i=1:length(imu2.ans(1,:))-1
    if isequal(imu2.ans(2:8,i), imu2.ans(2:8,i+1)) == 0
        vec(2,count) = imu2.ans(1,i+1);
        count = count + 1;
    end
end
count = 1;
for i=1:length(imu3.ans(1,:))-1
    if isequal(imu3.ans(2:8,i), imu3.ans(2:8,i+1)) == 0
        vec(3,count) = imu3.ans(1,i+1);
        count = count + 1;
    end
end
count = 1;
for i=1:length(imu4.ans(1,:))-1
    if isequal(imu4.ans(2:8,i), imu4.ans(2:8,i+1)) == 0
        vec(4,count) = imu4.ans(1,i+1);
        count = count + 1;
    end
end