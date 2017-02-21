from numpy import *
from scipy.interpolate import spline
import matplotlib.pyplot as pl
import math
import serial
import time
import argparse 

# parse arguments
parser = argparse.ArgumentParser()
parser.add_argument('-p', '--port', required=True, help='Serial port, ie /dev/ttyACMX on Linux, or COMX on Windows')
parser.add_argument('-r', '--rate', required=True, help='Baud rate')
parser.add_argument('-b', '--bar', action='store_true', default=False, help='Show Bargraphs Instead of line plots')
parser.add_argument('-n', '--num', action='store', default=100, help='Window width, default is 100 points')
parser.add_argument('-s', '--smooth', action='store_true', default=False, help='Make lines look smoother')
args = parser.parse_args()
argz = vars(args)
bar = argz['bar'] 
serial_device = argz['port']
baud_rate = argz['rate']
smooth = argz['smooth']
num_p = int(argz['num'])

f = open('results','w')

data = zeros((11,1000))

ser = serial.Serial(serial_device, baud_rate, timeout=1)

count = 0
print('Initializing run')
while (count < 1000):
	ser.write('D')
	line = ser.readline()
	if(len(line)>10):
		if(line[0] != '[' or line[-3] != ']'):
			continue
	line = line.split(' ')
	x = line[1:12]
	if(len(x)==11):
		for i in range(0,11):
			try:
				num = float(x[i])
			except ValueError:
				print('error')
				break
			data[i][count] = num 
			numb = str(num)
			f.write("%s\t" %numb)
		f.write("\n")
	count = count + 1
f.close()
ser.close()