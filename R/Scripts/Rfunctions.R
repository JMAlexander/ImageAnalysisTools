output_loctable <- function(dataframe, file_name){
  temp_table <- dataframe[, c("C1_Image", "C1_X Value (pixel)", "C1_Y Value (pixel)", "C1_T Value (frame)", "C1_T Value (sec)")];
  write.table(temp_table, row.names=FALSE, quote=FALSE, sep="\t",file = file_name);
  
  return();
}

ggplot_setup <- function(black){
  if (black){
    gp <- ggplot() + theme(panel.background = element_blank(),
                           title = element_text(size=10, face="bold", color="white"),
                           plot.margin = unit(c(0.5,0.5,0.5,0.5), "cm"),
                           plot.background = element_rect(fill="black", color=NULL),
                           panel.grid.major = element_blank(),
                           panel.grid.minor = element_blank(),
                           axis.line.x = element_line(size=1.2, color="white"),
                           axis.line.y = element_line(size=1.2, color="white"),
                           axis.text.x = element_text(size=14, color="white"),
                           axis.title.x=element_text(size=14, face="bold", color="white"),
                           axis.text.y = element_text(size=14, color="white"),
                           axis.title.y=element_text(size=14, face="bold", color="white"),
                           axis.ticks = element_line(color="white"))
  }
  else {
    gp <- ggplot() + theme(panel.background = element_blank(),
                           plot.margin = unit(c(1,5,1,1), "cm"),
                           plot.background = element_rect(fill="white"),
                           panel.grid.major = element_blank(),
                           panel.grid.minor = element_blank(),
                           axis.line.x = element_line(size=1.2, color="black"),
                           axis.line.y = element_line(size=1.2, color="black"),
                           axis.text.x = element_text(size=14, color="black"),
                           axis.title.x=element_text(size=14, face="bold", color="black"),
                           axis.text.y = element_text(size=14, color="black"),
                           axis.title.y=element_text(size=14, face="bold", color="black"),
                           axis.ticks = element_line(color="black"))
  }
  
  return(gp);
}

mix_model = function(x1, x2, ratio, n){
  n_x1 <- round(n * ratio)
  n_x2 <- n - n_x1
  mix_sample <- c(sample(x=x1, size=n_x1, replace=TRUE), sample(x=x2, size=n_x2, replace=TRUE))
  return(mix_sample)
}

max_like = function(den, data){
  ll <- 0;
  for (d in data){
    match <- which.min(abs(d - den$x))
    norm_y <- den$y/sum(den$y)
    ll <- ll + log10(norm_y[match])
  }
  return(ll)
}


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

annotate_MS2bursts <- function(dataset, frames, burst_gap){
  images <- unique(dataset$C1_Image)
  
  for(i in images){
    for(f in 1:frames){
      burst_start = FALSE
      if (f %in% dataset[dataset$C1_Image == i, "C1_T.Value..frame."]){
        if (dataset[dataset$C1_Image == i & dataset$C1_T.Value..frame. == f, "Pass_Filter"] == "True"){
          burst_start = TRUE
          for(b in 1:burst_gap){
            cur_frame = f - b;
            if(cur_frame >= 1){
              if (dataset[dataset$C1_Image == i & dataset$C1_T.Value..frame. == cur_frame, "Pass_Filter"] == "True"){
                burst_start = FALSE
              }
            }
          }
        }
        dataset[dataset$C1_Image == i & dataset$C1_T.Value..frame. == f, "Start_Burst"] <-  burst_start;
      }
    }
  }
  
  return(dataset)
  
}

window_MS2bursts <- function(dataset, window_size){
  new_count <- 0;
  images <- unique(dataset$C1_Image)
  bursts <- data.frame("Relative_Frame"=seq(1, (window_size + 5),by=1))
  for(i in images){
    print(i)
    temp_df <- dataset[dataset$C1_Image == i,]
    burst_frames <- temp_df[temp_df$Start_Burst == TRUE, "C1_T.Value..frame."]
    for(f in burst_frames){
      new_count <- new_count + 1;
      burst_name <- paste(i, "_", "burst_f", f, sep="")
      new_burst <- data.frame(array(NA, dim=(window_size + 5)))
      print(burst_name)
      colnames(new_burst) <- burst_name
      count <- 1
      for(c in -4:window_size){
        cur_frame <- f + c
        if (cur_frame %in% temp_df$C1_T.Value..frame){
          new_burst[count, 1] <- temp_df[temp_df$C1_T.Value..frame == cur_frame, "Norm_Height_Filter"]
        }
        count <- count + 1
      }
      bursts <- data.frame(bursts, new_burst)
    }
  }
  col_num <- ncol(bursts);
  bursts <- data.frame(bursts, "Average_Bursts"=NA)
  for (j in 1:(window_size + 5)){
    bursts[j, "Average_Bursts"] <- mean(as.numeric(bursts[j, 2:col_num]), na.rm=TRUE)
  }
  print(new_count)
  return(bursts)
  
  
}

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

autocor_series <- function(data, seriesbycol, maxlag, frames){
  df <- data
  if (seriesbycol){
    df <- t(df)
  }
  nseries <- nrow(df)
  m_value <- mean(df, na.rm=TRUE)
  variance <- sd(df, na.rm=TRUE)^2
  
  ac <- array(NA, dim = (maxlag + 1))
  for (i in 0:maxlag){
    cc <- c()
    for (j in 1:nseries){
      for (t in 1:(frames - i)){
        cc <- c(cc, ((df[j,t] - m_value) * (df[j, (t + i)] - m_value))/variance)
      }
    }
    ac[i + 1] <- mean(cc, na.rm=TRUE)
  }

  return(ac)
}
        