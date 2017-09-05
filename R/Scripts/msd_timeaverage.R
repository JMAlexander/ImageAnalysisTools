msd <- function(data, tpoints, tstep, dim){

x <- data;
cells <- unique(x$C1_Image);
col_num <- length(cells);
msd_table <- as.data.frame(matrix(NA, nrow=(tpoints / 2), ncol=(col_num + 10)));
cell_disp_array <- c()
time_disp_array <- c()
colnames(msd_table) <- c("Frame", "Time (sec)", cells, "Cell_Average_MSD", "Cell_Average_MSD_SD", "Cell_Average_Left_90_Conf_Int", "Cell_Average_Right_90_Conf_Int", "Data_Average_MSD", "Data_Average_MSD_SD", "Data_Average_Left_90_Conf_Int", "Data_Average_Right_90_Conf_Int");

msd_table$Frame <- seq(1, (tpoints/2), by=1);
msd_table$`Time (sec)` <- msd_table$Frame * tstep
  for (i in cells){
    for(a in 1:(tpoints / 2)){
      cell_disp_array <- c()
        for(j in 1:tpoints){
          if (j %in% x[x$C1_Image == i, "C1_T Value (frame)"] & (j + a) %in% x[x$C1_Image == i, "C1_T Value (frame)"]){
          if (dim == "XY"){
            value <- (x[x$C1_Image == i & x$`C1_T Value (frame)` == (j + a),"Corrected XY_Distance (um)"] - x[x$C1_Image == i & x$`C1_T Value (frame)` == j,"Corrected XY_Distance (um)"])^2
          }
            else if (dim == "XYZ"){
            value <- (x[x$C1_Image == i & x$`C1_T Value (frame)` == (j + a),"Corrected XYZ_Distance (um)"] - x[x$C1_Image == i & x$`C1_T Value (frame)` == j,"Corrected XYZ_Distance (um)"])^2
            }
          cell_disp_array <- c(cell_disp_array, value)
          }
        }
        
      msd_table[a, i] <- mean(cell_disp_array, na.rm=TRUE)
      }

  }
  for(a in 1:(tpoints / 2)){
    msd_table[a, "Cell_Average_MSD"] <- mean(as.numeric(msd_table[a,2:(ncol(msd_table)-8)]), na.rm=TRUE);
    msd_table[a, "Cell_Average_MSD_SD"] <- sd(as.numeric(msd_table[a,2:(ncol(msd_table)-8)]), na.rm=TRUE);
    m <- msd_table[a, "Cell_Average_MSD"];
    s <- msd_table[a, "Cell_Average_MSD_SD"];
    n<-sum(!is.na(msd_table[a,2:(ncol(msd_table)-8)]));
    error <- qnorm(0.975)*s/sqrt(n);
    msd_table[a, "Cell_Average_Left_90_Conf_Int"] <- m-error;
    msd_table[a, "Cell_Average_Right_90_Conf_Int"] <- m+error;
  }
  for(a in 1:(tpoints / 2)){
    time_disp_array <- c()
    for (i in cells){
      for(j in 1:tpoints){
      if (j %in% x[x$C1_Image == i, "C1_T Value (frame)"] & (j + a) %in% x[x$C1_Image == i, "C1_T Value (frame)"]){
        if (dim == "XY"){
          value <- (x[x$C1_Image == i & x$`C1_T Value (frame)` == (j + a),"Corrected XY_Distance (um)"] - x[x$C1_Image == i & x$`C1_T Value (frame)` == j,"Corrected XY_Distance (um)"])^2
        }
        else if (dim == "XYZ"){
          value <- (x[x$C1_Image == i & x$`C1_T Value (frame)` == (j + a),"Corrected XYZ_Distance (um)"] - x[x$C1_Image == i & x$`C1_T Value (frame)` == j,"Corrected XYZ_Distance (um)"])^2
        }
        time_disp_array <- c(time_disp_array, value)
      }
    }
    
    }
    msd_table[a, "Data_Average_MSD"] <- mean(time_disp_array, na.rm=TRUE)
    msd_table[a, "Data_Average_MSD_SD"] <- sd(time_disp_array, na.rm=TRUE);
    m <- msd_table[a, "Data_Average_MSD"];
    s <- msd_table[a, "Data_Average_MSD_SD"];
    n<-sum(!is.na(time_disp_array));
    error <- qnorm(0.975)*s/sqrt(n);
    msd_table[a, "Data_Average_Left_90_Conf_Int"] <- m-error;
    msd_table[a, "Data_Average_Right_90_Conf_Int"] <- m+error;
    
  
}


return(msd_table);
}
