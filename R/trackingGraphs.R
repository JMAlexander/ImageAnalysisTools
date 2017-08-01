trackingGraphs <- function(dataset, time_step){
library(circular)
x <- dataset;
t_point_step <- time_step
# ####### Distance Histograms ##########
pdf("~/Scripts/R/Tracking_data_plots.pdf");

cell_lines <- unique(x$Cell_Line);
for (i in cell_lines){
  par(mfrow=c(3,2), cex.main=0.8, cex=0.6);
  hist(x[x$Cell_Line == i, "Corrected XY_Distance (um)"], breaks=c(0,seq(0.01,1.0,0.01), 3), xlim=c(0,1), xlab="Corrected XY Distance (um)", ylab="Counts", main=paste("Distribution of XY Distances between Labels for", i, "ESCs", sep=" "));
  hist(x[x$Cell_Line == i, "Corrected XYZ_Distance (um)"], breaks=c(0,seq(0.015,1.5,0.015), 3), xlim=c(0,1.5), xlab="Corrected XYZ Distance (um)", ylab="Counts", xaxp=c(0,1.5,5), main=paste("Distribution of XYZ Distances between Labels for", i, "ESCs", sep=" "));
  x_50 <- x[x$Cell_Line == i & x$`Corrected XY_Distance (um)` <= 0.05,]
  x_100 <- x[x$Cell_Line == i & x$`Corrected XY_Distance (um)` <= 0.1 & x$`Corrected XY_Distance (um)` > 0.05, ];
  x_200 <- x[x$Cell_Line == i & x$`Corrected XY_Distance (um)` <= 0.2 & x$`Corrected XY_Distance (um)` > 0.1, ];
  x_300 <- x[x$Cell_Line == i & x$`Corrected XY_Distance (um)` <= 0.3 & x$`Corrected XY_Distance (um)` > 0.2, ];
  x_400 <- x[x$Cell_Line == i & x$`Corrected XY_Distance (um)` <= 0.4 & x$`Corrected XY_Distance (um)` > 0.3,];
  x_500 <- x[x$Cell_Line == i & x$`Corrected XY_Distance (um)` <= 0.5 & x$`Corrected XY_Distance (um)` > 0.4,];
  x_600 <- x[x$Cell_Line == i & x$`Corrected XY_Distance (um)` <= 0.6 & x$`Corrected XY_Distance (um)` > 0.5,];
  x_800 <- x[x$Cell_Line == i & x$`Corrected XY_Distance (um)` <= 0.8 & x$`Corrected XY_Distance (um)` > 0.6,];
  x_1000 <- x[x$Cell_Line == i & x$`Corrected XY_Distance (um)` <= 1.0 & x$`Corrected XY_Distance (um)` > 0.8,];
  
  
  #
  # ######## Velocity/Displacement Boxplots ############
  #
  #
  
  boxplot(x_50$`Relative_XY Displacement (um)`, x_100$`Relative_XY Displacement (um)`,
          x_200$`Relative_XY Displacement (um)`,x_300$`Relative_XY Displacement (um)`,
          x_400$`Relative_XY Displacement (um)`,x_500$`Relative_XY Displacement (um)`,
          x_600$`Relative_XY Displacement (um)`,
          x_800$`Relative_XY Displacement (um)`,
          x_1000$`Relative_XY Displacement (um)`,
          names=c("0-50", "50-100", "100-200", "200-300", "300-400", "400-500", "500-600", "600-800", "800-1000"), ylim=c(0,0.5), ylab="Relative XY Displacement (um)", main=paste("XY Displacement of C1_Locus Relative to C2 Between\n Frames of", i, "ESCs", sep=" "), outline=FALSE);
  
  x_50 <- x[x$Cell_Line == i & x$`Corrected XYZ_Distance (um)` <= 0.05,]
  x_100 <- x[x$Cell_Line == i & x$`Corrected XYZ_Distance (um)` <= 0.1 & x$`Corrected XYZ_Distance (um)` > 0.05, ];
  x_200 <- x[x$Cell_Line == i & x$`Corrected XYZ_Distance (um)` <= 0.2 & x$`Corrected XYZ_Distance (um)` > 0.1, ];
  x_300 <- x[x$Cell_Line == i & x$`Corrected XYZ_Distance (um)` <= 0.3 & x$`Corrected XYZ_Distance (um)` > 0.2, ];
  x_400 <- x[x$Cell_Line == i & x$`Corrected XYZ_Distance (um)` <= 0.4 & x$`Corrected XYZ_Distance (um)` > 0.3,];
  x_500 <- x[x$Cell_Line == i & x$`Corrected XYZ_Distance (um)` <= 0.5 & x$`Corrected XYZ_Distance (um)` > 0.4,];
  x_600 <- x[x$Cell_Line == i & x$`Corrected XYZ_Distance (um)` <= 0.6 & x$`Corrected XYZ_Distance (um)` > 0.5,];
  x_800 <- x[x$Cell_Line == i & x$`Corrected XYZ_Distance (um)` <= 0.8 & x$`Corrected XYZ_Distance (um)` > 0.6,];
  x_1000 <- x[x$Cell_Line == i & x$`Corrected XYZ_Distance (um)` <= 1.0 & x$`Corrected XYZ_Distance (um)` > 0.8,];
  boxplot(x_50$`Relative_XYZ Displacement (um)`, x_100$`Relative_XYZ Displacement (um)`,
          x_200$`Relative_XYZ Displacement (um)`, x_300$`Relative_XYZ Displacement (um)`,
          x_400$`Relative_XYZ Displacement (um)`, x_500$`Relative_XYZ Displacement (um)`,
          x_600$`Relative_XYZ Displacement (um)`,
          x_800$`Relative_XYZ Displacement (um)`,
          x_1000$`Relative_XYZ Displacement (um)`,
          names=c("0-50", "50-100", "100-200", "200-300", "300-400", "400-500", "500-600", "600-800", "800-1000"), ylim=c(0,1.0), ylab="Relative XYZ Displacement (um)", main=paste("XYZ Displacement of C1_Locus Relative to C2 Between\n Frames of", i, "ESCs", sep=" "));
  
# par(mfrow=c(3,2))
#  rose.diag(x_100$"Relative_XY Angle (radians)", shrink=1.0, bins=30, col="skyblue", axes=TRUE, prop=2.5);
#  rose.diag(x_200$"Relative_XY Angle (radians)", shrink=1.0, bins=30, col="skyblue", axes=TRUE, prop=2.5);
#  rose.diag(x_400$"Relative_XY Angle (radians)", shrink=1.0, bins=30, col="skyblue", axes=TRUE, prop=2.5);
#  rose.diag(x_600$"Relative_XY Angle (radians)", shrink=1.0, bins=30, col="skyblue", axes=TRUE, prop=2.5);
#  rose.diag(x_800$"Relative_XY Angle (radians)", shrink=1.0, bins=30, col="skyblue", axes=TRUE, prop=2.5);
#  rose.diag(x_1000$"Relative_XY Angle (radians)", shrink=1.0, bins=30, col="skyblue", axes=TRUE, prop=2.5);
  rose.diag(x$"Relative_XY Angle (radians)", shrink=1.0, bins=30, col="skyblue", axes=TRUE, prop=2.5);
  
}



# ######### Distance Scatterplots vs Time #########
#

for (i in cell_lines){
  par(mfrow=c(3,2))
  y <- x[x$`Corrected XY_Distance (um)` <= 0.15,];
  images <- unique(x[x$Cell_Line == i, "C1_Image"])
  for (k in 1:length(images)){current_line <- unique(x[x$C1_Image == images[k], "Cell_Line"]);
  plot(x[x$C1_Image == images[k], "C1_T Value (sec)"], x[x$C1_Image == images[k], "Corrected XY_Distance (um)"], type="p", pch=20, main="XY Distance vs. Time with 150nm Threshold Highlighted", sub=paste(current_line, images[k]), ylab="XY Distance (um)", xlab="Time (sec)", ylim=c(0,1.5), xlim=c(0,t_point_step * 100));
  points(y[y$C1_Image == images[k], "C1_T Value (sec)"], y[y$C1_Image == images[k], "Corrected XY_Distance (um)"], type="p", pch=20, col="red");
  lines(x[x$C1_Image == images[k], "C1_T Value (sec)"], x[x$C1_Image == images[k], "Relative_XY Displacement (um)"], col="yellow");
}

par(mfrow=c(3,2))
y <- x[x$`Corrected XYZ_Distance (um)` <= 0.20,];
for (k in 1:length(images)){current_line <- unique(x[x$C1_Image == images[k], "Cell_Line"]);
plot(x[x$C1_Image == images[k], "C1_T Value (sec)"], x[x$C1_Image == images[k], "Corrected XYZ_Distance (um)"], type="p", pch=20, main="XYZ Distance vs. Time with 300nm Threshold Highlighted", sub=paste(current_line, images[k]), ylab="XYZ Distance (um)", xlab="Time (sec)", ylim=c(0,1.5), xlim=c(0, t_point_step * 100));
points(y[y$C1_Image == images[k], "C1_T Value (sec)"], y[y$C1_Image == images[k], "Corrected XYZ_Distance (um)"], type="p", pch=20, col="yellow");
}
}
dev.off()
}