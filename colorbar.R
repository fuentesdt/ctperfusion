library(ggplot2)
library(gridExtra)
minn=0;maxx=1.5
jet.colors <-colorRampPalette(c("#00007F", "blue", "#007FFF", "cyan", "#7FFF7F", "yellow", "#FF7F00", "red", "#7F0000"))
hot.colors <- c('#010000','#0C0000','#170000','#210000','#2C0000','#360000','#410000','#4C0000','#560000','#610000',
                '#6C0000','#760000','#810000','#8B0000','#960000','#A10000','#AB0000','#B60000','#C10000','#CB0000',
                '#D60000','#E00000','#EB0000','#F60000','#FF0100','#FF0C00','#FF1700','#FF2100','#FF2C00','#FF3600',
                '#FF4100','#FF4C00','#FF5600','#FF6100','#FF6C00','#FF7600','#FF8100','#FF8B00','#FF9600','#FFA100',
                '#FFAB00','#FFB600','#FFC100','#FFCB00','#FFD600','#FFE000','#FFEB00','#FFF600','#FFFF02','#FFFF12',
                '#FFFF22','#FFFF32','#FFFF42','#FFFF52','#FFFF62','#FFFF72','#FFFF81','#FFFF91','#FFFFA1','#FFFFB1',
                '#FFFFC1','#FFFFD1','#FFFFE1','#FFFFF1')

# make a random plot
p1 <- ggplot(data=diamonds)+
  geom_point(aes(x=x,y=y,col=y))

# add color bar https://ggplot2.tidyverse.org/reference/guide_colourbar.html
p2 <- p1 + scale_colour_gradientn(name="colorbar",colours = jet.colors(128), limits=c(minn, maxx)) + 
  guides(col= guide_colorbar(barwidth = 10,
                             barheight = 1,
                             ticks=TRUE,
                             ticks.colour = "black",
                             frame.colour = "black",
                             direction="horizontal") )

# get legend only
leg = get_legend(p2)
grid.arrange(leg) 
ggsave(plot = leg,filename = '~/colorbar.png')
