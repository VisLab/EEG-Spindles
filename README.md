Spindler is a hybrid spindle detection method for EEG that chooses its
parameters based on the shape of spindle property surfaces. The toolbox
includes a full set of evaluation tools and graphics.

### Citing Spindler
The EEG-Spindles toolbox is freely available under the GNU General Public
License. Please cite the following publication if using:  
  
> Spindler: A framework for parametric analysis and detection of
> spindles in EEG with application to sleep spindles (2018)  
> J LaRocco, P Franaszczuk, S Kerick and K Robbins  
> Journal of Neural Engineering 15(6): 066015 (15pp) 
> https://iopscience.iop.org/article/10.1088/1741-2552/aadc1c. 

### To use  
You should have EEGLAB (https://sccn.ucsd.edu/eeglab/index.php) in your
path. Add the spindler directory and all of its subdirectories to the
path.  To run, execute the runSpindler in the main directory after
adjusting the directory path. The runSpindler assumes that the EEG
is in EEGLAB .set format and that event files are in a separate
directory and have the same filename but the .mat file extension.
Event files should contain an events variable holding a two column
array of start and end times of the events.

### Version  
Version 2.0.0 Released 07/08/2018 
 * Reorganized toolbox and generalized parameter curves
       
### Support      	
This research was sponsored by the Army Research Laboratory and
was accomplished under Cooperative Agreement Number W911NF-10-2-0022.
The views and conclusions contained in this document are those of the
authors and should not be interpreted as representing the official
policies, either expressed or implied, of the Army Research Laboratory
or the U.S. Government. The U.S. Government is authorized to reproduce
and distribute reprints for Government purposes notwithstanding any
copyright notation herein.
