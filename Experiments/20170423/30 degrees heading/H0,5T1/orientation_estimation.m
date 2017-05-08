%Calculates the orientation of each sensor
temp = load('IMU1_raw.mat');
imu1_raw = temp.ans;
temp = load('IMU2_raw.mat');
imu2_raw = temp.ans;
temp = load('IMU3_raw.mat');
imu3_raw = temp.ans;
temp = load('IMU4_raw.mat');
imu4_raw = temp.ans;

old1 = imu1_raw;
old2 = imu2_raw;
old3 = imu3_raw;
old4 = imu4_raw;

imu1_raw(5:7,:) = -1.*imu1_raw(5:7,:);
imu2_raw(5:7,:) = -1.*imu2_raw(5:7,:);
imu3_raw(5:7,:) = -1.*imu3_raw(5:7,:);
imu4_raw(5:7,:) = -1.*imu4_raw(5:7,:);

%Orientation vector, roll in 1st row, pitch in 2nd row, yaw in 3rd row
orientation = [];

%Rotating according to mounted orientation vs. body frame
init_orientation = [-pi/2, -pi/2, pi, pi;...
                    0, 0, 0, 0;...
                    0, pi, pi, 0];
                
%Assuming yaw angle is close to 0 or 180 degrees offset from ship yaw, the
%rotation matrix is set to
[J1, R1, T1] = eulerang(init_orientation(1,1), init_orientation(2,1), init_orientation(3,1));
[J2, R2, T2] = eulerang(init_orientation(1,2), init_orientation(2,2), init_orientation(3,2));
[J3, R3, T3] = eulerang(init_orientation(1,3), init_orientation(2,3), init_orientation(3,3));
[J4, R4, T4] = eulerang(init_orientation(1,4), init_orientation(2,4), init_orientation(3,4));

for i = 1:4
    eval(sprintf('imu%i_raw(2:4,:) = T%i*imu%i_raw(2:4,:);',i,i,i));
    eval(sprintf('imu%i_raw(5:7,:) = R%i*imu%i_raw(5:7,:);',i,i,i));
end

%Roll angle based on average measurements without movement
stop = 300;
avg_imu = [mean(imu1_raw(5,1:stop)), mean(imu2_raw(5,1:stop)), mean(imu3_raw(5,1:stop)), mean(imu4_raw(5,1:stop)); ...
    mean(imu1_raw(6,1:stop)), mean(imu2_raw(6,1:stop)), mean(imu3_raw(6,1:stop)), mean(imu4_raw(6,1:stop)); ...
    mean(imu1_raw(7,1:stop)), mean(imu2_raw(7,1:stop)), mean(imu3_raw(7,1:stop)), mean(imu4_raw(7,1:stop))];
orientation(1,:) = [atan(avg_imu(2,1)/avg_imu(3,1)), atan(avg_imu(2,2)/avg_imu(3,2)), ...
    atan(avg_imu(2,3)/avg_imu(3,3)), atan(avg_imu(2,4)/avg_imu(3,4))];
orientation(2,:) = [asin(avg_imu(1,1)/(avg_imu(:,1)'*avg_imu(:,1))^(1/2)), asin(avg_imu(1,2)/(avg_imu(:,2)'*avg_imu(:,2))^(1/2)), ...
    asin(avg_imu(1,3)/(avg_imu(:,3)'*avg_imu(:,3))^(1/2)), asin(avg_imu(1,4)/(avg_imu(:,4)'*avg_imu(:,4))^(1/2))];
orientation(3,:) = [0, 0, 0, 0];

%Assuming yaw angle is close to 0 or 180 degrees offset from ship yaw, the
%rotation matrix is set to
[J1, R11, T11] = eulerang(orientation(1,1), orientation(2,1), orientation(3,1));
[J2, R22, T22] = eulerang(orientation(1,2), orientation(2,2), orientation(3,2));
[J3, R33, T33] = eulerang(orientation(1,3), orientation(2,3), orientation(3,3));
[J4, R44, T44] = eulerang(orientation(1,4), orientation(2,4), orientation(3,4));

Rot1 = blkdiag(T11*T1, R11*R1);
Rot2 = blkdiag(T22*T2, R22*R2);
Rot3 = blkdiag(T33*T3, R33*R3);
Rot4 = blkdiag(T44*T4, R44*R4);

Rot = struct('imu1', Rot1, 'imu2', Rot2, 'imu3', Rot3, 'imu4', Rot4);

for i = 1:4
    eval(sprintf('r = T%i%i*imu%i_raw(2:4,:);',i,i,i));
    eval(sprintf('a = R%i%i*imu%i_raw(5:7,:);',i,i,i));
    figure(4+i)
    eval(sprintf('subplot(3,2,1); plot(old1(1,:),r(1,:), old1(1,:), old%i(2,:)); legend(''Rotated'',''Raw''); title(''Gyro X'');',i))
    eval(sprintf('subplot(3,2,3); plot(old1(1,:),r(2,:), old1(1,:), old%i(3,:)); legend(''Rotated'',''Raw''); title(''Gyro Y'');',i))
    eval(sprintf('subplot(3,2,5); plot(old1(1,:),r(3,:), old1(1,:), old%i(4,:)); legend(''Rotated'',''Raw''); title(''Gyro Z'');',i))
    eval(sprintf('subplot(3,2,2); plot(old1(1,:),a(1,:), old1(1,:), old%i(5,:)); legend(''Rotated'',''Raw''); title(''Accelerations X'');',i))
    eval(sprintf('subplot(3,2,4); plot(old1(1,:),a(2,:), old1(1,:), old%i(6,:)); legend(''Rotated'',''Raw''); title(''Accelerations Y'');',i))
    eval(sprintf('subplot(3,2,6); plot(old1(1,:),a(3,:), old1(1,:), old%i(7,:)); legend(''Rotated'',''Raw''); title(''Accelerations Z'');',i))
end

