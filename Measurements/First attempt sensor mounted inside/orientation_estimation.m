%Calculates the orientation of each sensor
temp = load('IMU1_raw.mat');
imu1_raw = temp.ans;
temp = load('IMU2_raw.mat');
imu2_raw = temp.ans;
temp = load('IMU3_raw.mat');
imu3_raw = temp.ans;
temp = load('IMU4_raw.mat');
imu4_raw = temp.ans;

%Orientation vector, roll in 1st row, pitch in 2nd row, yaw in 3rd row
orientation = [];

%Roll angle based on average measurements without movement
avg_imu = [mean(imu1_raw(5,1:495)), mean(imu2_raw(5,1:495)), mean(imu3_raw(5,1:495)), mean(imu4_raw(5,1:495)); ...
    mean(imu1_raw(6,1:495)), mean(imu2_raw(6,1:495)), mean(imu3_raw(6,1:495)), mean(imu4_raw(6,1:495)); ...
    mean(imu1_raw(7,1:495)), mean(imu2_raw(7,1:495)), mean(imu3_raw(7,1:495)), mean(imu4_raw(7,1:495))];
orientation(1,:) = [atan2(avg_imu(2,1),avg_imu(3,1)), atan2(avg_imu(2,2),avg_imu(3,2)), ...
    atan2(avg_imu(2,3),avg_imu(3,3)), atan2(avg_imu(2,4),avg_imu(3,4))];
orientation(2,:) = [asin(-avg_imu(1,1)/(avg_imu(:,1)'*avg_imu(:,1))^(1/2)), asin(-avg_imu(1,2)/(avg_imu(:,2)'*avg_imu(:,2))^(1/2)), ...
    asin(-avg_imu(1,3)/(avg_imu(:,3)'*avg_imu(:,3))^(1/2)), asin(-avg_imu(1,4)/(avg_imu(:,4)'*avg_imu(:,4))^(1/2))];
orientation(3,:) = [0, pi(), 0, pi()];

%Assuming yaw angle is close to 0 or 180 degrees offset from ship yaw, the
%rotation matrix is set to
R1 = zeros(3,3);
R2 = zeros(3,3);
R3 = zeros(3,3);
R4 = zeros(3,3);
J1 = zeros(3,3);
J2 = J1;
J3 = J2;
J4 = J3;


for i = 1:4
    eval(sprintf('R%i = [cos(orientation(3,i))*cos(orientation(2,i)), -sin(orientation(3,i))*cos(orientation(2,i))+cos(orientation(3,i))*sin(orientation(2,i))*sin(orientation(1,i)), sin(orientation(3,i))*sin(orientation(1,i))+cos(orientation(3,i))*cos(orientation(1,i))*sin(orientation(2,i)); sin(orientation(3,i))*cos(orientation(2,i)), cos(orientation(3,i))*cos(orientation(1,i))+sin(orientation(3,i))*sin(orientation(2,i))*sin(orientation(1,i)), -cos(orientation(3,i))*sin(orientation(1,i))+sin(orientation(2,i))*sin(orientation(3,i))*cos(orientation(1,i));-sin(orientation(2,i)), cos(orientation(2,i))*sin(orientation(1,i)), cos(orientation(1,i))*cos(orientation(2,i))];',i));
    eval(sprintf('J%i = [1, sin(orientation(1,i))*tan(orientation(2,i)), cos(orientation(1,i))*tan(orientation(2,i)); 0, cos(orientation(1,i)), -sin(orientation(1,i)); 0, sin(orientation(1,i))/cos(orientation(2,i)), cos(orientation(1,i))/cos(orientation(2,i))];',i));
end

Rot1 = blkdiag(J1, R1);
Rot2 = blkdiag(J2, R2);
Rot3 = blkdiag(J3, R3);
Rot4 = blkdiag(J4, R4);

Rot = struct('imu1', Rot1, 'imu2', Rot2, 'imu3', Rot3, 'imu4', Rot4);

for i = 1:4
    eval(sprintf('r = J%i*imu%i_raw(2:4,1:1000);',i,i));
    eval(sprintf('a = R%i*imu%i_raw(5:7,1:1000);',i,i));
    figure(i)
    eval(sprintf('subplot(3,2,1); plot(r(1,:)); hold on; plot(imu%i_raw(2,1:1000));',i))
    eval(sprintf('subplot(3,2,3); plot(r(2,:)); hold on; plot(imu%i_raw(3,1:1000));',i))
    eval(sprintf('subplot(3,2,5); plot(r(3,:)); hold on; plot(imu%i_raw(4,1:1000));',i))
    eval(sprintf('subplot(3,2,2); plot(a(1,:)); hold on; plot(imu%i_raw(5,1:1000));',i))
    eval(sprintf('subplot(3,2,4); plot(a(2,:)); hold on; plot(imu%i_raw(6,1:1000));',i))
    eval(sprintf('subplot(3,2,6); plot(a(3,:)); hold on; plot(imu%i_raw(7,1:1000));',i))
end

