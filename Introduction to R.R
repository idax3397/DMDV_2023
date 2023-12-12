# Introduction ####

# This is a comment
2 # print a number
2+3 # perform a simple calculation
log(2) # natural log

x = 2 # store an object
x # print this object
(x = 3) # store and print an object
x = "Hello" # store a string object
x

# Data types ####
?str
str(43)
str(43L)
str(as.integer(4))
str(5.5)
str(TRUE)
str(log) #its a function
str("string") #called charector
str(2i) #complex numbers, you dont really use them
str(as.raw(255)) #raw, you dont really use them


# Vectors ####

# Store a vector
Height =
  c(168, 177, 177, 177, 178, 172, 165, 171, 178, 170)
Height[2] # Print the second component

# Print the second, the 3rd, the 4th and 5th component
Height[2:5]
(obs = 1:10) # Define a vector as a sequence (1 to 10)

Weight = c(88, 72, 85, 52, 71, 69, 61, 61, 51, 75)

# Performs a simple calculation using vectors
BMI = Weight/((Height/100)^2)
BMI

# We can also describe the vector with length(), mean() and var().
length(Height)
mean(Height) # Compute the sample mean
var(Height)


# Matrices ####

M = cbind(obs,Height,Weight,BMI) # Create a matrix
typeof(M) # Give the type of the matrix
class(M) # Give the class of an object
is.matrix(M) # Check if M is a matrix
dim(M) # Dimensions of a matrix



# Simple plotting ####
# For “quick and dirty” plots, use plot.
# For more advanced and attractive data visualizations, use ggplot.
plot(Height,Weight,ylab="Weight",xlab="Height")


# Dataframes ####
mydat <- as.data.frame(M)
names(mydat) # Give the names of each variable
summary(mydat) # Descriptive Statistics

min(mydat$Height)

# Read and Write data
write.csv(mydat, "my_data.csv", row.names = FALSE)
mydat2=read.csv("my_data.csv")

# Special characters in R ####

# NA: Not Available (i.e. missing values)
# NaN: Not a Number (e.g. 0/0)
# Inf: Infinity
# -Inf: Minus Infinity. For instance 0 divided by 0 gives a NaN, but 1 divided by 0 gives Inf.

0/0

1/0


# Working directory ####
# We can define a working directory. Note for Windows users : R uses slash (“/”) in the
# directory instead of backslash (“\”).

setwd("C:/Users/") # Sets working directory
#setwd("~/Desktop") # Sets working directory
getwd() # Returns current working directory
dir() # Lists the content of the working directory


# Defining functions ####

example_function = function(a, b=2) {
  r=a/b
  return(r)
}
example_function(3)
example_function(3,4)
example_function(b=4, a=3)