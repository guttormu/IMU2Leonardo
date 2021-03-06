%Check time synchronization between IMU's

temp = load('IMU1_raw.mat');
imu1_raw = temp.ans(:,515:594);
temp = load('IMU2_raw.mat');
imu2_raw = temp.ans(:,515:594);
temp = load('IMU3_raw.mat');
imu3_raw = temp.ans(:,515:594);
temp = load('IMU4_raw.mat');
imu4_raw = temp.ans(:,515:594);

top = [];
top_count = [1 1 1 1];
buttom = [];
buttom_count = [1 1 1 1];

for i=1:length(imu1_raw)-2
    if (imu1_raw(7,i) < imu1_raw(7,i+1)) && (imu1_raw(7,i+1) > imu1_raw(7,i+2))
        top(1,top_count(1)) = imu1_raw(1,i+1);
        top_count(1) = top_count(1)+1;
    elseif (imu1_raw(7,i) > imu1_raw(7,i+1)) && (imu1_raw(7,i+1) < imu1_raw(7,i+2))
        buttom(1,buttom_count(1)) = imu1_raw(1,i+1);
        buttom_count(1) = buttom_count(1)+1;
    end
    if (imu2_raw(7,i) < imu2_raw(7,i+1)) && (imu2_raw(7,i+1) > imu2_raw(7,i+2))
        top(2,top_count(2)) = imu2_raw(1,i+1);
        top_count(2) = top_count(2)+1;
    elseif (imu2_raw(7,i) > imu2_raw(7,i+1)) && (imu2_raw(7,i+1) < imu2_raw(7,i+2))
        buttom(2,buttom_count(2)) = imu2_raw(1,i+1);
        buttom_count(2) = buttom_count(2)+1;
    end
    if (imu3_raw(7,i) < imu3_raw(7,i+1)) && (imu3_raw(7,i+1) > imu3_raw(7,i+2))
        top(3,top_count(3)) = imu3_raw(1,i+1);
        top_count(3) = top_count(3)+1;
    elseif (imu3_raw(7,i) > imu3_raw(7,i+1)) && (imu3_raw(7,i+1) < imu3_raw(7,i+2))
        buttom(3,buttom_count(3)) = imu3_raw(1,i+1);
        buttom_count(3) = buttom_count(3)+1;
    end
    if (imu4_raw(7,i) < imu4_raw(7,i+1)) && (imu4_raw(7,i+1) > imu4_raw(7,i+2))
        top(4,top_count(4)) = imu4_raw(1,i+1);
        top_count(4) = top_count(4)+1;
    elseif (imu4_raw(7,i) > imu4_raw(7,i+1)) && (imu4_raw(7,i+1) < imu4_raw(7,i+2))
        buttom(4,buttom_count(4)) = imu4_raw(1,i+1);
        buttom_count(4) = buttom_count(4)+1;
    end
end

x_plot = [0:0.01:4];

plot(imu1_raw(1,:)-26, imu1_raw(7,:), imu2_raw(1,:)-26, imu2_raw(7,:), imu3_raw(1,:)-26, imu3_raw(7,:), imu4_raw(1,:)-26, imu4_raw(7,:))
xlabel('Time [s]'); ylabel('Acceleration [mg]'); legend('IMU Master','IMU Slave#1', 'IMU Slave#2', 'IMU Slave#3');xlim([0,4]);

figure()
subplot(2,2,1)
xdata = imu1_raw(1,:)-26;
ydata = imu1_raw(7,:);
plot(xdata, ydata);
hold on
x0 = [1000; -1; 30; 0; -1000];
[x1, resnorm] = lsqcurvefit(@sine_wave, x0, xdata, ydata);
plot(x_plot, sine_wave(x1, x_plot))
xlabel('Time [s]'); ylabel('Acceleration [mg]'); legend('Raw data','Curve fit'); xlim([0,4]);title('IMU Master');

subplot(2,2,2)
xdata = imu2_raw(1,:)-26;
ydata = imu2_raw(7,:);
plot(xdata, ydata);
hold on
x0 = [1000; -1; 30; 0; -1000];
[x2, resnorm] = lsqcurvefit(@sine_wave, x0, xdata, ydata);
plot(x_plot, sine_wave(x2, x_plot))
xlabel('Time [s]'); ylabel('Acceleration [mg]'); legend('Raw data','Curve fit'); xlim([0,4]);title('IMU Slave#1');

subplot(2,2,3)
xdata = imu3_raw(1,:)-26;
ydata = imu3_raw(7,:);
plot(xdata, ydata);
hold on
x0 = [1000; -1; 30; 0; -1000];
[x3, resnorm] = lsqcurvefit(@sine_wave, x0, xdata, ydata);
plot(x_plot, sine_wave(x3, x_plot))
xlabel('Time [s]'); ylabel('Acceleration [mg]'); legend('Raw data','Curve fit'); xlim([0,4]);title('IMU Slave#2');

subplot(2,2,4)
xdata = imu4_raw(1,:)-26;
ydata = imu4_raw(7,:);
plot(xdata, ydata);
hold on
x0 = [1000; -1; 30; 0; -1000];
[x4, resnorm] = lsqcurvefit(@sine_wave, x0, xdata, ydata);
plot(x_plot, sine_wave(x4, x_plot))
xlabel('Time [s]'); ylabel('Acceleration [mg]'); legend('Raw data','Curve fit'); xlim([0,4]);title('IMU Slave#3');

figure()
plot(x_plot, sine_wave(x1, x_plot),x_plot, sine_wave(x2, x_plot),x_plot, sine_wave(x3, x_plot),x_plot, sine_wave(x4, x_plot))
xlabel('Time [s]'); ylabel('Acceleration [mg]'); legend('IMU Master','IMU Slave#1', 'IMU Slave#2', 'IMU Slave#3');xlim([0,4]);