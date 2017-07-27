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
