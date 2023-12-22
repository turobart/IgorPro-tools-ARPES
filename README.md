# IgorPro-tools-ARPES
Set of Igor Pro and Python scripts for ARPES data processing.
Igor Pro scripts are used to: 
1. fitBands - fit valence and conduction band of $Pb_{1-x}Sn_{x}Se$.
2. fitCones - dynamically fit surface states of (001)-oriented sample near $\bar X$ point.
3. fitRashbaH - dynamically fit Rashba-split surface states and topological surface states.
4. resizeGraphs - resize multiple ARPES images for easier comparision of the spectra.
---
Python ARPES_3D_cubes script is used to prepare properly cut 2D images intended for making 3D cube ARPES image.
The script uses [igor.py](https://github.com/wking/igor) module to read ibw. files generated during experiments at [URANOS](https://synchrotron.uj.edu.pl/en_GB/linie-badawcze/uranos) beamline at National Synchrotron Radiation Centre [SOLARIS](https://synchrotron.uj.edu.pl/en_GB/start) in Kraków, Poland.
User can set the boundaries of the reciprocal space and energy to obtain 3D cube image of the collected data.
