#Author : Krishna Chaitanya Chavati
#######################################################################################################
# Switching median filter with boundary discriminative noise detection for extremely corrupted images #
#######################################################################################################
#step 1: Impose a 21 X 21 window, which is centered around the current pixel.

#step 2: Sort the pixels in the window according to the ascending order and find the median, med, 
#of the sorted vector vo.

#step 3: Compute the intensity difference between each pair of adjacent pixels across the sorted vector
# vo and obtain the difference vector.

#step 4: For the pixel intensities between 0 and med in the vo, find the maximum intensity difference in the
#vD of the same range and mark its corresponding pixel in the vo as the boundary b1.

#step 5: Likewise, the boundary b2 is identified for pixel in- tensities between med and 255;
# three clusters are, thus, formed.

#step 6: If the pixel belongs to the middle cluster, it is clas- sified as “uncorrupted” pixel, and the 
#classification process stops; else, the second iteration will be in- voked in the following.

#step 7: Impose a 3 ￼ 3 window, being centered around the concerned pixel and repeat Steps 2)–5).

#step 8: If the pixel under consideration belongs to the middle cluster, it is classified as 
#“uncorrupted” pixel; otherwise, “corrupted.”

##Notes:
# Numpy or np is a numerical computation library functions used here are
# zeros - similar to matlab zeros
# copy - to copy an entire array
# sort - to sort an array in ascending order



from __future__ import print_function
import sys
from time import time
import numpy as np
from pprint import pprint
import matplotlib
import math

reload(sys)
sys.setdefaultencoding("utf-8")

def add_border_box(window_size, image):
	result = np.zeros((w+window_size,h+window_size), dtype=np.int);
	for m in range(0,h-1):
		for n in range(0,w-1):
			result[m+10][n+10] = result[m+10][n+10]+image[m][n];
	return result;		

def getB1(diff, intensity_vector):
	median = len(diff)/2;
	max = diff[1];
	position = 1;
	for m in range(1,median-1):
		if(diff[m]>max):
			max = diff[m];
			position = m;
	return intensity_vector[m];

def getB2(diff, intensity_vector):
	median = len(diff)/2;
	max = diff[median+1];
	position = median+1;
	for m in range(median+1,len(diff)-1):
		if(diff[m]>max):
			max = diff[m];
			position = m;
	return intensity_vector[m];

def IsPixelNoise(a, b, image):
	#sorted intensity vector calculation steps 1 & 2
	current_pixel_intensity = image[a,b];
	intensity_vector = [];
	for m in range(b-10,b+10):
		for n in range(a-10, a+10):
			intensity_vector.push(image[m][n]);
	difference_vector = np.zeros((1,len(intensity_vector)),dtype=np.int);
	np.sort(intensity_vector);

	#difference vector calculation step 3
	for i in range(0,len(intensity_vector)-2):
		difference_vector[i] = math.fabs(intensity_vector[i] - intensity_vector[i+1]);
	difference_vector[len(intensity_vector) -1] = 0;

	#Calculating B1 using difference vector and intensity vector step 4
	B1 = getB1(difference_vector, intensity_vector);

	#Calculating B1 using difference vector and intensity vector step 5
	B2 = getB2(difference_vector, intensity_vector);

	#Checking if nosie in first iteration. If it is in the middle cluster not corrupted else step 6
	#proceed to second iteration
	if current_pixel_intensity >=B1 and current_pixel_intensity<=B2:
		return 0;
	else:
		#second iteration repeat the above steps with 3X3 window step 7
		second_intensity_vector = [];
		for m in range(b-1,b+1):
			for n in range(a-1, a+1):
				second_intensity_vector.push(image[m][n]);
		second_difference_vector = np.zeros((1,len(second_intensity_vector)),dtype=np.int);
		np.sort(second_intensity_vector);
		for i in range(0,len(second_intensity_vector)-2):
			#math.fabs gives absolute value of a number
			second_difference_vector[i] = math.fabs(second_intensity_vector[i] - second_intensity_vector[i+1]);
		second_difference_vector[len(second_intensity_vector) -1] = 0;
		secondB1 = getB1(second_difference_vector, second_intensity_vector);
		secondB2 = getB2(second_difference_vector, second_intensity_vector);

		# step 8
		if current_pixel_intensity >=secondB1 and current_pixel_intensity<=secondB2: 
			return 0;
		else:
			return 1;

def performBDND(channel):
	#add border of 20 extra height and weight cells
	image = add_border_box(20, channel);
	#keep a binary map of whether a pixel is an uncorrupted one or otherwise. has same shape as image
	#contains 0 if at i,j if image[i][j] is a uncorrupted one 1 if corrupted
	binary = np.zeros((w+20,h+20), dtype=np.int);

	#detect impulse noise for each pixel
	for m in range(11,h-1):
		for n in range(11,w-1):
			binary[m][n] = IsPixelNoise(m,n,image);

	#deciding on the filter window size to apply for SM filtering 
	#calculated by counting number of ones in the binary map versus the whole count
	number_of_ones = sum(x.count(1) for x in binary);
	percentage = (int)(number_of_ones/w*h)*100);
	filter_window_size = 7; 
	if percentage <= 20:
		filter_window_size = 3;
	elif percentage >20 and percentage <=40:
		filter_window_size = 5;
	elif percentage > 40:
		filter_window_size = 7;
	return applyStandardMedianFilter(image,binary, filter_window_size);

def applyStandardMedianFilter(image, binary, filter_window_size):
	#standard median filter . Refer https://en.wikipedia.org/wiki/Median_filter for implementation
	result = np.copy(image);
	delta = math.floor(filter_window_size/2);
	for m in range(delta,len(binary)-delta):
		for n in range(delta,len(binary[0])-delta):
			if(binary[m][n]==1):
				window = [];
				for i in range(0,filter_window_size):
					for j in range(0,fiter_window_size):
						window.push(image[m+i-delta][n+j-delta]);
				np.sort(window);
				result[m][n] = window[delta * delta / 2];
	return result;

if __name__ == '__main__':
	#Function execution starts from here in python
	#Get the image
	imageMatrix = read_image('images/lena_color.gif');
	#add salt and pepper noise
	imageMatrix = salt_pepper_noise(imageMatrix, 0.1);
	#define width and height for use in other functions
	global w,h;
	h = len(imageMatrix);
	w = len(imageMatrix[0]);
	#split the RGB channels and perform BDND individually 
	redFiltered = performBDND(getRedChannel(imageMatrix));
	greenFiltered = performBDND(getGreenChannel(imageMatrix));
	blueFiltered = performBDND(getBlueChannel(imageMatrix));

	#merge them back , channels_merge and read_image are pseudo functions you need to replace with matlab analogues
	output_image = channels_merge(redFiltered, greenFiltered, blueFiltered);

