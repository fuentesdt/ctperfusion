/*=========================================================================
 *
 *  Copyright NumFOCUS
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *         http://www.apache.org/licenses/LICENSE-2.0.txt
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 *=========================================================================*/
#include "itkBinaryThinningImageFilter.h"
#include "itkImage.h"
#include "itkImageFileReader.h"
#include "itkImageFileWriter.h"
#include "itkRescaleIntensityImageFilter.h"

using ImageType = itk::Image<unsigned char, 3>;


int
main(int argc, char * argv[])
{
  ImageType::Pointer image = ImageType::New();
  if (argc <  3)
  {
    std::cerr << "Missing Parameters " << std::endl;
    std::cerr << "Usage: " << argv[0];
    std::cerr << " inputImage  outputImage "
              << std::endl;
    return EXIT_FAILURE;
  }

  using ImageReader = itk::ImageFileReader<ImageType>;
  ImageReader::Pointer reader = ImageReader::New();
  std::string          fileName = argv[1];
  reader->SetFileName(fileName);
  reader->Update();
  image = reader->GetOutput();
  image->Print(std::cout);

  using BinaryThinningImageFilterType = itk::BinaryThinningImageFilter<ImageType, ImageType>;
  BinaryThinningImageFilterType::Pointer binaryThinningImageFilter = BinaryThinningImageFilterType::New();
  binaryThinningImageFilter->SetInput(image);
  binaryThinningImageFilter->Update();

  // Rescale the image so that it can be seen (the output is 0 and 1, we want 0 and 255)
  using RescaleType = itk::RescaleIntensityImageFilter<ImageType, ImageType>;
  RescaleType::Pointer rescaler = RescaleType::New();
  rescaler->SetInput(binaryThinningImageFilter->GetOutput());
  rescaler->SetOutputMinimum(0);
  rescaler->SetOutputMaximum(255);
  rescaler->Update();

  using WriterType = itk::ImageFileWriter<ImageType>;
  WriterType::Pointer writer = WriterType::New();
  writer->SetFileName(argv[2]);
  writer->SetInput(rescaler->GetOutput());
  writer->Update();

  return EXIT_SUCCESS;
}


