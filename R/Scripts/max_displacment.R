pair_explore <- function(dataset, min_value, max_value) {
disp_table <- data.frame(unique(dataset[,"C1_Image"]), NA, NA, 0, 0, 0, 0, 0, 0);
colnames(disp_table) <- c("Image", "Max_Displacement (um)", "Time_Bound (frames)", "Start Location (um)", "Min Frontier (um)", "Max Frontier (um)")
images <- unique(disp_table[, "Image"])
for (i in images){
  min_disp <- 0;
  max_disp <- 0;
  min_dist <- 0;
  max_dist <- 0;
  start_dist <- 0;
  cur_dist <- 0;
  cur_disp <- 0;
  min_bound <- FALSE;
  max_bound <- FALSE;
  time_bound  <- NA;
  if ((nrow(x[x$C1_Image == i,]) > 90) & (1 %in% x[x$C1_Image == i, "C1_T Value (frame)"]) & (100 %in% x[x$C1_Image == i, "C1_T Value (frame)"])){
   for (k in 1:100) {
     if (k == 1){
       start_dist <- x[x$C1_Image == i & x$`C1_T Value (frame)` == 1, "Corrected XY_Distance (um)"];
       min_dist <- start_dist;
       max_dist <- start_dist;
       if (start_dist < min_value){
         min_bound <- TRUE;
       }
       else if (start_dist > max_value){
         max_bound <- TRUE;
       }
     }
     else if (k %in% x[x$C1_Image == i, "C1_T Value (frame)"]){
       cur_dist <- x[x$C1_Image == i & x$`C1_T Value (frame)` == k, "Corrected XY_Distance (um)"];
       cur_disp <- cur_dist - start_dist;
       if (cur_dist < min_dist){
         min_dist <- cur_dist;
       }
       if (cur_dist > max_dist){
         max_dist <- cur_dist;
       }
       if (cur_disp < min_disp){
         min_disp <- cur_disp;
       }
       if (cur_disp > max_disp){
         max_disp <- cur_disp
       }
       if (cur_dist < min_value){
         min_bound <- TRUE;
       }
       else if (cur_dist > max_value){
         max_bound <- TRUE;
       }
     }
     if (min_bound & max_bound & is.na(time_bound)){
       time_bound <- k;
     }
   } 
  
  disp_table[disp_table$Image == i, "Max_Displacement (um)"] <- abs(min_disp) + max_disp;
  disp_table[disp_table$Image == i, "Time_Bound (frames)"] <- time_bound;
  disp_table[disp_table$Image == i, "Start Location (um)"] <- start_dist;
  disp_table[disp_table$Image == i, "Min Frontier (um)"] <- min_dist;
  disp_table[disp_table$Image == i, "Max Frontier (um)"] <- max_dist;

  
  
  
  
  disp_table_short <- disp_table[!is.na(disp_table$`Max_Displacement (um)`),];
  disp_table_short$Image <- as.factor(disp_table_short$Image);
  disp_table_short$Image <- factor(disp_table_short$Image, levels=disp_table_short[order(disp_table_short$`Max_Displacement (um)`), "Image"]);
  gp <- ggplot(disp_table_short, aes(x=`Min Frontier (um)`, y=Image)) + ylab(paste(nrow(disp_table_short), "Cells")) + xlab("2D Distance (um)") + theme(axis.ticks.y = element_blank(), axis.text.y = element_blank()) + scale_x_continuous(breaks = seq(0,1.5,by=0.2), limits=c(0,1.5)) + geom_errorbarh(aes(y=Image, x=`Min Frontier (um)`, xmin=`Min Frontier (um)`, xmax=`Max Frontier (um)`), size=1.2, col="salmon", height=0) + geom_errorbarh(data=disp_table_short[!is.na(disp_table_short$`Time_Bound (frames)`),],aes(y=Image, x=`Min Frontier (um)`, xmin=`Min Frontier (um)`, xmax=`Max Frontier (um)`), size=1.2, col="orange", height=0) + geom_point(aes(x=`Start Location (um)`, y=Image)) + geom_vline(xintercept=min_value, linetype=2) + geom_vline(xintercept=max_value, linetype=2)
  }
  my_list <- list("table" = disp_table, "graph" = gp);
  
}

return(my_list);
}