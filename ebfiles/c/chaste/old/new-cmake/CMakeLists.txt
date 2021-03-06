cmake_minimum_required(VERSION 2.8.10)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_SOURCE_DIR}/cmake/Modules)
include(CheckIncludeFile)

include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/overrides.cmake)

project(Chaste)

include(ChasteBuildTypes)
include(ChasteCompilerFlags)
include(ChasteMacros)

set (Chaste_VERSION_MAJOR 3 CACHE STRING "Chaste major version number")
set (Chaste_VERSION_MINOR 3 CACHE STRING "Chaste minor version number")

set(Chaste_NUM_CPUS_TEST 1 CACHE STRING  "Number of cpus to use when running tests.")

option(Chaste_VERBOSE OFF "Provide extra information when building Chaste")
if (Chaste_VERBOSE AND MSVC)
    set(CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS} "/VERBOSE")
    set(CMAKE_C_FLAGS ${CMAKE_CXX_FLAGS} "/VERBOSE")
endif()

option(Chaste_USE_VTK "Compile Chaste with VTK support" ON)
option(Chaste_USE_CVODE "Compile Chaste with CVODE support" ON)

if (NOT (WIN32 OR CYGWIN))
    option(Chaste_USE_XERCES "Compile Chaste with XERCES and XSD support" ON)
else()
    option(Chaste_USE_XERCES "Compile Chaste with XERCES and XSD support" OFF)
endif()

option(Chaste_USE_PETSC_PARMETIS "Prefer to compile Chaste with PARMETIS library used by PETSc" ON)
option(Chaste_USE_PETSC_HDF5 "Prefer to compile Chaste with HDF5 library used by PETSc" ON)
if (UNIX)
    option(Chaste_MEMORY_TESTING "Run tests using valgrind for memory testing" OFF)
    set(Chaste_MEMORY_TESTING_OUTPUT_DIR ${Chaste_BINARY_DIR}/memtest)
    if (Chaste_MEMORY_TESTING)
        file(MAKE_DIRECTORY ${Chaste_MEMORY_TESTING_OUTPUT_DIR})
    endif()
    option(Chaste_COVERAGE "Build Chaste with coverage information" OFF)
    option(Chaste_PROFILE_GPERFTOOLS "Compile Chaste with gperftools profiling support" OFF)
    option(Chaste_PROFILE_GPROF "Compile Chaste with gprof profiling support" OFF)
    if (Chaste_PROFILE_GPROF AND Chaste_PROFILE_GPERFTOOLS)
        message(WARNING "Both Chaste_PROFILE_GROF and Chaste_PROFILE_GPERFTOOLS = ON, using latter by default")
        set(Chaste_PROFILE_GROF OFF)
    endif()
    if (Chaste_PROFILE_GPROF OR Chaste_PROFILE_GPERFTOOLS)
        set(Chaste_PROFILE_OUTPUT_DIR ${Chaste_BINARY_DIR}/profile)
        file(MAKE_DIRECTORY ${Chaste_PROFILE_OUTPUT_DIR})
    endif()
    if (Chaste_COVERAGE OR Chaste_MEMORY_TESTING OR Chaste_PROFILE_GROF OR Chaste_PROFILE_GPERFTOOLS)
        set(CMAKE_BUILD_TYPE "Debug")
    endif()
endif()
option(Chaste_UPDATE_PROVENANCE "Update build timestamp. Disable to prevent re-linking of all Chaste libraries" ON)

option(RUN_TESTS OFF "This option simply runs Chaste tests. You should also set the test family.")
set(TEST_FAMILY "Continuous" CACHE STRING "The name of the test family, e.g, Continuous, Failing, Nightly, Parallel etc.")
set(TestPackTypes "Continuous;Failing;Nightly;Parallel;Production;Weekly;Profile;ProfileAssembly")

if(RUN_TESTS)
	list(FIND TestPackTypes ${TEST_FAMILY} found)
	if(found EQUAL -1)
		message(FATAL_ERROR "Test family ${TEST_FAMILY} does not exist. Must be one of ${TestPackTypes}. Aborting.")
	else(found EQUAL -1)
		#get date and time, to append to test result filename
		execute_process(COMMAND cmd /c echo %DATE% %TIME%
			WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
			OUTPUT_VARIABLE date_time
		)
		string(REGEX REPLACE "[:/. \n]" "_" date_time "${date_time}")
		# Note: set 6 minute (360s) timeout for each test
		execute_process(COMMAND ctest -C Debug --output-on-failure -O ${TEST_FAMILY}TestOutputs_${date_time}.txt --timeout 360 -L ${TEST_FAMILY}
		WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
		OUTPUT_VARIABLE t_out
		RESULT_VARIABLE t_res
		ERROR_VARIABLE t_err
		)
		message("STDOUT______________\n${t_out}")
		message("STDERR______________\n${t_err}")
	endif(found EQUAL -1)
endif(RUN_TESTS)

if (WIN32 OR CYGWIN)
	option(Chaste_AUTO_INSTALL_DEPS
		"Set whether we will automatically download and install Chaste dependences (windows-only option). ON by default"
		ON)
endif()


#Set whether this is a statically or dynamically-linked build
if (WIN32 OR CYGWIN)
option(BUILD_SHARED_LIBS
    "Set whether we are set whether to generate dynamic-linked libraries. OFF by default"
    OFF)
else()
option(BUILD_SHARED_LIBS
    "Set whether we are set whether to generate dynamic-linked libraries. ON by default"
    ON)
endif()

option(Chaste_ENABLE_TESTING "Enable Chaste Testing" ON)

#Some Chaste-specific #defines
add_definitions(-DCHASTE_CMAKE)

if(WIN32 OR CYGWIN)
    add_definitions(-D_WIN64 -D_AMD64_)
    # Ensure M_PI is always defined in cmath
    add_definitions(-D_USE_MATH_DEFINES)
endif(WIN32 OR CYGWIN)


################################
#  FIND THIRD PARTY LIBRARIES  #
################################

set(Chaste_INCLUDES ${CMAKE_CURRENT_SOURCE_DIR})
set(Chaste_LINK_LIBRARIES "")

# Check prereqs
if (Chaste_COVERAGE)
    FIND_PROGRAM( GCOV_PATH gcov )
    FIND_PROGRAM( LCOV_PATH lcov )
    FIND_PROGRAM( GENHTML_PATH genhtml )
    FIND_PROGRAM( GCOVR_PATH gcovr PATHS ${CMAKE_SOURCE_DIR}/tests)

    IF(NOT GCOV_PATH)
        MESSAGE(FATAL_ERROR "gcov not found! Aborting...")
    ENDIF() # NOT GCOV_PATH

    IF(NOT LCOV_PATH)
		MESSAGE(FATAL_ERROR "lcov not found! Aborting...")
	ENDIF() # NOT LCOV_PATH

	IF(NOT GENHTML_PATH)
		MESSAGE(FATAL_ERROR "genhtml not found! Aborting...")
	ENDIF() # NOT GENHTML_PATH
endif()



#Gperftools profiling
if (Chaste_PROFILE_GPERFTOOLS)
    find_package(Gperftools REQUIRED)
    list(APPEND Chaste_LINK_LIBRARIES "-Wl,--no-as-needed ${GPERFTOOLS_PROFILER} -Wl,--as-needed")
endif()

#Gprof executable
if (Chaste_PROFILE_GPROF)
    find_file(GPROF_EXECUTABLE gprof DOC "Gprof code profiler")
    if (GPROF_EXECUTABLE)
        message("Found GPROF_EXECUTABLE = ${GPROF_EXECUTABLE}")
    else()
        message(FATAL_ERROR "Cannot find Gprof executable for profiling")
    endif()
endif()

#Valgrind
if (Chaste_MEMORY_TESTING)
    find_package(Valgrind REQUIRED)
    if(NOT (${Chaste_NUM_CPUS_TEST} EQUAL 1))
        message(WARNING "Memory testing is turned on (Chaste_MEMORY_TESTING=ON) but you are trying to setup testing in parallel. Please set Chaste_NUM_CPUS_TEST to 1 for memory testing. Configuration and generation of tests will continue, but all tests will be run in serial")
    endif()
endif()

#Locate Python
find_package(PythonInterp REQUIRED)

if (Chaste_ENABLE_TESTING)
    find_package(TextTest)
    if (NOT TEXTTEST_FOUND)
        message(WARNING "Texttest not found, turning off acceptance tests")
    endif()
endif()

if(Chaste_AUTO_INSTALL_DEPS)
	set(Chaste_DEPS_ROOT_DIR "${Chaste_BINARY_DIR}/../install/third_party_libs" CACHE PATH "Root directory for installed third party libraries")
	  FILE(GLOB children RELATIVE ${Chaste_DEPS_ROOT_DIR} ${Chaste_DEPS_ROOT_DIR}/*)
	foreach(subdir ${children})
		if(IS_DIRECTORY ${Chaste_DEPS_ROOT_DIR}/${subdir})
			if (${subdir} MATCHES ".*boost.*" AND NOT BOOST_ROOT)
				set(BOOST_ROOT "${Chaste_DEPS_ROOT_DIR}/${subdir}")
			#elseif (${subdir} MATCHES ".*petsc.*" AND NOT ENV{PETSC_DIR})
			#	set(ENV{PETSC_DIR} "${Chaste_DEPS_ROOT_DIR}/${subdir}")
			#	set(PETSC_ARCH "")
			elseif (${subdir} MATCHES ".*vtk.*" AND NOT VTK_DIR)
				set(VTK_DIR "${Chaste_DEPS_ROOT_DIR}/${subdir}/lib/vtk-5.8")
			elseif (${subdir} MATCHES ".*sundials.*" AND NOT ENV{SUNDIALS_ROOT})
				set(ENV{SUNDIALS_ROOT} "${Chaste_DEPS_ROOT_DIR}/${subdir}")
			elseif (${subdir} MATCHES ".*hdf5.*" AND NOT ENV{HDF5_ROOT})
				set(ENV{HDF5_ROOT} "${Chaste_DEPS_ROOT_DIR}/${subdir}")
			endif()
		endif()
	endforeach()
endif()

#Locate VTK
if (Chaste_USE_VTK)
    #set(VTK_FIND_QUIETLY ON)
    find_package(VTK REQUIRED)
    list(APPEND Chaste_INCLUDES "${VTK_INCLUDE_DIRS}")
    list(APPEND Chaste_LINK_LIBRARIES "${VTK_LIBRARIES}")
    add_definitions(-DCHASTE_VTK)
endif()

#find Boost
add_definitions( -DBOOST_ALL_NO_LIB )
set( Boost_USE_STATIC_RUNTIME ON) 
if(BUILD_SHARED_LIBS)
	set( Boost_USE_STATIC_LIBS OFF) 
else()
	set( Boost_USE_STATIC_LIBS ON) 
endif()
find_package(Boost COMPONENTS filesystem system serialization REQUIRED)
list(APPEND Chaste_INCLUDES "${Boost_INCLUDE_DIR}")
list(APPEND Chaste_LINK_LIBRARIES "${Boost_LIBRARIES}")


#find PETSc
find_package(PETSc REQUIRED COMPONENTS CXX)
list(APPEND Chaste_LINK_LIBRARIES "${PETSC_LIBRARIES}")

#find HDF5
if (Chaste_USE_PETSC_HDF5)
    set(ENV{HDF5_ROOT} "${PETSC_DIR}/${PETSC_ARCH}:${PETSC_DIR}/externalpackages:$ENV{HDF5_ROOT}")
endif()
find_program( HDF5_C_COMPILER_EXECUTABLE
    NAMES h5pcc h5cc
    HINTS ENV HDF5_ROOT
    PATH_SUFFIXES bin Bin
    DOC "HDF5 Wrapper compiler.  Used only to detect HDF5 compile flags." )
find_program( HDF5_CXX_COMPILER_EXECUTABLE
    NAMES h5pc++ h5c++ 
    HINTS ENV HDF5_ROOT
    PATH_SUFFIXES bin Bin
    DOC "HDF5 C++ Wrapper compiler.  Used only to detect HDF5 compile flags." )
find_package(HDF5 MODULE REQUIRED)
if (NOT HDF5_IS_PARALLEL)
    message(SEND_ERROR "Hdf5 library found was not build with --enable-parallel, use the HDF5_ROOT environment variable to specify a parallel hdf5 library. Note: include dirs are ${HDF5_INCLUDE_DIRS} and libraries are ${HDF5_LIBRARIES}")
endif()
list(APPEND Chaste_INCLUDES "${HDF5_INCLUDE_DIRS}")
list(APPEND Chaste_LINK_LIBRARIES "${HDF5_LIBRARIES}")

# put petsc includes after hdf5 includes or else the hdf5 headers 
# in the petsc include dir will clobber those chosen on FindHdf5.cmake
list(APPEND Chaste_INCLUDES "${PETSC_INCLUDES}")


#Locate MPI 
if (PETSC_COMPILER)
    string(REPLACE mpicc mpicxx MPI_CXX_COMPILER ${PETSC_COMPILER})
endif()

if (PETSC_MPIEXEC)
    if (IS_ABSOLUTE ${PETSC_MPIEXEC})
        set(MPIEXEC ${PETSC_MPIEXEC})
    else()
        find_program(MPIEXEC ${PETSC_MPIEXEC})
    endif()
endif()
find_package(MPI REQUIRED)
SET( CMAKE_CXX_FLAGS  "${CMAKE_CXX_FLAGS} ${MPI_CXX_COMPILE_FLAGS}" )
SET( CMAKE_C_FLAGS  "${CMAKE_C_FLAGS} ${MPI_C_COMPILE_FLAGS}" )
SET( CMAKE_EXE_LINKER_FLAGS  "${CMAKE_EXE_LINKER_FLAGS} ${MPI_CXX_LINK_FLAGS}" )
list(APPEND Chaste_INCLUDES "${MPI_CXX_INCLUDE_PATH}")

if (Chaste_MEMORY_TESTING)
    get_filename_component(openmpi_supp_path ${MPIEXEC} DIRECTORY)
    get_filename_component(openmpi_supp_path ${openmpi_supp_path} DIRECTORY)
    set(openmpi_supp_path "${openmpi_supp_path}/share/openmpi/openmpi-valgrind.supp")
    set(Chaste_MEMORY_TESTING_SUPPS "--suppressions=${Chaste_SOURCE_DIR}/chaste.supp")
    set(Chaste_MEMORY_TESTING_SUPPS "${Chaste_MEMORY_TESTING_SUPPS} --suppressions=${Chaste_SOURCE_DIR}/chaste-lucid.supp")
    if (EXISTS ${openmpi_supp_path})
        set(Chaste_MEMORY_TESTING_SUPPS "${Chaste_MEMORY_TESTING_SUPPS} --suppressions=${openmpi_supp_path}")
    endif()
endif()



#find ParMETIS and METIS
if (Chaste_USE_PETSC_PARMETIS)
    set(PARMETIS_ROOT "${PETSC_DIR}/${PETSC_ARCH}" 
                      "${PETSC_DIR}/externalpackages"
                      )
endif()
find_package(ParMETIS REQUIRED)
list(APPEND Chaste_LINK_LIBRARIES "${PARMETIS_LIBRARIES}")

#Locate Sundials
if (Chaste_USE_CVODE)
    if(BUILD_SHARED_LIBS)
	    set(SUNDIALS_USE_STATIC_LIBRARIES OFF)
    else()
	    set(SUNDIALS_USE_STATIC_LIBRARIES ON)
    endif()
    find_package(SUNDIALS COMPONENTS sundials_cvode sundials_nvecserial REQUIRED)
    list(APPEND Chaste_INCLUDES "${SUNDIALS_INCLUDE_DIRS}")
    #chaste_add_libraries(Chaste_LINK_LIBRARIES Chaste_THIRD_PARTY_STATIC_LIBRARIES Chaste_LINK_LIBRARIES)
    list(APPEND Chaste_LINK_LIBRARIES "${SUNDIALS_LIBRARIES}")
    add_definitions(-DCHASTE_CVODE)
    math(EXPR Chaste_SUNDIALS_VERSION "${SUNDIALS_VERSION_MAJOR}*10000 + ${SUNDIALS_VERSION_MINOR}*100 + ${SUNDIALS_VERSION_SUBMINOR}")
    add_definitions(-DCHASTE_SUNDIALS_VERSION=${Chaste_SUNDIALS_VERSION})
endif()


# ParMETIS and Sundials might need MPI, so add MPI libraries after these
#chaste_add_libraries(MPI_CXX_LIBRARIES Chaste_THIRD_PARTY_STATIC_LIBRARIES Chaste_LINK_LIBRARIES)
list(APPEND Chaste_LINK_LIBRARIES "${MPI_CXX_LIBRARIES}")


#Locate Xerces and XSD
if (Chaste_USE_XERCES)
	find_package(Xerces REQUIRED)
	find_package(XSD REQUIRED)
	list(APPEND Chaste_INCLUDES "${XERCESC_INCLUDE}" "${XSD_INCLUDE_DIRS}")
    list(APPEND Chaste_LINK_LIBRARIES "${XERCESC_LIBRARY}")
    add_definitions(-DCHASTE_XERCES)
endif()

set(CXXTEST_INCLUDES "${CMAKE_SOURCE_DIR}/cxxtest")

add_definitions(-DTRILIBRARY -DTETLIBRARY -DANSI_DECLARATORS)

if (WIN32 OR CYGWIN)
	#MS Includes
	set(MS_MPI_INCLUDES "C:/MS_HPC_PACK_2012/Inc" CACHE PATH "Path to MS HPC Pack header files.")
	set(WINDOWS_SDK "C:/Program Files (x86)/Microsoft SDKs/Windows/v7.1A/Include" CACHE PATH "Path to Windows SDK headers.")
	set(WINDOWS_KITS "C:/Program Files (x86)/Windows Kits/8.0/Include" CACHE PATH "Path to Windows kits headers.")

	if(MSVC11)
		set(VS_11_INCLUDES "C:/Program Files (x86)/Microsoft Visual Studio 11.0/VC/include" CACHE PATH "You are compiling with MSVC 2012. Set Visual Studio 11 header files.")
		set(VS_INCLUDES "${VS_11_INCLUnstalled libvtk-java and libvtk5-qt4-devDES}")
	endif(MSVC11)

	if(MSVC10)
		set(VS_10_INCLUDES "C:/Program Files (x86)/Microsoft Visual Studio 10.0/VC/include" CACHE PATH "You are compiling with MSVC 2010. Set Visual Studio 10 header files.")
	set(VS_INCLUDES "${VS_10_INCLUDES}")
endif(MSVC10)

list(APPEND Chaste_INCLUDES "${WINDOWS_SDK}" "${VS_INCLUDES}" "${MS_MPI_INCLUDES}")

endif(WIN32 OR CYGWIN)

if(Chaste_ENABLE_TESTING)
    enable_testing()
    list(APPEND CMAKE_INCLUDE_PATH "${Chaste_SOURCE_DIR}/cxxtest")
    find_package(CxxTest)
endif()

###########################################
# SETUP AVAILABLE COMPONENTS AND PROJECTS #
###########################################

# List the available Chaste components
set(Chaste_COMPONENTS global io linalg mesh ode pde continuum_mechanics cell_based crypt)
if (NOT (WIN32 OR CYGWIN))
    set(Chaste_COMPONENTS ${Chaste_COMPONENTS} lung heart)
endif()

# Find any projects
file(GLOB potential_dirs RELATIVE "${Chaste_SOURCE_DIR}/projects" "${Chaste_SOURCE_DIR}/projects/*")
set(Chaste_PROJECTS "")
foreach(potential_dir ${potential_dirs})
    if (IS_DIRECTORY "${Chaste_SOURCE_DIR}/projects/${potential_dir}")
        # test for CMakeLists.txt file
        if (EXISTS "${Chaste_SOURCE_DIR}/projects/${potential_dir}/CMakeLists.txt")
            list(APPEND Chaste_PROJECTS "${potential_dir}")
        else()
            message(WARNING "No CMakeLists.txt file found in project directory ${Chaste_SOURCE_DIR}/projects/${potential_dir}. This project will not be built")
        endif()
    endif ()
endforeach(potential_dir ${potential_dirs})

####################################
# setup tutorial generation target #
####################################

add_custom_target(tutorials)

#################################################
# setup test pack and component testing targets #
#################################################

if (Chaste_ENABLE_TESTING) 
    foreach(type ${TestPackTypes})
        add_custom_target(${type})
    endforeach()

    foreach(component ${Chaste_COMPONENTS})
        add_custom_target(${component})
    endforeach()

    foreach(project ${Chaste_PROJECTS})
        add_custom_target(project_${project})
    endforeach()
endif()

#######################################################
# SETUP COMPONENT DEPENDANCIES AND HEADER DIRECTORIES #
#######################################################

# Specify which other components each depends on.
# This information is used to set up CMake dependencies, include search paths and libraries to link against.
set(Chaste_DEPENDS_global "")
set(Chaste_DEPENDS_io global)
set(Chaste_DEPENDS_linalg global)
set(Chaste_DEPENDS_mesh linalg global)
set(Chaste_DEPENDS_ode linalg io global)
set(Chaste_DEPENDS_pde ode mesh linalg io global)
set(Chaste_DEPENDS_cell_based pde ode mesh linalg io global)
set(Chaste_DEPENDS_crypt cell_based pde ode mesh linalg io global)
set(Chaste_DEPENDS_continuum_mechanics pde ode mesh linalg io global)
set(Chaste_DEPENDS_heart ${Chaste_DEPENDS_continuum_mechanics} continuum_mechanics)
set(Chaste_DEPENDS_lung ${Chaste_DEPENDS_continuum_mechanics} continuum_mechanics)
set(Chaste_DEPENDS_core global io linalg mesh ode pde continuum_mechanics)

set(Chaste_ALL_LIBRARIES "")
foreach(component ${Chaste_COMPONENTS})
    list(APPEND Chaste_ALL_LIBRARIES chaste_${component})
endforeach()

foreach(component ${Chaste_COMPONENTS})
    set(Chaste_${component}_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/${component}/src")
    header_dirs(${Chaste_${component}_SOURCE_DIR} Chaste_${component}_INCLUDE_DIRS)
endforeach(component)

set(Chaste_PYTHON_DIR "${Chaste_SOURCE_DIR}/python")

#####################################
#  SETUP CONFIG FOR IN-TREE BUILDS  #
#####################################

configure_file(${Chaste_SOURCE_DIR}/cmake/Config/ChasteConfig.cmake.in
    "${Chaste_BINARY_DIR}/ChasteConfig.cmake" @ONLY)

set(Chaste_DIR ${Chaste_BINARY_DIR})

####################
# BUILD COMPONENTS #
####################

foreach(component ${Chaste_COMPONENTS})
    # Build each component as a project
    add_subdirectory(${component})
endforeach(component)

####################
#  BUILD MAIN APPS #
####################

#note, heart not supported in windows
if (NOT (WIN32 OR CYGWIN))
    add_subdirectory(apps)
endif()

####################
#  BUILD PROJECTS  #
####################

foreach(projectName ${Chaste_PROJECTS})
    add_subdirectory(projects/${projectName})
endforeach(projectName)

########################################
# EXPORT CONFIG FOR OUT-OF-TREE BUILDS #
########################################

export(PACKAGE Chaste)

export(TARGETS ${Chaste_ALL_LIBRARIES} 
    FILE "${Chaste_BINARY_DIR}/ChasteTargets.cmake"
    #added in 2.8.12, need this?    EXPORT_LINK_INTERFACE_LIBRARIES 
    )

# Configure file for install dir
set(EXPORT_Chaste_PYTHON_DIR "\${Chaste_CMAKE_DIR}/python")
foreach(component ${Chaste_COMPONENTS})
    set(EXPORT_Chaste_${component}_INCLUDE_DIRS "")
    foreach(dir ${Chaste_${component}_INCLUDE_DIRS})
        file(RELATIVE_PATH rel_dir "${Chaste_SOURCE_DIR}" "${dir}")
        list(APPEND EXPORT_Chaste_${component}_INCLUDE_DIRS "\${Chaste_CMAKE_DIR}/include/${rel_dir}")
    endforeach()
endforeach(component)

configure_file(${Chaste_SOURCE_DIR}/cmake/Config/ChasteConfig.cmake.in
    "${Chaste_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/ChasteConfig.cmake" @ONLY)

# Configure file for build dir
set(EXPORT_Chaste_PYTHON_DIR "${Chaste_PYTHON_DIR}")
foreach(component ${Chaste_COMPONENTS})
    set(EXPORT_Chaste_${component}_INCLUDE_DIRS ${Chaste_${component}_INCLUDE_DIRS})
endforeach(component)

configure_file(${Chaste_SOURCE_DIR}/cmake/Config/ChasteConfig.cmake.in
    "${Chaste_BINARY_DIR}/ChasteConfig.cmake" @ONLY)


file(COPY ${Chaste_SOURCE_DIR}/cmake/Modules/ChasteMacros.cmake 
    DESTINATION ${Chaste_BINARY_DIR}/cmake/Modules)

install(FILES
    "${Chaste_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/ChasteConfig.cmake"
    "${Chaste_BINARY_DIR}/ChasteTargets.cmake"
    "${Chaste_SOURCE_DIR}/cmake/Modules/ChasteMacros.cmake"
    DESTINATION .
     COMPONENT Config)

# Python folder
install(DIRECTORY ${Chaste_SOURCE_DIR}/python
    DESTINATION .
    COMPONENT Python)

####################
#    COVERAGE      #
####################


if (Chaste_COVERAGE)
    set(CTEST_COMMAND ctest)
    set(_outputname coverage)
	ADD_CUSTOM_TARGET(coverage

		# Cleanup lcov
		${LCOV_PATH} --directory . --zerocounters

		# Run tests
        COMMAND ${CTEST_COMMAND} "-L" "Continuous|Parallel" "--output-on-failure" 

		# Capturing lcov counters and generating report
		COMMAND ${LCOV_PATH} --directory . --capture --output-file ${_outputname}.info
        COMMAND ${LCOV_PATH} --remove ${_outputname}.info /usr/* */fortests/* */3rdparty/* Debug/* cxxtest/* --output-file ${_outputname}.info.cleaned
		COMMAND ${GENHTML_PATH} --no-function-coverage -o ${_outputname} ${_outputname}.info.cleaned
		COMMAND ${CMAKE_COMMAND} -E remove ${_outputname}.info ${_outputname}.info.cleaned

        DEPENDS Continuous Parallel
        WORKING_DIRECTORY ${Chaste_BINARY_DIR}
		COMMENT "Resetting code coverage counters to zero.\nProcessing code coverage counters and generating report."
        VERBATIM
	)

	# Show info where to find the report
	ADD_CUSTOM_COMMAND(TARGET coverage POST_BUILD
		COMMAND ;
		COMMENT "Open ./${_outputname}/index.html in your browser to view the coverage report."
	)
endif()

####################
#     Doxygen      #
####################

add_custom_target(doxygen
    COMMAND ${PYTHON_EXECUTABLE} "${Chaste_SOURCE_DIR}/cmake/run-doxygen.py" "${Chaste_SOURCE_DIR}" 
                                "${Chaste_BINARY_DIR}/doxygen" "${Chaste_REVISION}"
    WORKING_DIRECTORY ${Chaste_BINARY_DIR}
    COMMENT "Generating Doxygen documentation"
    VERBATIM)

add_custom_target(doxygen_coverage
    COMMAND ${PYTHON_EXECUTABLE} "${Chaste_SOURCE_DIR}/cmake/run-doxygen.py" "${Chaste_SOURCE_DIR}" 
                                "${Chaste_BINARY_DIR}/doxygen_coverage" "${Chaste_REVISION}" "True"
    WORKING_DIRECTORY ${Chaste_BINARY_DIR}
    COMMENT "Checking Doxygen coverage"
    VERBATIM)

####################
#  MEMORY TESTING  #
####################

if (Chaste_MEMORY_TESTING)
    set(CTEST_COMMAND ctest)
    add_custom_target(memtest
        COMMAND ${CTEST_COMMAND} "-L" Continuous "--output-on-failure" 
        COMMAND ${PYTHON_EXECUTABLE} "${Chaste_SOURCE_DIR}/cmake/process_valgrind_output.py" "${Chaste_MEMORY_TESTING_OUTPUT_DIR}"
        DEPENDS Continuous
        WORKING_DIRECTORY ${Chaste_BINARY_DIR}
        VERBATIM)
endif()

####################
#     Profiling    #
####################

if (Chaste_PROFILE_GPROF OR Chaste_PROFILE_GPERFTOOLS)
    if (Chaste_PROFILE_GPERFTOOLS)
        set(extension gif)
    else()
        set(extension gmon)
    endif()
    
    set(CTEST_COMMAND ctest)
    add_custom_target(profile
        COMMAND ${CTEST_COMMAND} "-L" "Profile|ProfileAssembly" "--output-on-failure"
        COMMAND ${PYTHON_EXECUTABLE} "${Chaste_SOURCE_DIR}/cmake/process_profile.py" "${Chaste_PROFILE_OUTPUT_DIR}" ${extension}
        DEPENDS Profile ProfileAssembly
        WORKING_DIRECTORY ${Chaste_BINARY_DIR}
        VERBATIM)
endif()


####################
#    PACKAGING     #
####################

set(CPACK_PACKAGE_NAME "${CMAKE_PROJECT_NAME}")
set(CPACK_PACKAGE_VENDOR "Computational Biology Group - Computer Science - University of Oxford")
set(CPACK_PACKAGE_CONTACT "Chaste Team <chaste-admin@maillist.ox.ac.uk>")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Chaste (Cancer, Heart and Soft Tissue Environment).")
set(CPACK_PACKAGE_DESCRIPTION  "
 Chaste is a general purpose simulation package aimed at multi-scale, 
 computationally demanding problems arising in biology and physiology. 
 Current functionality includes tissue and cell level electrophysiology, 
 discrete tissue modelling, and soft tissue modelling. The package is 
 being developed by a team mainly based in the Computational Biology Group 
 at Oxford University Computing Laboratory, and development draws on expertise
 from software engineering, high performance computing, mathematical modelling
 and scientific computing.
 .
 The main website for Chaste can be found at
 http://www.cs.ox.ac.uk/chaste
")
SET(CPACK_PACKAGE_VERSION_MAJOR "${Chaste_VERSION_MAJOR}")
SET(CPACK_PACKAGE_VERSION_MINOR "${Chaste_VERSION_MINOR}")
SET(CPACK_PACKAGE_VERSION_PATCH "${chaste_revision}")


foreach(component ${Chaste_COMPONENTS})
    set(CPACK_COMPONENT_${component}_libraries_GROUP "libraries")
    set(CPACK_COMPONENT_${component}_headers_GROUP "headers")
    set(CPACK_COMPONENT_${component}_tests_GROUP "tests")


    set(CPACK_COMPONENT_${component}_headers_GROUP "headers")
    set(CPACK_COMPONENT_${component}_tests_GROUP "tests")

    set(CPACK_COMPONENT_${component}_headers_DESCRIPTION "C++ header files (.hpp) for Chaste component ${component}")
    set(CPACK_COMPONENT_${component}_tests_DESCRIPTION "Test Suite (C++ headers and source files) for Chaste component ${component}")

    if (BUILD_SHARED_LIBRARIES)
        set(CPACK_COMPONENT_${component}_libraries_DISPLAY_NAME "Dynamic Libraries")
        set(CPACK_COMPONENT_${component}_libraries_DESCRIPTION "Dynamic Libraries for Chaste component ${component}")
    else(BUILD_SHARED_LIBRARIES)
        set(CPACK_COMPONENT_${component}_libraries_DISPLAY_NAME "Static Libraries")
        set(CPACK_COMPONENT_${component}_libraries_DESCRIPTION "Static Libraries for Chaste component ${component}")
    endif(BUILD_SHARED_LIBRARIES)

    set(CPACK_COMPONENT_${component}_headers_DISPLAY_NAME "C++ Headers")
    set(CPACK_COMPONENT_${component}_tests_DISPLAY_NAME "C++ Test Suite")

    foreach(depend_component Chaste_DEPENDS_${component})
        set(CPACK_COMPONENT_${component}_headers_DEPENDS ${CPACK_COMPONENT_${component}_headers_DEPENDS} ${depend_component}_headers)
        set(CPACK_COMPONENT_${component}_libraries_DEPENDS ${CPACK_COMPONENT_${component}_libraries_DEPENDS} ${depend_component}_libraries)
        #set(CPACK_COMPONENT_${component}_tests_DEPENDS ${CPACK_COMPONENT_${component}_tests_DEPENDS} ${depend_component}_tests)
    endforeach(depend_component Chaste_DEPENDS_${component})

endforeach(component ${Chaste_COMPONENTS})



SET(CPACK_DEBIAN_PACKAGE_DEPENDS "cmake, g++, libopenmpi-dev, petsc-dev (>= 2.3.3-14), libhdf5-openmpi-dev, xsdcxx, libboost-serialization-dev, libboost-filesystem-dev, libparmetis-dev, libxerces-c2-dev, libsundials-serial-dev, libvtk5-dev, python-lxml, python-amara, python-rdflib")
set(CPACK_DEBIAN_PACKAGE_RECOMMENDS "valgrind, libfltk1.1")
set(CPACK_DEBIAN_PACKAGE_SUGGESTS "libgoogle-perftools-dev, doxygen, graphviz, eclipse-cdt, gnuplot")
set(CPACK_DEBIAN_PACKAGE_PRIORITY extra)
set(CPACK_DEBIAN_PACKAGE_SECTION science)



# This must always be last!
include(CPack)
