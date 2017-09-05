unique_df <- function(df, cols){
  df_dups <- x[,cols];
  return(x[!duplicated(df_dups),])
}