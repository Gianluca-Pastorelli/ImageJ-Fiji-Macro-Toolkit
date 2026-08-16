// ---------------------------
// Batch Image Processing Tool
// ---------------------------

// --- User Input Window ---
Dialog.create("Batch Image Processor");

Dialog.addMessage("Select folders");
Dialog.addDirectory("Input folder:", "");
Dialog.addDirectory("Output folder:", "");
Dialog.addMessage("WARNING:\nOriginal files will be overwritten if input and output folders are the same,\nunless the output format is changed.");

Dialog.addCheckbox("Enable image resizing", false);
Dialog.addNumber("Target width (px):", 1000);
Dialog.addNumber("Target height (px):", 1000);
Dialog.addChoice("Interpolation:", 
    newArray("None", "Bilinear", "Bicubic"), 
    "Bilinear");

Dialog.addMessage("Rotation and flipping");
Dialog.addChoice("Rotate",
    newArray("No", "90 deg clockwise", "90 deg counterclockwise", "180 deg"),
    "No");
Dialog.addCheckbox("Flip horizontal (left becomes right)", false);
Dialog.addCheckbox("Flip vertical (up becomes down)", false);

Dialog.addMessage("Conversions and enhancements");
Dialog.addCheckbox("Convert indexed to gray LUT", false);
Dialog.addCheckbox("Normalize contrast", false);
Dialog.addCheckbox("Convert to 8-bit", false);

Dialog.addMessage("Output format");
Dialog.addCheckbox("Add brightness rank to filename", false);
Dialog.addChoice("Save images as:",
    newArray("Same as original", "Tiff", "Jpeg", "PNG"),
    "Same as original");

Dialog.show();

// --- Read user choices ---
inputDir      = Dialog.getString();
outputDir     = Dialog.getString();

doResize      = Dialog.getCheckbox();
tWidth        = Dialog.getNumber();
tHeight       = Dialog.getNumber();
interp        = Dialog.getChoice();

rotation      = Dialog.getChoice();
flipH         = Dialog.getCheckbox();
flipV         = Dialog.getCheckbox();

toGrayLUT     = Dialog.getCheckbox();
normalize     = Dialog.getCheckbox();
to8bit        = Dialog.getCheckbox();

addRank       = Dialog.getCheckbox();
saveFormat    = Dialog.getChoice();

// Ensure directory format ends with /
if (!endsWith(inputDir, File.separator)) {
    inputDir += File.separator;
}

if (!endsWith(outputDir, File.separator)) {
    outputDir += File.separator;
}

// Create output folder if it does not exist
if (!File.exists(outputDir)) {
    File.makeDirectory(outputDir);
}

// Get list of images
list = getFileList(inputDir);

// Remember exactly which output files were created
outputFiles = newArray(list.length);
outputCount = 0;

// ---------------------------
// Processing Loop
// ---------------------------

for (i = 0; i < list.length; i++) {

    file = list[i];
    lower = toLowerCase(file);

    // Process only common image formats
    if (endsWith(lower, ".tif") || endsWith(lower, ".tiff") ||
        endsWith(lower, ".jpg") || endsWith(lower, ".jpeg") ||
        endsWith(lower, ".png")) {

        fullPath = inputDir + file;

        print("Processing: " + fullPath);

        open(fullPath);

        // --- Resize ---
        if (doResize) {

            interpParam = "";

            if (interp != "None") {
                interpParam = " interpolation=" + interp;
            }

            run("Size...",
                "width=" + tWidth +
                " height=" + tHeight +
                interpParam);
        }

        // --- Rotation and flipping ---
        if (rotation == "90 deg clockwise") {

            run("Rotate 90 Degrees Right");

        } else if (rotation == "90 deg counterclockwise") {

            run("Rotate 90 Degrees Left");

        } else if (rotation == "180 deg") {

            run("Rotate 90 Degrees Right");
            run("Rotate 90 Degrees Right");
        }

        if (flipH) {
            run("Flip Horizontally");
        }

        if (flipV) {
            run("Flip Vertically");
        }

        // --- Convert LUT indexed → gray ---
        if (toGrayLUT) {
            run("Grays");
        }

        // --- Normalize contrast ---
        if (normalize) {
            run("Enhance Contrast...", "saturated=0.35 normalize");
        }

        // --- Convert to 8 bit ---
        if (to8bit) {
            run("8-bit");
        }

        // -------------------------------------------------
        // Determine output filename
        // -------------------------------------------------

        dotIndex = lastIndexOf(file, ".");

        if (dotIndex == -1) {
            nameWithoutExt = file;
        } else {
            nameWithoutExt = substring(file, 0, dotIndex);
        }

        // -------------------------------------------------
        // Save processed image
        // -------------------------------------------------

        if (saveFormat != "Same as original") {

            if (saveFormat == "Tiff") {

                outputFile = nameWithoutExt + ".tif";
                saveAs("Tiff", outputDir + outputFile);

            } else if (saveFormat == "Jpeg") {

                outputFile = nameWithoutExt + ".jpg";
                saveAs("Jpeg", outputDir + outputFile);

            } else if (saveFormat == "PNG") {

                outputFile = nameWithoutExt + ".png";
                saveAs("PNG", outputDir + outputFile);
            }

        } else {

            // Preserve original format
            if (endsWith(lower, ".tif") ||
                endsWith(lower, ".tiff")) {

                outputFile = file;
                saveAs("Tiff", outputDir + outputFile);

            } else if (endsWith(lower, ".jpg") ||
                       endsWith(lower, ".jpeg")) {

                outputFile = file;
                saveAs("Jpeg", outputDir + outputFile);

            } else if (endsWith(lower, ".png")) {

                outputFile = file;
                saveAs("PNG", outputDir + outputFile);
            }
        }

        // Remember exactly which output file was created
        outputFiles[outputCount] = outputFile;
        outputCount++;

        // Close the image
        close();
    }
}

// ---------------------------
// Brightness Ranking
// ---------------------------

if (addRank && outputCount > 0) {

    print("Calculating brightness ranking...");

    // Arrays for brightness and filenames
    brightness = newArray(outputCount);
    rankFiles = newArray(outputCount);

    // -----------------------------------------
    // Measure brightness of FINAL output images
    // -----------------------------------------

    for (i = 0; i < outputCount; i++) {

        file = outputFiles[i];

        print("Measuring: " + file);

        open(outputDir + file);

        getRawStatistics(nPixels, mean);

        // Sum brightness
        brightness[i] = mean * nPixels;

        rankFiles[i] = file;

        close();
    }

    // -----------------------------------------
    // Sort brightest → darkest
    // -----------------------------------------

    Array.sort(brightness, rankFiles);

    Array.reverse(brightness);
    Array.reverse(rankFiles);

    // -----------------------------------------
    // Rename files according to brightness rank
    // -----------------------------------------

    // First rename to temporary unique names.
    // This prevents filename collisions while
    // swapping files around.
    tempNames = newArray(outputCount);

    for (i = 0; i < outputCount; i++) {

        oldName = rankFiles[i];

        tempName = "__rank_tmp_" + i + "_" + oldName;

        File.rename(
            outputDir + oldName,
            outputDir + tempName
        );

        tempNames[i] = tempName;
    }

    // -----------------------------------------
    // Rename temporary files to final names
    // -----------------------------------------

    for (i = 0; i < outputCount; i++) {

        oldName = rankFiles[i];

        // Split extension
        dotIndex = lastIndexOf(oldName, ".");

        if (dotIndex == -1) {

            base = oldName;
            ext = "";

        } else {

            base = substring(oldName, 0, dotIndex);
            ext = substring(oldName, dotIndex);
        }

        // Four-digit brightness rank
        rank = IJ.pad(i + 1, 4);

        newName = rank + "_" + base + ext;

        print("Rank " + rank + ": " + oldName);

        File.rename(
            outputDir + tempNames[i],
            outputDir + newName
        );
    }

    print("Brightness ranking completed.");
}

print("Processing completed.");