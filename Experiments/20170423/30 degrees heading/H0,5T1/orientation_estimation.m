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

%Measured position of each IMU relative center of gravity defined in Quali

l1 = [100, 200, 1];
l2 = [10, 20, 30];
l3 = [-50, 200, 1];
l4 = [80, 93, 54];

% H1 = Hmatrix(l1);
% H2 = Hmatrix(l2);
% H3 = Hmatrix(l3); 
% H4 = Hmatrix(l4);
% 
% S1 = Smtrx(l1);
% S2 = Smtrx(l2);
% S3 = Smtrx(l3);
% S4 = Smtrx(l4); 
% 
% G = [eye(3), -S1, H1; eye(3), -S2, H2; eye(3), -S3, H3; eye(3), -S4, H4];

%Estimation of angular rate, modeling a LTI system in Kalman Filter

omega = [];

for i = 1:5:(length(oqus)-rem(length(oqus),5))
    omega(i) = mean(oqus(5,i:i+4)/0.01);
end
figure()
plot(omega)

%State variable = [angle, ang_rate, ang_acc]'
A = eye(9);
A(1:3,4:6) = 0.01*eye(3);
A(1:3,7:9) = 1/2*0.01^2*eye(3);
A(4:6,7:9) = 0.01*eye(3);
C = [eye(3), zeros(3,6)];

x = zeros(9,1);
P = eye(9);

Q = blkdiag(10^-6*eye(6), 10^-3.5*eye(3));
R = 0.005*eye(3);

omega_hat = [];
lambda = 1;
tracern = [];

K = blkdiag(eye(3), zeros(6,6));

for i = 1:length(oqus)
    %Prediction
    x = A*x; %x_(k,k-1)=A*x_(k-1,k-1)
    P_prev = P; %P_(k-1,k-1)
    P = lambda*A*P*A'+Q; %P_(k,k-1)=A*P_(k-1,k-1)*..
    
    %Optimal forgetting factor
    M = C*A*P_prev*A'*C';
    N = C*P*C'-C*Q*C';
    lambda = max(1, trace(N*inv(M)));
    tracern(i) = trace(N*inv(M));
    
    %Kalman gain
    K = P*C'*inv(C*P*C'+R); %K_k = P_(k,k-1)
    
    %Update
    x = x + K*(oqus(5:7,i)-C*x); %x_(k,k) = x_(k,k-1)
    omega_hat(:,i) = x;
    P = (eye(9)-K*C)*P; %P_(k,k) = P_(k,k-1)
end
figure()
subplot(3,1,1);plot(omega_hat(1,:));hold on;plot(oqus(5,:));
subplot(3,1,2);plot(omega_hat(2,:));hold on;plot(oqus(6,:));
subplot(3,1,3);plot(omega_hat(3,:));hold on;plot(oqus(7,:));

%Estimating velocity using Taylor Series Expansion, v=[vk, vb0, vb1..]'
v = zeros(6,length(oqus));

T = 0.01;

for i = 3:2:length(oqus)-1
    vb0 = (oqus(5,i)-oqus(5,i-2))/T;
    vb1 = (v(2,i)-v(2,i-2))/T;
    vb2 = (v(3,i)-v(3,i-2))/T;
    vb3 = (v(4,i)-v(4,i-2))/T;
    vb4 = (v(5,i)-v(5,i-2))/T;
    vk = vb0 + vb1*T + 1/2*vb2*T^2 + 1/6*vb3*T^3 + 1/24*vb4*T^4;
    v(1:6,i) = [vk; vb0; vb1; vb2; vb3; vb4];
end
figure()
plot(v(1,:))


%Translating all accelerations to CO
%State vector x = [p, v, g, b, w, b]' according to Kjerstad

%Initial states
p0 = Smtrx(omega_hat(1:3,100))*oqus(2:4,1);
x = [po, zeros(1,15)]';
P = eye(18);

%Selection matrices
B1 = [eye(3), zeros(3,9)];
B2 = [zeros(3,3), eye(3), zeros(3,6)];

j = 1;          %Counter for oqus measurements
for i = 1:length(imu1_raw)
    a_m = [imu1_raw(5:7,i); imu2_raw(5:7,i); imu3_raw(5:7,i); imu4_raw(5:7,i)];
    while imu1_raw(1,i) ~= oqus(1,j)
        j = j+1;
    end
    %System matrix
    A = [-Smtrx(omega_hat(4:6,j)), eye(3), zeros(3,12);...
        zeros(3,3), -Smtrx(omega_hat(4:6,j)), -eye(3), -eye(3), zeros(3,6);...
        zeros(3,6), -Smtrx(omega_hat(4:6,j)), zeros(3,9);...
        zeros(3,18); zeros(3,15), eye(3); zeros(3,18)];
    %Gain matrix
    B = [zeros(3,12); B1; zeros(6,12); B2; zeros(3,12)]*inv(G);
end