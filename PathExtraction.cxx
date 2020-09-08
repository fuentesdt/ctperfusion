// General includes
#include <string>
#include <iostream>

// ITK includes
#include "itkNumericTraits.h"
#include "itkImage.h"
#include "itkImageFileReader.h"
#include "itkImageFileWriter.h"
#include "itkPolyLineParametricPath.h"
#include "itkNearestNeighborInterpolateImageFunction.h"
#include "itkLinearInterpolateImageFunction.h"
#include "itkArrivalFunctionToPathFilter.h"
#include "itkSpeedFunctionToPathFilter.h"
#include "itkPathIterator.h"
#include "itkGradientDescentOptimizer.h"
#include "itkRegularStepGradientDescentOptimizer.h"
#include "itkIterateNeighborhoodOptimizer.h"

int
example_gradientdescent(int argc, char * argv[])
{
  // Typedefs
  constexpr unsigned int Dimension = 3;
  using PixelType = float;
  using OutputPixelType = unsigned char;
  using ImageType = itk::Image<PixelType, Dimension>;
  using OutputImageType = itk::Image<OutputPixelType, Dimension>;
  using ReaderType = itk::ImageFileReader<ImageType>;
  using WriterType = itk::ImageFileWriter<OutputImageType>;
  using PathType = itk::PolyLineParametricPath<Dimension>;
  using PathFilterType = itk::SpeedFunctionToPathFilter<ImageType, PathType>;
  using CoordRepType = PathFilterType::CostFunctionType::CoordRepType;
  using PathIteratorType = itk::PathIterator<OutputImageType, PathType>;

  // Get filename arguments
  unsigned int argi = 1;
  const char * outputFileName = argv[argi++];
  const char * speedFileName = argv[argi++];

  // Read speed function
  ReaderType::Pointer reader = ReaderType::New();
  reader->SetFileName(speedFileName);
  reader->Update();
  ImageType::Pointer speed = reader->GetOutput();

  // Setup path points
  PathFilterType::PointType start, end, way1;
  ImageType::IndexType indexstart,indexend;
  indexstart[0] = 272;
  indexstart[1] = 262;
  indexstart[2] = 72;
  indexend[0] =174;
  indexend[1] =251;
  indexend[2] =12;
  way1[0] =174;
  way1[1] =251;
  way1[2] =12;


  speed->TransformIndexToPhysicalPoint( indexstart, start);
  speed->TransformIndexToPhysicalPoint( indexend, end);
  
  std::cout << indexstart << std::endl;
  std::cout << start << std::endl;
  std::cout << indexend << std::endl;
  std::cout << end << std::endl;
  std::cout << speed->TransformPhysicalPointToIndex( way1) << std::endl;

  speed->DisconnectPipeline();

  // Create interpolator
  using InterpolatorType = itk::LinearInterpolateImageFunction<ImageType, CoordRepType>;
  InterpolatorType::Pointer interp = InterpolatorType::New();

  // Create cost function
  PathFilterType::CostFunctionType::Pointer cost = PathFilterType::CostFunctionType::New();
  cost->SetInterpolator(interp);

  // Create optimizer
  //using OptimizerType = itk::GradientDescentOptimizer;
  using OptimizerType = itk::IterateNeighborhoodOptimizer;
  OptimizerType::Pointer optimizer = OptimizerType::New();
  //optimizer->SetNumberOfIterations(1000);
  using NeighborhoodSizeType = itk::Array<PixelType>;
  NeighborhoodSizeType myradius(3);
  myradius[0]=2;
  myradius[1]=2;
  myradius[2]=2;
  optimizer->SetNeighborhoodSize(myradius);

  // Create path filter
  PathFilterType::Pointer pathFilter = PathFilterType::New();
  pathFilter->SetInput(speed);
  pathFilter->SetCostFunction(cost);
  pathFilter->SetOptimizer(optimizer);
  PixelType TerminationValue = std::stod(argv[4]);
  std::cout << TerminationValue << std::endl;
  pathFilter->SetTerminationValue(TerminationValue );

  // Add path information
  using PathInformationType = PathFilterType::PathInformationType;
  PathInformationType::Pointer info = PathInformationType::New();
  info->SetStartPoint(start);
  info->SetEndPoint(end);
  //info->AddWayPoint(way1);
  pathFilter->AddPathInformation(info);

  // Compute the path
  pathFilter->Update();

  // Allocate output image
  OutputImageType::Pointer output = OutputImageType::New();
  output->SetRegions(speed->GetLargestPossibleRegion());
  output->SetSpacing(speed->GetSpacing());
  output->SetOrigin(speed->GetOrigin());
  output->Allocate();
  output->FillBuffer(itk::NumericTraits<OutputPixelType>::Zero);

  // Rasterize path
  for (unsigned int i = 0; i < pathFilter->GetNumberOfOutputs(); i++)
  {
    // Get the path
    PathType::Pointer path = pathFilter->GetOutput(i);
    const PathType::VertexListType * vertexList = path->GetVertexList();

    // Check path is valid
    if (vertexList->Size() == 0)
    {
      std::cout << "WARNING: Path " << (i + 1) << " contains no points!" << std::endl;
      continue;
    }
    for (unsigned int i = 0; i < vertexList->Size(); ++i)
    {
      std::cout << vertexList->GetElement(i) << std::endl;
    }
 

    // Iterate path and convert to image
    PathIteratorType it(output, path);
    for (it.GoToBegin(); !it.IsAtEnd(); ++it)
    {
      it.Set(itk::NumericTraits<OutputPixelType>::max());
    }
  }

  // Write output
  WriterType::Pointer writer = WriterType::New();
  writer->SetFileName(outputFileName);
  writer->SetInput(output);
  writer->Update();

  // Return
  return EXIT_SUCCESS;
}

int
example_regularstepgradientdescent(int argc, char * argv[])
{
  // Typedefs
  constexpr unsigned int Dimension = 3;
  using PixelType = float;
  using OutputPixelType = unsigned char;
  using ImageType = itk::Image<PixelType, Dimension>;
  using OutputImageType = itk::Image<OutputPixelType, Dimension>;
  using ReaderType = itk::ImageFileReader<ImageType>;
  using WriterType = itk::ImageFileWriter<OutputImageType>;
  using PathType = itk::PolyLineParametricPath<Dimension>;
  using PathFilterType = itk::SpeedFunctionToPathFilter<ImageType, PathType>;
  using CoordRepType = PathFilterType::CostFunctionType::CoordRepType;
  using PathIteratorType = itk::PathIterator<OutputImageType, PathType>;

  // Get filename arguments
  unsigned int argi = 1;
  const char * outputFileName = argv[argi++];
  const char * speedFileName = argv[argi++];

  // Read speed function
  ReaderType::Pointer reader = ReaderType::New();
  reader->SetFileName(speedFileName);
  reader->Update();
  ImageType::Pointer speed = reader->GetOutput();
  speed->DisconnectPipeline();

  // Create interpolator
  using InterpolatorType = itk::LinearInterpolateImageFunction<ImageType, CoordRepType>;
  InterpolatorType::Pointer interp = InterpolatorType::New();

  // Create cost function
  PathFilterType::CostFunctionType::Pointer cost = PathFilterType::CostFunctionType::New();
  cost->SetInterpolator(interp);

  // Create optimizer
  using OptimizerType = itk::RegularStepGradientDescentOptimizer;
  OptimizerType::Pointer optimizer = OptimizerType::New();
  optimizer->SetNumberOfIterations(1000);
  optimizer->SetMaximumStepLength(0.5);
  optimizer->SetMinimumStepLength(0.1);
  optimizer->SetRelaxationFactor(0.5);

  // Create path filter
  PathFilterType::Pointer pathFilter = PathFilterType::New();
  pathFilter->SetInput(speed);
  pathFilter->SetCostFunction(cost);
  pathFilter->SetOptimizer(optimizer);
  pathFilter->SetTerminationValue(std::stod(argv[4]));

  // Setup path points
  PathFilterType::PointType start, end, way1;
  start[0] = 272;
  start[1] = 262;
  start[2] = 72;
  end[0] =174;
  end[1] =251;
  end[2] =12;
  way1[0] = 10;
  way1[1] = 10;

  // Add path information
  using PathInformationType = PathFilterType::PathInformationType;
  PathInformationType::Pointer info = PathInformationType::New();
  info->SetStartPoint(start);
  info->SetEndPoint(end);
  //info->AddWayPoint(way1);
  pathFilter->AddPathInformation(info);

  // Compute the path
  pathFilter->Update();
  pathFilter->Print(std::cout);

  // Allocate output image
  OutputImageType::Pointer output = OutputImageType::New();
  output->SetRegions(speed->GetLargestPossibleRegion());
  output->SetSpacing(speed->GetSpacing());
  output->SetOrigin(speed->GetOrigin());
  output->Allocate();
  output->FillBuffer(itk::NumericTraits<OutputPixelType>::Zero);

  // Rasterize path
  for (unsigned int i = 0; i < pathFilter->GetNumberOfOutputs(); i++)
  {
    // Get the path
    PathType::Pointer path = pathFilter->GetOutput(i);

    // Check path is valid
    if (path->GetVertexList()->Size() == 0)
    {
      std::cout << "WARNING: Path " << (i + 1) << " contains no points!" << std::endl;
      continue;
    }

    // Iterate path and convert to image
    PathIteratorType it(output, path);
    for (it.GoToBegin(); !it.IsAtEnd(); ++it)
    {
      it.Set(itk::NumericTraits<OutputPixelType>::max());
    }
  }

  // Write output
  WriterType::Pointer writer = WriterType::New();
  writer->SetFileName(outputFileName);
  writer->SetInput(output);
  writer->Update();

  // Return
  return EXIT_SUCCESS;
}

int
main(int argc, char * argv[])
{
  if (argc < 3)
  {
    std::cerr << "Usage: MinimalPathExtraction <OutputImage> <SpeedImage> [UseRegularStepGradientDescentOptimizer] seedX seedY seedZ "
              << std::endl;
    return EXIT_FAILURE;
  }

  int useRegularStepGradientDescentOptimizer = 0;
  if (argc > 3)
  {
    useRegularStepGradientDescentOptimizer = std::atoi(argv[3]);
  }

  if (useRegularStepGradientDescentOptimizer)
  {
    return example_regularstepgradientdescent(argc, argv);
  }
  return example_gradientdescent(argc, argv);
}
