# -*- coding: utf-8 -*-
"""
This is an example code for finding ds (raindrop diameter) from the rain streak information.

If you use this code, please cite it as below.

Lee, J., Byun, J., Baik, J., Jun, C., and Kim, H.-J.(2022) Estimation of raindrop size distribution and rain rate with infrared surveillance camera in dark conditions, Atmos. Meas. Tech. Discuss. [preprint], https://doi.org/10.5194/amt-2022-196, in review.

"""

from scipy.special import lambertw
import numpy as np 
import matplotlib.pyplot as plt

lp = 60 # length in pixels
dp = 10 # diameter in pixels

f = 4.5 # focal length, mm
df = 1000 # focus distance, mm
hs = 5.7 * (640/1080) # height of sensor, mm
ws =  7.6 * (640/1920) # width of sensor, mm
N = 1.6 # F-number 
cp = 0.005 # circle of confusion, mm
hp = 640 # height of cropped image (number of pixels)
wp = 640 # width of cropped image (number of pixels)
t = 1/250 # exposure time (second)       

# calculate s (distance) 
A = -0.6* ( (df-f)/(df*f) ) * (hs/hp) * dp
B = ( (df-f)/(df*f) ) * (hs/hp) * lp
C = (10300*t) * (A/B) * (np.exp(9650*t*A/B))       
s = (9650*t*A-B*lambertw(C, 0)) / (A*B)
s = np.real(s)

# calculate ls and ds    
ds = ((df-f)/(df*f)) * (ws/wp) * dp * s

print(ds)