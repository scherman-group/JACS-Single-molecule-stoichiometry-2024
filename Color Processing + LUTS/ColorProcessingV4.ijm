		Dialog.create("Color Processing");
		Dialog.addNumber("       File Number:", 1);
		Dialog.addNumber("       Radius Expander:", 0);
		Dialog.addMessage("..................................................................................................................................................................................................................");
		Dialog.addNumber("       Intensity Min: ", 0);
		Dialog.addNumber("       Intensity Max: ", 4096);
		Dialog.addNumber("       Range Min: ", 0);
		Dialog.addNumber("       Range Max: ", 13297);
		Dialog.addNumber("       Gaussian Blur (sigma): ", 0.0);		
		Dialog.addMessage("..................................................................................................................................................................................................................");
		Dialog.show()
		FileNumber=Dialog.getNumber();
		RadiusExpander=Dialog.getNumber();
		IntMin=Dialog.getNumber();
		IntMax=Dialog.getNumber();
		RangeMin=Dialog.getNumber();
		RangeMax=Dialog.getNumber();
		GBlur=Dialog.getNumber();

		root = getDirectory("image");

		//Adjust Min and Max
		setMinAndMax(IntMin,IntMax);
		
		//Clear Previous ROIs if any were loaded
		
		ROIsize=roiManager("count")
		if(ROIsize>0)
		{
		roiManager("Deselect");
		roiManager("Delete");
		}
		
		//Import ROI file
		roiManager("Open",root+'01_ROIset_SUM' + '.zip');
		
		//Run Perimeter Feature Expander (to Shrink Features to Original Size)
		size=roiManager("Count"); //get number of ROIs
		run("Set Scale...", "distance=1 known=1");
		for (n=1; n<=size; n=n+1)   
		{
		roiManager("Select", n-1);
		run("Enlarge...", "enlarge=RadiusExpander");
		roiManager("Update");
		}
		roiManager("Deselect");
		
		//
		run("Clear Results");
		lineseparator = "\n";
   		cellseparator = ",\t";

     		// copies the whole RT to an array of lines
		pathfile=root + "Tphotons_preremoval_" + FileNumber + ".csv";
		filestring=File.openAsString(pathfile);
	        lines=split(filestring, lineseparator);

     		// recreates the columns headers
     		labels=split(lines[0], cellseparator);
    		 if (labels[0]==" ")
       		 k=1; // it is an ImageJ Results table, skip first column
    		 else
      		  k=0; // it is not a Results table, load all columns
     		for (j=k; j<labels.length; j++)
      		  setResult(labels[j],0,0);

     		// dispatches the data into the new RT
  		   run("Clear Results");
   		  for (i=1; i<lines.length; i++) {
      		  items=split(lines[i], cellseparator);
      		  for (j=k; j<items.length; j++)
       		    setResult(labels[j],i-1,items[j]);
  		   }
  		   updateResults();
		 
		//
		for (n=0; n<=(size-1); n=n+1)  
		{
		currentResult=getResult("Budget",n);
		if(currentResult==0)
		{
		roiManager("Select", n);
		roiManager("Delete");
		IJ.deleteRows(n,n);
		n=n-1;
		size=size-1;
		}
		if(currentResult>500000)
		{
		roiManager("Select", n);
		roiManager("Delete");
		IJ.deleteRows(n,n);
		n=n-1;
		size=size-1;
		}
		}

		 //Run Color Coder
		   run("ROI Color Coder", "measurement=Budget lut=redyellow-2color width=0 opacity=80 range="+RangeMin+"-"+RangeMax+" n.=5 decimal=0 ramp=[256 pixels] font=Arial font_size=16 draw");
		   selectWindow("FrameAveragedMax.tif");

	//Fix Overlay
	run("Flatten");

	//Apply Unsharp Mask (Makes Colors Pop)
	//run("Unsharp Mask...", "radius=1 mask=0.60");

	//Apply Gaussian Blur
	run("Gaussian Blur...", "sigma="+GBlur+"");

	//Save Image
	saveAs("TIF",root + "Color_Image" + "_GB" + GBlur + "_" + RangeMin + "_" + RangeMax);

	//Multiplies binary (0-1; no signal-color signal) colorized image by normalized framemax image to retrieve correct intensities
	selectWindow("FrameAveragedMax.tif");
	close();
	pathfile_FrameAveragedMax=root + "FrameAveragedMax" + ".tif";
	open(pathfile_FrameAveragedMax);
	run("Enhance Contrast...", "saturated=0 normalize"); //normalizes Framemax image, enhanced contrast is set to 0
	colorimage = "Color_Image" + "_GB" + GBlur + "_" + RangeMin + "_" + RangeMax + ".tif";
	selectWindow(colorimage);
	run("HSB Stack");
	setSlice(3);
	imageCalculator("Multiply",colorimage,"FrameAveragedMax.tif");
	run("RGB Color");

	//Save Image
	saveAs("TIF",root + "Color_Image" + "_GB" + GBlur + "_" + RangeMin + "_" + RangeMax + "_intensity_multiplied");