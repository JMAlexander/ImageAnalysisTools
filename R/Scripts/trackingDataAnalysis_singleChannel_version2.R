library(stringr);
library(optparse);

### It looks like trackmate shifts pixel value by 0.5.

option_list = list(
	make_option(c("-d", "--dir"), type="character", dest="dir", default=NULL, help="Directory containing trackmate files.  Should contain 200_spots and 600_spots subdirectories..."),
	make_option(c("-o", "--out"), action="store_true", dest="out", default=FALSE, help="Save data to an R.data file in directory specified as 'dir'"),
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

num_spots = 1200;

if (!is.null(opt$dir)){
    setwd(opt$dir);
    spot_dir <- list.files(path=".", pattern="[0-9]+_spots");
    setwd(spot_dir);
	
	c1_textfile_spots1 <- paste(opt$dir, spot_dir, "/", Sys.glob("C1*.txt"), sep="");

	setwd(opt$dir);

} else {
	c1_textfile_spots1 <- "/Users/Jeff/Desktop/01_26_2017_Batch34/TrackMate/200_spots/C1_Batch34.txt";
	c2_textfile_spots1 <- "/Users/Jeff/Desktop/01_26_2017_Batch34/TrackMate/200_spots/C2_Batch34.txt";

	c1_textfile_spots2 <- "/Users/Jeff/Desktop/05_27_16_Batch06/TrackMate/Cropped_Images/600_spots/C1_Batch06.txt";
	c2_textfile_spots2 <- "/Users/Jeff/Desktop/05_27_16_Batch06/TrackMate/Cropped_Images/600_spots/C2_Batch06.txt";
	traj_file <- "/Users/Jeff/Desktop/05_27_16_Batch06/TrackMate/Cropped_Images/Batch06_traj_pairs.txt";
}


## Open data files

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
Rdata_file <- ""
G1_pairs <- as.array(traj_pairs[,2]);
x_pixel_size <- 0.091;  ###Edit these where appropriate
y_pixel_size <- 0.091;
z_step_size <- 0.3;
t_point_step <- opt$time;


BatchXX_data_c1_spots1 <- read.delim(file=c1_textfile_spots1, header=TRUE, sep="\t", stringsAsFactors = FALSE);
BatchXX_data_c1_spots1 <- BatchXX_data_c1_spots1[,1:7];
BatchXX_data_c1_spots1 <- data.frame("Place_holder", "Place_holder", opt$sync, BatchXX_data_c1_spots1, 0, 0, 0, 0, stringsAsFactors=FALSE);
colnames(BatchXX_data_c1_spots1) <- c("Cell_Line", "Batch", "Sync", "C1_Image", "C1_TrackID", "C1_SpotID", "C1_X Value (pixel)", "C1_Y Value (pixel)", "C1_Z Value (slice)", "C1_T Value (frame)", "C1_X Value (um)", "C1_Y Value (um)", "C1_Z Value (um)", "C1_T Value (sec)");
BatchXX_data_c1_spots1[,"C1_Image"] <- as.character(BatchXX_data_c1_spots1$C1_Image);
BatchXX_data_c1_spots1[,"C1_SpotID"] <- as.character(BatchXX_data_c1_spots1$C1_SpotID);
BatchXX_data_c1_spots1$`C1_X Value (pixel)` <- BatchXX_data_c1_spots1$`C1_X Value (pixel)` + 0.5;
BatchXX_data_c1_spots1$`C1_Y Value (pixel)` <- BatchXX_data_c1_spots1$`C1_Y Value (pixel)` + 0.5;
BatchXX_data_c1_spots1$`C1_T Value (frame)` <- BatchXX_data_c1_spots1$`C1_T Value (frame)` + 1;

BatchXX_data_c1_spots1$`C1_X Value (um)` <- BatchXX_data_c1_spots1$`C1_X Value (pixel)` *  x_pixel_size;
BatchXX_data_c1_spots1$`C1_Y Value (um)` <- BatchXX_data_c1_spots1$`C1_Y Value (pixel)` *  y_pixel_size;
BatchXX_data_c1_spots1$`C1_Z Value (um)` <- BatchXX_data_c1_spots1$`C1_Z Value (slice)` *  z_step_size;
BatchXX_data_c1_spots1$`C1_T Value (sec)` <- BatchXX_data_c1_spots1$`C1_T Value (frame)` * t_point_step;

######

BatchXX_data_spots1_combined <- data.frame(BatchXX_data_c1_spots1, FALSE, stringsAsFactors=FALSE);
col_value <- ncol(BatchXX_data_c1_spots1);
colnames(BatchXX_data_spots1_combined)[1:col_value] <- colnames(BatchXX_data_c1_spots1);
colnames(BatchXX_data_spots1_combined)[col_value + 1] <- "Tagged";

for (i in 1:nrow(traj_pairs)) {
  start = 1;
  end = opt$frames;
  if (str_detect(traj_pairs[i, "Notes"], "[0-9]+")){
    matches <- str_extract_all(traj_pairs[i, "Notes"], "[0-9]+", simplify=TRUE);
    start = as.integer(matches[,1]);
    end = as.integer(matches[,2]);
  }
  if (traj_pairs[i, "Num_Spots"] == num_spots){
  for (j in start:end) {
    if ((j %in% BatchXX_data_c1_spots1[BatchXX_data_c1_spots1$C1_Image == traj_pairs[i,"Image_Stack"] & BatchXX_data_c1_spots1$C1_TrackID == traj_pairs[i,"C1_Pair"], "C1_T Value (frame)"])){
    BatchXX_data_spots1_combined[BatchXX_data_spots1_combined$C1_Image == traj_pairs[i,"Image_Stack"] & BatchXX_data_spots1_combined$C1_TrackID == traj_pairs[i,"C1_Pair"] & BatchXX_data_spots1_combined$`C1_T Value (frame)` == j,"Tagged"] <- TRUE;
    BatchXX_data_spots1_combined[BatchXX_data_spots1_combined$C1_Image == traj_pairs[i,"Image_Stack"] & BatchXX_data_spots1_combined$C1_TrackID == traj_pairs[i,"C1_Pair"] & BatchXX_data_spots1_combined$`C1_T Value (frame)` == j,"Cell_Line"] <- traj_pairs[i, "Cell_Line"];
    BatchXX_data_spots1_combined[BatchXX_data_spots1_combined$C1_Image == traj_pairs[i,"Image_Stack"] & BatchXX_data_spots1_combined$C1_TrackID == traj_pairs[i,"C1_Pair"] & BatchXX_data_spots1_combined$`C1_T Value (frame)` == j,"Batch"] <- traj_pairs[i, "Batch"];
    
    }
  }
  }
  
}



BatchXX_data_combined <- rbind(BatchXX_data_spots1_combined);

BatchXX_data_combined_sorted <- BatchXX_data_combined[order(BatchXX_data_combined$C1_Image, BatchXX_data_combined$C1_TrackID, BatchXX_data_combined$`C1_T Value (frame)`),];
BatchXX_data_combined_pairs_trackmate <- BatchXX_data_combined_sorted[BatchXX_data_combined_sorted$Tagged == TRUE,];
#BatchXX_data_combined_pairs_trackmate <- BatchXX_data_combined_pairs_trackmate[BatchXX_data_combined_pairs_trackmate$`C1_Z Value (slice)` > 2,];
#BatchXX_data_combined_pairs_trackmate <- BatchXX_data_combined_pairs_trackmate[BatchXX_data_combined_pairs_trackmate$`C1_Z Value (slice)` < 25,];

images <- unique(BatchXX_data_combined_pairs_trackmate$C1_Image);

if (opt$out) {
save.image("tracking_DataAnalysis.Rdata");
}
