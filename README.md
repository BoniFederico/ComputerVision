# Routed Application

## DESCRIPTION  
 
In the doc.pdf file there is a brief description of the project and its functions.

## DEMO  

At the following link there is a demo video of the application.
```
https://www.youtube.com/watch?v=2RqP0i5ZCNo
```
## CODE

In the backend folder there is the api project:
```
backend\routed\src\main\java\com\federicoboni
```
In the frontend folder there is the Vue.js project of the application:
```
frontend\src
```







# ComputerVision

## DESCRIPTION  
MatLab project that implement Zhang calibration for a camera. Developed for Computer Vision and Pattern Recognition course in University of Trieste.

##PROJECT
The project is divided into 4 files:  

```
-ZhangCalibration: contains the ZhangCalibration function.

-compRadialDistortion: contains the compRadialDistortion function.

-SetZOrientation: contains the SetZOrientation function.

-Project: contains the code that loads the calibration images, calls the previous functions for calibration and builds the images with the superimposed object.
```

There are 3 folders in the project:  

```
-CalibrationImages1: contains the calibration images from lab lecture 1

-CalibrationImages2: contains the calibration images obtained with the smartphone

-Screenshot: contains screenshots of the superimposed object.
```

Note:  
```
!! -> The file that has to be executed is "Project.m"

!! -> In the Project.m file header, you can change the ImageSet variable to switch between image sets. ImageSet=false to use the images from lab lecture 1, ImageSet=true to use the images from the smartphone.

!! -> Optimization ToolBox is needed to use the fsolve function. 

!! -> ComputerVision ToolBox is needed to use the detectCheckerboardPoints function. 
```
