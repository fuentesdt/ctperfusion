# This is the root ITK CMakeLists file.
cmake_minimum_required(VERSION 3.10.2 FATAL_ERROR)
foreach(p
    ## Only policies introduced after the cmake_minimum_required
    ## version need to explicitly be set to NEW.
    CMP0070 #3.10.0 Define ``file(GENERATE)`` behavior for relative paths.
    CMP0071 #3.10.0 Let ``AUTOMOC`` and ``AUTOUIC`` process ``GENERATED`` files.
    )
  if(POLICY ${p})
    cmake_policy(SET ${p} NEW)
  endif()
endforeach()


# This project is designed to be built outside the Insight source tree.
project(perfusion)

# Find ITK.
find_package(ITK REQUIRED)
include(${ITK_USE_FILE})

add_executable(itkSLICImageFilter itkSLICImageFilter.cxx )
add_executable(ImageReadWrite     ImageReadWrite.cxx )
add_executable(ConnectedThresholdImageFilter ConnectedThresholdImageFilter.cxx )
add_executable(ConvertImageWithLabelsToShapeLabelMap ConvertImageWithLabelsToShapeLabelMap.cxx )
add_executable(ShapeAttributesForBinaryImage ShapeAttributesForBinaryImage.cxx )
add_executable(ThinImage  ThinImage.cxx )


target_link_libraries(itkSLICImageFilter  ${ITK_LIBRARIES})
target_link_libraries(ImageReadWrite      ${ITK_LIBRARIES})
target_link_libraries(ConnectedThresholdImageFilter ${ITK_LIBRARIES})
target_link_libraries(ConvertImageWithLabelsToShapeLabelMap ${ITK_LIBRARIES})
target_link_libraries(ShapeAttributesForBinaryImage ${ITK_LIBRARIES})
target_link_libraries(ThinImage  ${ITK_LIBRARIES})

