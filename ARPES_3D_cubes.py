# Author: Bartlomiej Turowski, IP PAS, ON 6.2 MagTop
# Initial version date: 12.02.2021
# Last revised: 20.05.2023
# Code purpose:   creation of cube maps using IGOR pro .ibw files
#                 generated in ARPES experiment

import numpy as np
import matplotlib.pyplot as plt

from igor.binarywave import load as loadibw
import os
import scipy.interpolate as interp

def get_wave_range(slice_files):
    # get min and max of slices for colormap
    # get X and Y ranges of data
    all_mins=[]
    all_maxs=[]
    RangesX=[]
    RangesY=[]
    for ii in range(len(slice_files)):
        wave_data = loadibw(slice_files[ii])
        
        delta_X_axis = wave_data["wave"]["wave_header"]["sfA"][0]
        delta_Y_axis = wave_data["wave"]["wave_header"]["sfA"][1]
        start_X_axis = wave_data["wave"]["wave_header"]["sfB"][0]
        start_Y_axis = wave_data["wave"]["wave_header"]["sfB"][1]
        wave_data_slice = wave_data["wave"]["wData"]
        
        dataSizeX, dataSizeY = wave_data_slice.shape
        
        fullXAxisRange=np.linspace(start=start_X_axis, stop=start_X_axis+(dataSizeX-1)*delta_X_axis, num=dataSizeX)
        fullYAxisRange=np.linspace(start=start_Y_axis, stop=start_Y_axis+(dataSizeY-1)*delta_Y_axis, num=dataSizeY)
        
        fullRangeX = fullXAxisRange[-1]-fullXAxisRange[0]
        fullRangeY = fullYAxisRange[-1]-fullYAxisRange[0]
        
        RangesX.append(fullRangeX)
        RangesY.append(fullRangeY)
        
        
        _min, _max = np.amin(wave_data_slice[~np.isnan(wave_data_slice)]), np.amax(wave_data_slice[~np.isnan(wave_data_slice)])
        all_mins.append(_min)
        all_maxs.append(_max)
    return min(all_mins), max(all_maxs), RangesX, RangesY

def get_slices_ibws(files_folder_path):
    slice_files_full_paths = []
    for ibw_file in os.listdir(files_folder_path):
        if ibw_file.endswith(".ibw"):
            slice_files_full_paths.append(os.path.join(files_folder_path, ibw_file))
    return slice_files_full_paths

print('Started')

sample_folder_name = 'sample_folder_name'
sliceX = 0 #position of sliceX in ky
sliceY = 0 #position of sliceY in kx
sliceE = 13.279 # position of sliceE in energy

# four parameters defining shape and k-space range of generated cube
startKx=-0 #start of kx axis in sliceY
stopKx=0.15 #stop of kx axis in sliceY
startKy=-0 #start of ky axis in sliceX
stopKy=0.15 #stop of ky axis in sliceX

# two parameters defining energy range
startE=13.279 #start of E axis in sliceE = position of bottom slice
stopE=13.629 #stop of E axis in sliceE = position of top slice

# path to .ibw folder: script_filder\'plot_data'\sample_filder_name\'ibws'
# pngs are generated in folder: script_filder\'plot_data'\sample_filder_name\'pngs'
ibws_folder_path=os.path.dirname(os.path.realpath(__file__))+'\\'+'plot_data\\'+sample_folder_name+'\\ibws'
png_save_folder = os.path.dirname(os.path.realpath(__file__))+'\\'+'plot_data\\'+sample_folder_name+'\\pngs'

if not os.path.exists(png_save_folder):
    os.makedirs(png_save_folder)
    
make_png=False

slice_files_full_paths = get_slices_ibws(ibws_folder_path)
_min, _max, RangesX, RangesY = get_wave_range(slice_files_full_paths)
_max=_max*0.35

print('Processing...')

for ii in range(len(slice_files_full_paths)):
#     if ii != 5 and ii!=0 and ii!=2:
#         continue
    
    wave_data = loadibw(slice_files_full_paths[ii])
    
    delta_X_axis = wave_data["wave"]["wave_header"]["sfA"][0]
    delta_Y_axis = wave_data["wave"]["wave_header"]["sfA"][1]
    start_X_axis = wave_data["wave"]["wave_header"]["sfB"][0]
    start_Y_axis = wave_data["wave"]["wave_header"]["sfB"][1]
    
    wave_data_slice = wave_data["wave"]["wData"]
    dataSizeX, dataSizeY = wave_data_slice.shape
    
    fullXAxis=np.linspace(start=start_X_axis, stop=start_X_axis+(dataSizeX-1)*delta_X_axis, num=dataSizeX)
    fullYAxis=np.linspace(start=start_Y_axis, stop=start_Y_axis+(dataSizeY-1)*delta_Y_axis, num=dataSizeY)
      
    wave_data_slice_rotated = np.rot90(wave_data_slice.copy(), -1)
    wave_data_slice_rotated = np.flip(wave_data_slice_rotated,1)
    
    mask = np.isnan(wave_data_slice_rotated)
    wave_data_slice_rotated[mask] = np.interp(np.flatnonzero(mask), np.flatnonzero(~mask), wave_data_slice_rotated[~mask])
    
    slice_interpolation=interp.RectBivariateSpline(fullYAxis, fullXAxis, wave_data_slice_rotated)
    
# ---- set proper axes to sices ---
# xy to sliceE, ye to sliceX, xe to sliceY
    if ii == 0:
        sliceAxisX = np.round(np.linspace(start=round(start_X_axis, 3), stop=round(fullXAxis[-1], 3), num=round((round(fullXAxis[-1], 3)-round(fullXAxis[0], 3))*1000)+1), 3)
        sliceAxisY = np.round(np.linspace(start=round(start_Y_axis, 3), stop=round(fullYAxis[-1], 3), num=round((round(fullYAxis[-1], 3)-round(fullYAxis[0], 3))*1000)+1), 3)
        
        sliceAxisX = sliceAxisX[:(len(sliceAxisX)-len(sliceAxisX)%2)]
        sliceAxisY = sliceAxisY[:(len(sliceAxisY)-len(sliceAxisY)%2)]
        
        if sliceAxisX[0]<sliceAxisY[0]:
            rangeStart = sliceAxisY[0]
            sliceAxisX = sliceAxisX[np.where(sliceAxisX==rangeStart)[0][0]:]
        else: 
            rangeStart = sliceAxisX[0]
            sliceAxisY = sliceAxisY[np.where(sliceAxisY==rangeStart)[0][0]:]
        if sliceAxisX[-1]>sliceAxisY[-1]:
            rangeStop = sliceAxisY[-1]
            sliceAxisX = sliceAxisX[:np.where(sliceAxisX==rangeStop)[0][0]+1]
        else:
            rangeStop = sliceAxisX[-1]
            sliceAxisY = sliceAxisY[:np.where(sliceAxisY==rangeStop)[0][0]+1]
            
        interpolatedAxisX = sliceAxisX
        interpolatedAxisY = sliceAxisY   
    
        Z2 = slice_interpolation(sliceAxisY, sliceAxisX)
        
        plotAxisX=sliceAxisX
        plotAxisY=sliceAxisY
        
    elif ii == 1:
        Z2 = slice_interpolation(interpolatedAxisY, interpolatedAxisX)
        plotAxisX=interpolatedAxisX
        plotAxisY=interpolatedAxisY
    elif ii == 2:
        interpolatedAxisE = np.round(np.linspace(start=round(start_Y_axis, 3), stop=round(fullYAxis[-1], 3), num=round((round(fullYAxis[-1], 3)-round(fullYAxis[0], 3))*500)+1), 3)
        Z2 = slice_interpolation(interpolatedAxisE, interpolatedAxisY)
        plotAxisX=interpolatedAxisY
        plotAxisY=interpolatedAxisE
    elif ii == 3:
        Z2 = slice_interpolation(interpolatedAxisE, interpolatedAxisY)
        plotAxisX=interpolatedAxisY
        plotAxisY=interpolatedAxisE
    elif ii == 4:
        Z2 = slice_interpolation(interpolatedAxisE, interpolatedAxisX)
        plotAxisX=interpolatedAxisX
        plotAxisY=interpolatedAxisE
    elif ii == 5:
        Z2 = slice_interpolation(interpolatedAxisE, interpolatedAxisX)
        plotAxisX=interpolatedAxisX
        plotAxisY=interpolatedAxisE
        
    if ii ==0 or ii ==1: #E
        startSliceX = np.where(plotAxisX==startKx)[0][0]
        inSliceX = np.where(plotAxisX==sliceY)[0][0]
        stopSliceX = np.where(plotAxisX==stopKx)[0][0]
        startSliceY = np.where(plotAxisY==startKy)[0][0]
        inSliceY = np.where(plotAxisY==sliceX)[0][0]
        stopSliceY = np.where(plotAxisY==stopKy)[0][0]
    elif ii ==2 or ii ==3: #X
        startSliceX = np.where(plotAxisX==startKy)[0][0]
        inSliceX = np.where(plotAxisX==sliceX)[0][0]
        stopSliceX = np.where(plotAxisX==stopKy)[0][0]
        startSliceY = np.where(plotAxisY==startE)[0][0]
        inSliceY = np.where(plotAxisY==sliceE)[0][0]
        stopSliceY = np.where(plotAxisY==stopE)[0][0]
    elif ii ==4 or ii ==5: #Y
        startSliceX = np.where(plotAxisX==startKx)[0][0]
        inSliceX = np.where(plotAxisX==sliceY)[0][0]
        stopSliceX = np.where(plotAxisX==stopKx)[0][0]
        startSliceY = np.where(plotAxisY==startE)[0][0]
        inSliceY = np.where(plotAxisY==sliceE)[0][0]
        stopSliceY = np.where(plotAxisY==stopE)[0][0]

    wave_data_slice_rotated = Z2
    
    if ii == 0 and (startSliceX!=inSliceX and startSliceY!=inSliceY): # inner slice E
        make_png=True
        
        wave_data_slice_rotated = wave_data_slice_rotated[startSliceY:inSliceY+1, :]
        wave_data_slice_rotated = wave_data_slice_rotated[:, startSliceX:inSliceX+1]
        
        plotAxisX = plotAxisX[startSliceX:inSliceX+1]
        plotAxisY = plotAxisY[startSliceY:inSliceY+1]
        
        scaleFactorX = plotAxisX[-1]-plotAxisX[0]
        scaleFactorY = plotAxisY[-1]-plotAxisY[0]
        
    elif ii == 1: # outer slice E
        make_png=True
        
        wave_data_slice_rotated[:inSliceY, :inSliceX]=np.NaN
        wave_data_slice_rotated = wave_data_slice_rotated[startSliceY:stopSliceY+1, :]
        wave_data_slice_rotated = wave_data_slice_rotated[:, startSliceX:stopSliceX+1]
        
        plotAxisX = plotAxisX[startSliceX:stopSliceX+1]
        plotAxisY = plotAxisY[startSliceY:stopSliceY+1]
        
        scaleFactorX = plotAxisX[-1]-plotAxisX[0]
        scaleFactorY = plotAxisY[-1]-plotAxisY[0]
        
    elif ii == 2 and (startSliceX!=inSliceX or startKx==sliceY): #inner slice X
        # to have parts ramoved close to -X-Y point, the same parts needs to be removed and X slice needs to be flopped
        make_png=True
        
        wave_data_slice_rotated = wave_data_slice_rotated[inSliceY:stopSliceY+1, :]
        if startSliceX==inSliceX and startKx==sliceY:
            wave_data_slice_rotated = wave_data_slice_rotated[:, inSliceX:stopSliceX+1]
            plotAxisX = plotAxisX[inSliceX:stopSliceX+1]
        elif (startKx==sliceY):
            wave_data_slice_rotated = wave_data_slice_rotated[:, startSliceX:stopSliceX+1]
            plotAxisX = plotAxisX[startSliceX:stopSliceX+1]
        else: 
            wave_data_slice_rotated = wave_data_slice_rotated[:, startSliceX:inSliceX+1]
            plotAxisX = plotAxisX[startSliceX:inSliceX+1]
        plotAxisY = plotAxisY[inSliceY:stopSliceY+1]
        
        scaleFactorX = plotAxisX[-1]-plotAxisX[0]
        scaleFactorY = plotAxisY[-1]-plotAxisY[0]
        
    elif ii == 3 and (startKx!=sliceY): #outer slice X
        # to have parts ramoved close to -X-Y point, the same parts needs to be removed and X slice needs to be flopped
        make_png=True
        
        wave_data_slice_rotated[inSliceY:, :inSliceX]=np.NaN
        wave_data_slice_rotated = wave_data_slice_rotated[startSliceY:stopSliceY+1, :]
        wave_data_slice_rotated = wave_data_slice_rotated[:, startSliceX:stopSliceX+1]
        plotAxisX = plotAxisX[startSliceX:stopSliceX+1]
        plotAxisY = plotAxisY[startSliceY:stopSliceY+1]
        
        scaleFactorX = plotAxisX[-1]-plotAxisX[0]
        scaleFactorY = plotAxisY[-1]-plotAxisY[0]
        
    elif ii == 4 and (startSliceX!=inSliceX or startKy==sliceX): #inner slice Y    
        make_png=True
        
        wave_data_slice_rotated = wave_data_slice_rotated[inSliceY:stopSliceY+1, :]
        if (startSliceX==inSliceX and startKy==sliceX):
            wave_data_slice_rotated = wave_data_slice_rotated[:, inSliceX:stopSliceX+1]
            plotAxisX = plotAxisX[inSliceX:stopSliceX+1]
        elif  (startKy==sliceX):
            wave_data_slice_rotated = wave_data_slice_rotated[:, startSliceX:stopSliceX+1]
            plotAxisX = plotAxisX[startSliceX:stopSliceX+1]
        else:
            wave_data_slice_rotated = wave_data_slice_rotated[:, startSliceX:inSliceX+1]
            plotAxisX = plotAxisX[startSliceX:inSliceX+1]
        
        plotAxisY = plotAxisY[inSliceY:stopSliceY+1]

        scaleFactorX = plotAxisX[-1]-plotAxisX[0]
        scaleFactorY = plotAxisY[-1]-plotAxisY[0]
        
    elif ii == 5 and (startKy!=sliceX): #outer  slice Y
        make_png=True
        
        wave_data_slice_rotated[inSliceY:, :inSliceX]=np.NaN
        wave_data_slice_rotated = wave_data_slice_rotated[startSliceY:stopSliceY+1, :]
        wave_data_slice_rotated = wave_data_slice_rotated[:, startSliceX:stopSliceX+1]
          
        plotAxisX = plotAxisX[startSliceX:stopSliceX+1]
        plotAxisY = plotAxisY[startSliceY:stopSliceY+1]
          
        scaleFactorX = plotAxisX[-1]-plotAxisX[0]
        scaleFactorY = plotAxisY[-1]-plotAxisY[0]
        

    # more colour maps (cmap) available at: https://matplotlib.org/stable/tutorials/colors/colormaps.html
    # vmin and vmax can be adjusted to fine tune data presentation
    if make_png:
        print(os.path.join(png_save_folder, os.path.basename(slice_files_full_paths[ii])[:-4]+'.png'))
        plt.figure(figsize=(10*round(scaleFactorX, 3),10*round(scaleFactorY, 3)), dpi=100)
        if ii ==0:
            plt.pcolormesh(plotAxisX, plotAxisY, wave_data_slice_rotated, cmap='hot', vmin = _min*1, vmax = _max*1)
        elif ii ==1:
            plt.pcolormesh(plotAxisX, plotAxisY, wave_data_slice_rotated, cmap='hot', vmin = _min*1, vmax = _max*1)
        else:
            plt.pcolormesh(plotAxisX, plotAxisY, wave_data_slice_rotated, cmap='hot', vmin = _min*1, vmax = _max*1)
        if ii==2 or ii==3:
            plt.gca().invert_xaxis()
        plt.subplots_adjust(bottom = 0)
        plt.subplots_adjust(top = 1)
        plt.subplots_adjust(right = 1)
        plt.subplots_adjust(left = 0)
        plt.axis('off')
        plt.savefig(os.path.join(png_save_folder, os.path.basename(slice_files_full_paths[ii])[:-4]+'.png'), transparent=True, dpi='figure')
    
    make_png=False
print('Finished')
