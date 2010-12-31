#' Add a line with slope and intercept.
#'
#' @keywords internal
#' @name stat_abline
#' @export
#' @examples
#' # see geom_abline
StatAbline <- proto(Stat, {
  calculate <- function(., data, scales, intercept = NULL, slope = NULL, ...) {
    data <- aesdefaults(data, .$default_aes(), list(...))
    if (is.null(intercept)) {
      if (is.null(data$intercept)) data$intercept <- 0
    } else {
      data <- data[rep(1, length(intercept)), , drop = FALSE]
      data$intercept <- intercept
    }
    if (is.null(slope)) {
      if (is.null(data$slope)) data$slope <- 1
    } else {
      data <- data[rep(1, length(slope)), , drop = FALSE]
      data$slope <- slope
    }
    unique(data)
  }
  
  icon <- function(.) GeomAbline$icon()
  default_geom <- function(.) GeomAbline
})

#' Add a vertical line
#'
#' @keywords internal
#' @name stat_vline
#' @export
#' @examples
#' # see geom_vline
StatVline <- proto(Stat, {
  calculate <- function(., data, scales, xintercept = NULL, intercept, ...) {
    if (!missing(intercept)) {
      stop("stat_vline now uses xintercept instead of intercept")
    }
    data <- compute_intercept(data, xintercept, "x")
    
    unique(within(data, {
      x    <- xintercept
      xend <- xintercept
    }))
  }
  
  icon <- function(.) GeomVline$icon()
  
  required_aes <- c()
  default_geom <- function(.) GeomVline
})

#' Add a horizontal line
#'
#' @keywords internal
#' @name stat_hline
#' @export
#' @examples
#' # see geom_hline
StatHline <- proto(Stat, {
  calculate <- function(., data, scales, yintercept = NULL, intercept, ...) {
    if (!missing(intercept)) {
      stop("stat_hline now uses yintercept instead of intercept")
    }

    data <- compute_intercept(data, yintercept, "y")
    
    unique(within(data, {
      y    <- yintercept
      yend <- yintercept
    }))
  }
  
  objname <- "hline" 
  desc <- "Add a horizontal line"
  icon <- function(.) GeomHline$icon()
  
  required_aes <- c()
  default_geom <- function(.) GeomHline
  
  examples <- function(.) {
    # See geom_hline for examples
  }
})


# Compute intercept for vline and hline from data and parameters
# 
# @keyword internal
compute_intercept <- function(data, intercept, var = "x") {
  ivar <- paste(var, "intercept", sep = "")
  if (is.null(intercept)) {
    # Intercept comes from data, default to 0 if not set
    if (is.null(data[[ivar]])) data[[ivar]] <- 0
    
  } else if (is.numeric(intercept)) {
    # Intercept is a numeric vector of positions
    data <- data[rep(1, length(intercept)), ]
    data[[ivar]] <- intercept
    
  } else if (is.character(intercept) || is.function(intercept)) {
    # Intercept is a function
    f <- match.fun(intercept)
    trans <- function(data) {
      data[[ivar]] <- f(data[[var]])
      data
    }
    data <- ddply(data, .(group), trans)
  } else {
    stop("Invalid intercept type: should be a numeric vector, a function", 
         ", or a name of a function", call. = FALSE)
  }
  data
}