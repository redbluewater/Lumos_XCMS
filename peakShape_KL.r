#xset2 <- peakShape_KL(xset1,cor.val=0.9)

#and then proceed with group(), retcor(), etc.  Decreasing cor.val will
#let more non-gaussian peaks through the filter

#original file version from the Google Groups for xcms from Tony Larson
#KL corrected this version 8/23/2011 ...seems to be from an older version of XCMS
#KL updated 9/24/2018 to change line 29 to as.double. The previous code used as.integer, 
#presumably to speed up the processing time. However,the Lumos makes peaks that exceed the 
#maximum allowed integer in R. Can find the maximum allowed integer in R using this 
#code: as.integer(.Machine$integer.max) where you will get 2.1e9 as the maximum integer. The 
#Lumos is just barely exceeding this value.

#peakShape function to remove non-gaussian peaks from an xcmsSet
#code originally had cor.val = 0.9; 0.5 is too low (not doing enough pruning)
peakShape_KL <- function(object, cor.val=0.9)
{
require(xcms)

files <- object@filepaths
peakmat <- object@peaks
peakmat.new <- matrix(-1,1,ncol(peakmat))
colnames(peakmat.new) <- colnames(peakmat)
for(f in 1:length(files))
        {
        xraw <- xcmsRaw(files[f], profstep=0)
        sub.peakmat <- peakmat[which(peakmat[,"sample"]==f),,drop=F]
        corr <- numeric()
        for (p in 1:nrow(sub.peakmat))
                {
                #extract using rawEIC method +/1 0.01 m/z to give smoother traces
                #changed this from as.integer to as.double 9/1=24/2018 bc the Lumos
                #has peak areas that exceed the maximum allowed integer in R.
                tempEIC <-
as.double((rawEIC(xraw,mzrange=c(sub.peakmat[p,"mzmin"]-0.001,sub.peakmat[p,"mzmax"]+0.001))$intensity))
                minrt.scan <- which.min(abs(xraw@scantime-sub.peakmat[p,"rtmin"]))[1]
                maxrt.scan <- which.min(abs(xraw@scantime-sub.peakmat[p,"rtmax"]))[1]
                eics <- tempEIC[minrt.scan:maxrt.scan]
                #set min to 0 and normalise
                eics <- eics-min(eics)
                if(max(eics)>0)
                        {
                        eics <- eics/max(eics)
                        }
                #fit gauss and let failures to fit through as corr=1
                fit <- try(nls(y ~ SSgauss(x, mu, sigma, h), data.frame(x =
1:length(eics), y = eics)),silent=T)
                if(class(fit) == "try-error")
                        {
                        corr[p] <- 1
                        } else
                        {
                        #calculate correlation of eics against gaussian fit
                        if(length(which(!is.na(eics-fitted(fit)))) > 4 &&
length(!is.na(unique(eics)))>4 && length(!is.na(unique(fitted(fit))))>4)
                                {
                                cor <- NULL
                                options(show.error.messages = FALSE)
                                cor <- try(cor.test(eics,fitted(fit),method="pearson",use="complete"))
                                options(show.error.messages = TRUE)
                                if (!is.null(cor))
                                        {
                                        if(cor$p.value <= 0.05) corr[p] <- cor$estimate else corr[p] <- 0
                                        } else corr[p] <- 0
                                } else corr[p] <- 0
                        }
                }
        filt.peakmat <- sub.peakmat[which(corr >= cor.val),]
        peakmat.new <- rbind(peakmat.new, filt.peakmat)
        n.rmpeaks <- nrow(sub.peakmat)-nrow(filt.peakmat)
        cat("Peakshape evaluation: sample ", sampnames(object)[f],"
",n.rmpeaks,"/",nrow(sub.peakmat)," peaks removed","\n")
        if (.Platform$OS.type == "windows") flush.console()
        }

peakmat.new <- peakmat.new[-1,]

object.new <- object
object.new@peaks <- peakmat.new
return(object.new) 
}