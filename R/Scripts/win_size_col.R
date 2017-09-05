win_size_col <- function(data, min, max,thresh, win_yes) {

window_data_init <- data.frame("Place_holder", "Place_holder", "Place_holder", 0, stringsAsFactors = FALSE);
colnames(window_data_init)<- c("Cell_Line", "Batch", "Image", "Window_Size")
window_data <- data.frame("Place_holder", "Place_holder", "Place_holder", 0, stringsAsFactors = FALSE);  
colnames(window_data)<- c("Cell_Line", "Batch", "Image", "Window_Size")
window_merged = TRUE;
x <- cbind(data, FALSE, 0, FALSE);

thresh_col_name <- paste("Pass_Threshold", min, max, sep="_");
window_name <- paste("Window_Size", min, max, sep="_");
prop_col_name <- paste("Pass_Proportional_Threshold", min, max, sep="_");


colnames(x)[(ncol(data) + 1):(ncol(data) + 3)] <- c(thresh_col_name, window_name, prop_col_name);
thresh_min <- min;
thresh_max <- max;
prop_threshold <- thresh;
dimensions <- "XY";
images <- unique(x$C1_Image);
pass <- 1;

if (dimensions == "XY"){
  x[x$`Corrected XY_Distance (um)` > thresh_min & x$`Corrected XY_Distance (um)` <= thresh_max , thresh_col_name] <- "TRUE";
  x[x$`Corrected XY_Distance (um)` > thresh_min & x$`Corrected XY_Distance (um)` <= thresh_max , prop_col_name] <- "TRUE";

}
else if (dimensions == "XYZ"){
  x[x$`Corrected XYZ_Distance (um)` > thresh_min & x$`Corrected XYZ_Distance (um)` <= thresh_max , thresh_col_name] <- "TRUE";
  x[x$`Corrected XYZ_Distance (um)` > thresh_min & x$`Corrected XYZ_Distance (um)` <= thresh_max , prop_col_name] <- "TRUE";

}
else{
  stop;
}

###################


while (window_merged){
  print(c("Pass: ", pass), quote=FALSE);
  pass = pass + 1;
  mod_win = 1;
  window_merged <- FALSE;

for (k in 1:length(images)){
  print(images[k], quote=FALSE);
  t_start <- 0;
  t_end <- 0;
  false_window <- FALSE;
  true_window <- FALSE;
  nPASS <- 0;
  nFAIL <- 0;
  noDATA <- 0;
  for (l in 1:100){
    if (!(l %in% x[x$C1_Image == images[k], "C1_T Value (frame)"])){
      noDATA <- noDATA + 1;
    }
    else if (x[x$C1_Image == images[k] & x$`C1_T Value (frame)` == l, prop_col_name] == "TRUE" & t_start == 0){
      t_start <- l;
    }
    else if (x[x$C1_Image == images[k] & x$`C1_T Value (frame)` == l, prop_col_name] == "FALSE" & l != 0 & !false_window){
      false_window <- TRUE;
    }
    else if (x[x$C1_Image == images[k] & x$`C1_T Value (frame)` == l, prop_col_name] == "TRUE" & false_window & !true_window){
      true_window <- TRUE;
      next_window_start <- l;
    }
    else if (x[x$C1_Image == images[k] & x$`C1_T Value (frame)` == l, prop_col_name] == "FALSE" & false_window & true_window){
      t_end <- l;
      nPASS <- nrow(x[x$C1_Image == images[k] & x$`C1_T Value (frame)` %in% seq(t_start,t_end,by=1) & x[,thresh_col_name] == TRUE,]);
      nFAIL <- nrow(x[x$C1_Image == images[k] & x$`C1_T Value (frame)` %in% seq(t_start,t_end,by=1) & x[,thresh_col_name] == FALSE,]);
      proportion <- nPASS / (nPASS + nFAIL + noDATA);
      if (proportion > prop_threshold){
        mod_win = mod_win + 1;
        x[x$C1_Image == images[k] & x$`C1_T Value (frame)` %in% seq(t_start,t_end,by=1), prop_col_name] <- TRUE;
        window_merged <- TRUE;
      }
      t_start <- next_window_start;
      t_end <- next_window_start;
      false_window <- TRUE;
      true_window <- FALSE;
      nPASS <- 0;
      nFAIL <- 0;
      noDATA <- 0;
    }

  }
}
print(c("Modified Windows: ", mod_win), quote=FALSE);
}

####################################

win_size = 0;
cur_row = 1;
images <- unique(x$C1_Image);
for (k in 1:length(images)){
  t_start <- 0;
  t_end <- 0;
  for (l in 1:100){

    if (l %in% x[x$C1_Image == images[k], "C1_T Value (frame)"]){
      if (x[x$C1_Image == images[k] & x$`C1_T Value (frame)` == l, prop_col_name] == "TRUE"){
        if (win_size == 0){
          t_start <- l;
        }
        win_size <- win_size + 1;
      }
      else if (win_size > 0){

        window_data[cur_row,] <- c(unique(x[x$C1_Image == images[k], "Cell_Line"]), unique(x[x$C1_Image == images[k], "Batch"]), unique(x[x$C1_Image == images[k], "C1_Image"]), win_size);
        window_data <- rbind(window_data, window_data_init);
        cur_row <- cur_row + 1;

        t_end <- l - 1;
        for(m in t_start:t_end){
          x[x$C1_Image == images[k] & x$`C1_T Value (frame)` == m, window_name] <- win_size;
        }
        t_start = 0;
        t_end = 0;
        win_size <- 0;

      }
    }
    else if (win_size > 0){
      window_data[cur_row,] <- c(unique(x[x$C1_Image == images[k], "Cell_Line"]), unique(x[x$C1_Image == images[k], "Batch"]), unique(x[x$C1_Image == images[k], "C1_Image"]), win_size);
      win_size <- 0;
      window_data <- rbind(window_data, window_data_init);
      cur_row <- cur_row + 1;
    }
  }
  if (win_size > 0){
    window_data[cur_row,] <- c(unique(x[x$C1_Image == images[k], "Cell_Line"]), unique(x[x$C1_Image == images[k], "Batch"]), unique(x[x$C1_Image == images[k], "C1_Image"]), win_size);
    window_data <- rbind(window_data, window_data_init);
    cur_row <- cur_row + 1;

    t_end <- l - 1;
    for(m in t_start:t_end){
      x[x$C1_Image == images[k] & x$`C1_T Value (frame)` == m, window_name] <- win_size;
    }
    win_size <- 0;
    t_start = 0;
    t_end = 0;

  }
}
colnames(window_data)<- c("Cell_Line", "Batch", "Image", "Window_Size")
window_data$Window_Size <- as.numeric(window_data$Window_Size);

if (win_yes) { return(window_data) }
else { return(x) }

}