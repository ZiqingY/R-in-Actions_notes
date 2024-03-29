#----------------------------------------------------#
# R in Action (3rd ed): Chapter 19                   #
# Advanced graphics: customizing using ggplot2       #
# requires packages ggplot2, ISLR, scales, showtext, #    
# ggrepl, dplyr, gapminder, patchwork, and plotly.   #
# install.packages(c("ggplot2", "ISLR", "scales",    #      
#    "showtext", "ggrepl", "dplyr", "gapminder",     #  
#    "patchwork", "plotly"))                         #
#----------------------------------------------------#


install.packages(c("ggplot2", "ISLR", "scales",
                   "showtext", "ggrepl", "dplyr", "gapminder", 
                   "patchwork", "plotly"))

# 1. modifying scales
library(ggplot2)
ggplot(data = mtcars, aes(x = wt, y = mpg)) +
  geom_point() +
  labs(title = "Fuel efficiency by car weight") 

# Plot of fuel efficiency by car weight with customized axes
library(ggplot2)
ggplot(mtcars, aes(x = wt, y = mpg)) + 
  geom_point() +
  scale_x_continuous(name = "Weight (1000 lbs.)",   
                     n.breaks = 10,                 
                     minor_breaks = NULL,           
                     limits = c(1.5, 5.5)) +        
  scale_y_continuous(name = "Miles per gallon",     
                     breaks = seq(10, 35, 5),       
                     minor_breaks = seq(10, 35, 1), 
                     limits = c(10, 35)) +          
  labs(title = "Fuel efficiency by car weight")

# Bar chart for categorical variables' compositions
library(ISLR)
library(ggplot2)
ggplot(Wage, aes(race, fill = education)) +
  geom_bar(position = "fill") +
  labs(title = "Participant Education by Race")

# Bar chart for categorical variables' compositions with customized axes
library(ISLR)
library(ggplot2)
library(scales)
ggplot(Wage, aes(race, fill=education)) +
  geom_bar(position="fill") +
  scale_x_discrete(name = "",                                              
                   limits = c("3. Asian", "1. White", "2. Black"),    
                   labels = c("Asian", "White", "Black")) +
  scale_color_discrete(labels = c("<HS Grad", "HS Grad", "Some College",
                                  "College Grad", "Advanced Degree")) +
  scale_y_continuous(name = "Percent",                                     
                     label = percent_format(accuracy=2),            
                     n.breaks=10) +                                 
  labs(title="Participant Education by Race")


# 2. use colors to indicate variable changes
# Color gradients for continuous variables
library(ggplot2)
p <- ggplot(mtcars, aes(x=wt, y=mpg, color=disp)) +
  geom_point(shape=19, size=3) +
  scale_x_continuous(name = "Weight (1000 lbs.)",
                     n.breaks = 10,
                     minor_breaks = NULL,
                     limits=c(1.5, 5.5)) +
  scale_y_continuous(name = "Miles per gallon",
                     breaks = seq(10, 35, 5),
                     minor_breaks = seq(10, 35, 1),
                     limits = c(10, 35))
p

p + ggtitle("A. Default color gradient")

p + scale_color_gradient(low="grey", high="black") +
  ggtitle("B. Greyscale gradient")

p + scale_color_gradient(low="red", high="blue") +
  ggtitle("C. Red-blue color gradient")

p + scale_color_steps(low="red", high="blue") +
  ggtitle("D. Red-blue binned color Gradient")

p + scale_color_steps2(low="red", mid="white", high="blue",
                       midpoint=median(mtcars$disp)) +
  ggtitle("E. Red-white-blue binned gradient")

p + scale_color_viridis_c(direction = -1) +
  ggtitle("F. Viridis color gradient")


# Color schemes for categorical variables
library(ISLR)
library(ggplot2)
p1 <- ggplot(Wage, aes(race, fill=education)) +
  geom_bar(position="fill") +
  scale_y_continuous("Percent", label=scales::percent_format(accuracy=2),
                     n.breaks=10) +
  scale_x_discrete("",
                   limits=c("3. Asian", "1. White", "2. Black"),
                   labels=c("Asian", "White", "Black"))
p1

p1 + ggtitle("A. Default colors")

p1 + scale_fill_brewer(palette="Set2") +
  ggtitle("B. ColorBrewer Set2 palette")

p1 + scale_fill_viridis_d() +
  ggtitle("C. Viridis color scheme")

p1 + scale_fill_manual(values=c("gold4", "orange2", "deepskyblue3", 
                               "brown2", "yellowgreen")) +
  ggtitle("D. Manual color selection")


# 3. Customizing the plot area
# Demonstration of 4 preconfigured ggplot2 themes
library(ggplot2)
p2 <- ggplot(data = mtcars, aes(x = wt, y = mpg)) +
  geom_point() +
  labs(x = "Weight (1000 lbs)",
       y = "Miles per gallon")
p2
p2 + theme_grey() + labs(title = "theme_grey")  
p2 + theme_bw() + labs(title = "theme_bw")  
p2 + theme_minimal() + labs(title = "theme_minimal")  
p2 + theme_classic() + labs(title = "theme_classic")


#▲ Locating local font files
findfont <- function(x){
  suppressMessages(require(showtext))
  suppressMessages(require(dplyr))
  filter(font_files(), grepl(x, family, ignore.case=TRUE)) %>%
    select(path, file, family, face)
}

findfont("comic")

# Customizing fonts in a ggplot2 graph
# note; this code may not work on your system it depends on the fonts you have installed
library(ggplot2)
library(showtext)

font_add("comic", regular = "comic.ttf",                 
         bold = "comicbd.ttf", italic="comici.ttf")
font_add("caveat", regular = "caveat-regular.ttf",
         bold = "caveat-bold.ttf")

font_add_google("Schoolbell", "bell")                    
font_add_google("Gochi Hand", "gochi")

showtext_auto()                                          
ggplot(data = mtcars, aes(x = wt, y = mpg)) +
  geom_point() +
  labs(title = "Fuel Efficiency by Car Weight",
       subtitle = "Motor Trend Magazine 1973",
       caption = "source: mtcars dataset",
       x = "Weight (1000 lbs)",
       y = "Miles per gallon") +
  theme(plot.title    = element_text(family = "bell", size=14),   #4
        plot.subtitle = element_text(family = "gochi"),
        plot.caption  = element_text(family = "caveat", size=15),
        axis.title    = element_text(family = "comic"),
        axis.text     = element_text(family = "comic", 
                                     face="italic", size=8))

# Customizing a plot legend
library(ggplot2)
ggplot(mtcars, aes(wt, mpg, color = factor(cyl))) +
  geom_point(size=3) +
  scale_color_discrete(name="Cylinders") +
  labs(title = "Fuel Efficiency for 32 Automobiles",
       x = "Weight (1000 lbs)",
       y = "Miles per gallon") +
  theme(legend.position = c(.95, .95),
        legend.justification = c(1, 1),
        legend.background = element_rect(fill = "lightgrey",
                                         color = "white",
                                         size = 1),
        legend.key = element_blank(),
        legend.direction = "horizontal")

# Customizing the plot area
library(ggplot2)
mtcars$am <- factor(mtcars$am, labels = c("Automatic", "Manual")) 
ggplot(data=mtcars, aes(x = disp, y = mpg)) +                     
  geom_point(aes(color=factor(cyl)), size=2) +                   
  geom_smooth(method="lm", formula = y ~ x + I(x^2),                             
              linetype="dotted", se=FALSE) +
  scale_color_discrete("Number of cylinders") +
  facet_wrap(~am, ncol=2) +                                      
  labs(title = "Mileage, transmission type, and number of cylinders",
       x = "Engine displacement (cu. in.)",
       y = "Miles per gallon") +
  theme_bw() +                                                  
  theme(strip.background = element_rect(fill = "white"),
        panel.grid.major = element_line(color="lightgrey"),
        panel.grid.minor = element_line(color="lightgrey",
                                        linetype="dashed"),
        axis.ticks = element_blank(),
        legend.position = "bottom",
        legend.key = element_blank())


# 4. scatter plots
# Scatter plot with labeled points
library(ggplot2)
ggplot(data = mtcars, aes(x = wt, y = mpg)) +
  geom_point(color = "steelblue") +
  geom_text(label = row.names(mtcars)) +
  labs(title = "Fuel efficiency by car weight",
       x = "Weight (1000 lbs)",
       y = "Miles per gallon")

# Scatter plot with labeled points using ggrepel
library(ggplot2)
library(ggrepel)
ggplot(data = mtcars, aes(x= wt, y = mpg)) +
  geom_point(color = "steelblue") +
  geom_hline(yintercept = median(mtcars$mpg),                     
             linetype = "dashed",
             color = "steelblue") +
  geom_label(x = 5.2, y = 20.5,                                      
             label = "median MPG", 
             color = "white", 
             fill = "steelblue",
             size = 3) +
  geom_text_repel(label = row.names(mtcars), size = 3) +  
  labs(title = "Fuel efficiency by car weight",
       x = "Weight (1000 lbs)",
       y = "Miles per gallon")


# 5. bar chart
# Adding percent labels to a bar chart
library(ggplot2)
library(dplyr)
library(ISLR)

plotdata <- Wage %>%                                  
  group_by(race) %>%
  summarize(n = n()) %>%
  mutate(pct = n / sum(n),
         lbls = scales::percent(pct),
         race = factor(race, labels = c("White", "Black", 
                                        "Asian", "Other")))
plotdata

ggplot(data=plotdata, aes(x=race, y=pct)) +
  geom_bar(stat = "identity", fill="steelblue") +     
  geom_text(aes(label = lbls),                    
            vjust = -0.5, 
            size = 3) +
  labs(title = "Participants by Race",
       x = "", 
       y="Percent") +
  theme_minimal()

# Adding percent labels to a stacked (filled) bar chart
library(ggplot2)
library(dplyr)
library(ISLR)

plotdata1 <- Wage %>%                                
  group_by(race, education) %>%
  summarize(n = n()) %>% 
  mutate(pct = n/sum(n),
         lbl = scales::percent(pct))

ggplot(plotdata1, aes(x=race, y=pct, fill=education)) +
  geom_bar(stat = "identity", 
           position="fill", 
           color="lightgrey") +
  scale_y_continuous("Percent",                                 
                     label=scales::percent_format(accuracy=2),
                     n.breaks=10) +
  scale_x_discrete("",                                            
                   limits=c("3. Asian", "1. White", "2. Black"),
                   labels=c("Asian", "White", "Black")) +
  geom_text(aes(label = lbl),                                   
            size=3, 
            position = position_stack(vjust = 0.5)) +
  labs(title="Participant Education by Race",
       fill = "Education") +
  theme_minimal() +                                                
  theme(panel.grid.major.x=element_blank())


# 6. Bar chart
# Highlighting one trend among many
library(ggplot2)
library(dplyr)
library(gapminder)
plotdata2 <- gapminder %>%
  filter(continent == "Asia")         

plotdata2$highlight <- ifelse(plotdata2$country %in%     
                               c("Cambodia"), "y", "n") 

ggplot(plotdata2, aes(x = year, y = lifeExp, 
                     group = country,            
                     size = highlight, 
                     color = highlight)) +
  scale_color_manual(values=c("lightgrey", "red")) +
  scale_size_manual(values=c(.5, 1)) +
  geom_line() + 
  geom_label(x=2000, y= 52, label="Cambodia",  
             color="red", size=3) +
  labs(title="Life expectancy for Asian countries",
       x="Year",
       y="Life expectancy") +
  theme_minimal() +                                        
  theme(legend.position="none",
        text=element_text(size=10))


# 6. Combining graphs using the patchwork package
library(ggplot2)
library(patchwork)

p4 <- ggplot(mtcars, aes(disp, mpg)) +                
  geom_point() + 
  labs(x="Engine displacement",
       y="Miles per gallon")

p5 <- ggplot(mtcars, aes(factor(cyl), mpg)) +
  geom_boxplot() + 
  labs(x="Number of cylinders",
       y="Miles per gallon")

p6 <- ggplot(mtcars, aes(mpg)) +
  geom_histogram(bins=8, fill="darkgrey", color="white") +
  labs(x = "Miles per gallon",
       y = "Frequency")

(p4 | p5) / p6 +                                      
  plot_annotation(title = 'Fuel Efficiency Data') &
  theme_minimal() +
  theme(axis.title = element_text(size=8),
        axis.text = element_text(size=8))


# 7. Converting a ggplot2 graph to an interactive plotly graph: displayed in Viewer
library(ggplot2)
library(plotly)
mtcars$cyl <- factor(mtcars$cyl)
mtcars$name <- row.names(mtcars)

p7 <- ggplot(mtcars, aes(x = disp, y= mpg, color = cyl)) +
  geom_point()
ggplotly(p7)

# Customizing the plotly tooltip
p8 <- ggplot(mtcars,
            aes(x = disp, y=mpg, color=cyl,
                text = paste(name, "\n",
                             "mpg:", mpg, "\n",
                             "disp:", disp, "\n",
                             "cyl:", cyl, "\n",
                             "gear:", gear))) +
  geom_point()
ggplotly(p8, tooltip=c("text"))


