clear all

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

%Loading raw data to new variables for comparison plot
old1 = imu1_raw;
old2 = imu2_raw;
old3 = imu3_raw;
old4 = imu4_raw;

%Transforming linear coordinate system to right-hand oriented
imu1_raw(5:7,:) = -1.*imu1_raw(5:7,:);
imu2_raw(5:7,:) = -1.*imu2_raw(5:7,:);
imu3_raw(5:7,:) = -1.*imu3_raw(5:7,:);
imu4_raw(5:7,:) = -1.*imu4_raw(5:7,:);

%Translating all oqus angles from degrees to radians
oqus(5:7,:) = deg2rad(oqus(5:7,:));

%Estimation of angular rate, modeling a LTI system in Kalman Filter
omega = [];

%LPP approach with mean value sampling rate of 20Hz
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
    P = 1.2*A*P*A'+Q; %P_(k,k-1)=A*P_(k-1,k-1)*..
    
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
subplot(3,2,1);plot(oqus(1,:), rad2deg(omega_hat(1,:)), oqus(1,:), rad2deg(oqus(5,:)));legend('Estimated \phi','True \phi');
subplot(3,2,3);plot(oqus(1,:), rad2deg(omega_hat(2,:)), oqus(1,:), rad2deg(oqus(6,:)));legend('Estimated \theta','True \theta');
subplot(3,2,5);plot(oqus(1,:), rad2deg(omega_hat(3,:)), oqus(1,:), rad2deg(oqus(7,:)));legend('Estimated \psi','True \psi');
subplot(3,2,2);plot(oqus(1,:), rad2deg(omega_hat(4,:))); legend('Estimated p');
subplot(3,2,4);plot(oqus(1,:), rad2deg(omega_hat(5,:))); legend('Estimated q');
subplot(3,2,6);plot(oqus(1,:), rad2deg(omega_hat(6,:))); legend('Estimated r');

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
%State vector x = [p_v, v, g, b_l, w, b_w]' according to Kjerstad

%Rotating all accelerations to coordinate frame parallel to body
imu1_raw(2:7,:) = Rot.imu1*imu1_raw(2:7,:);
imu2_raw(2:7,:) = Rot.imu2*imu2_raw(2:7,:);
imu3_raw(2:7,:) = Rot.imu3*imu3_raw(2:7,:);
imu4_raw(2:7,:) = Rot.imu4*imu4_raw(2:7,:);

%Measured position of each IMU relative CO defined in Quali
l1 = [-465, -184, -73];
l2 = [-244, 184, -13];
l3 = [740, 130, 82];
l4 = [450, -160, 82];

H1 = Hmatrix(l1);
H2 = Hmatrix(l2);
H3 = Hmatrix(l3); 
H4 = Hmatrix(l4);

S1 = Smtrx(l1);
S2 = Smtrx(l2);
S3 = Smtrx(l3);
S4 = Smtrx(l4);

G = [eye(3), -S1, H1; eye(3), -S2, H2; eye(3), -S3, H3; eye(3), -S4, H4];

%Initial states
p0 = Rzyx(omega_hat(1,20), omega_hat(2,20), omega_hat(3,20))'*oqus(2:4,1);
x = [p0; zeros(15,1)];
P = eye(18);

%Selection matrices
B1 = [eye(3), zeros(3,9)];
B2 = [zeros(3,3), eye(3), zeros(3,6)];

C = [eye(3), zeros(3,15); zeros(3,12), eye(3), zeros(3,3)];

%Covariance matrices for Kalman Filter
Q = 10^-5*blkdiag(zeros(3,3),eye(3),zeros(6,6),eye(3),zeros(3,3));
R = 10^-3*eye(6);

%Acceleration output
accel_hat = [];
z = [];
y = [];

j = 1;          %Counter for oqus measurements
for i = 1:length(imu1_raw)
    a_m = [imu1_raw(5:7,i); imu2_raw(5:7,i); imu3_raw(5:7,i); imu4_raw(5:7,i)];
    while imu1_raw(1,i) ~= oqus(1,j) %Finding corresponding oqus measurement
        j = j+1;
    end
    
    %System matrix
    A = [-Smtrx(omega_hat(4:6,j)), eye(3), zeros(3,12);...
        zeros(3,3), -Smtrx(omega_hat(4:6,j)), -eye(3), -eye(3), zeros(3,6);...
        zeros(3,6), -Smtrx(omega_hat(4:6,j)), zeros(3,9);...
        zeros(3,18); zeros(3,15), eye(3); zeros(3,18)];
    %Gain matrix
    BG = [zeros(3,12); B1; zeros(6,12); B2; zeros(3,12)]*inv(G);
    
    z(:,i) = inv(G)*a_m;
    
    %Discretization manually
    disc = 0.05.*[A, BG; zeros(12,30)];
    disc_exp = expm(disc);
    A_disc = disc_exp(1:18,1:18);
    B_disc = disc_exp(1:18, 19:30);
    
    %sysc = ss(A, BG, C, D, 0.05);
    %sysd = c2d(sysc, 0.05);
    
    K = P*C'*inv(C*P*C'+R);
    y(:,i) = [Rzyx(omega_hat(1,j),omega_hat(2,j),omega_hat(3,j))'*oqus(2:4,j);omega_hat(4:6,j)];
    x = x+K*(y(:,i) - C*x);
    accel_hat(:,i) = x;
    P = (eye(18)-K*C)*P*(eye(18)-K*C)'+K*R*K';
    %Predicting next state
    x = A_disc*x + B_disc*a_m;
    P = A_disc*P*A_disc'+Q;
end

%Plotting results
figure()
subplot(3,1,1); plot(imu1_raw(1,:),accel_hat(1,:), imu1_raw(1,:), y(1,:)); legend('Estimated x', 'True x');
subplot(3,1,2); plot(imu1_raw(1,:),accel_hat(2,:), imu1_raw(1,:), y(2,:)); legend('Estimated y', 'True y');
subplot(3,1,3); plot(imu1_raw(1,:),accel_hat(3,:), imu1_raw(1,:), y(3,:)); legend('Estimated z', 'True z');

figure()
subplot(3,1,1); plot(imu1_raw(1,:), accel_hat(4,:));title('Velocities');
subplot(3,1,2); plot(imu1_raw(1,:), accel_hat(5,:));
subplot(3,1,3); plot(imu1_raw(1,:), accel_hat(6,:));

figure()
subplot(3,1,1); plot(imu1_raw(1,:),accel_hat(7,:));title('Gravity');
subplot(3,1,2); plot(imu1_raw(1,:),accel_hat(8,:));
subplot(3,1,3); plot(imu1_raw(1,:),accel_hat(9,:));

figure()
subplot(3,1,1); plot(imu1_raw(1,:), accel_hat(10,:)); title('linear bias');
subplot(3,1,2); plot(imu1_raw(1,:), accel_hat(11,:)); 
subplot(3,1,3); plot(imu1_raw(1,:), accel_hat(12,:));

figure()
subplot(3,1,1); plot(imu1_raw(1,:), accel_hat(13,:)); title('Angular rate');
subplot(3,1,2); plot(imu1_raw(1,:), accel_hat(14,:));
subplot(3,1,3); plot(imu1_raw(1,:), accel_hat(15,:));

figure()
subplot(3,1,1); plot(imu1_raw(1,:), accel_hat(16,:)); title('rotational bias');
subplot(3,1,2); plot(imu1_raw(1,:), accel_hat(17,:)); 
subplot(3,1,3); plot(imu1_raw(1,:), accel_hat(18,:));

%Estimating accelerations in CO based on position measurements
%State variable = [position, velocity, acceleration]'
A = eye(9);
A(1:3,4:6) = 0.01*eye(3);
A(1:3,7:9) = 1/2*0.01^2*eye(3);
A(4:6,7:9) = 0.01*eye(3);
C = [eye(3), zeros(3,6)];

x = [Rzyx(omega_hat(1,i),omega_hat(2,i),omega_hat(3,i))'*oqus(2:4,i);zeros(6,1)];
P = eye(9);

Q = blkdiag(10^-6*eye(6), 10^-3.5*eye(3));
R = 0.05*eye(3);

p_hat = [];
p_v = [];
K = zeros(9,9);

for i = 1:length(oqus)
    %Prediction
    x = A*x; %x_(k,k-1)=A*x_(k-1,k-1)
    P_prev = P; %P_(k-1,k-1)
    P = 1.2*A*P*A'+Q; %P_(k,k-1)=A*P_(k-1,k-1)*..
    
    %Kalman gain
    K = P*C'*inv(C*P*C'+R); %K_k = P_(k,k-1)
    
    %Position in body-frame
    p_v(:,i) = Rzyx(omega_hat(1,i),omega_hat(2,i),omega_hat(3,i))'*oqus(2:4,i);
    
    %Update
    x = x + K*(p_v(:,i)-C*x); %x_(k,k) = x_(k,k-1)
    p_hat(:,i) = x;
    P = (eye(9)-K*C)*P; %P_(k,k) = P_(k,k-1)
end
figure()
subplot(3,2,1);plot(oqus(1,:), p_hat(1,:), oqus(1,:), p_v(1,:));legend('Estimated x','True x');
subplot(3,2,3);plot(oqus(1,:), p_hat(2,:), oqus(1,:), p_v(2,:));legend('Estimated \theta','True \theta');
subplot(3,2,5);plot(oqus(1,:), p_hat(3,:), oqus(1,:), p_v(3,:));legend('Estimated \psi','True \psi');
subplot(3,2,2);plot(oqus(1,:), p_hat(4,:)); legend('Estimated u');
subplot(3,2,4);plot(oqus(1,:), p_hat(5,:)); legend('Estimated v');
subplot(3,2,6);plot(oqus(1,:), p_hat(6,:)); legend('Estimated w');
figure()
subplot(3,1,1);plot(oqus(1,:), p_hat(7,:)); legend('Estimated a_x');
subplot(3,1,2);plot(oqus(1,:), p_hat(8,:)); legend('Estimated a_y');
subplot(3,1,3);plot(oqus(1,:), p_hat(9,:)); legend('Estimated a_z');