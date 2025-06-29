#' Pairwise comparison matrix
#'
#' Make a matrix from a data frame containing species data.
#'
#' @param DF Data frame containing species information, produced with [`formatStats()`]
#' @param column The variable from the data frame to extract species data from.
#' @param defaultDiagonal Maximum possible value of variable.
#' @param defaultValue Minimum possible value of variable.
#' @param impute Logical. If TRUE, applies missForest to fill in missing values.
#'
#' @return A square `matrix` where rows and columns are sample identifiers and
#' values are statistics for the pairs of samples.  In addition it has an
#' attribute "builtWith" that records the value of `column`.
#'
#' @author Noa Brenner
#' @author Charles Plessy
#'
#' @export
#'
#' @examples
#' makeMatrix(Halo_DF, "percent_difference_global", 100, 50)
#'
#' # Missing values get NA by default unless specified in the 4th argument.
#' makeMatrix(Halo_DF |> tail(-1), "percent_difference_global", 100)

makeMatrix <- function(DF, column, defaultDiagonal = 100, defaultValue = NA, impute = FALSE) {
  all_species <- sort(unique(DF$species2))
  m <- matrix(defaultValue, nrow = length(all_species), ncol = length(all_species))
  colnames(m) <- rownames(m) <- all_species
  for (i in 1:nrow(m)) {
    m[i, i] <- defaultDiagonal
  }
  for (i in 1:nrow(DF)) {
    species1 <- DF[i, "species1"]
    species2 <- DF[i, "species2"]
    if (species1 %in% all_species) {
      m[species1, species2] <- DF[i, column]
    }
  }
  
  fillSymmetricNA <- function(mat) {
    na_pos <- which(is.na(mat) & !is.na(t(mat)), arr.ind = TRUE)
    mat[na_pos] <- t(mat)[na_pos]
    mat
  }
  
  m <- fillSymmetricNA(m)
  
  # Optional: Impute missing values using missForest
  if (impute) {
    if (!requireNamespace("missForest", quietly = TRUE)) {
      stop("Package 'missForest' is required for imputation. Please install it.")
    }
    suppressMessages({
      m <- as.matrix(missForest::missForest(as.data.frame(m))$ximp)
    })
  }
  
  attr(m, "builtWith") <- column
  return(m)
}

makeMatrix.old <- function(DF, column, defaultDiagonal = 100, defaultValue = NA, impute = FALSE, ...) {
  all_species <- unique(DF$species2)
  your_matrix <- matrix(defaultValue, nrow=length(all_species), ncol=length(all_species))
  colnames(your_matrix) <- rownames(your_matrix) <- all_species
  for (i in 1:length(all_species)) {
    your_matrix[i,i] <- defaultDiagonal
  }
  for (i in 1:nrow(DF)) {
    species1 <- DF[i, "species1"]
    species2 <- DF[i, "species2"]
    if(species1 %in% all_species)
      your_matrix[species1, species2] <- DF[i, column]
  }
  m <- your_matrix
  fillSymmetricNA <- function(mat) {
    na_pos <- which(is.na(mat) & !is.na(t(mat)), arr.ind = TRUE)
    mat[na_pos] <- t(mat)[na_pos]
    mat
  }
  m <- fillSymmetricNA(m)
  #   # Optional: Impute missing values using missForest
  if (impute) {
    if (!requireNamespace("missForest", quietly = TRUE)) {
      stop("Package 'missForest' is required for imputation. Please install it.")
    }
    suppressMessages({
      m <- as.matrix(missForest::missForest(as.data.frame(m), ...)$ximp)
    })
  }
  attr(m, "builtWith") <- column
  return(m)
}
