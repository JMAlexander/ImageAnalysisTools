win_size_col <- function(data) {

window_data_init <- data.frame("Place_holder", "Place_holder", "Place_holder", 0, stringsAsFactors = FALSE);
window_data <- data.frame("Place_holder", "Place_holder", "Place_holder", 0, stringsAsFactors = FALSE);  
window_merged = TRUE;
x <- cbind(data, FALSE, 0, FALSE);
colnames(x)[48:50] <- c("Pass_Threshold_150_300", "Window_Size_150_300", "Pass_Proportional_Threshold_150_300");
thresh_min <- 0.15;
thresh_max <- 0.3;
prop_threshold <- 0.90;
dimensions <- "XY";
images <- unique(x$C1_Image);
pass <- 1;

if (dimensions == "XY"){
  x[x$`Corrected XY_Distance (um)` > thresh_min & x$`Corrected XY_Distance (um)` <= thresh_max , "Pass_Threshold_150_300"] <- "TRUE";
  x[x$`Corrected XY_Distance (um)` > thresh_min & x$`Corrected XY_Distance (um)` <= thresh_max , "Pass_Proportional_Threshold_150_300"] <- "TRUE";

}
else if (dimensions == "XYZ"){
  x[x$`Corrected XYZ_Distance (um)` > thresh_min & x$`Corrected XYZ_Distance (um)` <= thresh_max , "Pass_Threshold_150_300"] <- "TRUE";
  x[x$`Corrected XYZ_Distance (um)` > thresh_min & x$`Corrected XYZ_Distance (um)` <= thresh_max , "Pass_Proportional_Threshold_150_300"] <- "TRUE";

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
    else if (x[x$C1_Image == images[k] & x$`C1_T Value (frame)` == l, "Pass_Proportional_Threshold_150_300"] == "TRUE" & t_start == 0){
      t_start <- l;
    }
    else if (x[x$C1_Image == images[k] & x$`C1_T Value (frame)` == l, "Pass_Proportional_Threshold_150_300"] == "FALSE" & l != 0 & !false_window){
      false_window <- TRUE;
    }
    else if (x[x$C1_Image == images[k] & x$`C1_T Value (frame)` == l, "Pass_Proportional_Threshold_150_300"] == "TRUE" & false_window & !true_window){
      true_window <- TRUE;
      next_window_start <- l;
    }
    else if (x[x$C1_Image == images[k] & x$`C1_T Value (frame)` == l, "Pass_Proportional_Threshold_150_300"] == "FALSE" & false_window & true_window){
      t_end <- l;
      nPASS <- nrow(x[x$C1_Image == images[k] & x$`C1_T Value (frame)` %in% seq(t_start,t_end,by=1) & x$Pass_Threshold_150_300 == TRUE,]);
      nFAIL <- nrow(x[x$C1_Image == images[k] & x$`C1_T Value (frame)` %in% seq(t_start,t_end,by=1) & x$Pass_Threshold_150_300 == FALSE,]);
      proportion <- nPASS / (nPASS + nFAIL + noDATA);
      if (proportion > prop_threshold){
        mod_win = mod_win + 1;
        x[x$C1_Image == images[k] & x$`C1_T Value (frame)` %in% seq(t_start,t_end,by=1),"Pass_Proportional_Threshold_150_300"] <- TRUE;
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
images <- unique(x$C1_Image);
for (k in 1:length(images)){
  t_start <- 0;
  t_end <- 0;
  for (l in 1:100){

    if (l %in% x[x$C1_Image == images[k], "C1_T Value (frame)"]){
      if (x[x$C1_Image == images[k] & x$`C1_T Value (frame)` == l, "Pass_Proportional_Threshold_150_300"] == "TRUE"){
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
          x[x$C1_Image == images[k] & x$`C1_T Value (frame)` == m, "Window_Size_150_300"] <- win_size;
        }
        t_start = 0;
        t_end = 0;
        win_size <- 0;

      }
    }
    else if (win_size > 0){
      #window_data[cur_row,] <- c(unique(x[x$C1_Image == images[k], "Cell_Line"]), unique(x[x$C1_Image == images[k], "Batch"]), unique(x[x$C1_Image == images[k], "C1_Image"]), win_size);
      #win_size <- 0;
      #window_data <- rbind(window_data, window_data_init);
      #cur_row <- cur_row + 1;
    }
  }
  if (win_size > 0){
    window_data[cur_row,] <- c(unique(x[x$C1_Image == images[k], "Cell_Line"]), unique(x[x$C1_Image == images[k], "Batch"]), unique(x[x$C1_Image == images[k], "C1_Image"]), win_size);
    window_data <- rbind(window_data, window_data_init);
    cur_row <- cur_row + 1;

    t_end <- l - 1;
    for(m in t_start:t_end){
      x[x$C1_Image == images[k] & x$`C1_T Value (frame)` == m, "Window_Size_150_300"] <- win_size;
    }
    win_size <- 0;
    t_start = 0;
    t_end = 0;

  }
}

return(x)
}