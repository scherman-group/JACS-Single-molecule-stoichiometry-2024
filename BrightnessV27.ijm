		//Dialog Boxes; Jump to 'Code Begins Here' for Code
		
		Dialog.create("Brightness Calculator");
			Dialog.addMessage("Welcome to 'The Scherman Lab' (TM) Brightness Calculator.");
			Dialog.addMessage("The following code will calculate the brightness of your single molecules.");
			Dialog.addMessage("..................................................................................................................................................................................................................");
			Dialog.addMessage("Camera/Collection Settings");
			Dialog.addMessage("If you are pre-processing bias and gain set values to 0 (bias) and 1 (gain).");
			Dialog.addMessage("If you do not want to factor in collection efficiency, set to 1.");
			Dialog.addNumber("       Camera Bias (Mean): ", 100);
			Dialog.addNumber("       Camera Gain (Mean): ", 4);
			Dialog.addNumber("       Collection Efficiency (Default 0.95*0.5*0.95*0.95*0.9 **Under Revision): ", 0.95);
			Dialog.addNumber("       Photon-to-Signal Efficiency Factor ", 1);
			Dialog.addMessage("..................................................................................................................................................................................................................");
		Dialog.show()
		Bias=Dialog.getNumber();
		Gain=Dialog.getNumber();
		Collection=Dialog.getNumber();
		EfficiencyF=Dialog.getNumber();

		Dialog.create("Brightness Calculator 2");
			Dialog.addMessage("Threshold Settings");
			Dialog.addNumber("       Signal-to-Noise Multiplier Start(x times above Noise): ", 3.0);
			Dialog.addNumber("       Signal-to-Noise Multiplier End(x times above Noise): ", 60.0);
			Dialog.addNumber("       Signal-to-Noise Multiplier Step Size: ", 1);
			Dialog.addCheckbox("Rolling Ball Correction (Does Not Apply to Integral, Only to Image for Threshold Identification)?", true);
			Dialog.addNumber("       Rolling Ball Radius, Pixels (Only Active if Rolling Ball Correction Checked): ", 5);
			Dialog.addNumber("       Particle Area Min (Units: Pixels): ", 5);
			Dialog.addNumber("       Particle Area Max (Unit: Pixels): ", 20);
			Dialog.addNumber("       Particle Circularity Min: ", 0.80);
			Dialog.addNumber("       Particle Circularity Max: ", 1.0);
			Dialog.addNumber("       Universal Feature Perimeter Expander: ", 2);
			Dialog.addCheckbox("Local Background Correction?", true);
			Dialog.addNumber("       Band Size: ", 2);
			Dialog.addMessage("........................................................................................................................................................................................................................................................................................................");
		Dialog.show()
		
		multiplierSTA=Dialog.getNumber();
		multiplierEND=Dialog.getNumber();
		multiplierSTEP=Dialog.getNumber();
		RBYN=Dialog.getCheckbox();
		RBradius=Dialog.getNumber();
		SizeMin=Dialog.getNumber();
		SizeMax=Dialog.getNumber();
		CircMin=Dialog.getNumber();
		CircMax=Dialog.getNumber();
		PerimExpander=Dialog.getNumber();
		LocalBackgroundYN=Dialog.getCheckbox();
		BandSize=Dialog.getNumber();
		
		Dialog.create("Brightness Calculator 3");
			Dialog.addMessage("Advanced Settings");
			Dialog.addNumber("       Backend % of Slices Used for Background Determination: ", 7);
			Dialog.addNumber("       Gaussian Blur Sigma: ", 25);
			Dialog.addNumber("       Frame Averager for Threshold Image Generator: ", 1);
			Dialog.addCheckbox("       Eliminate Blips?", false);
			Dialog.addNumber("       Blip Eliminator Frame Averager Size (Do not recommend exceeding 10): ", 5);
			Dialog.addNumber("       Blip Eliminator Frame Set Counts (Recommended 2 or 3; Multiple of Averager Size and Set Counts Should Not Exceed Frame Averager): ", 4);
			Dialog.addCheckbox("       Custom Slice Stop (Not Last Frame)?", true);
			Dialog.addNumber("       Frame Stop Multiplier To Determine Last Frame (Times Frame Averager): ", 2);
			Dialog.addMessage("........................................................................................................................................................................................................................................................................................................");
		Dialog.show()
		
		sliceMultiplier0=Dialog.getNumber();	
		sliceMultiplier=(100-sliceMultiplier0)/100;
		GBSigma=Dialog.getNumber();
		FrameAverager=Dialog.getNumber();
		FrameAverager0=FrameAverager;
		BlipsYN=Dialog.getCheckbox();
		BlipFrameSize=Dialog.getNumber();
		BlipFrameSet=Dialog.getNumber();
		BlipLength=BlipFrameSize*BlipFrameSet;
		if(BlipsYN==true)
		{
		FrameAverager=FrameAverager/BlipLength;
		}
		SliceStopYN=Dialog.getCheckbox();
		SliceStopMultiplier=Dialog.getNumber();
		FrameStop=FrameAverager*SliceStopMultiplier;
		
		//****************************************************************************************************************
		//File Saving
		
		Dialog.create("Name_Your_Directory");
			Dialog.addString("Name Your Directory:", "",30);
			Dialog.addMessage("In the following prompt you will be asked to select where to save this directory.");
			Dialog.addMessage("....................................................................................................................................................................................................................................................................................");
		Dialog.show()
		
		root=Dialog.getString();
		
		dir = getDirectory("Choose a Directory");
		rootD = dir + "/"+root+"/";
		LOG = rootD + "/0_logs/";
		OR = rootD + "/1_original_corrected_and_background_subtracted/";
		Sum = rootD + "/2_summed_final_image_marked/";
		BK = rootD + "/3_stacks_for_determining_background/"; 
		Noise = rootD + "/4_stacks_for_determining_noise/";
		FrameAveraged = rootD + "/5_frame_averaged_stacks_threshold/";
		Integrals = rootD + "/6_integrals/";
		ROIS = rootD + "/7_ROIs/";
		Traj = rootD + "/8_trajectories/";

		File.makeDirectory(rootD);
		File.makeDirectory(LOG);
		File.makeDirectory(OR);
		File.makeDirectory(BK);
		File.makeDirectory(Noise);
		File.makeDirectory(FrameAveraged);
		File.makeDirectory(Sum);
		File.makeDirectory(Integrals);
		File.makeDirectory(ROIS);
		File.makeDirectory(Traj);
		for (multiplier=multiplierSTA; multiplier<=multiplierEND; multiplier=multiplier+multiplierSTEP)   
		{
		File.makeDirectory(Integrals + "Threshold" + ""+multiplier+"");
		File.makeDirectory(ROIS + "Threshold" + ""+multiplier+"");
		File.makeDirectory(Traj + "Threshold" + ""+multiplier+"");
		}
		File.makeDirectory(ROIS + "01_ROI_OGs/");
		File.makeDirectory(ROIS + "02_ROI_exps/");
		File.makeDirectory(ROIS + "03_ROI_bands/");
		File.makeDirectory(ROIS + "Threshold_SUM/");
		File.makeDirectory(Integrals + "Threshold_SUM/");
		File.makeDirectory(Integrals + "Threshold_FINAL_ALL/");
		File.makeDirectory(Traj + "Threshold_SUM/");
		//open(dir);
		
		//****************************************************************************************************************

		Dialog.create("Images to Display/Save (Display In Development, Not Working Currently)");	
			Dialog.addMessage("Original and Corrected Stacks");
			rows=2;
			columns=2;
			n= rows*columns;
			labels=newArray(n);
			defaults = newArray(n);
			labels[0]="Original (Display)";
			labels[1]="Original (Save)";
			labels[2]="Original Corrected (Display)";
			labels[3]="Original Corrected (Save)";
			defaults[0]=false;
			defaults[1]=false;
			defaults[2]=false;
			defaults[3]=false;
			Dialog.addCheckboxGroup(rows, columns, labels, defaults);
			Dialog.addMessage("...............................................................................................................................................................................................................................................................................................");
			Dialog.addMessage("Stacks/Images for Determining Background Subtraction");
			rows2=3;
			columns2=2;
			n2= rows2*columns2;
			labels2=newArray(n2);
			defaults2 = newArray(n2);
			labels2[0]="Backend Crop Stack (Display)";
			labels2[1]="Backend Crop Stack (Save)";
			labels2[2]="Backend Crop Blur Stack (Display)";
			labels2[3]="Backend Crop Blur Stack (Save)";
			labels2[4]="Backend Crop Blur Average (Display)";
			labels2[5]="Backend Crop Blur Average (Save)";
			defaults2[0]=false;
			defaults2[1]=false;
			defaults2[2]=false;
			defaults2[3]=false;
			defaults2[4]=false;
			defaults2[5]=false;
			Dialog.addCheckboxGroup(rows2, columns2, labels2, defaults2);
			Dialog.addMessage("...............................................................................................................................................................................................................................................................................................");
			Dialog.addMessage("Background Subtracted Stack");
			rows3=1;
			columns3=2;
			n3= rows3*columns3;
			labels3=newArray(n3);
			defaults3= newArray(n3);
			labels3[0]="Background Subtracted Stack (Display)";
			labels3[1]="Background Subtracted Stack (Save)";
			defaults3[0]=false;
			defaults3[1]=false;
			Dialog.addCheckboxGroup(rows3, columns3, labels3, defaults3);
			Dialog.addMessage("...............................................................................................................................................................................................................................................................................................");
		Dialog.show()
			
		originalD=Dialog.getCheckbox();
		originalS=Dialog.getCheckbox();
		originalCD=Dialog.getCheckbox();
		originalCS=Dialog.getCheckbox();
		backendCD=Dialog.getCheckbox();
		backendCS=Dialog.getCheckbox();
		backendCBD=Dialog.getCheckbox();
		backendCBS=Dialog.getCheckbox();
		backendCBAD=Dialog.getCheckbox();
		backendCBAS=Dialog.getCheckbox();
		backgroundsubtractedD=Dialog.getCheckbox();
		backgroundsubtractedS=Dialog.getCheckbox();
		
		Dialog.create("Images to Display/Save 2 (Display In Development, Not Working Currently)");
			Dialog.addMessage("Stacks/Images for Determining Noise");
			rows4=3;
			columns4=2;
			n4= rows4*columns4;
			labels4=newArray(n4);
			defaults4 = newArray(n4);
			labels4[0]="Backend Background Subtracted Crop Stack (Display)";
			labels4[1]="Backend Background Subtracted Crop Stack (Save)";
			labels4[2]="Backend Background Subtracted Crop Blur Stack (Display)";
			labels4[3]="Backend Background Subtracted Crop Blur Stack (Save)";
			labels4[4]="Backend Background Subtracted Crop Blur Average (Display)";
			labels4[5]="Backend Background Subtracted Crop Blur Average (Save)";
			defaults4[0]=false;
			defaults4[1]=false;
			defaults4[2]=false;
			defaults4[3]=false;
			defaults4[4]=false;
			defaults4[5]=false;
			Dialog.addCheckboxGroup(rows4, columns4, labels4, defaults4);
			Dialog.addMessage("...............................................................................................................................................................................................................................................................................................");
			Dialog.addMessage("Stacks/Images for Determining Threshold and Point Selection");
			rows5=2;
			columns5=2;
			n5=rows5*columns5;
			labels5=newArray(n5);
			defaults5 = newArray(n5);
			labels5[0]="Transformed Stack; Frame Averaged Background Subtracted Stack (Display)";
			labels5[1]="Transformed Stack; Frame Averaged Background Subtracted Stack (Save)";
			labels5[2]="Transformed Stack; Frame Averaged Background Subtracted Max (Display)";
			labels5[3]="Transformed Stack; Frame Averaged Background Subtracted Max (Save)";
			defaults5[0]=false;
			defaults5[1]=false;
			defaults5[2]=false;
			defaults5[3]=true;
			Dialog.addCheckboxGroup(rows5, columns5, labels5, defaults5);
			Dialog.addMessage("...............................................................................................................................................................................................................................................................................................");
			Dialog.addMessage("Summed Image for Determing Brightness Integral");
			rows6=2;
			columns6=2;
			n6= rows6*columns6;
			labels6=newArray(n6);
			defaults6= newArray(n6);
			labels6[0]="Background Subtracted Sum (Display)";
			labels6[1]="Background Subtracted Sum (Save)";
			labels6[2]="Background Subtracted Sum Marked (Display)";
			labels6[3]="Background Subtracted Sum Marked (Save)";
			defaults6[0]=false;
			defaults6[1]=true;
			defaults6[2]=false;
			defaults6[3]=true;
			Dialog.addCheckboxGroup(rows6, columns6, labels6, defaults6);
		Dialog.show()
	
		backgroundsubtractedbackendCD=Dialog.getCheckbox();
		backgroundsubtractedbackendCS=Dialog.getCheckbox();
		backgroundsubtractedbackendCBD=Dialog.getCheckbox();
		backgroundsubtractedbackendCBS=Dialog.getCheckbox();
		backgroundsubtractedbackendCBAD=Dialog.getCheckbox();
		backgroundsubtractedbackendCBAS=Dialog.getCheckbox();
		transformedstackD=Dialog.getCheckbox();
		transformedstackS=Dialog.getCheckbox();
		transformedmaxD=Dialog.getCheckbox();
		transformedmaxS=Dialog.getCheckbox();
		backgroundsubtractedsumD=Dialog.getCheckbox();
		backgroundsubtractedsumS=Dialog.getCheckbox();
		backgroundsubtractedsummarkedD=Dialog.getCheckbox();
		backgroundsubtractedsummarkedS=Dialog.getCheckbox();

		Dialog.create("Additional Output Selection");
			Dialog.addMessage("Measurements");
			Dialog.addCheckbox("Custom Measurements? (Must be set manually before running.)", false);
			Dialog.addMessage("Default measurements are area, mean, min/max, and integrated intensity.");
			Dialog.addMessage("............................................................................................................................................................................................................................................................................");
			Dialog.addMessage("Trajectories");
			Dialog.addCheckbox("Save Trajectories?", true);
			Dialog.addMessage("Trajectory generation should be postprocessed with Matlab Script.");
			Dialog.addMessage("............................................................................................................................................................................................................................................................................");
			Dialog.addMessage("Trajectories (Old)");
			Dialog.addCheckbox("Save Trajectories (Saves SUM as Default unless Multiplier Checked)?", false);
			Dialog.addCheckbox("... for Multiplier?", false);
			Dialog.addNumber("       Type in Multiplier That You Want Exported (Can Only Do Single Multiplier) ", 20);
			Dialog.addMessage("Trajectory generation (old) will take 5-15 minutes.");
			Dialog.addMessage("............................................................................................................................................................................................................................................................................");
			Dialog.addMessage("Histogram");
			Dialog.addCheckbox("Generate Histogram?", true)
			Dialog.addCheckbox("Auto-Bin Histogram?", true)
			Dialog.addNumber("Number of Bins (if the auto-bin option is selected as false):", 10)
			Dialog.addMessage("To generate histogram, BAR FIJI package required (visit: https://imagej.net/plugins/bar for installation instructions).");
			Dialog.addMessage("............................................................................................................................................................................................................................................................................");
		Dialog.show()

		custommeasurementsYN=Dialog.getCheckbox();
		trajectoriesYN=Dialog.getCheckbox();
		trajectoriesYN2=Dialog.getCheckbox();
		MultiplierYN2=Dialog.getCheckbox();
		MultiplierNum2=Dialog.getNumber();
		histogramYN=Dialog.getCheckbox();
		autobinYN=Dialog.getCheckbox();
		binN=Dialog.getNumber();

		//****************************************************************************************************************
		//Code Begins Here

		setBatchMode(true);

		//Save Settings as CSV
		print("\\Clear");
		print("CameraBias,CameraGain,CollectionEfficiency,EfficiencyFactor,SNMultiplierStart,SNMultiplierEnd,SNMultiplierStep,RollingBallYN,RollingBallRadius,ParticleSizeMin,ParticleSizeMax,ParticleCircularityMin,ParticleCircularityMax,UniversalPerimeterExpander,LocalBackgroundYN,BandSize,Backend%Slices,GaussianBlurSigma,FrameAverager0,FrameAverager,BlipsYN,BlipFrameSize,BlipFrameSet,BlipLength,SliceStopYN,SliceStopMutliplier,FrameStop,CustomMeasurementsYN,TrajectoriesYN,TrajectoriesYN2,HistogramYN");
		print(""+Bias+","+Gain+","+Collection+","+EfficiencyF+","+multiplierSTA+","+multiplierEND+","+multiplierSTEP+","+RBYN+","+RBradius+","+SizeMin+","+SizeMax+","+CircMin+","+CircMax+","+PerimExpander+","+LocalBackgroundYN+","+BandSize+","+sliceMultiplier0+","+GBSigma+","+FrameAverager0+","+FrameAverager+","+BlipsYN+","+BlipFrameSize+","+BlipFrameSet+","+BlipLength+","+SliceStopYN+","+SliceStopMultiplier+","+FrameStop+","+custommeasurementsYN+","+trajectoriesYN+","+trajectoriesYN2+","+histogramYN+"");
		selectWindow("Log");
		saveAs("Text", LOG + "01_Settings.csv");

		//Set Measurements We Will Need (Can Be Overrided with Custom Measurements Option)

		if(custommeasurementsYN==false)
		{
		run("Set Measurements...", "area mean min integrated redirect=None");
		}

		//Rename Original File and Account for Bias and Gain

		rename("Original");   ////
		
		if(originalS==true)
		{
		save(OR + "Original");
		}

		//run("Duplicate...", "title=OriginalCorrected duplicate");   ////    duplicate image to produce corrected image
		run("Subtract...", "value="+Bias+" stack");   ////   subtract bias
		run("Divide...", "value="+Gain+" stack");   ////     divide by gain
		run("Divide...", "value="+Collection+" stack");   ////     divide by collection efficiency
		run("Multiply...", "value="+EfficiencyF+" stack");   ////     multiply by photon-to-signal efficiency factor
		rename("OriginalCorrected");

		if(originalCS==true)
		{
		save(OR + "OriginalCorrected");
		}

		//Background Subtraction

		//Run Slice Keeper to Select Backend Slices With Lack of Spots

		slicef=nSlices();   ////       set final slice equal to the last slice
		slice90=slicef*sliceMultiplier;   ////       based on backend slice %, set starting range
		run("Slice Keeper", "first="+slice90+" last="+slicef+" increment=1");   ////     crop slices to specified range
		rename("Crop");   ////       rename file to 'Crop'
		run("Duplicate...", "title=BackendSlices duplicate");   ////      duplicate 'Crop'
		
		if(backendCS==true)
		{
		save(BK + "BackendCropStack");
		}
		
		//Run Gaussian Blur to Subtract Instrument Background from Slices, 'stack' required to apply to full stack

		run("Gaussian Blur...", "sigma="+GBSigma+" stack");   ////
		rename("Blurred");   ////

		if(backendCBS==true)
		{
		save(BK + "BackendCropBlurStack");
		}
		
		//Average Gaussian Blur to Achieve an Average Background Image

		run("Z Project...", "projection=[Average Intensity]");   ////
		rename("Average");   ////
		
		if(backendCBAS==true)
		{
		save(BK + "BackendCropBlurAverage");
		}

		//Subtract Background Across Entire Stack
    		imageCalculator("Subtract create 32-bit stack", "OriginalCorrected","Average");
		rename("BackgroundSubtracted");

		if(backgroundsubtractedS==true)
		{
		save(OR + "BackgroundSubtracted");
		}

		//Determine Noise	

		//Slice Background Subtract
		run("Slice Keeper", "first="+slice90+" last="+slicef+" increment=1");
		rename("CropBackgroundSubtract");
		run("Duplicate...", "title=BackendSlicesBackgroundSubtract duplicate");
		rename("CropBackgroundSubtractDup");

		//Apply Absolute Value
		run("Abs", "CropBackgroundSubtractAverage stack");

		if(backgroundsubtractedbackendCS==true)
		{
		save(Noise + "BackgroundSubtractedBackendABS");
		}
		
		//Run Gaussian Blur
		run("Gaussian Blur...", "sigma="+GBSigma+" stack");
		
		if(backgroundsubtractedbackendCBS==true)
		{
		save(Noise + "BackgroundSubtractedBackendBlurABS");
		}

		//Average Background to Wash Out Signal
		run("Z Project...", "projection=[Average Intensity]");
		rename("CropBackgroundSubtractAverage");

		if(backgroundsubtractedbackendCBAS==true)
		{
		save(Noise + "BackgroundSubtractedBackendBlurAverageABS");
		}

		//Measure and Record Noise
		run("Measure");
		Mean=getResult("Mean");
		Min=getResult("Min");
		Max=getResult("Max");
		
		//Print Log
		print("\\Clear");
		print("Mean,Min,Max");
		print(""+Mean+","+Min+","+Max+"");

		//Save Log
		selectWindow("Log");
		saveAs("Text", LOG + "02_Noise_Mean_Min_Max.csv");
		
		//Create Image for Thresholding
		selectWindow("BackgroundSubtracted"); 

		//Blip Correction
		if(BlipsYN==true)
		{
		n=nSlices();
		t=getTitle;
		for (i=1; i<=n; i=i+BlipFrameSize)   
		{
        	 selectWindow(t);
		 setSlice(i);  
  	       run("Z Project...", "start="+i+" stop="+(i+BlipFrameSize-1)+" projection=[Average Intensity]");
		 rename("BackgroundSubtractedBlipCorrected"+i);
		}
		run("Images to Stack", "name=[Transformed Stack] title=BackgroundSubtractedBlipCorrected use");

		if(transformedstackS==true)
		{
		save(FrameAveraged + "BlinkCorrected1Stack");
		}
	
		//Blip Correction Part 2
		n=nSlices();
		t=getTitle;
		for (i=1; i<=n; i=i+BlipFrameSet)   
		{
        	 selectWindow(t);
		 setSlice(i);  
  	       run("Z Project...", "start="+i+" stop="+(i+BlipFrameSet-1)+" projection=[Min Intensity]");
		 rename("BackgroundSubtractedBlipCorrected2"+i);
		}
		run("Images to Stack", "name=[Transformed Stack] title=BackgroundSubtractedBlipCorrected2 use");

		if(transformedstackS==true)
		{
		save(FrameAveraged + "BlinkCorrected2Stack");
		}
		}

		//Frame Averager
		n=nSlices();
		if(SliceStopYN==true)
		{
		n=FrameStop;
		}
		t=getTitle;
		for (i=1; i<=n; i=i+FrameAverager)   
		{
        	 selectWindow(t);
		 setSlice(i);  
  	       run("Z Project...", "start="+i+" stop="+(i+FrameAverager-1)+" projection=[Average Intensity]");
		 rename("BackgroundSubtractedSliceAverage"+i);
		}
		run("Images to Stack", "name=[Transformed Stack] title=BackgroundSubtractedSliceAverage use");
		
		if(transformedstackS==true)
		{
		save(FrameAveraged + "FrameAveragedStack");
		}
		
		//Take Max of Frame Averaged Set
		run("Z Project...", "projection=[Max Intensity]");

		//Rolling Ball Correction
		if(RBYN==true)
		{
		run("Subtract Background...", "radius=RBradius");
		}

		if(transformedmaxS==true)
		{
		save(FrameAveraged + "FrameAveragedMax");
		}
		rename("FrameAveragedMax");
		
		//Sum Slices to Get a Summed Stack for Integral
		selectWindow("BackgroundSubtracted");
		run("Z Project...", "projection=[Sum Slices]");
		rename("BackgroundSubtractedSum");
		if(backgroundsubtractedsumS==true)
		{
		save(Sum+ "BackgroundSubtractedSum");
		}

		//****************************************************************************************************************
		//Preparing for Threshold Loop
		
		//Multiple FrameAveragedMax for Loop
		selectWindow("FrameAveragedMax");
		for (multiplier=multiplierSTA; multiplier<=multiplierEND; multiplier=multiplier+multiplierSTEP)   
		{
		FrameAveragedMaxTitle="FrameAveragedMax" + multiplier;
		FrameAveragedMaxTitleB="FrameAveragedMax" + multiplier + "B";
		run("Duplicate...", "title="+FrameAveragedMaxTitle+" duplicate");
		run("Duplicate...", "title="+FrameAveragedMaxTitleB+" duplicate");
		}
		run("Duplicate...", "title=FrameAveragedMaxSUM duplicate"); //extra stacks for summed integral
		run("Duplicate...", "title=FrameAveragedMaxSUMB duplicate"); //extra stacks for summed integral
		
		//Apply Overlay to Summed Image and Calculate Integrals
		selectWindow("BackgroundSubtractedSum");
		for (multiplier=multiplierSTA; multiplier<=multiplierEND; multiplier=multiplier+multiplierSTEP)   
		{
		BackgroundSubtractedSumTitle="BackgroundSubtractedSum" + multiplier;
		BackgroundSubtractedSumTitleB="BackgroundSubtractedSum" + multiplier + 'B';
		run("Duplicate...", "title="+BackgroundSubtractedSumTitle+" duplicate");
		run("Duplicate...", "title="+BackgroundSubtractedSumTitleB+" duplicate");
		}
		run("Duplicate...", "title=BackgroundSubtractedSumSUM duplicate"); //extra stacks for summed integral
		run("Duplicate...", "title=BackgroundSubtractedSumSUMB duplicate"); //extra stacks for summed integral
		//****************************************************************************************************************
		//Threshold Loop
		
		for (multiplier=multiplierSTA; multiplier<=multiplierEND; multiplier=multiplier+multiplierSTEP)   
		{
		selectWindow("FrameAveragedMax" + multiplier);

		//Define Noise Threshold
		Threshold=multiplier*Mean;
		setThreshold(Threshold, 1e30);
		
		//Analyze Particles
		run("Clear Results");
		run("Set Scale...", "distance=1 known=1");
		run("Select Bounding Box");
		run("Enlarge...", "enlarge=-2");
		run("Analyze Particles...", "size=SizeMin-SizeMax pixel circularity=CircMin-CircMax show=Overlay exclude display clear summarize");
		if(nResults>0)
		{

		//Copy to ROI Manager
		run("To ROI Manager", "");
		roiManager('save', ROIS + "Threshold" + ""+multiplier+"" + "/" +'01_ROIset_T' + multiplier + '.zip');
		roiManager('save', ROIS + "01_ROI_OGs/" +'01_ROIset_T' + multiplier + '.zip');

		//Run Perimeter Feature Expander
		size=roiManager("count"); //get number of ROIs
		for (n=1; n<=size; n=n+1)   
		{
		roiManager("Select", n-1);
		run("Enlarge...", "enlarge=PerimExpander");
		roiManager("Update");
		}
		roiManager("Deselect");
		roiManager('save', ROIS + "Threshold" + ""+multiplier+"" + "/" +'02_ROIset_exp_T' + multiplier + '.zip');
		roiManager('save', ROIS + "02_ROI_exps/" +'02_ROIset_exp_T' + multiplier + '.zip');

		//Make Features Ellipses
		size=roiManager("count"); //get number of ROIs
		for (n=1; n<=size; n=n+1)   
		{
		roiManager("Select",0);
		run("Fit Ellipse");
		roiManager("Add");
		roiManager("Select",0);
		roiManager("Delete");
		}
		roiManager('save', ROIS + "Threshold" + ""+multiplier+"" + "/" +'02_ROIset_exp_T' + multiplier + '.zip');
		roiManager('save', ROIS + "02_ROI_exps/" +'02_ROIset_exp_T' + multiplier + '.zip');

		if(transformedmaxS==true)
		{
		run("Flatten");
		saveAs("TIFF", FrameAveraged + "FrameAveragedMaxThreshold" + multiplier + ".tiff");
		}
	
		selectWindow("FrameAveragedMax" + multiplier + "B");
		run("From ROI Manager");
		if(transformedmaxS==true)
		{
		run("Flatten");
		saveAs("TIFF", FrameAveraged + "FrameAveragedMaxMarked" + multiplier + ".tiff");
		}
		
		//Open and Save Background Subtracted Sum at Threshold Multiplier
		selectWindow("BackgroundSubtractedSum" + multiplier);

		run("From ROI Manager");

		//Continuing ROI Analysis
		run("Clear Results");
		run("Set Scale...", "distance=1 known=1");
		roiManager("Measure");

		if(backgroundsubtractedsummarkedS==true)
		{
		run("Flatten");
		saveAs("TIFF", Sum+ "BackgroundSubtractedSumMarked" + multiplier + ".tiff");
		}

		//Save Results
		selectWindow("Results");
		saveAs("Text", Integrals + "Threshold" + ""+multiplier+"" + "/" + "01_Results_T" + multiplier + ".csv");

		//Apply Local Background Correction to Integral
		if(LocalBackgroundYN==true){

		AreaR = newArray(nResults);
		for(i=0; i<nResults; i++) {
		AreaR[i]= getResult("Area", i);
		}

		IntegralR = newArray(nResults);
		for(i=0; i<nResults; i++) {
		IntegralR[i]= getResult("RawIntDen", i);
		}

		selectWindow("BackgroundSubtractedSum" + multiplier + 'B');
		run("From ROI Manager");

		//Run Band Expansion
		size=roiManager("count"); //get number of ROIs
		for(n=1; n<=size; n=n+1)   
		{
		roiManager("Select", n-1);
		run("Set Scale...", "distance=1 known=1");
		run("Make Band...", "band=BandSize");
		roiManager("Update");
		}
		roiManager("Deselect");
		roiManager('save', ROIS + "Threshold" + ""+multiplier+"" + "/" +'03_ROIset_band_T' + multiplier + '.zip');
		roiManager('save', ROIS + "03_ROI_bands/" +'03_ROIset_band_T' + multiplier + '.zip');

		//Run Band Expansion
		size=roiManager("count"); //get number of ROIs
		for(n=1; n<=size; n=n+1)   
		{
		roiManager("Select", n-1);
		run("Set Scale...", "distance=1 known=1");
		run("Make Band...", "band=BandSize");
		roiManager("Update");
		}
		roiManager("Deselect");
		roiManager('save', ROIS + "Threshold" + ""+multiplier+"" + "/" +'03_ROIset_band_T' + multiplier + '.zip');
		roiManager('save', ROIS + "03_ROI_bands/" +'03_ROIset_band_T' + multiplier + '.zip');
		
		//Continuing ROI Analysis
		run("Clear Results");
		run("Set Scale...", "distance=1 known=1");
		roiManager("Measure");

		if(backgroundsubtractedsummarkedS==true)
		{
		run("Flatten");
		saveAs("TIFF", Sum+ "BackgroundSubtractedSumMarkedBand" + multiplier + ".tiff");
		}

		//Save Results
		selectWindow("Results");
		saveAs("Text", Integrals + "Threshold" + ""+multiplier+"" + "/" + "02_ResultsBackground_T" + multiplier + ".csv");
		
		//Corrected Integral
		AreaB = newArray(nResults);
		for(i=0; i<nResults; i++) {
		AreaB[i]= getResult("Area", i);
		}

		IntegralB = newArray(nResults);
		for(i=0; i<nResults; i++) {
		IntegralB[i]= getResult("RawIntDen", i);
		}
		
		print("\\Clear");
		print("Area,PhotonBudgetResults,PhotonBudgetBackground,PhotonBudgetDifference");
		  for(i=0; i<nResults; i++) {
    	 		print(AreaR[i],",",IntegralR[i],",",((IntegralB[i]/AreaB[i])*AreaR[i]),",",IntegralR[i]-((IntegralB[i]/AreaB[i])*AreaR[i]));
		}
		
		selectWindow("Log");
		saveAs("Text", Integrals + "Threshold" + ""+multiplier+"" + "/" + "03_ResultsBackgroundSubtracted_T" + multiplier + ".csv");
		saveAs("Text", Integrals + "Threshold_FINAL_ALL/" + "03_ResultsBackgroundSubtracted_T" + multiplier + ".csv");
		}

		//****************************************************************************************************************
		//Trajectories for Threshold Stack
		if(trajectoriesYN==true)
		{

		roiManager("Delete");

		//Open Result Trajectories
		selectWindow("BackgroundSubtracted");
		roiManager("Open", ROIS + "02_ROI_exps/" +'02_ROIset_exp_T' + multiplier + '.zip');
		run("Clear Results");
		run("Set Scale...", "distance=1 known=1");
		roiManager("multi-measure measure_all");
		selectWindow("Results");
		saveAs("Text", Traj + "Threshold" + ""+multiplier+"" + "/" + "01_TrajectoriesSignal" + ".csv");

		roiManager("Delete");

		//Background Trajectories
		selectWindow("BackgroundSubtracted");
		roiManager("Open", ROIS + "03_ROI_bands/" +'03_ROIset_band_T' + multiplier + '.zip');
		run("Clear Results");
		run("Set Scale...", "distance=1 known=1");
		roiManager("multi-measure measure_all");
		selectWindow("Results");
		saveAs("Text", Traj + "Threshold" + ""+multiplier+"" + "/" + "02_TrajectoriesBackground" + ".csv");
		}
		}

		else
		{
		multiplierEND=multiplier-multiplierSTEP;
		}
		}
		
		selectWindow("Summary");
		saveAs("Text", Integrals + "SummaryThresholds.csv");
		//****************************************************************************************************************
		//Combined ROI Stack

		run("Clear Results");
		print("\\Clear");
		roiManager("Delete");
		
		//Switch to Window of Interest
		selectWindow("FrameAveragedMaxSUM");
		for (multiplier=multiplierSTA; multiplier<=multiplierEND; multiplier=multiplier+multiplierSTEP)   
		{
		roiManager("Open", ROIS + "01_ROI_OGs/" +'01_ROIset_T' + multiplier + '.zip');
		}
		
		roiManager("Combine");
		roiManager("Delete");
		roiManager("Split");
		roiManager('save', ROIS + "Threshold_SUM/" +'01_ROIset_SUM' + '.zip');

		//Run Perimeter Feature Expander
		size=roiManager("Count"); //get number of ROIs
		run("Set Scale...", "distance=1 known=1");
		for (n=1; n<=size; n=n+1)   
		{
		roiManager("Select", n-1);
		run("Enlarge...", "enlarge=PerimExpander");
		roiManager("Update");
		}
		roiManager("Deselect");
		roiManager('save', ROIS + "Threshold_SUM/" +'02_ROIset_exp_SUM' + '.zip');

		//Make Features Ellipses
		size=roiManager("count"); //get number of ROIs
		for (n=1; n<=size; n=n+1)   
		{
		roiManager("Select",0);
		run("Fit Ellipse");
		roiManager("Add");
		roiManager("Select",0);
		roiManager("Delete");
		}
		roiManager('save', ROIS + "Threshold_SUM/" +'02_ROIset_exp_SUM' + '.zip');

		if(transformedmaxS==true)
		{
		run("Flatten");
		saveAs("TIFF", FrameAveraged + "FrameAveragedMaxThreshold" + 'SUM' + ".tiff");
		}
	
		selectWindow("FrameAveragedMaxSUMB");
		run("From ROI Manager");
		if(transformedmaxS==true)
		{
		run("Flatten");
		saveAs("TIFF", FrameAveraged + "FrameAveragedMaxMarked" + 'SUM' + ".tiff");
		}
		
		//Apply Overlay to Summed Image and Calculate Integrals
		selectWindow("BackgroundSubtractedSumSUM");
	
		if(backgroundsubtractedsumS==true)
		{
		save(Sum+ "BackgroundSubtractedSum" + 'SUM');
		}

		run("From ROI Manager");

		//Continuing ROI Analysis
		run("Clear Results");
		run("Set Scale...", "distance=1 known=1");
		roiManager("Measure");

		if(backgroundsubtractedsummarkedS==true)
		{
		run("Flatten");
		saveAs("TIFF", Sum+ "BackgroundSubtractedSumMarked" + 'SUM' + ".tiff");
		}

		//Save Results
		selectWindow("Results");
		saveAs("Text", Integrals + 'Threshold_SUM/' + "01_Results_SUM" + ".csv");

		//Apply Local Background Correction to Integral
		if(LocalBackgroundYN==true){

		AreaR = newArray(nResults);
		for(i=0; i<nResults; i++) {
		AreaR[i]= getResult("Area", i);
		}

		IntegralR = newArray(nResults);
		for(i=0; i<nResults; i++) {
		IntegralR[i]= getResult("RawIntDen", i);
		}

		selectWindow("BackgroundSubtractedSumSUMB");
		run("From ROI Manager");

		//Run Band Expansion
		size=roiManager("count"); //get number of ROIs
		for(n=1; n<=size; n=n+1)   
		{
		roiManager("Select", n-1);
		run("Set Scale...", "distance=1 known=1");
		run("Make Band...", "band=BandSize");
		roiManager("Update");
		}
		roiManager("Deselect");
		roiManager('save', ROIS + "Threshold_SUM/" +'03_ROIset_band_' + 'SUM' + '.zip');
				
		//Continuing ROI Analysis
		run("Clear Results");
		run("Set Scale...", "distance=1 known=1");
		roiManager("Measure");

		if(backgroundsubtractedsummarkedS==true)
		{
		run("Flatten");
		saveAs("TIFF", Sum+ "BackgroundSubtractedSumMarkedBand" + 'SUM' + ".tiff");
		}

		//Save Results
		selectWindow("Results");
		saveAs("Text", Integrals + 'Threshold_SUM/' + "02_ResultsBackground_" + 'SUM' + ".csv");

		AreaB = newArray(nResults);
		for(i=0; i<nResults; i++) {
		AreaB[i]= getResult("Area", i);
		}

		IntegralB = newArray(nResults);
		for(i=0; i<nResults; i++) {
		IntegralB[i]= getResult("RawIntDen", i);
		}
		
		print("\\Clear");
		print("Area,PhotonBudgetResults,PhotonBudgetBackground,PhotonBudgetDifference");
		  for(i=0; i<nResults; i++) {
    	 		print(AreaR[i],",",IntegralR[i],",",((IntegralB[i]/AreaB[i])*AreaR[i]),",",IntegralR[i]-((IntegralB[i]/AreaB[i])*AreaR[i]));
		}
		
		selectWindow("Log");
		saveAs("Text", Integrals + 'Threshold_SUM/' + "03_ResultsBackgroundSubtracted_SUM" + ".csv");
		saveAs("Text", Integrals + "Threshold_FINAL_ALL/" + "03_ResultsBackgroundSubtracted_SUM" + ".csv");
		}

		//****************************************************************************************************************
		//Trajectories for Combined ROI Stack
		if(trajectoriesYN==true)
		{

		roiManager("Delete");

		//Open Result Trajectories
		selectWindow("BackgroundSubtracted");
		roiManager("Open", ROIS + "Threshold_SUM/" +'02_ROIset_exp_SUM' + '.zip');
		run("Clear Results");
		run("Set Scale...", "distance=1 known=1");
		roiManager("multi-measure measure_all");
		selectWindow("Results");
		saveAs("Text", Traj + 'Threshold_SUM/' + "01_TrajectoriesSignal" + ".csv");

		roiManager("Delete");

		//Background Trajectories
		selectWindow("BackgroundSubtracted");
		roiManager("Open", ROIS + "Threshold_SUM/" +'03_ROIset_band_SUM' + '.zip');
		run("Clear Results");
		run("Set Scale...", "distance=1 known=1");
		roiManager("multi-measure measure_all");
		selectWindow("Results");
		saveAs("Text", Traj + 'Threshold_SUM/' + "02_TrajectoriesBackground" + ".csv");
		}

		//****************************************************************************************************************
		//Old Trajectories Code. Can Still Run but Very Slow, Only Runs on One Set, The Pro Being that Output Data Includes Processed Background Subtracted Trajectories

		if(trajectoriesYN2==true)
		{
		run("Clear Results");
		print("\\Clear");
		roiManager("Delete");

		//Switch to Window of Interest
		selectWindow("BackgroundSubtracted");

		if(MultiplierYN2==true)
		{
		roiManager("Open", ROIS + "02_ROI_exps/" +'02_ROIset_exp_T' + MultiplierNum2 + '.zip');
		File.makeDirectory(Traj + "Threshold" + ""+MultiplierNum2+"" + "/" + "03_Trajectories_INDIVIDUAL");
		}

		else
		{
		roiManager("Open", ROIS + "Threshold_SUM/" +'02_ROIset_exp_SUM' + '.zip');
		File.makeDirectory(Traj + 'Threshold_SUM/' + "03_Trajectories_INDIVIDUAL");
		}

		//Get Area Results
		run("Clear Results");
		roiManager("Measure");
		areaMeasurements = newArray(nResults);
		for(i=0; i<nResults; i++) {
		areaMeasurements[i]= getResult("Area", i);
		}

		//Run Loop to Export Trajectories

		size=roiManager("count"); //get number of ROIs
		for (n=1; n<=size; n=n+1)   
		{
		print("\\Clear");
		selectWindow("BackgroundSubtracted");
		roiManager("Select", n-1);
		run("Plot Z-axis Profile");
		Plot.getValues( x, y );
		
		index = newArray(x.length);
		for(i=0; i<x.length; i++) {
		index[i]= x[i];
		}		
		ZPlotProfile = newArray(x.length);
		for(i=0; i<x.length; i++) {
		ZPlotProfile[i]= y[i];
		}
		
		if(LocalBackgroundYN==true)
		{
		print("\\Clear");
		selectWindow("BackgroundSubtracted");
		roiManager("Select", n-1);
		run("Set Scale...", "distance=1 known=1");
		run("Make Band...", "band=BandSize");
		roiManager("Update");
		run("Plot Z-axis Profile");
		Plot.getValues( x, y );
		ZPlotProfileBack = newArray(x.length);
		for(i=0; i<x.length; i++) {
		ZPlotProfileBack[i]= y[i];
		}
		
		Plot.getValues( x, y );
			print("Frame Index,IntensityAverage(ZPlotProfile),IntensityBackgroundAverage(ZPlotProfile),IntensityDifference,Intensity*Area,Area:",",",areaMeasurements[n-1]);
		  for (i=0; i<x.length; i++) {
    	 		print(index[i],",",ZPlotProfile[i],",",ZPlotProfileBack[i],",",ZPlotProfile[i]-ZPlotProfileBack[i],",",(ZPlotProfile[i]-ZPlotProfileBack[i])*areaMeasurements[n-1]);
				}
				
		selectWindow("Log");
		if(MultiplierYN2==true)
		{
		saveAs("Text", Traj + "Threshold" + ""+MultiplierNum2+"" + "/" + "03_Trajectories_INDIVIDUAL" + "/" + n + ".csv" );
		}
		else
		{
		saveAs("Text", Traj + 'Threshold_SUM/' + "03_Trajectories_INDIVIDUAL/" + n + ".csv" );
		}
		}
		else{
		Plot.getValues( x, y );
			print("Frame Index,IntensityAverage(ZPlotProfile),Intensity*Area,Area:",",",areaMeasurements[n-1]);
		  for (i=0; i<x.length; i++) 
    	 		print(index[i],",",ZPlotProfile[i],",",ZPlotProfile[i]*areaMeasurements[n-1]); //May consider adding i+1 added instead of x[i]+1 for leftmost value
				
		selectWindow("Log");
		if(MultiplierYN2==true)
		{
		saveAs("Text", Traj + "Threshold" + ""+MultiplierNum2+"" + "/" + "03_Trajectories_INDIVIDUAL" + "/" + n + ".csv" );
		}
		else
		{
		saveAs("Text", Traj + 'Threshold_SUM/' + "03_Trajectories_INDIVIDUAL/" + n + ".csv" );
		}
		}
		}
		}

		selectWindow("FrameAveragedMaxSUMB");
		setBatchMode(false);
		//****************************************************************************************************************
		//Histogram. Generates Sample Histogram Based off Data. Uses FIJI BAR Plugin which must be installed.

		if(histogramYN==true)
		{
		run("Clear Results");
		//run("Results... ");

		if(LocalBackgroundYN==true){

		lineseparator = "\n";
   		cellseparator = ",\t";

     		// copies the whole RT to an array of lines
		pathfile=Integrals + 'Threshold_SUM/' + "03_ResultsBackgroundSubtracted_SUM" + ".csv"; //can change if you want a different path, currently set for SUM
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
		
		run("Plots...", "width=600 height=600 font=11 draw_ticks list minimum=0 maximum=0 interpolate");
		if(autobinYN==true)
		{
		run("Distribution Plotter", "parameter=PhotonBudgetDifference tabulate=[Relative frequency (%)] autoBin=59 userBins=8");
		}
		//selectWindow("Plot Values");
		else
		{
		run("Distribution Plotter", "parameter=PhotonBudgetDifference tabulate=[Relative frequency (%)] automatic=[Specify manually below:] bins="+binN+"");
		}
		selectWindow("Plot Values");
		saveAs("Results", rootD + "histogram_values.csv");

		//IJ.renameResults("histogram_values.csv","Results");
		//updateResults();
		//Table.deleteColumn("Y0");
		//Table.deleteColumn("X1");
		//Table.deleteColumn("Y1");
		//updateResults();
		
		////New Section for Figuring out Number of Bins
		run("Clear Results");
		lineseparator = "\n";
   		cellseparator = ",\t";

     		// copies the whole RT to an array of lines
		pathfile=rootD + "histogram_values.csv"; /// Used in the event that local background subtraction not applied
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
		////End this Part of the Code

		resultsLength = getValue("results.count");
		binNumber = getValue("results.count");
		for (i=1; i<resultsLength;i++)
		{
		currentResult = getResult("X1",i);
		if(currentResult==0)
		{
		binNumber=binNumber-1;
		}
		}
		styleNumber = 309+465*binNumber;
		selectWindow("Histograms for PhotonBudgetDifference");
		Plot.setStyle(styleNumber, "black,none,2.0,Linehidden");
		//Plot.setStyle(3564, "black,none,2.0,Linehidden");
		//Plot.setStyle(4029, "black,none,2.0,Linehidden");
		//Plot.setStyle(4494, "black,none,2.0,Linehidden");
		//Plot.setStyle(4959, "black,none,2.0,Linehidden");
		Plot.setAxisLabelSize(16.0, "plain");
		Plot.setFontSize(14.0);
		Plot.setXYLabels("Photon Budget", "Relative frequency (%)");
		Plot.setFormatFlags("11001100110001");
		Plot.setStyle(6, "black,none,1.0,Circlehidden");
		Plot.setStyle(7, "black,none,1.0,Circlehidden");
		Plot.makeHighResolution("Histograms for PhotonBudgetDifference_HiRes",4.0);
		selectWindow("Histograms for PhotonBudgetDifference_HiRes");
		saveAs("Tiff", rootD + "histogram");
		}
		
		else{
		run("Clear Results");
		lineseparator = "\n";
   		cellseparator = ",\t";

     		// copies the whole RT to an array of lines
		pathfile=Integrals + 'Threshold_SUM/' + "01_Results_SUM" + ".csv"; /// Used in the event that local background subtraction not applied
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

		run("Plots...", "width=600 height=600 font=11 draw_ticks list minimum=0 maximum=0 interpolate");
		if(autobinYN==true)
		{
		run("Distribution Plotter", "parameter=RawIntDen tabulate=[Relative frequency (%)] autoBin=59 userBins=8");
		}
		else
		{
		run("Distribution Plotter", "parameter=RawIntDen tabulate=[Relative frequency (%)] automatic=[Specify manually below:] bins="+binN+"");
		}
		//Plot.setStyle(4959, "black,none,2.0,Linehidden");
		Plot.setAxisLabelSize(16.0, "plain");
		Plot.setFontSize(14.0);
		Plot.setXYLabels("Photon Budget", "Relative frequency (%)");
		Plot.setFormatFlags("11001100110001");
		Plot.setStyle(6, "black,none,1.0,Circlehidden");
		Plot.setStyle(7, "black,none,1.0,Circlehidden");
		Plot.makeHighResolution("Histograms for PhotonBudgetDifference_HiRes",4.0);
		selectWindow("Histograms for PhotonBudgetDifference_HiRes");
		saveAs("Tiff", rootD + "histogram");
		selectWindow("Plot Values");
		saveAs("Results", rootD + "histogram_values.csv");
		}
		}

		//****************************************************************************************************************
		//Useful Commands
		//waitForUser("Click OK to continue");
		//exec("open", LOG + "Results.csv");