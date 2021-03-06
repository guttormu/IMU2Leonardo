function [ H ] = Hmatrix( l )
%Function that creates H matrix
% Calculates the H matrix according to "Disturbance rejection by
% acceleration feedforward for marine surface vessels" by Kjerstad and
% Skjetne

H = [0, -l(1), -l(1), l(2), l(3), 0; ...
    -l(2), 0, -l(2), l(1), 0, l(3); ...
    -l(3), -l(3), 0, 0, l(1), l(2)];
end

