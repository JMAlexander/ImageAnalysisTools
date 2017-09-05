mdisp_table <- data.frame(unique(x[x$Cell_Line == "101515.C3_ESC", "C1_Image"]), NA, NA);
colnames(min_disp_table) <- c("Image", "Pass_Criteria", "Time_Bound (frames)")
images <- unique(x[x$Cell_Line == "101515.C3_NPC", "C1_Image"])
for (i in images){
  min_disp <- 0;
  start_dist <- 0;
  cur_dist <- 0;
  cur_disp <- 0;
  min_bound <- FALSE;
  time_bound  <- NA;
  if ((nrow(x[x$C1_Image == i,]) > 90) & (1 %in% x[x$C1_Image == i, "C1_T Value (frame)"]) & (100 %in% x[x$C1_Image == i, "C1_T Value (frame)"])){
    min_disp_table[min_disp_table$Image == i, "Pass_Criteria"] <- TRUE;
    
    for (k in 1:100) {
      if (k == 0){
        start_dist <- x[x$C1_Image == i & x$`C1_T Value (frame)` == 0, "Corrected XY_Distance (um)"];
        if (start_dist < 0.015){
          min_bound <- TRUE;
        }
        
      }
      else if (k %in% x[x$C1_Image == i, "C1_T Value (frame)"]){
        cur_dist <- x[x$C1_Image == i & x$`C1_T Value (frame)` == k, "Corrected XY_Distance (um)"];
        cur_disp <- cur_dist - start_dist;
        if (cur_disp < min_disp){
          min_disp <- cur_disp;
        }
        if (cur_dist < 0.150){
          min_bound <- TRUE;
        }
        
      }
      if (min_bound & is.na(time_bound)){
        time_bound <- k;
      }
    } 
    
    min_disp_table[min_disp_table$Image == i, "Time_Bound (frames)"] <- time_bound;
    
  }
  
}