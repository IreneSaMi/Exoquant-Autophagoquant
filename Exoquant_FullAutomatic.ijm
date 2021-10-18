////FULLY AUTOMATIC DETECTION OF NEURON-EXTERNAL PROTEINS////
////I took the code from Olivier Burri and modified with my code and three lines more to automatically select the boutons///


/*
 * Complex Format EXPORT MACRO
 * By Olivier Burri @ EPFL - SV - PTECH - BIOP
 * Given a folder, extracts all series inside all multi-file files with given extension in new folders 
 * Last edit: 13.02.2017
 */


 ////////////////////// SET PARAMETERS //////////////////////
 ////////////////////////////////////////////////////////////
 
 
// Set the extension you would like this macro to work with.
// Do not add a . at the beggining
extension = "lif";  //eg "lif", "vsi", etc...


// Set to true if you want all planes of the image to be saved individually
// if set to false, it will save each series as a stack. 
is_save_individual_planes = false; // set to either true or false

// Padding for the naming of the series if you want to save all 
// Images individually
pad = 2; // 0 means no padding. 2 means '01', '02' etc...


 //////////////////// END SET PARAMETERS ////////////////////
 ////////////////////////////////////////////////////////////
 




// Beggining of macro. You should now have anything to edit after this line. 

dir = getDirectory("Select a directory containing one or several ."+extension+" files.");

files = getFileList(dir);


setBatchMode(true);
k=0;
n=0;

run("Bio-Formats Macro Extensions");
for(f=0; f<files.length; f++) {
	if(endsWith(files[f], "."+extension)) {
		k++;
		id = dir+files[f];
		Ext.setId(id);
		Ext.getSeriesCount(seriesCount);
		print(seriesCount+" series in "+id);
		n+=seriesCount;
		for (i=0; i<seriesCount; i++) {
			run("Bio-Formats Importer", "open=["+id+"] color_mode=Default view=Hyperstack stack_order=XYCZT series_"+(i+1));
			fullName	= getTitle();
			dirName 	= substring(fullName, 0,lastIndexOf(fullName, "."+extension));
			fileName 	= substring(fullName, lastIndexOf(fullName, " - ")+3, lengthOf(fullName));
			File.makeDirectory(dir+File.separator+dirName+File.separator);

			print("Saving "+fileName+" under "+dir+File.separator+dirName);
			
			getDimensions(x,y,c,z,t);
			
			
			if(is_save_individual_planes) {
				save_string = getSaveString(pad);
				print(dir+File.separator+dirName+File.separator+fileName+"_"+save_string+".tif");
				run("Image Sequence... ", "format=TIFF name=["+fileName+"] digits="+pad+" save=["+dir+File.separator+dirName+File.separator+"]");
				
			} else {
				saveAs("tiff", dir+File.separator+dirName+File.separator+fileName+"_"+(i+1)+".tif");
			}
			run("Close All");
		}
	}
}
Ext.close();
setBatchMode(false);
//showMessage("Done with "+k+" files and "+n+" series!");


function getSaveString(pad) {
	str ="";
	getDimensions(x,y,c,z,t);
	if(t > 1)  str+="t_"+IJ.pad(1,pad);
	if(z > 1)  str+="z_"+IJ.pad(1,pad);
	if(c > 1)  str+="c_"+IJ.pad(1,pad);
	
	return str;
}

//////Selecting all the folders in the directory and do the macro on all////  
  // dir = getDirectory("Choose a Directory ");
   setBatchMode(true);
   count = 0;
   countFiles(dir);
   n = 0;
   processFiles(dir);
   print(count+" files processed");
   
   function countFiles(dir) {
      list = getFileList(dir);
      for (i=0; i<list.length; i++) {
          if (endsWith(list[i], "/"))
              countFiles(""+dir+list[i]);
          else
              count++;
      }
  }

   function processFiles(dir) {
      list = getFileList(dir);
      for (i=0; i<list.length; i++) {
          if (endsWith(list[i], "/"))
              processFiles(""+dir+list[i]);
          else {
             showProgress(n++, count);
             path = dir+list[i];
             processFile(path);
          }
      }
  }

  function processFile(path) {
       if (endsWith(path, ".tif")) {
           open(path);
           //////MEASURING NEURON-EXTERNAL PPROTEINS//////

////To select the parameters that are going to be measured////
run("Set Measurements...", "area mean standard modal min center perimeter integrated median skewness kurtosis area_fraction redirect=None decimal=3");
run("Colors...", "foreground=white background=black selection=yellow");

////To measure the total intensity of each channel////
//It is assumed that green channel is going to be the external protein to be measured in channel 1//
//It is assumed that red channel (membrane marker) is in channel 2//
Stack.setChannel(1);
hrpgfp = getImageID();
run("Measure");
Stack.setChannel(2);
run("Measure");

////To obtain the perimeter of the neuron from the red channel////
Stack.setChannel(1);
run("Duplicate...", "use");
hrpThreshold=getImageID();
setAutoThreshold("Otsu b&w dark");
run("Convert to Mask");
//setTool("Wand");
//run("Wand Tool...", "tolerance=0 mode=8-connected");//Choose over 4-connected and tolerance 1-5
//waitForUser("Choose the perfect bouton and then click ok");
run("Analyze Particles...", "size=10-Infinity add");
roiManager("deselect");
roiManager("combine");


////To obtain the parameters measured from the inside of the neuron////
selectImage(hrpgfp); //To select again the complete stack
Stack.setChannel(1);
run("Restore Selection");
run("Measure");
Stack.setChannel(2);
run("Restore Selection");
run("Measure");

////To obtain the parameters from outside the neuron to the enlargement size selected////
run("Clear", "stack");//To clean inside the neuron//
Stack.setChannel(1);
run("Enlarge...", "enlarge=1"); //This is 1 micrometer enlargement but if you change the 1 you will obtain diferent size//
run("Measure");
Stack.setChannel(2);
run("Restore Selection");
run("Enlarge...", "enlarge=1");
run("Measure");

////To measure the total intensity of each channel without the neuron inside intensity////
Stack.setChannel(1);
run("Select None");
run("Measure");
Stack.setChannel(2);
run("Select None");
run("Measure");

           save(path);
           close();
      }
  }
