#!/bin/bash
# The patch changes the preferred version of python from 3.4 to 3.6. 
# Modify this if the version of python3 changes!
diff -Naur old new > opencv-cmake.patch
