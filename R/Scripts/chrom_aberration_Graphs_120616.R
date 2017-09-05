library(MASS);

pdf("~/Scripts/R/chromatic_aberr_hists.pdf");
outfile <- file("~/Scripts/R/chromatic_aberr_script_output.txt", open="wt");
sink(outfile, type="output");



x <- Sox2_data_emp_correction;
par(mfrow=c(3,2), cex.main=0.8, cex=0.6);
batches <- unique(x$Batch);
print("Data: Sox2_data_emp_correction");

for (i in batches){
  hist(x[x$Batch == i, "X_Distance (um)"], breaks=c(-3,seq(-1,1.0,0.02), 3), xlim=c(-1,1), xlab="X Distance (um)", ylab="Counts", main=paste("Distribution of X Distances between Labels for", i, sep=" "));
  lines(x=c(0.0244, 0.0244), y=c(0, 10), lwd = 3, col="red");
  print(paste("Batch:", i, sep=" "));
  print("fitdistr(x[x$Batch == i, 'X_Distance (um)'], densfun='normal'", quote=FALSE);
  dist <- fitdistr(x[x$Batch == i, "X_Distance (um)"], densfun="normal");
  print(dist$estimate);
}

for (i in batches){
  hist(x[x$Batch == i, "Y_Distance (um)"], breaks=c(-3,seq(-1,1.0,0.02), 3), xlim=c(-1,1), xlab="Y Distance (um)", ylab="Counts", main=paste("Distribution of Y Distances between Labels for", i, sep=" "));
  lines(x=c(0.0153, 0.0153), y=c(0, 10), lwd = 3, col="red");
  print(paste("Batch:", i, sep=" "));
  print("fitdistr(x[x$Batch == i, 'Y_Distance (um)'], densfun='normal'", quote=FALSE);
  dist <- fitdistr(x[x$Batch == i, "Y_Distance (um)"], densfun="normal");
  print(dist$estimate);
}


for (i in batches){
  hist(x[x$Batch == i, "Z_Distance (um)"], breaks=c(-3,seq(-1,1.0,0.02), 3), xlim=c(-1,1), xlab="Z Distance (um)", ylab="Counts", main=paste("Distribution of Z Distances between Labels for", i, sep=" "));
  lines(x=c(-0.192, -0.192), y=c(0, 10), lwd = 3, col="red");
  print(paste("Batch:", i, sep=" "));
  print("fitdistr(x[x$Batch == i, 'Z_Distance (um)'], densfun='normal'", quote=FALSE);
  dist <- fitdistr(x[x$Batch == i, "Z_Distance (um)"], densfun="normal");
  print(dist$estimate);
}



sink(type = "output");
close(outfile);

dev.off()
