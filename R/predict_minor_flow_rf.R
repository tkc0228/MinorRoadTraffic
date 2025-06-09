#' Predict minor road traffic using random forest
#'
#' This function trains a random forest regression model using observed minor
#' road traffic counts and associated predictor variables. Predictions are
#' returned for all roads.
#'
#' @param network \code{sf} object containing the road network. The following
#'   columns should be present: \code{traffic_flow_minor}, \code{major_flow},
#'   \code{nearest_junc_dist}, \code{std_centrality}, \code{road_density},
#'   \code{pop_2018}, \code{cars_percap_2018}, \code{poi_count}, and
#'   \code{household_count}.
#' @param seed integer used to initialise the random number generator.
#' @return The input \code{network} with an additional column
#'   \code{rf_prediction}. The fitted \code{ranger} model is attached as an
#'   attribute named \code{\"rf_model\"}.
#' @examples
#' \dontrun{
#'   net <- predict_minor_flow_rf(net)
#' }
#' @export
predict_minor_flow_rf <- function(network, seed = 42) {
  if (!requireNamespace("ranger", quietly = TRUE)) {
    stop("Package 'ranger' is required for random forest predictions")
  }
  if (!requireNamespace("dplyr", quietly = TRUE)) {
    stop("Package 'dplyr' is required for random forest predictions")
  }

  dat <- dplyr::select(sf::st_drop_geometry(network),
                       traffic_flow_minor, major_flow, nearest_junc_dist,
                       std_centrality, road_density, pop_2018,
                       cars_percap_2018, poi_count, household_count)

  train <- dat[!is.na(dat$traffic_flow_minor), ]

  set.seed(seed)
  rf_mod <- ranger::ranger(
    traffic_flow_minor ~ .,
    data = train,
    num.trees = 500,
    mtry = floor(sqrt(ncol(train) - 1)),
    importance = "permutation"
  )

  network$rf_prediction <- predict(rf_mod, data = dat)$predictions
  attr(network, "rf_model") <- rf_mod
  network
}
