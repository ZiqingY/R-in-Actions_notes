#--------------------------------------------------------------------#
# R in Action (3rd ed): Chapter 20                                   #
# Advanced R programming                                             #
# requires packages ggplot2, tidyr, foreach, doParallel              #
#--------------------------------------------------------------------#

install.packages(c("ggplot2", "tidyr", "foreach", "doParallel"))

# 1. Data Types
# Atomic vectors
passed <- c(TRUE, TRUE, FALSE, TRUE)
ages <- c(15, 18, 25, 14, 19)
cmplxNums <- c(1+2i, 0+1i, 39+3i, 12+2i)
names <- c("Bob", "Ted", "Carol", "Alice")

# Matrices
x <- c(1,2,3,4,5,6,7,8)
class(x)
print(x)

attr(x, "dim") <- c(2,4)
print(x)
class(x)
attributes(x)

attr(x, "dimnames") <- list(c("A1", "A2"),                                       
                            c("B1", "B2", "B3", "B4"))
print(x)
attr(x, "dim") <- NULL 
class(x)
print(x)

# Generic vectors (lists)
head(iris)
unclass(iris)     # list out data for each column and row number
attributes(iris)

set.seed(1234)
fit <- kmeans(iris[1:4], 3)
names(fit)
unclass(fit)
sapply(fit, class)

# Indexing atomic vectors
x <- c(20, 30, 40)
x[3]
x[c(2,3)]

x <- c(A=20, B=30, C=40)
x
x[c(2,3)]
x[c("B", "C")]

# Indexing lists
fit    # cluster results as a list from above
fit[c(2,7)]
fit[2]
fit[[2]]  # output a matrix
fit$centers
fit[[2]][1,]
fit$centers$Petal.Width  # should give an error

# Practice: Plotting the centroides from a k-mean 
# cluster analysis
set.seed(1234)
fit <- kmeans(iris[1:4], 3)                              
means <- as.data.frame(fit$centers)
means$cluster <- row.names(means)

library(tidyr)                                         
plotdata <- gather(means, 
                   key="key", 
                   value="value", 
                   Sepal.Length:Petal.Width)
names(plotdata) <- c("Cluster", "Measurement", "Centimeters")
head(plotdata)
library(ggplot2)                                          
ggplot(data=plotdata, 
       aes(x=Measurement, y=Centimeters, group=Cluster)) + 
  geom_point(size=3, aes(shape=Cluster, color=Cluster)) +
  geom_line(size=1, aes(color=Cluster)) +
  ggtitle("Mean Profiles for Iris Clusters") +
  theme_minimal()


# 2. logic syntax
# for loops
for(i in 1:5) print(1:i)
for(i in 5:1)print(1:i)

vars <- c("mpg", "disp", "hp", "wt")
for(i in vars) hist(mtcars[[i]])


# if else
pvalues <- c(.0867, .0018, .0054, .1572, .0183, .5386)
results <- ifelse(pvalues <.05, "Significant", "Not Significant")
results

pvalues <- c(.0867, .0018, .0054, .1572, .0183, .5386)
results <- vector(mode="character", length=length(pvalues))
for(i in 1:length(pvalues)){
  if (pvalues[i] < .05) results[i] <- "Significant" 
  else results[i] <- "Not Significant"
}
results


# 3. functions
# Creating functions
f <- function(x, y, z=1){
  result <- x + (2*y) + (3*z)
  return(result)
}

f(2,3,4) # z as 4
f(2,3) # z default as 1
f(x=2, y=3)
f(z=4, y=2, 3) # 3 means x=3
args(f)

# object scope
x <- 2
y <- 3
z <- 4
f <- function(w){
  z <- 2
  x <- w*y*z
  return(x)
}
f(x)
x
y
z

# Working with environments
x <- 5
myenv <- new.env()
assign("x", "Homer", env=myenv)
ls()
ls(myenv)
x
get("x", env=myenv)

myenv <- new.env()
myenv$x <- "Homer"
myenv$x

parent.env(myenv)

# function closures: a function that is created by another function
trim <- function(p){
  trimit <- function(x){
    n <- length(x)
    lo <- floor(n*p) + 1
    hi <- n + 1 - lo
    x <- sort.int(x, partial = unique(c(lo, hi)))[lo:hi]
  }
  trimit
}
x <- 1:10
trim10pct <- trim(.1)
y <- trim10pct(x)
y
trim20pct <- trim(.2)
y <- trim20pct(x)
y

ls(environment(trim10pct))
get("p", env=environment(trim10pct))

makeFunction <- function(k){
  f <- function(x){
    print(x + k)
  }
}

g <- makeFunction(10)
g (4)
k <- 2
g (5)

ls(environment(g))
environment(g)$k

# non-standard evaluation: R has a default method for when and how to evaluate expressions
mystats <- function(data, x){
  x <- data[[x]]
  c(n=length(x), mean=mean(x), sd=sd(x))
}

mystats(mtcars, mpg) # produces an error
mystats(mtcars, "mpg") # does not produce an error

mystats <- function(data, x){
  x <- as.character(substitute(x))
  x <- data[[x]]
  c(n=length(x), mean=mean(x), sd=sd(x))
}

mystats(mtcars, mpg)   # does not produces an error
mystats(mtcars, "mpg") # does not produce an error

# Generic functions
summary(women)
fit <- lm(weight ~ height, data=women)
summary(fit)

class(women)
class(fit)
methods(summary)

# An example of a generic function
mymethod <- function(x, ...) UseMethod("mymethod")    
mymethod.a <- function(x) print("Using A")
mymethod.b <- function(x) print("Using B")
mymethod.default <- function(x) print("Using Default")

x <- 1:5
y <- 6:10
z <- 10:15
class(x) <- "a"             
class(y) <- "b"

mymethod(x)                 
mymethod(y)
mymethod(z)

class(z) <- c("a", "b")     
mymethod(z)
class(z) <- c("c", "a", "b")
mymethod(z)


# 4.coding techniques
# Vectorization and efficient code
set.seed(1234)
mymatrix <- matrix(rnorm(10000000), ncol=10)
accum <- function(x){
  sums <- numeric(ncol(x))
  for (i in 1:ncol(x)){
    for(j in 1:nrow(x)){
      sums[i] <- sums[i] + x[j,i]
    }
  }
}
system.time(accum(mymatrix))   # using loops
system.time(colSums(mymatrix)) # using vectorization

# Correctly size objects
set.seed(1234)
k <- 100000
x <- rnorm(k)

y <- 0
system.time(for (i in 1:length(x)) y[i] <- x[i]^2)

y <- numeric(k)
system.time(for (i in 1:k) y[i] <- x[i]^2)

y <- numeric(k)
system.time(y <- x^2)

# Parallelization with foreach and doParallel
library(foreach)                                  
library(doParallel)
registerDoParallel(cores=detectCores())

eig <- function(n, p){                            
  x <- matrix(rnorm(100000), ncol=100)
  r <- cor(x)
  eigen(r)$values
} 
n <- 1000000                                      
p <- 100
k <- 500

system.time(
  x <- foreach(i=1:k, .combine=rbind) %do% eig(n, p)    
)

system.time(
  x <- foreach(i=1:k, .combine=rbind) %dopar% eig(n, p)
)


# 5. debugging
# Finding common errors
mtcars$Transmission <- factor(mtcars$a, 
                              levels=c(1,2), 
                              labels=c("Automatic", "Manual"))
aov(mpg ~ Transmission, data=mtcars) # generates error
head(mtcars[c("mpg", "Transmission")])
table(mtcars$Transmission) # here is the source of the error

#  A sample debugging session
args(mad)
debug(mad)
mad(1:10)
# enters debugging mode
# Q to quit - see text
undebug(mad)

# Sample debugging session with recover()
f <- function(x, y){
  z <- x + y
  g(z)
}
g <- function(x){
  z <- round(x)
  h(z)
}

h <- function(x){
  set.seed(1234)
  z <- rnorm(x)
  print(z)
}
options(error=recover)

f(2,3)
f(2, -3) # enters debugging mode at this point
