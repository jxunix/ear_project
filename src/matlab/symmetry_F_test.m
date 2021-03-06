%
% Filename: symmetry_F_test.m
% Author: Jun Xu
% Email: junx@cs.bu.edu
% Created Time: Thu 07 Apr 2016 03:22:36 PM EDT
% Description: This script is to perform a F-test for ear symmetry.
%

%% read the image filenames
fname = '../../results/image_names.txt';
names = textread(fname, '%s', 'delimiter', '\n');

%% read the coordinates of the feature points and remove missing data (whose
%  corresponding filename contains '(remedy)'.
fname = '../../results/features_asm.csv';
%fname = '../../results/features_manual.csv';
M = csvread(fname);

rows = size(M,1);
index = zeros(rows, 1);
for i = 1:rows
	s = size(strfind(names{ceil(i/2)}, 'remedy'), 2);
	
	if s == 1
		i = ceil(i/8)*8+1;
		index(i-8) = 1;
		index(i-7) = 1;
		index(i-6) = 1;
		index(i-5) = 1;
		index(i-4) = 1;
		index(i-3) = 1;
		index(i-2) = 1;
		index(i-1) = 1;
	end
end

index = logical(index);
M = M(~index, :);

index = index(1:2:length(index));
names = names(~index);

%% standardize all feature vectors without scaling
M = align(M);
rows = size(M,1) / 2;

%% reshape the data set
X = reshape(M', size(M,2)*2, rows)';
X_l = ~cellfun('isempty', strfind(names, '-l'));
X_r = ~cellfun('isempty', strfind(names, '-r'));

X_l = X(X_l, :);
X_r = X(X_r, :);

%% perform F-test
mean_X_l = mean(X_l);
mean_X_r = mean(X_r);
mean_X = mean(X);

SSB_l = sum((mean_X_l - mean_X) .^ 2, 2) * rows / 2;
SSB_r = sum((mean_X_r - mean_X) .^ 2, 2) * rows / 2;
SSB = SSB_l + SSB_r;

SSE_l = sum(sum((X_l - repmat(mean_X_l, rows / 2, 1)) .^ 2, 2));
SSE_r = sum(sum((X_r - repmat(mean_X_r, rows / 2, 1)) .^ 2, 2));
SSE = SSE_l + SSE_r;

F = SSB / (SSE / (rows - 2));
p = 1 - fcdf(F, 1, rows - 2)
