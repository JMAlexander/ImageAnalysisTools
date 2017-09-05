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
  
ll_dat <- data.frame("Mix_Prop"=0, "LogLik"=0) 
plot(NA, ylab="Normalized Density", xlab="3D Distance (um)", ylim=c(0,4), xlim=c(0,1))
pal <- rainbow(100)

for (num in n){
  col_num <- num * 100
  mix_dist <- mix_model(x1, x2, num, 100000)
  den_mix <- density(mix_dist, from=0, to=1.0, n=100)
  lines(den_mix$x, den_mix$y, col=alpha(pal[col_num], 0.35))
  probs <- max_like(den_mix, data=x4)
  ll_dat[nrow(ll_dat),"Mix_Prop"] <- num
  ll_dat[nrow(ll_dat),"LogLik"] <- probs
  ll_dat <- rbind(ll_dat, c(NA,NA))
}



