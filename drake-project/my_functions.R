prepare <- function(raw_data) {
  normalizeFeatures(raw_data, "m2.price")
}

make_plot1 <- function(data) {
  ggplot(data = data, aes(x = construction.year, y = m2.price)) +
    geom_point()
}

make_plot2 <- function(data, model) {
  ggplot(data = data, aes(x = surface, y = m2.price)) +
    geom_point()
}