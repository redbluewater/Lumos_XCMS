#code from metabolomics forum to get the TICS of a set of samples...
#source this code and then run as follows:
#getTICs_KL(xcmsSet = xset, pdfname = "TICs.pdf",rt = "corrected")
# or getTICs_KL(files = mzdatafiles, pdfname = "TICs.pdf")
# or getTICs_KL(files = mzdatafiles[c(9,14,18)], pdfname = "testing3.pdf", rt = "raw")
# Krista Longnecker
# Woods Hole Oceanographic Institution

getTIC <- function(file,rtcor=NULL) {
  object <- xcmsRaw(file)
  cbind(if (is.null(rtcor)) object@scantime else rtcor, rawEIC(object,mzrange=range(object@env$mz))$intensity)
}

##
##  overlay TIC from all files in current folder or from xcmsSet, create pdf
##
getTICs_KL <- function(xcmsSet=NULL,files=NULL, pdfname="TICs.pdf",rt=c("raw","corrected")) {
  if (is.null(xcmsSet)) {
    filepattern <- c("[Cc][Dd][Ff]", "[Nn][Cc]", "([Mm][Zz])?[Xx][Mm][Ll]",
                     "[Mm][Zz][Dd][Aa][Tt][Aa]", "[Mm][Zz][Mm][Ll]")
    filepattern <- paste(paste("\\.", filepattern, "$", sep = ""), collapse = "|")
    if (is.null(files))
      files <- getwd()
    info <- file.info(files)
    listed <- list.files(files[info$isdir], pattern = filepattern,
                         recursive = TRUE, full.names = TRUE)
    files <- c(files[!info$isdir], listed)
  } else {
    files <- filepaths(xcmsSet)
  }
  
  N <- length(files)
  TIC <- vector("list",N)
  
  for (i in 1:N) {
    cat(files[i],"\n")
    if (!is.null(xcmsSet) && rt == "corrected")
      rtcor <- xcmsSet@rt$corrected[[i]] else
        rtcor <- NULL
    TIC[[i]] <- getTIC(files[i],rtcor=rtcor)
  }
  
  pdf(pdfname,w=16,h=10)
  #   col = colorList[putDataHere.1$SampleType])
  # legend("bottomleft", legend = levels(putDataHere.1$SampleType), col = colorList, 
  #        
  #this does not work (made empty plot)
  #   colorList <- c("deepskyblue", "magenta", "forestgreen", 
  #                   "darkorchid","firebrick")
  # #this did work:
  # colorList <- c( "#FF0000FF", "#00FF00FF" , "#FF00FFFF","#2A00FFFF","#D5FF00FF")
  # cols <- colorList[putDataHere.1$SampleType]
  
#   ##this version will color differently depending on the variable in SampleType
#   nLevels <- length(levels(putDataHere.1$SampleType))
#   colorList <- rainbow(nLevels)
#   cols <- colorList[putDataHere.1$SampleType]
  
  ##this version just splits the colors based on the rainbow palette options
  cols <- rainbow(N)
  
  lty = 1:N
  pch = 1:N
  xlim = range(sapply(TIC, function(x) range(x[,1])))
  ylim = range(sapply(TIC, function(x) range(x[,2])))
  plot(0, 0, type="n", xlim = xlim, ylim = ylim, main = "Total Ion Chromatograms", xlab = "Retention Time", ylab = "TIC")
  for (i in 1:N) {
    tic <- TIC[[i]]
    points(tic[,1], tic[,2], col = cols[i], pch = pch[i], type="l")
  }
  legend("topright",paste(basename(files)), col = cols, lty = lty, pch = pch)
  dev.off()
  
  invisible(TIC)
}
