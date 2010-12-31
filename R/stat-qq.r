#' Calculation for quantile-quantile plot.
#'
#' @name stat_qq
#' 
#' @param quantiles Quantiles to compute and display
#' @param dist Distribution function to use, if x not specified
#' @param dparams Parameters for distribution function
#' @param ... Other arguments passed to distribution function
#' @return a data.frame with additional columns:
#'   \item{sample}{sample quantiles}
#'   \item{theoretical}{theoretical quantiles}
#' @export
#' @examples
#' # From ?qqplot
#' y <- rt(200, df = 5)
#' qplot(sample = y, stat="qq")
#' 
#' # qplot is smart enough to use stat_qq if you use sample
#' qplot(sample = y)
#' qplot(sample = precip)
#' 
#' qplot(sample = y, dist = qt, dparams = list(df = 5))
#' 
#' df <- data.frame(y)
#' ggplot(df, aes(sample = y)) + stat_qq()
#' ggplot(df, aes(sample = y)) + geom_point(stat = "qq")
#' 
#' # Use fitdistr from MASS to estimate distribution params
#' params <- as.list(MASS::fitdistr(y, "t")$estimate)
#' ggplot(df, aes(sample = y)) + stat_qq(dist = qt, dparam = params)
#' 
#' # Using to explore the distribution of a variable
#' qplot(sample = mpg, data = mtcars)
#' qplot(sample = mpg, data = mtcars, colour = factor(cyl))    
StatQq <- proto(Stat, {
  
  default_geom <- function(.) GeomPoint
  default_aes <- function(.) aes(y = ..sample.., x = ..theoretical..)
  required_aes <- c("sample")

  calculate <- function(., data, scales, quantiles = NULL, distribution = qnorm, dparams = list(), na.rm = FALSE) {
    data <- remove_missing(data, na.rm, "sample", name = "stat_qq")    

    sample <- sort(data$sample)
    n <- length(sample)
    
    # Compute theoretical quantiles
    if (is.null(quantiles)) {
      quantiles <- ppoints(n)
    } else {
      stopifnot(length(quantiles) == n)
    }

    theoretical <- safe.call(distribution, c(list(p = quantiles), dparams))
  
    data.frame(sample, theoretical)
  }
  
  
})
