%Calculates the orientation of each sensor

temp = load('IMU1_raw.mat');
imu1_raw = temp.ans;
temp = load('IMU2_raw.mat');
imu2_raw = temp.ans;
temp = load('IMU3_raw.mat');
imu3_raw = temp.ans;
temp = load('IMU4_raw.mat');
imu4_raw = temp.ans;

%Orientation vector, roll in 1st row, pitch in 2nd row
orientation = [];

%Roll angle based on average measurements without movement
avg_imu = [mean(imu1_raw(5,1:495)), mean(imu2_raw(5,1:495)), mean(imu3_raw(5,1:495)), mean(imu4_raw(5,1:495)); ...
    mean(imu1_raw(6,1:495)), mean(imu2_raw(6,1:495)), mean(imu3_raw(6,1:495)), mean(imu4_raw(6,1:495)); ...
    mean(imu1_raw(7,1:495)), mean(imu2_raw(7,1:495)), mean(imu3_raw(7,1:495)), mean(imu4_raw(7,1:495))];
orientation(1,:) = [atan(avg_imu(2,1)/avg_imu(3,1)), atan(avg_imu(2,2)/avg_imu(3,2)), ...
    atan(avg_imu(2,3)/avg_imu(3,3)), atan(avg_imu(2,4)/avg_imu(3,4))];
orientation(2,:) = [asin(-avg_imu(1,1)/(avg_imu(:,1)'*avg_imu(:,1))^(1/2)), asin(-avg_imu(1,2)/(avg_imu(:,2)'*avg_imu(:,2))^(1/2)), ...
    asin(-avg_imu(1,3)/(avg_imu(:,3)'*avg_imu(:,3))^(1/2)), asin(-avg_imu(1,4)/(avg_imu(:,4)'*avg_imu(:,4))^(1/2))];
