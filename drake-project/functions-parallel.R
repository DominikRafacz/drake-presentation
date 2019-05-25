resample_parallel <- function(learner, task, cv10) {
  parallelStartSocket(4, level = NA)
  resample(learner, task, cv10)
  parallelStop()
}
