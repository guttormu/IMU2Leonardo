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
load('rotation_matrix');

%Transforming linear coordinate system to right-hand oriented
imu1_raw(5:7,:) = -1.*imu1_raw(5:7,:);
imu2_raw(5:7,:) = -1.*imu2_raw(5:7,:);
imu3_raw(5:7,:) = -1.*imu3_raw(5:7,:);
imu4_raw(5:7,:) = -1.*imu4_raw(5:7,:);

%Translating all oqus angles from degrees to radians
oqus(5:7,:) = deg2rad(oqus(5:7,:));

p = [];

for i = 1:length(oqus(1,:))
    p(:,i) = Rzyx(oqus(5,i),oqus(6,i),oqus(7,i))'*oqus(2:4,i);
end

drift = p(1,:)';
Fs = 100;
t = imu1_raw(1,:)';

%load(fullfile(matlabroot,'examples','signal','earthquake.mat'))

Nf = 6;
Fpass = 10;
Fstop = 15;

d = designfilt('differentiatorfir','FilterOrder',Nf, ...
    'PassbandFrequency',Fpass,'StopbandFrequency',Fstop, ...
    'SampleRate',Fs);

dt = t(2)-t(1);

vdrift = filter(d,drift)/dt;

delay = mean(grpdelay(d));

tt = t(1:end-delay);
vd = vdrift;
vd(1:delay) = [];

tt(1:delay) = [];
vd(1:delay) = [];

[pkp,lcp] = findpeaks(drift);
zcp = zeros(size(lcp));

[pkm,lcm] = findpeaks(-drift);
zcm = zeros(size(lcm));

subplot(2,1,1)
plot(t,drift,t([lcp lcm]),[pkp -pkm],'or')
xlabel('Time (s)')
ylabel('Displacement (cm)')
grid

subplot(2,1,2)
plot(tt,vd,t([lcp lcm]),[zcp zcm],'or')
xlabel('Time (s)')
ylabel('Speed (cm/s)')
grid