%Getting B1
function y = getB1(difference_vector, intensity_vector)
	med = floor(length(difference_vector)/2);
	array = difference_vector(1:med);
	index = find(array == max(array), 1);
	y = intensity_vector(index);
end

%Getting B2
function y = getB2(difference_vector, intensity_vector)
	med = floor(length(difference_vector)/2);
	array = difference_vector(med+1:length(difference_vector));
	index = find(array == max(array), 1);
	y = intensity_vector(index);
end

%Adding Border Box
function y = addBorderBox(window_size,channel)
	[m,n] = size(channel);
	Box = zeros(m+window_size-1,n+window_size-1);
	offset = floor(window_size/2);
	for i = 1:m
		for j = 1:n
			Box(i+offset,j+offset) = Box(i+offset,j+offset)+channel(i,j);
		end
	end
	y = Box;
end

%Check If pixels is Noise
function y = isPixelNoise(a,b,image_matrix, window_size)

end

% apply standard filter
function y = applyStandardMedianFilter(image_matrix, binary_map, filter_window_size)
	result = image_matrix;
	delta = floor(filter_window_size/2);
	[m,n] = size(binary_map);
	for i = delta:m-delta
		for j = delta:n-delta
			if binary_map(i,j)==1
				filter_window= [];
				for k = 1:filter_window_size
					for l = 1:filter_window_size
						filter_window(end+1) = image_matrix(i+k-delta,j+n-delta);
					end
				end
				filter_window = sort(filter_window);
				result(i,j) = filter_window(floor((delta*delta)/2));
		end
	end
	y = result;
end

%Perform BDND
function y = performBDND(window_size,channel)
	image_matrix = addBorderBox(window_size,channel);
	[m,n] = size(channel);
	offset=floor(window_size/2);
	binary_map zeros(m+window_size-1,n+window_size-1);
	for i = offset+1:m
		for j=offset+1:n
			binary_map(i,j) = isPixelNoise(i,j,image_matrix,window_size);
		end
	end
	number_of_ones = sum(binary_map==1);
	percentage = (number_of_ones/(m*n))*100;
	filter_window_size = 7;
	if percentage <= 20
		filter_window_size = 3;
	else if percentage>20 and percentage<=40
		filter_window_size = 5;
	else
		filter_window_size = 7;
	end
	y = applyStandardMedianFilter(image_matrix, binary_map, filter_window_size);
end







