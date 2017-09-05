for (i in sample_steps) {
  test_dist <- mix_model(x1, x2,i, 10000)
  k <- ks.test(Sox2_data_unsync_20sec[Sox2_data_unsync_20sec$Cell_Line == "101515.C3_NPC", "Corrected XYZ_Distance (um)"], test_dist)
  print(paste(i, ":", as.numeric(k$statistic), " ", as.numeric(k$p.value)))
}
