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
setTool("Wand");
run("Wand Tool...", "tolerance=0 mode=8-connected");//Choose over 4-connected and tolerance 1-5
waitForUser("Choose the perfect bouton and then click ok");

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
