# ComputerVisionProject

The project is divided into 4 files:

-ZhangCalibration: contains the ZhangCalibration function.
-compRadialDistortion: contains the compRadialDistortion function.
-SetZOrientation: contains the SetZOrientation function.
-Project: contains the code that loads the calibration images, calls the previous functions for calibration and builds the images with the superimposed object.

There are 3 folders in the project:

-CalibrationImages1: contains the calibration images from lab lecture 1
-CalibrationImages2: contains the calibration images obtained with the smartphone
-ScreenShot: contains screenshots of the superimposed object.

Note:

In the Project file header, you can change the ImageSet variable to switch between image sets. ImageSet=false to use the images from lab lecture 1, ImageSet=true to use the images from the smartphone.
