# -*- coding: utf-8 -*-
"""
Created on Fri Sep 30 17:06:21 2022

@author: JY
"""

#%% 00. Library
import cv2

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import os
from glob import glob
from tqdm import tqdm
from datetime import datetime, timedelta
import collections
from collections import Counter
from random import sample 
from matplotlib import cm
from matplotlib.colors import ListedColormap, LinearSegmentedColormap

import matplotlib
import matplotlib.font_manager as fm
from cv2 import cvtColor
import time

def digit_three(num):
    return '%03d' %num

def digit_four(num):
    return '%04d' %num

def imgshow(window_name, ima_path):
    img = cv2.imread(ima_path)
    cv2.imshow(window_name, img)
    cv2.waitKey(0)
    cv2.destroyAllWindows()
    cv2.waitKey(1)
    cv2.waitKey(1)
    cv2.waitKey(1)
    cv2.waitKey(1)
    
def imgshow_array(window_name, array):
    cv2.imshow(window_name, array)
    cv2.waitKey(0)
    cv2.destroyAllWindows()
    cv2.waitKey(1)
    cv2.waitKey(1)
    cv2.waitKey(1)
    
#%% 01. Path Setting
# current_path = r"D:\01.code\23.CCTV_DSD_논문작업\#20230116_배경분리코드"
current_path = r"F:\#20230116_배경분리코드"
os.chdir(current_path)
vid_list = [x for x in glob('./*.mp4')]

#%% 02. Video Info & Setting
vid = cv2.VideoCapture(vid_list[0])
length = vid.get(cv2.CAP_PROP_FRAME_COUNT)
width = int(vid.get(cv2.CAP_PROP_FRAME_WIDTH))
height = int(vid.get(cv2.CAP_PROP_FRAME_HEIGHT))
fps = round(vid.get(cv2.CAP_PROP_FPS))
codec = cv2.VideoWriter_fourcc(*'mp4v')
fourcc = cv2.VideoWriter_fourcc(*'DIVX')
total_time = int(length/fps)
select_frame = np.arange(0,length).astype(int)
image_save_type = '.png'
#%% 03. ROI Setting

roi_start_point_x = 600
roi_start_point_y = 200
roi_size = 640

pt1 = np.array([roi_start_point_x, roi_start_point_y])
pt2 = pt1 + roi_size
red = (0,0,255)

samele_file = vid_list[0]
vid = cv2.VideoCapture(vid_list[0])
return_value, frame = vid.read()

cv2.rectangle(frame, pt1, pt2, red, 5)

# cv2.rectangle(frame, (1050,150),(1050+640,150+640), red, 5)
            # crop_img = rain_streak[200:200+640,600:600+640] # CAM1
            # crop_img = rain_streak[150:150+640,250:250+640] # CAM5
cv2.imshow('ROI_CHECK',frame)
# cv2.imwrite('d:/sample.png', img)
cv2.waitKey(2000) # Wait for 2000ms(=2s) for ROI_CHECK window / Put '0' to maintain the ROI_CHECK window.
cv2.destroyAllWindows()
#%% 04. Backgroud Subtraction_total

fgbg = cv2.createBackgroundSubtractorKNN(detectShadows=False)
kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE,(5,5))
kernel2 = cv2.getStructuringElement(cv2.MORPH_RECT, (7,7))
binary_threshold_lower_limit = 20
binary_threshold_upper_limit = 255
binary_type = cv2.THRESH_BINARY


while True:
    start = time.time()
    
    # (0) Read Frame
    return_value, frame = vid.read()
     
    if return_value:
        frame = frame[200:200+640,600:600+640]
        
        # (1) Foreground Setting by KNN subtractor
        foreground = fgbg.apply(frame)
        foreground = cv2.dilate(foreground,kernel,iterations=1)
        opening = cv2.morphologyEx(foreground, cv2.MORPH_OPEN, kernel2)
        foreground = np.stack((opening,)*3, axis=-1)
        
        # (2) Background Setting from Foreground
        background = fgbg.getBackgroundImage() # 배경
        
        # (3) RainStreak_Extraction = Frame - Background 
        rain_streak = cv2.subtract(cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY), cv2.cvtColor(background, cv2.COLOR_BGR2GRAY))
        _, binary_rain_streak = cv2.threshold(rain_streak, binary_threshold_lower_limit, binary_threshold_upper_limit, binary_type)
        rain_streak = np.stack((rain_streak,)*3, axis=-1)
        binary_rain_streak = np.stack((binary_rain_streak,)*3, axis=-1)
        
        
        # (4) Visualization
        visualization_img = rain_streak
        cv2.imshow('background extraction video', visualization_img) # PRESS 'SPACE' to progress rain streak visualizaion & 
        cv2.waitKey()
        
    else : 
        print('#### Video is finished #### OR #### There is an error in frame ####')
        break
    
    k = cv2.waitKey(0)
    if k == ord('s') or k == 27: # PRESS 's' key or 'ESC' to stop
        break

cv2.destroyAllWindows()

#%%