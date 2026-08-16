macro "Register XRF and RGB Images" {

// Open the RGB image
  openPath = File.openDialog("Choose the template RGB image");
  open(openPath);
  RGB_Image = getTitle();

// Open the XRF image
  openPath = File.openDialog("Choose a target XRF image (or image sequence) with visible features");
  open(openPath);
  XRF_Image = getTitle();
  
// Get the XRF directory and the list of XRF images
   dir = getDirectory("image");
  files = getFileList(dir);
    
// Select points on the RGB image
  selectWindow(RGB_Image)
  waitForUser("Select at least 10 points on the RGB image using the multi-point selection tool")

// Select corresponding points on the XRF image and add them to ROI
  selectWindow(XRF_Image)
  waitForUser("Select the corresponding points in the same order on the XRF image (zoom in if needed)");
  run("ROI Manager...");
  roiManager("Add");

// Create a new folder for registered images
  NewFolder = dir + File.separator + "Registered" + File.separator;
  File.makeDirectory(NewFolder);

// Iterate through the list of XRF images
  for (i = 0; i < files.length; i++) {
    open(dir + files[i]);
    XRF_Image = getTitle();
    
    // Select the previously added ROI
    roiManager("Select", 0);
    setOption("Changes",false); // resets the 'changes' flag of the current image
    
    // Use the `Transform -> Landmark Correspondence` plugin (to resample images, add interpolate after Affine)
    run("Landmark Correspondences", "source_image=XRF_Image template_image=RGB_Image transformation_method=[Least Squares] alpha=1 mesh_resolution=32 transformation_class=Affine");
  
  	// Save the transformed image in the "Registered" folder
  	originalTitle = files[i];
  	saveAs("tiff", NewFolder+originalTitle);
  }
  
// Close all opened images and the ROI manager
  while (nImages>0) { 
    selectImage(nImages);
    close(); 
  } 
    close("ROI Manager");
    
// Display a message indicating that images have been saved
	print("Registration completed successfully! The images are saved in the 'Registered' sub-folder in the original XRF directory.");
}
