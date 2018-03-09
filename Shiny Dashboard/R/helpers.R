## Dominic Mullen
## 7/11/2016 
## Helpers table 

##====================================================================================================
## Scientific Notation (applied in ggplot: scale_y_continuous(labels = si_notation))
##====================================================================================================
# Comment scale will work incorrectly if values > 10 million
si_num <- function(x){
  
  if (!is.na(x)) {
    if (x >= 1e6) { 
      chrs <- strsplit(format(x, scientific=12), split="")[[1]]
      # format turns x into a character 
      # strsplit turns x into individual characters
      if(chrs[2] != '0'){
        rem <- append(chrs[1], values = c(".", chrs[2], "M"))
      }
      else{
      rem <- chrs[seq(1,length(chrs)-6)]
      # selects first character element
      rem <- append(rem, "M")
      # append M
      }
    }
    
    else if (x >= 1e5) { 
      chrs <- strsplit(format(x, scientific=12), split="")[[1]]
      if(chrs[2] != '0') {   # if the number does not have five 0's  (ex. 150,000)
        rem <- append(chrs[1:3], "K")
      }
      else {   # five 0's case 
        chrs <- strsplit(format(x, scientific=12), split="")[[1]]
        rem <- chrs[seq(1,length(chrs)-3)]
        rem <- append(rem, "K")
      }
    }
    
    else if (x >= 1e4) { 
      chrs <- strsplit(format(x, scientific=12), split="")[[1]]
      if(chrs[2] != '0') {   # if the number does not have four 0's  (ex. 15,000)
        rem <- append(chrs[1:2], "K")
      }
      else {   # four 0's case 
        chrs <- strsplit(format(x, scientific=12), split="")[[1]]
        rem <- chrs[seq(1,length(chrs)-3)]
        rem <- append(rem, "K")
      }
    }
    
    else if (x >= 1e3) { 
      chrs <- strsplit(format(x, scientific=12), split="")[[1]]
      if(chrs[2] != '0') {   # if the number does not have three 0's  (ex. 1500)
      rem <- append(chrs[1], values = c(".", chrs[2], "K")) 
      }
      else {   # three 0's case 
        chrs <- strsplit(format(x, scientific=12), split="")[[1]]
        rem <- chrs[seq(1,length(chrs)-3)]
        rem <- append(rem, "K")
      }
    }
    else {
      return(x)
    }
    
    return(paste(rem, sep="", collapse=""))
  }
  else return(NA)
} 

# applys the functions over a list
si_notation <- function(x) {
  sapply(x, FUN = si_num)
}


##====================================================================================================
## Dollar Notation (applied in ggplot: scale_y_continuous(labels = dollar_notation))
##====================================================================================================
dollar_num <- function(x){
  
  if (!is.na(x)) {
    if (x > 0) {
      rem <- append('$', as.character(x))
    }
    else {
      return(x)
    }
    
    return(paste(rem, sep="", collapse=""))
  }
  else return(NA)
} 


# applys the functions over a list
dollar_notation <- function(x) {
  sapply(x, FUN = dollar_num)
}


##====================================================================================================
## Dollar + Scientific Notation (applied in ggplot: scale_y_continuous(labels = dollar_si_notation))
##====================================================================================================
# Comment scale will work incorrect if values > 10 million
dollar_si_num <- function(x){
  
  if (!is.na(x)) {
    if (x >= 1e6) { 
      chrs <- strsplit(format(x, scientific=12), split="")[[1]]
      # format turns x into a character 
      # strsplit turns x into individual characters
      if(chrs[2] != '0'){
        rem <- append('$', values = c(chrs[1],".", chrs[2], "M"))
      }
      else{
        rem <- chrs[seq(1,length(chrs)-6)]
        # selects first character element
        rem <- append('$', values = c(rem, "M"))
        # append M
      }
    }
    
    else if (x >= 1e5) { 
      chrs <- strsplit(format(x, scientific=12), split="")[[1]]
      if(chrs[2] != '0') {   # if the number does not have five 0's  (ex. 150,000)
        rem <- append('$', values = c(chrs[1:3], "K"))
      }
      else {   # five 0's case 
        chrs <- strsplit(format(x, scientific=12), split="")[[1]]
        rem <- chrs[seq(1,length(chrs)-3)]
        rem <- append('$', values <- c(rem, "K"))
      }
    }
    
    else if (x >= 1e4) { 
      chrs <- strsplit(format(x, scientific=12), split="")[[1]]
      if(chrs[2] != '0') {   # if the number does not have four 0's  (ex. 15,000)
        rem <- append('$', values = c(chrs[1:2], "K"))
      }
      else {   # four 0's case 
        chrs <- strsplit(format(x, scientific=12), split="")[[1]]
        rem <- chrs[seq(1,length(chrs)-3)]
        rem <- append('$', values = c(rem, "K"))
      }
    }
    
    else if (x >= 1e3) { 
      chrs <- strsplit(format(x, scientific=12), split="")[[1]]
      if(chrs[2] != '0') {   # if the number does not have three 0's  (ex. 1500)
        rem <- append('$', values = c(chrs[1],".", chrs[2], "K")) 
      }
      else {   # three 0's case 
        chrs <- strsplit(format(x, scientific=12), split="")[[1]]
        rem <- chrs[seq(1,length(chrs)-3)]
        rem <- append('$', values = c(rem, "K"))
      }
    }
    else {
      return(x)
    }
    
    return(paste(rem, sep="", collapse=""))
  }
  else return(NA)
} 

# applys the functions over a list
dollar_si_notation <- function(x) {
  sapply(x, FUN = dollar_si_num)
}

##====================================================================================================
## Percent Notation (applied in ggplot: scale_y_continuous(labels = percent_notation_small))
## Function is for small scale: [0:1] 
##====================================================================================================
percent_num_small <- function(x){
  
  if (!is.na(x)) {
      if (x == 1){
        rem <- append(as.character(x), "00%")
      }
      else if (x < 1 && x >= .1){
        chrs <- strsplit(format(x, scientific=12), split="")[[1]]
        if(length(chrs) == 4) {
          rem <- chrs[3:4]
          rem <- append(rem, "%")
        }
        else if (length(chrs) == 3){
          rem <- chrs[3]
          rem <- append(rem, "0%")
        }
      }
      else if (x <.1 && x > 0){
        chrs <- strsplit(format(x, scientific=12), split="")[[1]]
        rem <- chrs[4]
        rem <- append(rem, "%")
      }
      else {
        return(x)
      }
    return(paste(rem, sep="", collapse=""))
  }
  else return(NA)
} 

# applys the functions over a list
percent_notation_small <- function(x) {
  sapply(x, FUN = percent_num_small)
}


##====================================================================================================
## Percent Notation (applied in ggplot: scale_y_continuous(labels = percent_notation_large))
## Function is for large scale: [0:100] 
##====================================================================================================
percent_num_large <- function(x){

  if (!is.na(x)) {
    if(x == 100){
      rem <- append(as.character(x), "%")
    }
    else if (x >= 1 && x <= 99) { 
      rem <- append(as.character(x), "%")
    }
    else{
      return(x)
    }
    return(paste(rem, sep="", collapse=""))
  }
  else return(NA)
} 

# applys the functions over a list
percent_notation_large <- function(x) {
  sapply(x, FUN = percent_num_large)
}
