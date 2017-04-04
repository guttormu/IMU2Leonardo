function F = sine_wave(x,xdata)
F = x(1)*exp(x(2)*xdata) .* (sin(x(3) * xdata + x(4))) + x(5);
end