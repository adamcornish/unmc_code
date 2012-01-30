#!/usr/local/bin/Rscript
library(ggplot2)

#sample <- read.table ( pipe ( "cut -f7,8 combined_counts.txt" ) )
    d <- read.csv ( "gene_exp.diff", sep = "\t", header = T)

plot_png_filename <- "plot.png"
png ( filename = plot_png_filename, width = 1920, height = 1080, units = "px" )

    p <- qplot ( log ( value_1 ), log ( value_2 ), data = d, xlab = "Human Brain", ylab = "Human Skeletal Muscle", main = "Absolute counts between Human brain and skeletal muscle tissues", colour = value_1 )
    p + geom_abline()
print ( plot_png_filename )
