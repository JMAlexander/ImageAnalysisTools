gpggplot_setup <- function(black){
  if (black){
    gp <- ggplot() + theme(panel.background = element_blank(),
            plot.margin = unit(c(1,5,1,1), "cm"),
            plot.background = element_rect(fill="black"),
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
      gp <- ggplot() + theme_classic()
    }

  return(gp);
}