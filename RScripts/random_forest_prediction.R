# Example usage of the predict_minor_flow_rf function
#
# Assumes that the network object already contains observed minor road counts
# in the `traffic_flow_minor` column as well as the required predictor
# variables. The resulting network will include a column `rf_prediction` with
# the model predictions.

library(sf)
library(MinorRoadTraffic)

# load your prepared network here
# network <- st_read("path/to/your/network.gpkg")

network <- predict_minor_flow_rf(network)

# inspect the importance of predictors
print(attr(network, "rf_model")$variable.importance)

# write results if desired
# st_write(network, "network_rf_predictions.gpkg")
