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
	current_pixel_intensity = image_matrix(a,b);
	intensity_vector = [];
	offset=floor(window_size/2);
	for m = a-offset:a+offset
		for n = b-offset:b+offset
			intensity_vector(end+1) = image_matrix(m,n);
		end
	end
	intensity_vector = sort(intensity_vector);
	len_intensity = length(intensity_vector);
	difference_vector = zeros(1,len_intensity);
	for i = 1:len_intensity-1
		difference_vector(i)=abs(intensity_vector(i)-intensity_vector(i+1));
	end
	b1 = getB1(difference_vector,intensity_vector);
	b2 = getB2(difference_vector, intensity_vector);
	if current_pixel_intensity >=b1 or current_pixel_intensity <=b2
		y=0;
	else
		second_intensity_vector = [];
		for m = a-1:a+1
			for n = b-1:b+1
				second_intensity_vector(end+1) = image_matrix(m,n);
			end
		end
		len_second_intensity = length(second_intensity_vector);
		second_difference_vector = zeros(1,len_second_intensity);
		second_intensity_vector = sort(second_intensity_vector);
		secondB1 = getB1(second_difference_vector,second_intensity_vector);
		secondB2 = getB2(second_difference_vector, second_intensity_vector);

		if current_pixel_intensity >=secondB1 and current_pixel_intensity<=secondB2
			y = 0;
		else
			y = 1;
		end
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


% BDND INITIALIZE AND RUN

function initializeAndRunBDND(path_to_file)
	image_file = imread(path_to_file);
	image_file = imnoise(image_file,'salt & pepper',0.10);

	red = image_file(:,:,1);
	green = image_file(:,:,2);
	blue = image_file(:,:,3);

	window_size = 21;

	red_filtered = performBDND(window_size,red);
	green_filtered = performBDND(window_size,green);
	blue_filtered = performBDND(window_size,blue);

	enhanced_image = cat(3,red_filtered,green_filtered,blue_filtered);

	[X1,map1]=imread(image_file);
	[X2,map2]=imread(enhanced_image);
	subplot(1,2,1), subimage(X1,map1)
	subplot(1,2,2), subimage(X2,map2)
end






