#!/bin/bash
diff -Naur old-cmake new-cmake > cmake.patch
diff -Naur old-cell new-cell > cell.patch
diff -Naur old-petsc new-petsc > petsc.patch

