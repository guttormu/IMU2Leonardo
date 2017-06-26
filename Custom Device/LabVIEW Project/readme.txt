%This LabVIEW project was created by Guttorm Udjus, and here is a short explanation on how to build the project for use on cRIO

Open the 'IMU Custom Device Project.lvproj'. 

Two building operations must be performed:
In the treem open "My Computer", right click on "Build Specifications", choose "Build All". 
In the tree, open NI-cRIO9024-CSAD, right click on "Build Specification", choose "Build All". 

Finally, the C-file from the last build must be moved to the correct directory. Go to the directory: 
C:\Users\Public\Documents\National Instruments\NI VeriStand 2015\Custom Devices\IMU\c

Copy the file "IMU Engine - VxWorks.llb", and paste in the path above:
C:\Users\Public\Documents\National Instruments\NI VeriStand 2015\Custom Devices\IMU

Now, the custom device is ready to be included in the NI VeriStand System Definition File for use in Simulink etc. 