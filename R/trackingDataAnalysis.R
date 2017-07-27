library(stringr);
library(optparse);

### It looks like trackmate shifts pixel value by 0.5.

option_list = list(
	make_option(c("-d", "--dir"), type="character", dest="dir", default=NULL, help="Directory containing trackmate files.  Should contain 200_spots and 600_spots subdirectories..."),
	make_option(c("-o", "--out"), action="store_true", dest="out", default=FALSE, help="Save data to an R.data file in directory specified as 'dir'"),
	make_option(c("-p", "--plot"), action="store_true", dest="plot", default=FALSE, help="Generate plots for data in folder 'Analysis' in folder specified by 'dir'"),
	make_option(c("-t", "--time"), type="integer", dest="time", default=20, help="Time interval between z-stacks."),
	make_option(c("-s", "--sync"), action="store_true", dest="sync", default=FALSE, help="Marks data as synchronized (i.e. cell culture synchronized)"),
	make_option(c("-c", "--csv"), action="store_true", dest="csv", default=FALSE, help="Inputs file format of traj_pairs text file.  If invoked, file will be opened as comma-separated.  Otherwise, file will be opened as tab-delimited"),
    make_option(c("-f", "--frames"), type="integer", dest="frames", default=60, help="Inputs number of frames for the movies analyzed.")

)


opt = parse_args(OptionParser(option_list=option_list));
print(paste("Data Directory:  ", opt$dir, sep=""), quote=FALSE);
print(paste("Output Plots:  ", opt$plot, sep=""), quote=FALSE);
print(paste("Save Rdata File:  ", opt$out, sep=""), quote=FALSE);
print(paste("Time Interval:  ", opt$time, sep=""), quote=FALSE);
print(paste("Frames:  ", opt$frames, sep=""), quote=FALSE);
print(paste("Synchronized:  ", opt$sync, sep=""), quote=FALSE);
print(paste("Pair File CSV:  ", opt$csv, sep=""), quote=FALSE);


if (!is.null(opt$dir)){
        setwd(opt$dir);
        spot_dir <- list.files(path=".", pattern="[0-9]+_spots");
        setwd(spot_dir);
        c1_textfile_spots <- paste(opt$dir, spot_dir, "/", Sys.glob("C1*.txt"), sep="");
        c2_textfile_spots <- paste(opt$dir, spot_dir, "/", Sys.glob("C2*.txt"), sep="");

} else {
	c1_textfile_spots1 <- "/Users/Jeff/Desktop/01_26_2017_Batch34/TrackMate/200_spots/C1_Batch34.txt";
	c2_textfile_spots1 <- "/Users/Jeff/Desktop/01_26_2017_Batch34/TrackMate/200_spots/C2_Batch34.txt";
	traj_file <- "/Users/Jeff/Desktop/05_27_16_Batch06/TrackMate/Cropped_Images/Batch06_traj_pairs.txt";
}


## Open data files

setwd(opt$dir);

if (opt$csv){
  traj_file <- Sys.glob("*traj_pairs*.csv");
  traj_pairs <- read.delim(traj_file, header=TRUE, sep=",", stringsAsFactors = FALSE);
} else {
  traj_file <- Sys.glob("*traj_pairs*.txt");
  traj_pairs <- read.delim(traj_file, header=TRUE, sep="\t", stringsAsFactors = FALSE);
}
traj_pairs[,"Image_Stack"] <- as.character(traj_pairs$Image_Stack);
traj_pairs[,"Cell_Line"] <- as.character(traj_pairs$Cell_Line);
traj_pairs[,"Batch"] <- as.character(traj_pairs$Batch)
G1_pairs <- as.array(traj_pairs[,2]);
x_pixel_size <- 0.091;  ###Edit these where appropriate
y_pixel_size <- 0.091;
z_step_size <- 0.3;
t_point_step <- opt$time;
x_correction_offset <-  -0.0205;
y_correction_offset <-  -0.001;
z_correction_offset <-   0.132;




file = c1_textfile_spots;
BatchXX_data_c1_spots <- read.delim(file, header=TRUE, sep="\t", stringsAsFactors = FALSE);
BatchXX_data_c1_spots <- BatchXX_data_c1_spots[,1:7];
BatchXX_data_c1_spots <- data.frame("Place_holder", "Place_holder", opt$sync, BatchXX_data_c1_spots, 0, 0, 0, 0, stringsAsFactors=FALSE);
colnames(BatchXX_data_c1_spots) <- c("Cell_Line", "Batch", "Sync", "C1_Image", "C1_TrackID", "C1_SpotID", "C1_X Value (pixel)", "C1_Y Value (pixel)", "C1_Z Value (slice)", "C1_T Value (frame)", "C1_X Value (um)", "C1_Y Value (um)", "C1_Z Value (um)", "C1_T Value (sec)");
BatchXX_data_c1_spots[,"C1_Image"] <- as.character(BatchXX_data_c1_spots$C1_Image);
BatchXX_data_c1_spots[,"C1_SpotID"] <- as.character(BatchXX_data_c1_spots$C1_SpotID);
BatchXX_data_c1_spots$`C1_X Value (pixel)` <- BatchXX_data_c1_spots$`C1_X Value (pixel)` + 0.5;
BatchXX_data_c1_spots$`C1_Y Value (pixel)` <- BatchXX_data_c1_spots$`C1_Y Value (pixel)` + 0.5;
BatchXX_data_c1_spots$`C1_T Value (frame)` <- BatchXX_data_c1_spots$`C1_T Value (frame)` + 1;
BatchXX_data_c1_spots$`C1_X Value (um)` <- BatchXX_data_c1_spots$`C1_X Value (pixel)` *  x_pixel_size;
BatchXX_data_c1_spots$`C1_Y Value (um)` <- BatchXX_data_c1_spots$`C1_Y Value (pixel)` *  y_pixel_size;
BatchXX_data_c1_spots$`C1_Z Value (um)` <- BatchXX_data_c1_spots$`C1_Z Value (slice)` *  z_step_size;
BatchXX_data_c1_spots$`C1_T Value (sec)` <- BatchXX_data_c1_spots$`C1_T Value (frame)` * t_point_step;

### Channel 2 spots

file = c2_textfile_spots;
BatchXX_data_c2_spots <- read.delim(file, header=TRUE, sep="\t", stringsAsFactors = FALSE);
BatchXX_data_c2_spots <- BatchXX_data_c2_spots[,1:7];
BatchXX_data_c2_spots <- data.frame("Place_holder", "Place_holder", opt$sync, BatchXX_data_c2_spots, 0, 0, 0, 0, stringsAsFactors=FALSE);
colnames(BatchXX_data_c2_spots) <- c("Cell_Line", "Batch", "Sync", "C2_Image", "C2_TrackID", "C2_SpotID", "C2_X Value (pixel)", "C2_Y Value (pixel)", "C2_Z Value (slice)", "C2_T Value (frame)", "C2_X Value (um)", "C2_Y Value (um)", "C2_Z Value (um)", "C2_T Value (sec)");
BatchXX_data_c2_spots[,"C2_Image"] <- as.character(BatchXX_data_c2_spots$C2_Image);
BatchXX_data_c2_spots[,"C2_SpotID"] <- as.character(BatchXX_data_c2_spots$C2_SpotID);
BatchXX_data_c2_spots$`C2_X Value (pixel)` <- BatchXX_data_c2_spots$`C2_X Value (pixel)` + 0.5;
BatchXX_data_c2_spots$`C2_Y Value (pixel)` <- BatchXX_data_c2_spots$`C2_Y Value (pixel)` + 0.5;
BatchXX_data_c2_spots$`C2_T Value (frame)` <- BatchXX_data_c2_spots$`C2_T Value (frame)` + 1;
BatchXX_data_c2_spots$`C2_X Value (um)` <- BatchXX_data_c2_spots$`C2_X Value (pixel)` *  x_pixel_size;
BatchXX_data_c2_spots$`C2_Y Value (um)` <- BatchXX_data_c2_spots$`C2_Y Value (pixel)` *  y_pixel_size;
BatchXX_data_c2_spots$`C2_Z Value (um)` <- BatchXX_data_c2_spots$`C2_Z Value (slice)` *  z_step_size;
BatchXX_data_c2_spots$`C2_T Value (sec)` <- BatchXX_data_c2_spots$`C2_T Value (frame)` * t_point_step;

######
BatchXX_data_spots_combined <- data.frame(BatchXX_data_c1_spots, 0, "Place_holder", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, stringsAsFactors=FALSE);
col_value <- ncol(BatchXX_data_c1_spots);
colnames(BatchXX_data_spots_combined)[1:col_value] <- colnames(BatchXX_data_c1_spots);
colnames(BatchXX_data_spots_combined)[(col_value + 1):(col_value + 10)] <- colnames(BatchXX_data_c2_spots)[4:13];
colnames(BatchXX_data_spots_combined)[(col_value + 11):(col_value + 23)] <- c("X_Distance (um)", "Y_Distance (um)", "Z_Distance (um)", "XY_Distance (um)", "XYZ_Distance (um)","C1_Corrected X_Value (um)", "C1_Corrected Y_Value (um)", "C1_Corrected Z_Value (um)", "Corrected X_Distance (um)", "Corrected Y_Distance (um)", "Corrected Z_Distance (um)", "Corrected XY_Distance (um)", "Corrected XYZ_Distance (um)");
BatchXX_data_spots_combined[,"C2_SpotID"] <- as.character(BatchXX_data_spots_combined$C2_SpotID);
for (i in 1:nrow(traj_pairs)) {
  start = 1;
  end = opt$frames;
  if (str_detect(traj_pairs[i, "Notes"], "[0-9]+")){
    matches <- str_extract_all(traj_pairs[i, "Notes"], "[0-9]+", simplify=TRUE);
    start = as.integer(matches[,1]);
    end = as.integer(matches[,2]);
  }

  for (j in start:end) {
      if ((j %in% BatchXX_data_c2_spots[BatchXX_data_c2_spots$C2_Image == traj_pairs[i,"Image_Stack"] & BatchXX_data_c2_spots$C2_TrackID == traj_pairs[i,"C2_Pair"], "C2_T Value (frame)"]) & (j %in% BatchXX_data_c1_spots[BatchXX_data_c1_spots$C1_Image == traj_pairs[i,"Image_Stack"] & BatchXX_data_c1_spots$C1_TrackID == traj_pairs[i,"C1_Pair"], "C1_T Value (frame)"])){ BatchXX_data_spots_combined[BatchXX_data_spots_combined$C1_Image == traj_pairs[i,"Image_Stack"] & BatchXX_data_spots_combined$C1_TrackID == traj_pairs[i,"C1_Pair"] & BatchXX_data_spots_combined$`C1_T Value (frame)` == j,(col_value + 1):(col_value + 10)] <- BatchXX_data_c2_spots[BatchXX_data_c2_spots$C2_Image == traj_pairs[i,"Image_Stack"] & BatchXX_data_c2_spots$C2_TrackID == traj_pairs[i, "C2_Pair"] & BatchXX_data_c2_spots$`C2_T Value (frame)` == j, 4:13]
    BatchXX_data_spots_combined[BatchXX_data_spots_combined$C1_Image == traj_pairs[i,"Image_Stack"] & BatchXX_data_spots_combined$C1_TrackID == traj_pairs[i,"C1_Pair"] & BatchXX_data_spots_combined$`C1_T Value (frame)` == j,"Cell_Line"] <- traj_pairs[i, "Cell_Line"];
    BatchXX_data_spots_combined[BatchXX_data_spots_combined$C1_Image == traj_pairs[i,"Image_Stack"] & BatchXX_data_spots_combined$C1_TrackID == traj_pairs[i,"C1_Pair"] & BatchXX_data_spots_combined$`C1_T Value (frame)` == j,"Batch"] <- traj_pairs[i, "Batch"];   
    
    }
  }

}


BatchXX_data_combined <- rbind(BatchXX_data_spots_combined);
BatchXX_data_combined$`X_Distance (um)` <- (BatchXX_data_combined$`C1_X Value (um)` - BatchXX_data_combined$`C2_X Value (um)`);
BatchXX_data_combined$`Y_Distance (um)` <- (BatchXX_data_combined$`C1_Y Value (um)` - BatchXX_data_combined$`C2_Y Value (um)`);
BatchXX_data_combined$`Z_Distance (um)` <- (BatchXX_data_combined$`C1_Z Value (um)` - BatchXX_data_combined$`C2_Z Value (um)`);
BatchXX_data_combined$`XY_Distance (um)` <- sqrt((BatchXX_data_combined$`C1_X Value (um)` - BatchXX_data_combined$`C2_X Value (um)`)^2 + (BatchXX_data_combined$`C1_Y Value (um)` - BatchXX_data_combined$`C2_Y Value (um)`)^2);
BatchXX_data_combined$`XYZ_Distance (um)` <- sqrt((BatchXX_data_combined$`C1_X Value (um)` - BatchXX_data_combined$`C2_X Value (um)`)^2 + (BatchXX_data_combined$`C1_Y Value (um)` - BatchXX_data_combined$`C2_Y Value (um)`)^2 + (BatchXX_data_combined$`C1_Z Value (um)` - BatchXX_data_combined$`C2_Z Value (um)`)^2);

BatchXX_data_combined$`C1_Corrected X_Value (um)` <- BatchXX_data_combined$`C1_X Value (um)` + x_correction_offset;
BatchXX_data_combined$`C1_Corrected Y_Value (um)` <- BatchXX_data_combined$`C1_Y Value (um)` + y_correction_offset;
BatchXX_data_combined$`C1_Corrected Z_Value (um)` <- BatchXX_data_combined$`C1_Z Value (um)` + z_correction_offset;
BatchXX_data_combined$`Corrected X_Distance (um)` <- (BatchXX_data_combined$`C1_Corrected X_Value (um)` - BatchXX_data_combined$`C2_X Value (um)`);
BatchXX_data_combined$`Corrected Y_Distance (um)` <- (BatchXX_data_combined$`C1_Corrected Y_Value (um)` - BatchXX_data_combined$`C2_Y Value (um)`);
BatchXX_data_combined$`Corrected Z_Distance (um)` <- (BatchXX_data_combined$`C1_Corrected Z_Value (um)` - BatchXX_data_combined$`C2_Z Value (um)`);
BatchXX_data_combined$`Corrected XY_Distance (um)` <- sqrt((BatchXX_data_combined$`C1_Corrected X_Value (um)` - BatchXX_data_combined$`C2_X Value (um)`)^2 + (BatchXX_data_combined$`C1_Corrected Y_Value (um)` - BatchXX_data_combined$`C2_Y Value (um)`)^2);
BatchXX_data_combined$`Corrected XYZ_Distance (um)` <- sqrt((BatchXX_data_combined$`C1_Corrected X_Value (um)` - BatchXX_data_combined$`C2_X Value (um)`)^2 + (BatchXX_data_combined$`C1_Corrected Y_Value (um)` - BatchXX_data_combined$`C2_Y Value (um)`)^2 + (BatchXX_data_combined$`C1_Corrected Z_Value (um)` - BatchXX_data_combined$`C2_Z Value (um)`)^2);

BatchXX_data_combined_sorted <- BatchXX_data_combined[order(BatchXX_data_combined$C1_Image, BatchXX_data_combined$C1_TrackID, BatchXX_data_combined$`C1_T Value (frame)`),];
BatchXX_data_combined_pairs_trackmate <- BatchXX_data_combined_sorted[BatchXX_data_combined_sorted$C2_SpotID != "Place_holder",]
BatchXX_data_combined_pairs_trackmate <- BatchXX_data_combined_pairs_trackmate[BatchXX_data_combined_pairs_trackmate$`C1_Z Value (slice)` > 2,];
BatchXX_data_combined_pairs_trackmate <- BatchXX_data_combined_pairs_trackmate[BatchXX_data_combined_pairs_trackmate$`C2_Z Value (slice)` > 2,];
BatchXX_data_combined_pairs_trackmate <- BatchXX_data_combined_pairs_trackmate[BatchXX_data_combined_pairs_trackmate$`C1_Z Value (slice)` < 25,];
BatchXX_data_combined_pairs_trackmate <- BatchXX_data_combined_pairs_trackmate[BatchXX_data_combined_pairs_trackmate$`C2_Z Value (slice)` < 25,];

images <- unique(BatchXX_data_combined_pairs_trackmate$C1_Image);

#######
temp_table <- data.frame(BatchXX_data_combined_pairs_trackmate, 0, 0, 0, 0, 0, 0, 0, stringsAsFactors=FALSE);
col_value = ncol(BatchXX_data_combined_pairs_trackmate);
colnames(temp_table)[1:col_value] <- colnames(BatchXX_data_combined_pairs_trackmate);
colnames(temp_table)[(col_value + 1):(col_value + 7)] <- c("Relative_C1_Corrected_X Value (um)", "Relative_C1_Corrected_Y Value (um)", "Relative_C1_Corrected_Z Value (um)", "Relative_XY Displacement (um)", "Relative_XYZ Displacement (um)", "Relative_XY Angle (radians)", "Relative_XYZ Angle (radians)");
BatchXX_data_combined_pairs_trackmate <- temp_table;

#######

BatchXX_data_combined_pairs_trackmate$`Relative_C1_Corrected_X Value (um)` <- BatchXX_data_combined_pairs_trackmate$`C1_Corrected X_Value (um)` - BatchXX_data_combined_pairs_trackmate$`C2_X Value (um)`;
BatchXX_data_combined_pairs_trackmate$`Relative_C1_Corrected_Y Value (um)` <- BatchXX_data_combined_pairs_trackmate$`C1_Corrected Y_Value (um)` - BatchXX_data_combined_pairs_trackmate$`C2_Y Value (um)`
BatchXX_data_combined_pairs_trackmate$`Relative_C1_Corrected_Z Value (um)` <- BatchXX_data_combined_pairs_trackmate$`C1_Corrected Z_Value (um)` - BatchXX_data_combined_pairs_trackmate$`C2_Z Value (um)`



######## Relative XY Displacement
for (i in 1:nrow(traj_pairs)) {
  start = 1;
  end = opt$frames;
  cur_image = traj_pairs[i, "Image_Stack"];
  cur_data = BatchXX_data_combined_pairs_trackmate[BatchXX_data_combined_pairs_trackmate$C1_Image == cur_image,];
  for (j in start:end) {
    if (nrow(cur_data[cur_data$`C1_T Value (frame)` == (j - 1),]) != 0 && nrow(cur_data[cur_data$`C1_T Value (frame)` == j,]) != 0){
      BatchXX_data_combined_pairs_trackmate[BatchXX_data_combined_pairs_trackmate$C1_Image == cur_image & BatchXX_data_combined_pairs_trackmate$`C1_T Value (frame)` == j, "Relative_XY Displacement (um)"] <- sqrt((BatchXX_data_combined_pairs_trackmate[BatchXX_data_combined_pairs_trackmate$C1_Image == cur_image & BatchXX_data_combined_pairs_trackmate$`C1_T Value (frame)` == (j - 1), "Relative_C1_Corrected_X Value (um)"] - BatchXX_data_combined_pairs_trackmate[BatchXX_data_combined_pairs_trackmate$C1_Image == cur_image & BatchXX_data_combined_pairs_trackmate$`C1_T Value (frame)` == j, "Relative_C1_Corrected_X Value (um)"])^2 + (BatchXX_data_combined_pairs_trackmate[BatchXX_data_combined_pairs_trackmate$C1_Image == cur_image & BatchXX_data_combined_pairs_trackmate$`C1_T Value (frame)` == (j - 1), "Relative_C1_Corrected_Y Value (um)"] - BatchXX_data_combined_pairs_trackmate[BatchXX_data_combined_pairs_trackmate$C1_Image == cur_image & BatchXX_data_combined_pairs_trackmate$`C1_T Value (frame)` == j, "Relative_C1_Corrected_Y Value (um)"])^2);
    }
    else{
      BatchXX_data_combined_pairs_trackmate[BatchXX_data_combined_pairs_trackmate$C1_Image == cur_image & BatchXX_data_combined_pairs_trackmate$`C1_T Value (frame)` == j, "Relative_XY Displacement (um)"] <- NA;
    }
  }
}

##### Angle of XY Displacement
for (i in 1:nrow(traj_pairs)) {
  start = 1;
  end = opt$frames;
  cur_image = traj_pairs[i, "Image_Stack"];
  cur_data= BatchXX_data_combined_pairs_trackmate[BatchXX_data_combined_pairs_trackmate$C1_Image == cur_image,];
  for (j in start:end) {
    if (nrow(cur_data[cur_data$`C1_T Value (frame)` == (j - 2),]) != 0 && nrow(cur_data[cur_data$`C1_T Value (frame)` == (j - 1),]) != 0 && nrow(cur_data[cur_data$`C1_T Value (frame)` == j,]) != 0){
      u <- c(BatchXX_data_combined_pairs_trackmate[BatchXX_data_combined_pairs_trackmate$C1_Image == cur_image & BatchXX_data_combined_pairs_trackmate$`C1_T Value (frame)` == (j-1), "Relative_C1_Corrected_X Value (um)"] - BatchXX_data_combined_pairs_trackmate[BatchXX_data_combined_pairs_trackmate$C1_Image == cur_image & BatchXX_data_combined_pairs_trackmate$`C1_T Value (frame)` == (j - 2), "Relative_C1_Corrected_X Value (um)"], BatchXX_data_combined_pairs_trackmate[BatchXX_data_combined_pairs_trackmate$C1_Image == cur_image & BatchXX_data_combined_pairs_trackmate$`C1_T Value (frame)` == (j-1), "Relative_C1_Corrected_Y Value (um)"] - BatchXX_data_combined_pairs_trackmate[BatchXX_data_combined_pairs_trackmate$C1_Image == cur_image & BatchXX_data_combined_pairs_trackmate$`C1_T Value (frame)` == (j - 2), "Relative_C1_Corrected_Y Value (um)"], BatchXX_data_combined_pairs_trackmate[BatchXX_data_combined_pairs_trackmate$C1_Image == cur_image & BatchXX_data_combined_pairs_trackmate$`C1_T Value (frame)` == (j-1), "Relative_C1_Corrected_Z Value (um)"] - BatchXX_data_combined_pairs_trackmate[BatchXX_data_combined_pairs_trackmate$C1_Image == cur_image & BatchXX_data_combined_pairs_trackmate$`C1_T Value (frame)` == (j - 2), "Relative_C1_Corrected_Z Value (um)"]);
      v <- c(BatchXX_data_combined_pairs_trackmate[BatchXX_data_combined_pairs_trackmate$C1_Image == cur_image & BatchXX_data_combined_pairs_trackmate$`C1_T Value (frame)` == (j), "Relative_C1_Corrected_X Value (um)"] - BatchXX_data_combined_pairs_trackmate[BatchXX_data_combined_pairs_trackmate$C1_Image == cur_image & BatchXX_data_combined_pairs_trackmate$`C1_T Value (frame)` == (j - 1), "Relative_C1_Corrected_X Value (um)"], BatchXX_data_combined_pairs_trackmate[BatchXX_data_combined_pairs_trackmate$C1_Image == cur_image & BatchXX_data_combined_pairs_trackmate$`C1_T Value (frame)` == (j), "Relative_C1_Corrected_Y Value (um)"] - BatchXX_data_combined_pairs_trackmate[BatchXX_data_combined_pairs_trackmate$C1_Image == cur_image & BatchXX_data_combined_pairs_trackmate$`C1_T Value (frame)` == (j - 1), "Relative_C1_Corrected_Y Value (um)"], BatchXX_data_combined_pairs_trackmate[BatchXX_data_combined_pairs_trackmate$C1_Image == cur_image & BatchXX_data_combined_pairs_trackmate$`C1_T Value (frame)` == j, "Relative_C1_Corrected_Z Value (um)"] - BatchXX_data_combined_pairs_trackmate[BatchXX_data_combined_pairs_trackmate$C1_Image == cur_image & BatchXX_data_combined_pairs_trackmate$`C1_T Value (frame)` == (j - 1), "Relative_C1_Corrected_Z Value (um)"]);
      dot_uv <- u[1:2]%*%v[1:2];
      det_uv <- det(matrix(c(u[1:2],v[1:2]), nrow=2, ncol=2, byrow=TRUE));
      XY_angle <- atan2(det_uv, dot_uv);
      if (XY_angle < 0){
        XY_angle = (2 * 3.14159) + XY_angle;
      }
      BatchXX_data_combined_pairs_trackmate[BatchXX_data_combined_pairs_trackmate$C1_Image == cur_image & BatchXX_data_combined_pairs_trackmate$`C1_T Value (frame)` == j, "Relative_XY Angle (radians)"] <- XY_angle;
      dist_u <- dist(matrix(c(0,0,0,u[1], u[2],u[3]), nrow=2, ncol=3, byrow=TRUE), method="euclidean");
      dist_v <- dist(matrix(c(0,0,0,v[1], v[2],v[3]), nrow=2, ncol=3, byrow=TRUE), method="euclidean");
      dot_uv <- u%*%v;
      XYZ_angle <- acos(dot_uv/(dist_u * dist_v));
      if (XYZ_angle < 0){
        XYZ_angle = (2 * 3.14159) + XYZ_angle;
      }
      BatchXX_data_combined_pairs_trackmate[BatchXX_data_combined_pairs_trackmate$C1_Image == cur_image & BatchXX_data_combined_pairs_trackmate$`C1_T Value (frame)` == j, "Relative_XYZ Angle (radians)"] <- XYZ_angle;
      
    }
    else{
      BatchXX_data_combined_pairs_trackmate[BatchXX_data_combined_pairs_trackmate$C1_Image == cur_image & BatchXX_data_combined_pairs_trackmate$`C1_T Value (frame)` == j, "Relative_XY Angle (radians)"] <- NA;
      BatchXX_data_combined_pairs_trackmate[BatchXX_data_combined_pairs_trackmate$C1_Image == cur_image & BatchXX_data_combined_pairs_trackmate$`C1_T Value (frame)` == j, "Relative_XYZ Angle (radians)"] <- NA;
    }
  }
}

######## Relative XYZ Displacement

for (i in 1:nrow(traj_pairs)) {
  start = 1;
  end = opt$frames;
  cur_image = traj_pairs[i, "Image_Stack"];
  cur_data= BatchXX_data_combined_pairs_trackmate[BatchXX_data_combined_pairs_trackmate$C1_Image == cur_image,];
  for (j in start:end) {
    if (nrow(cur_data[cur_data$`C1_T Value (frame)` == (j - 1),]) != 0 && nrow(cur_data[cur_data$`C1_T Value (frame)` == j,]) != 0){
      BatchXX_data_combined_pairs_trackmate[BatchXX_data_combined_pairs_trackmate$C1_Image == cur_image & BatchXX_data_combined_pairs_trackmate$`C1_T Value (frame)` == j, "Relative_XYZ Displacement (um)"] <- sqrt((BatchXX_data_combined_pairs_trackmate[BatchXX_data_combined_pairs_trackmate$C1_Image == cur_image & BatchXX_data_combined_pairs_trackmate$`C1_T Value (frame)` == (j - 1), "Relative_C1_Corrected_X Value (um)"] - BatchXX_data_combined_pairs_trackmate[BatchXX_data_combined_pairs_trackmate$C1_Image == cur_image & BatchXX_data_combined_pairs_trackmate$`C1_T Value (frame)` == j, "Relative_C1_Corrected_X Value (um)"])^2 + (BatchXX_data_combined_pairs_trackmate[BatchXX_data_combined_pairs_trackmate$C1_Image == cur_image & BatchXX_data_combined_pairs_trackmate$`C1_T Value (frame)` == (j - 1), "Relative_C1_Corrected_Y Value (um)"] - BatchXX_data_combined_pairs_trackmate[BatchXX_data_combined_pairs_trackmate$C1_Image == cur_image & BatchXX_data_combined_pairs_trackmate$`C1_T Value (frame)` == j, "Relative_C1_Corrected_Y Value (um)"])^2 + (BatchXX_data_combined_pairs_trackmate[BatchXX_data_combined_pairs_trackmate$C1_Image == cur_image & BatchXX_data_combined_pairs_trackmate$`C1_T Value (frame)` == (j - 1), "Relative_C1_Corrected_Z Value (um)"] - BatchXX_data_combined_pairs_trackmate[BatchXX_data_combined_pairs_trackmate$C1_Image == cur_image & BatchXX_data_combined_pairs_trackmate$`C1_T Value (frame)` == j, "Relative_C1_Corrected_Z Value (um)"])^2);
    }
    else{
      BatchXX_data_combined_pairs_trackmate[BatchXX_data_combined_pairs_trackmate$C1_Image == cur_image & BatchXX_data_combined_pairs_trackmate$`C1_T Value (frame)` == j, "Relative_XYZ Displacement (um)"] <- NA;
    }
  }
}


if (opt$plot){  

# 
# 
# 
# ######### Figures ################
# ##################################
#

# ####### Distance Histograms ##########
pdf("./Tracking_data_plots.pdf");
par(mfrow=c(2,2), cex.main=0.8, cex=0.6);
x <- BatchXX_data_combined_pairs_trackmate;
cell_lines <- unique(x$Cell_Line);
for (i in cell_lines){
    hist(x[x$Cell_Line == i, "Corrected XY_Distance (um)"], breaks=c(0,seq(0.01,1.0,0.01), 3), xlim=c(0,1), xlab="Corrected XY Distance (um)", ylab="Counts", main=paste("Distribution of XY Distances between Labels for", i, "ESCs", sep=" "));
    hist(x[x$Cell_Line == i, "Corrected XYZ_Distance (um)"], breaks=c(0,seq(0.015,1.5,0.015), 3), xlim=c(0,1.5), xlab="Corrected XYZ Distance (um)", ylab="Counts", main=paste("Distribution of XYZ Distances between Labels for", i, "ESCs", sep=" "));
    x_100 <- x[x$Cell_Line == i & x$`Corrected XY_Distance (um)` <= 0.1,]
    x_200 <- x[x$Cell_Line == i & x$`Corrected XY_Distance (um)` <= 0.2 & x$`Corrected XY_Distance (um)` > 0.1, ];
    x_400 <- x[x$Cell_Line == i & x$`Corrected XY_Distance (um)` <= 0.4 & x$`Corrected XY_Distance (um)` > 0.2,];
    x_600 <- x[x$Cell_Line == i & x$`Corrected XY_Distance (um)` <= 0.6 & x$`Corrected XY_Distance (um)` > 0.4,];
    x_800 <- x[x$Cell_Line == i & x$`Corrected XY_Distance (um)` <= 0.8 & x$`Corrected XY_Distance (um)` > 0.6,];
    x_1000 <- x[x$Cell_Line == i & x$`Corrected XY_Distance (um)` <= 1.0 & x$`Corrected XY_Distance (um)` > 0.8,];


#
# ######## Velocity/Displacement Boxplots ############
#
#

boxplot(x_100$`Relative_XY Displacement (um)`,
x_200$`Relative_XY Displacement (um)`,
x_400$`Relative_XY Displacement (um)`,
x_600$`Relative_XY Displacement (um)`,
x_800$`Relative_XY Displacement (um)`,
x_1000$`Relative_XY Displacement (um)`,
names=c("0-100", "100-200", "200-400", "400-600", "600-800", "800-1000"), ylim=c(0,0.8), ylab="Relative XY Displacement (um)", main=paste("XY Displacement of C1_Locus Relative to C2 Between\n Frames of", i, "ESCs", sep=" "));

boxplot(x_100$`Relative_XYZ Displacement (um)`,
x_200$`Relative_XYZ Displacement (um)`,
x_400$`Relative_XYZ Displacement (um)`,
x_600$`Relative_XYZ Displacement (um)`,
x_800$`Relative_XYZ Displacement (um)`,
x_1000$`Relative_XYZ Displacement (um)`,
names=c("0-100", "100-200", "200-400", "400-600", "600-800", "800-1000"), ylim=c(0,1.0), ylab="Relative XYZ Displacement (um)", main=paste("XYZ Displacement of C1_Locus Relative to C2 Between\n Frames of", i, "ESCs", sep=" "));
}

# ######### Distance Scatterplots vs Time #########
#

par(mfrow=c(3,2))
x <- BatchXX_data_combined_pairs_trackmate;
y <- x[x$`Corrected XY_Distance (um)` <= 0.15,];
images <- unique(x$C1_Image)
for (k in 1:length(images)){current_line <- unique(x[x$C1_Image == images[k], "Cell_Line"]);
plot(x[x$C1_Image == images[k], "C1_T Value (sec)"], x[x$C1_Image == images[k], "Corrected XY_Distance (um)"], type="p", pch=20, main="XY Distance vs. Time with 150nm Threshold Highlighted", sub=paste(current_line, images[k]), ylab="XY Distance (um)", xlab="Time (sec)", ylim=c(0,1.5), xlim=c(0,t_point_step * 100));
points(y[y$C1_Image == images[k], "C1_T Value (sec)"], y[y$C1_Image == images[k], "Corrected XY_Distance (um)"], type="p", pch=20, col="red");
}


par(mfrow=c(3,2))
x <- BatchXX_data_combined_pairs_trackmate;
y <- x[x$`Corrected XYZ_Distance (um)` <= 0.30,];
images <- unique(x$C1_Image)
for (k in 1:length(images)){current_line <- unique(x[x$C1_Image == images[k], "Cell_Line"]);
plot(x[x$C1_Image == images[k], "C1_T Value (sec)"], x[x$C1_Image == images[k], "Corrected XYZ_Distance (um)"], type="p", pch=20, main="XYZ Distance vs. Time with 300nm Threshold Highlighted", sub=paste(current_line, images[k]), ylab="XYZ Distance (um)", xlab="Time (sec)", ylim=c(0,1.5), xlim=c(0, t_point_step * 100));
points(y[y$C1_Image == images[k], "C1_T Value (sec)"], y[y$C1_Image == images[k], "Corrected XYZ_Distance (um)"], type="p", pch=20, col="yellow");
}

dev.off()
}

if (opt$out) {
save.image("tracking_DataAnalysis.Rdata");
}
