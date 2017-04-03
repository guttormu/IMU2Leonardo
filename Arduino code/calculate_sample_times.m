fileID = fopen('sample_times.txt', 'r');
vec = [];
for i=1:33
    fscanf(fileID, '%[Time before and after:]');
    vec(1:2,i) = fscanf(fileID, '%i');
    vec(3,i) = vec(2,i)-vec(1,i);
end
%Sample time in microseconds:
sample_time = mean(vec(3,:));