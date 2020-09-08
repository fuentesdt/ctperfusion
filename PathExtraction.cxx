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
  ImageType::IndexType indexstart,indexend,indexway;
    
  indexstart[0] = std::atoi(argv[3]);
  indexstart[1] = std::atoi(argv[4]);
  indexstart[2] = std::atoi(argv[5]);
  indexend[0]   = std::atoi(argv[6]);
  indexend[1]   = std::atoi(argv[7]);
  indexend[2]   = std::atoi(argv[8]);
  // 272 262 72 174 251 12
  //indexstart[0] = 272;
  //indexstart[1] = 262;
  //indexstart[2] = 72;
  //indexend[0] =174;
  //indexend[1] =251;
  //indexend[2] =12;
  //way1[0] =174;
  //way1[1] =251;
  //way1[2] =12;


  speed->TransformIndexToPhysicalPoint( indexstart, start);
  speed->TransformIndexToPhysicalPoint( indexend, end);
  std::cout << indexstart << std::endl;
  std::cout << start << std::endl;
  std::cout << indexend << std::endl;
  std::cout << end << std::endl;
  if (argc > 13)
   {
    indexway[0] = std::atoi(argv[11]);
    indexway[1] = std::atoi(argv[12]);
    indexway[2] = std::atoi(argv[13]);
    speed->TransformIndexToPhysicalPoint( indexway, way1);
    std::cout << indexway << std::endl;
    std::cout << way1 << std::endl;
   }
  speed->DisconnectPipeline();

  // Create interpolator
  using InterpolatorType = itk::LinearInterpolateImageFunction<ImageType, CoordRepType>;
  InterpolatorType::Pointer interp = InterpolatorType::New();

  // Create cost function
  PathFilterType::CostFunctionType::Pointer cost = PathFilterType::CostFunctionType::New();
  cost->SetInterpolator(interp);

  // Create path filter
  PathFilterType::Pointer pathFilter = PathFilterType::New();
  pathFilter->SetInput(speed);
  pathFilter->SetCostFunction(cost);
  PixelType TerminationValue = 2;
  if (argc > 10)
  {
    TerminationValue = std::stod(argv[10]);
  }


  std::cout << TerminationValue << std::endl;
  pathFilter->SetTerminationValue(TerminationValue );

  int useRegularStepGradientDescentOptimizer = 2;
  if (argc > 9)
   {
    useRegularStepGradientDescentOptimizer = std::atoi(argv[9]);
   }

  // Create optimizer
  if (useRegularStepGradientDescentOptimizer == 2)
   {
     std::cout << "IterateNeighborhoodOptimizer"<< std::endl;
     using OptimizerType = itk::IterateNeighborhoodOptimizer;
     OptimizerType::Pointer optimizer = OptimizerType::New();
     using NeighborhoodSizeType = itk::Array<PixelType>;
     NeighborhoodSizeType myradius(3);
     myradius[0]=2;
     myradius[1]=2;
     myradius[2]=2;
     optimizer->SetNeighborhoodSize(myradius);
     pathFilter->SetOptimizer(optimizer);
   }
  else if (useRegularStepGradientDescentOptimizer == 1)
   {
     std::cout << "RegularStepGradientDescentOptimizer"<< std::endl;
     using OptimizerType = itk::RegularStepGradientDescentOptimizer;
     OptimizerType::Pointer optimizer = OptimizerType::New();
     optimizer->SetNumberOfIterations(1000);
     optimizer->SetMaximumStepLength(0.5);
     optimizer->SetMinimumStepLength(0.1);
     optimizer->SetRelaxationFactor(0.5);
     pathFilter->SetOptimizer(optimizer);
   }
  else
   {
     std::cout << "GradientDescentOptimizer"<< std::endl;
     using OptimizerType = itk::GradientDescentOptimizer;
     OptimizerType::Pointer optimizer = OptimizerType::New();
     optimizer->SetNumberOfIterations(1000);
     pathFilter->SetOptimizer(optimizer);
   }


  // Add path information
  using PathInformationType = PathFilterType::PathInformationType;
  PathInformationType::Pointer info = PathInformationType::New();
  info->SetStartPoint(start);
  info->SetEndPoint(end);
  if (argc > 13) info->AddWayPoint(way1);
  info->Print(std::cout);

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
      std::cout << "MeshPoints: " << vertexList->GetElement(i) << std::endl;
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
  if (argc < 9)
  {
    std::cerr << "Usage: MinimalPathExtraction OutputImage SpeedImage startIdX startIdY startIdZ endIdX endIdY endIdZ [UseRegularStepGradientDescentOptimizer]  [wayIdX] [wayIdY] [wayIdZ] [TerminationValue]  "
              << std::endl;
    return EXIT_FAILURE;
  }

  return example_gradientdescent(argc, argv);
}
