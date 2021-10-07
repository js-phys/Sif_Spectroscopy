# Sif_Evaluation
#### Language: Matlab (and Andor Basic)
Acquisition & Evaluation (Matlab) of time-dependent spectroscopic data acquired with an Andor CCD camera (Newton).

---

This is a loose collection of software that was used to 
  - Acquire spectroscopic data with an Andor detector 
  - Evaluate the spectra with Matlab. 

The acquisition program was written in Andor Basic and can be executed directly in the Andor SOLIS software. It spools several spectra to disc and saves it in one file (.sif). It'll also create a .report file with some metadata. 

The .sif file can later be loaded into Matlab (if the .report file is misisng, standard parameters are used). After loading the .sif, individual spectra can be access and extracted  for further evaluation.

---

**Note:** For proper function the Andor Software Development Kit (SDK) has to be installed first.

---
