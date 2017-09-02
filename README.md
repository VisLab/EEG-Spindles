# EEG-Spindles
Spindler Toolbox for detecting alpha and sleep spindles in EEG

### Spindler is freely available under the GNU General Public License. 
Please cite the following publication if using: 
> Spindler: Spatiotemporal adaptive matching pursuit 
> for EEG-based spindle detection  
> John LaRocco, Piotr Franaszczuk, Scott Kerick, Kay Robbins  


### Installing and running spindler

	- run EEGLAB to install it
	- add the spindler directory and all its subdirectories to your MATLAB path
	- modify and uncomment a setup for your directories in ``runSpindler.m`
	- execute the script `runSpindler`

#### Example setup
Spindler is designed to be run in batch mode. Edit `runSpindler` to set:  

    - dataDir         path of directory containing EEG .set files to analyze
    - eventDir        directory of labeled event files
    - resultsDir      directory that Spindler uses to write its output
    - imageDir        directory that Spindler users to save images
    - summaryFile     full path name of the file containing the summary analysis
    - channelLabels   cell array containing possible channel labels 
                       (Spindler uses the first label that matches one in EEG)
    - paramsInit      structure containing the parameter values
                      (if an empty structure, Spindler uses defaults)  
 
Spindler uses the input to run a batch analysis. If `eventDir` is not empty, Spindler runs performance comparisons, provided it can match file names for files in `eventDir` with those in `dataDir`.  Ideally, the event file names should have the data file names as prefixes, although Spindler tries more complicated matching strategies as well.  Event files contain "ground truth" in text files that have two columns containing the start and end times in seconds.
	
### Dependencies:
* EEGLAB: https://sccn.ucsd.edu/eeglab/  

### Releases:
Version 1.0.3 Released 09/02/2017
* Fixed resampling issue in spindlerExtractSpindles when ICA present
* Added warningCodes to spindlerExtractSpindles
* Added a generic spindlerAllChannels with example run functions
* Improved documentation on various functions  

Version 1.0.2 Released 08/25/2017
* Renamed getChannelNumbers as getChannelNumbersFromLabels
      
Version 1.0.1 Released 08/25/2017
* Changed params and spindlerExtractSpindles to just handle a single channel
* Added 'basic' figureLevel value that only plots key curves
* Added getSpindlerVersion function
* Now treat invalid atomRange as an error in spindlerGetParameterCurves  

### Support:    
	
This research was sponsored by the Army Research Laboratory and was accomplished under Cooperative Agreement Number W911NF-10-2-0022. The views and conclusions contained in this document are those of the authors and should not be interpreted as representing the official policies, either expressed or implied, of the Army Research Laboratory or the U.S. Government. The U.S. Government is authorized to reproduce and distribute reprints for Government purposes notwithstanding any copyright notation herein.