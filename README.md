# ImageJ/Fiji Macro Toolkit

A collection of ImageJ/Fiji macros for image processing, registration, and file conversion.

## Macros

### Batch Image Processor

This macro provides batch processing of common image formats, including TIFF, JPEG, and PNG files.

It can optionally perform image resizing, rotation, horizontal and vertical flipping, grayscale LUT conversion, contrast normalization, 8-bit conversion, and output format conversion.

The macro can also optionally calculate the brightness of the processed images and add a four-digit brightness rank to their filenames, with the brightest image receiving rank `0001`.

#### Features

- Batch processing of TIFF, JPEG, and PNG images
- Optional image resizing with selectable interpolation
- Rotation by 90°, 180°, or 270°
- Horizontal and vertical flipping
- Conversion to grayscale LUT
- Contrast normalization
- Conversion to 8-bit
- Saving in the original format or as TIFF, JPEG, or PNG
- Optional brightness-based ranking of the processed images

#### Usage

1. **Select folders**
   - Choose the input folder containing the images to process.
   - Choose the output folder for the processed images.

2. **Select processing options**
   - Enable or disable resizing, rotation, flipping, grayscale conversion, contrast normalization, and 8-bit conversion as needed.

3. **Select output format**
   - Keep the original format or convert the images to TIFF, JPEG, or PNG.

4. **Optional brightness ranking**
   - Enable the brightness ranking option to rank the final processed images from brightest to darkest.
   - A four-digit rank is added to the beginning of each filename, e.g. `0001_image.tif`.

5. **Output**
   - Processed images are saved in the selected output folder.

> **Warning:** If the input and output folders are the same, the original files may be overwritten unless the output format is changed.

---

### XRF-RGB Image Registration

This macro is designed to register a set of MA-XRF (macro X-ray fluorescence spectroscopy) images to a visible (RGB) image.

The registration is based on selecting corresponding points in both the RGB and XRF images using the **Landmark Correspondences** plugin. The macro then applies an **Affine transformation** to align the XRF images with the RGB image.

#### Requirements

- [ImageJ](https://imagej.nih.gov/ij/) or Fiji
- [Landmark Correspondences](https://imagej.net/plugins/landmark-correspondences) plugin

#### Usage

1. **Open RGB image**
   - Run the macro and choose the RGB image when prompted.

2. **Select XRF image**
   - Choose an XRF image containing visible features that can be matched to the RGB image.

3. **Select corresponding points**
   - Select at least 10 points on the RGB image using the multi-point selection tool.
   - Select the corresponding points on the XRF image in the same order.

4. **Register XRF images**
   - The macro uses Landmark Correspondences to apply an Affine transformation to the XRF images.

5. **Output**
   - Registered images are saved as TIFF files in a `Registered` subfolder within the original XRF image directory.


## Requirements

The macros are written in the ImageJ macro language and are intended to run in **ImageJ or Fiji**.

The **XRF-RGB Image Registration** macro additionally requires the **Landmark Correspondences** plugin.

## Installation and General Usage

1. Clone or download this repository.
2. Open ImageJ or Fiji.
3. Open the desired `.ijm` macro or run it using **Plugins → Macros → Run...**.
4. Follow the on-screen instructions for the selected macro.
