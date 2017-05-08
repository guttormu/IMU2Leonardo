clear all

%Open data files
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

imu1_raw(:,1:350) = [];

%Transforming linear coordinate system to right-hand oriented
imu1_raw(5:7,:) = -1.*imu1_raw(5:7,:);
imu2_raw(5:7,:) = -1.*imu2_raw(5:7,:);
imu3_raw(5:7,:) = -1.*imu3_raw(5:7,:);
imu4_raw(5:7,:) = -1.*imu4_raw(5:7,:);

%Translating all oqus angles from degrees to radians
oqus(5:7,:) = deg2rad(oqus(5:7,:));

%Translating all positions to coordinate system parallel to NED, with
%origin coinciding with CO
oqus(2:4) = -1.*oqus(2:4);

%Rotating all accelerations to coordinate frame parallel to body
imu1_raw(2:7,:) = Rot.imu1*imu1_raw(2:7,:);
imu2_raw(2:7,:) = Rot.imu2*imu2_raw(2:7,:);
imu3_raw(2:7,:) = Rot.imu3*imu3_raw(2:7,:);
imu4_raw(2:7,:) = Rot.imu4*imu4_raw(2:7,:);

%Estimating true angular rate from Qualisys measurements
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

K = blkdiag(eye(3), zeros(6,6));

for i = 1:length(oqus)
    %Prediction
    x = A*x; %x_(k,k-1)=A*x_(k-1,k-1)
    P_prev = P; %P_(k-1,k-1)
    P = 1.2*A*P*A'+Q; %P_(k,k-1)=A*P_(k-1,k-1)*..
    
    %Kalman gain
    K = P*C'*inv(C*P*C'+R); %K_k = P_(k,k-1)
    
    %Update
    x = x + K*(oqus(5:7,i)-C*x); %x_(k,k) = x_(k,k-1)
    omega_hat(:,i) = x;
    P = (eye(9)-K*C)*P; %P_(k,k) = P_(k,k-1)
end

%Initial states
p0 = Rzyx(omega_hat(1,20), omega_hat(2,20), omega_hat(3,20))'*oqus(2:4,1);
x = [p0; zeros(5,1); -1000];
P = eye(9);

%Constant system matrices
B = [zeros(3,3); eye(3); zeros(3,3)];
C = [eye(3), zeros(3,6)];

%Covariance matrices for Kalman Filter
Q = 10^-4*blkdiag(zeros(3,3),eye(3),zeros(3,3));
R = 10^-3*eye(3);

%Acceleration output
accel_hat = [];
z = [];
y = [];

j = 1;          %Counter for oqus measurements
for i = 1:length(imu1_raw)
    a_m = [imu1_raw(5:7,i)];
    while imu1_raw(1,i) ~= oqus(1,j) %Finding corresponding oqus measurement
        j = j+1;
    end
    
    %System matrix
    A = [-Smtrx(omega_hat(4:6,j)), eye(3), zeros(3,3);...
        zeros(3,3), -Smtrx(omega_hat(4:6,j)), -eye(3);...
        zeros(3,6), -Smtrx(omega_hat(4:6,j))];
    
    z(:,i) = a_m;
    
    %Discretization manually
    disc = 0.05.*[A, B; zeros(3,12)];
    disc_exp = expm(disc);
    A_disc = disc_exp(1:9,1:9);
    B_disc = disc_exp(1:9, 10:12);
    
    K = P*C'*inv(C*P*C'+R);
    y(:,i) = [Rzyx(oqus(5,j),oqus(6,j),oqus(7,j))'*oqus(2:4,j)];
    x = x+K*(y(:,i) - C*x);
    accel_hat(:,i) = A*x+B*a_m;
    P = (eye(9)-K*C)*P*(eye(9)-K*C)'+K*R*K';
    %Predicting next state
    x = A_disc*x + B_disc*a_m;
    P = A_disc*P*A_disc'+Q;
end 
