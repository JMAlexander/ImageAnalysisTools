loc_window_analysis <- function(batch, cell_line, dimensions) {


b <- data.frame("Place_Holder", 0, 0, 0, 0, 0 ,0, 0 ,0 ,0 ,0 ,0 ,0, 0, 0 ,0 ,0 ,0 ,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, stringsAsFactors = FALSE);
colnames(b) <- c("Analysis_Subset", "150nm_Window0-4", "150nm_Window4-8", "150nm_Window8-12", "150nm_Window12-16", "150nm_Window16-20", "150nm_Window20-100", "300nm_Window0-4", "300nm_Window4-8", "300nm_Window8-12", "300nm_Window12-16", "300nm_Window16-20", "300nm_Window20-100", "450nm_Window0-4", "450nm_Window4-8", "450nm_Window8-12", "450nm_Window12-16", "450nm_Window16-20", "450nm_Window20-100", "600nm_Window0-4", "600nm_Window4-8", "600nm_Window8-12", "600nm_Window12-16", "600nm_Window16-20", "600nm_Window20-100", "750nm_Window0-4", "750nm_Window4-8", "750nm_Window8-12", "750nm_Window12-16", "750nm_Window16-20", "750nm_Window20-100", "1000nm_Window0-4", "1000nm_Window4-8", "1000nm_Window8-12", "1000nm_Window12-16", "1000nm_Window16_20", "1000nm_Window20-100");
b[1,"Analysis_Subset"] <- paste("window_data", dimensions, batch, cell_line, sep="_")
##########
for (i in seq(1,1)){

if (i == 1){
  thresh_min <- 0;
  thresh_max <- 0.15;
  row_min <- 2;
  row_max <- 7;
}
else if (i == 2){
  thresh_min <- 0.15;
  thresh_max <- 0.3;
  row_min <- 8;
  row_max <- 13;
}
else if (i == 3){
    thresh_min <- 0.3;
    thresh_max <- 0.45;
    row_min <- 14;
    row_max <- 19;
}
else if (i == 4){
    thresh_min <- 0.45;
    thresh_max <- 0.6;
    row_min <- 20;
    row_max <- 25;
}
else if (i == 5){
    thresh_min <- 0.6;
    thresh_max <- 0.75;
    row_min <- 26;
    row_max <- 31;
}
else if (i == 6){
    thresh_min <- 0.75;
    thresh_max <- 1.0;
    row_min <- 32;
    row_max <- 37;
}

x <- Sox2_data_sync[Sox2_data_sync$Cell_Line == "101515.C3_NPC", ];
x <- cbind(x, "FALSE", 0, 0);
colnames(x)[49:51] <- c("Pass_Threshold", "Window_Size", "Window_Size (sec)");
levels(x$Pass_Threshold) <- c("FALSE", "TRUE");

if (dimensions == "XY"){
x[x$`Corrected XY_Distance (um)` > thresh_min & x$`Corrected XY_Distance (um)` <= thresh_max , "Pass_Threshold"] <- "TRUE";
}
else if (dimensions == "XYZ"){
x[x$`Corrected XYZ_Distance (um)` > thresh_min & x$`Corrected XYZ_Distance (um)` <= thresh_max , "Pass_Threshold"] <- "TRUE";
}
else{
    stop;
}


win_size <- 0;
images <- unique(x$C1_Image);
window_data_init <- data.frame("Place_holder", "Place_holder", "Place_holder", 0, stringsAsFactors = FALSE);
window_data <- data.frame("Place_holder", "Place_holder", "Place_holder", 0, stringsAsFactors = FALSE);
cur_row <- 1;
colnames(window_data) <- c("Cell_Line", "Batch", "Image", "Window_Size");
colnames(window_data_init) <- c("Cell_Line", "Batch", "Image", "Window_Size");

for (k in 1:length(images)){
  t_start <- 0;
  t_end <- 0;
  for (l in 1:100){

    if (l %in% x[x$C1_Image == images[k], "C1_T Value (frame)"]){
      if (x[x$C1_Image == images[k] & x$`C1_T Value (frame)` == l, "Pass_Threshold"] == "TRUE"){
        if (win_size == 0){
          t_start <- l;
        }
        win_size <- win_size + 1;
      }
      else if (win_size > 0){
        
        window_data[cur_row,] <- c(unique(x[x$C1_Image == images[k], "Cell_Line"]), unique(x[x$C1_Image == images[k], "Batch"]), unique(x[x$C1_Image == images[k], "C1_Image"]), win_size);
        window_data <- rbind(window_data, window_data_init);
        cur_row <- cur_row + 1;
        
        t_end <- l;
        for(m in t_start:t_end){
        x[x$C1_Image == images[k] & x$`C1_T Value (frame)` == m, "Window_Size"] <- win_size;
        }
        t_start = 0;
        t_end = 0;
        win_size <- 0;
        
      }
    }
    else if (win_size > 0){
      #window_data[cur_row,] <- c(unique(x[x$C1_Image == images[k], "Cell_Line"]), unique(x[x$C1_Image == images[k], "Batch"]), unique(x[x$C1_Image == images[k], "C1_Image"]), win_size);
      win_size <- 0;
      #window_data <- rbind(window_data, window_data_init);
      #cur_row <- cur_row + 1;
    }
  }
  if (win_size > 0){
    window_data[cur_row,] <- c(unique(x[x$C1_Image == images[k], "Cell_Line"]), unique(x[x$C1_Image == images[k], "Batch"]), unique(x[x$C1_Image == images[k], "C1_Image"]), win_size);
    window_data <- rbind(window_data, window_data_init);
    cur_row <- cur_row + 1;
    
    t_end <- l;
    for(m in t_start:t_end){
      x[x$C1_Image == images[k] & x$`C1_T Value (frame)` == m, "Window_Size"] <- win_size;
    }
    win_size <- 0;
    t_start = 0;
    t_end = 0;
    
  }
}
class(window_data$Window_Size) <- "numeric";

temp_hist <- hist(window_data$Window_Size, breaks=c(0,4,8,12,16,20,100), plot=FALSE);
b[,row_min:row_max] <- temp_hist$counts;
}


return(b)
}

##########
below_values = 0
above_values = 0

for (i in 1:nrow(window_data)){
  if (window_data[i, 4] < 10){
  
   below_values = below_values + window_data[i, 4]
   }
   else if (window_data[i, 4] >= 10){
         above_values = above_values + window_data[i, 4]
   }
}
print(above_values);
print(below_values + above_values);
