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
    eval(sprintf('subplot(3,2,1); plot(%s(1,:),%s(2,:),%s(1,:),%s(2,:));title(''Gyro X IMU%i'');', name, name, name, raw, i));
    eval(sprintf('subplot(3,2,3); plot(%s(1,:),%s(3,:),%s(1,:),%s(3,:));title(''Gyro Y IMU%i'');', name, name, name, raw, i));
    eval(sprintf('subplot(3,2,5); plot(%s(1,:),%s(4,:),%s(1,:),%s(4,:));title(''Gyro Z IMU%i'');', name, name, name, raw, i));
    eval(sprintf('subplot(3,2,2); plot(%s(1,:),%s(5,:),%s(1,:),%s(5,:));title(''Accelerations X IMU%i'');', name, name, name, raw, i));
    eval(sprintf('subplot(3,2,4); plot(%s(1,:),%s(6,:),%s(1,:),%s(6,:));title(''Accelerations Y IMU%i'');', name, name, name, raw, i));
    eval(sprintf('subplot(3,2,6); plot(%s(1,:),%s(7,:),%s(1,:),%s(7,:));title(''Accelerations Z IMU%i'');', name, name, name, raw, i));
    fignum = fignum+1;
end

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
filtered5 = [];
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


for i = 1:4
    figure(fignum)
    name = sprintf('imu%i',i);
    raw = sprintf('imu%i_raw',i);
    filt = sprintf('filtered%i',i);
    eval(sprintf('subplot(3,2,1); plot(%s(1,:),%s(2,:),%s(1,:),%s(1,:));title(''Gyro X IMU%i'');', name, raw, name, filt, i));
    eval(sprintf('subplot(3,2,3); plot(%s(1,:),%s(3,:),%s(1,:),%s(2,:));title(''Gyro Y IMU%i'');', name, raw, name, filt, i));
    eval(sprintf('subplot(3,2,5); plot(%s(1,:),%s(4,:),%s(1,:),%s(3,:));title(''Gyro Z IMU%i'');', name, raw, name, filt, i));
    eval(sprintf('subplot(3,2,2); plot(%s(1,:),%s(5,:),%s(1,:),%s(4,:));title(''Accelerations X IMU%i'');', name, raw, name, filt, i));
    eval(sprintf('subplot(3,2,4); plot(%s(1,:),%s(6,:),%s(1,:),%s(5,:));title(''Accelerations Y IMU%i'');', name, raw, name, filt, i));
    eval(sprintf('subplot(3,2,6); plot(%s(1,:),%s(7,:),%s(1,:),%s(6,:));title(''Accelerations Z IMU%i'');', name, raw, name, filt, i));
    fignum = fignum+1;
end
figure(fignum)
plot(imu1_raw(1,:),filtered1(6,:),imu1_raw(1,:),filtered4(6,:));
figure(fignum+1)
plot(imu1_raw(1,:),filtered2(6,:),imu1_raw(1,:),filtered3(6,:));


for i = 1:t
    p = patch(isosurface(f(:,:,:,i), 42)); % Where 42 is the isovalue
    isonormals(f(:,:,:,i), p)
    set(p, 'FaceColor', 'red', 'EdgeColor', 'none');
    daspect([1,1,1])
    view(3); axis tight
    camlight; lighting gouraud
    pause(0.1)
end