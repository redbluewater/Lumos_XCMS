# Lumos
4 December 2018

XCMS code to process data from Lumos.

These files require XCMS < 3. At the moment, we use XCMS 1.52 in the lab. 

These files assume you start with RAW files from a Thermo instrument. Use ms_convert_tool_Lumos_v2.r to use the ProteoWizard msconvert tool to shift the files to the open source mzML files.

Then use the Mtab_XCMS_forLumos_UPLC_withPeakShape.2018.09.24.Rmd RMarkdown file to run through all the processing steps. The Rmd file will use the other .r files found in this repository.

There is a sample sequence available here as well (sampleSequence_forLC_Lumos_abbreviated.xls) so that you can see what is expected as a file format. The Rmd file will need to be updated with the name of this data file.

Krista Longnecker
Woods Hole Oceanographic Institution
