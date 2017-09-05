msd <- function(data, tpoints, dim, time_average){

x <- data;
cells <- unique(x$C1_Image);
col_num <- length(cells);
msd_table <- as.data.frame(matrix(NA, nrow=tpoints, ncol=col_num));
msd_table <- cbind(msd_table, 0);

colnames(msd_table)[1:col_num] <- cells;
colnames(msd_table)[col_num + 1] <- "MSD";

if (time_average){
  for(c in 1:(tpoints/2))
    print(c)
}
  
if (dim == "XY"){
for (i in cells){
  for (j in 1:tpoints){
  if (1 %in% x[x$C1_Image == i, "C1_T Value (frame)"] & j %in% x[x$C1_Image == i, "C1_T Value (frame)"]) {
      msd_table[j, i] <- (x[x$C1_Image == i & x$`C1_T Value (frame)` == j,"Corrected XY_Distance (um)"] - x[x$C1_Image == i & x$`C1_T Value (frame)` == 1,"Corrected XY_Distance (um)"])^2}}}
} else if (dim == "XYZ"){
for (i in cells) {for (j in 1:tpoints) {if (1 %in% x[x$C1_Image == i, "C1_T Value (frame)"] & j %in% x[x$C1_Image == i, "C1_T Value (frame)"]) {msd_table[j, i] <- (x[x$C1_Image == i & x$`C1_T Value (frame)` == j,"Corrected XYZ_Distance (um)"] - x[x$C1_Image == i & x$`C1_T Value (frame)` == 1,"Corrected XYZ_Distance (um)"])^2}}}
}

msd_table[,"MSD"] <- rowMeans(msd_table[,-ncol(msd_table)], na.rm=TRUE);

return(msd_table);
}
