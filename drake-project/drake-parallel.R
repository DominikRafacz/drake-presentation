library(drake)
library(mlr)
library(parallelMap)

source("drake-project/functions-parallel.R")

# data source: https://www.openml.org/d/1471

plan <- drake_plan(
  data_raw = read.csv(file_in("drake-project/phplE7q6h.csv")),
  data_processed = normalizeFeatures(data_raw, target = "Class"),
  task = target(
    makeClassifTask("task", data, "Class"),
    transform = map(data = c(data_raw, data_processed))
  ),
  learner = target(
    makeLearner(model),
    transform = map(model = c("classif.ranger", 
                              "classif.logreg", 
                              "classif.ada",
                              "classif.nnet",
                              "classif.binomial"))
  ),
  resample = target(
    resample(learner, task, cv10),
    transform = cross(learner, task)
  ),
  summarise_dataset = target(
    summary(resample),
    transform = combine(resample, .by = task)
  )
  
)

plan_mlr_parallel <- drake_plan(
  data_raw = read.csv(file_in("drake-project/phplE7q6h.csv")),
  data_processed = normalizeFeatures(data_raw, target = "Class"),
  task = target(
    makeClassifTask("task", data, "Class"),
    transform = map(data = c(data_raw, data_processed))
  ),
  learner = target(
    makeLearner(model),
    transform = map(model = c("classif.ranger", 
                              "classif.logreg", 
                              "classif.ada",
                              "classif.nnet",
                              "classif.binomial"))
  ),
  resample = target(
    resample_parallel(learner, task, cv10),
    transform = cross(learner, task)
  ),
  summarise_dataset = target(
    summary(resample),
    transform = combine(resample, .by = task)
  )
  
)

make(plan)

config <- drake_config(plan)
vis_drake_graph(config,  
                build_times = "none", 
                targets_only = TRUE, 
                navigationButtons = FALSE)

clean()
future::plan(future::multicore)
rbenchmark::benchmark(
  drake_parallelization = {
    make(plan, jobs = 4, parallelism = "future")
    clean()},
  no_parallelization = {
    make(plan)
    clean()},
  mlr_parallelization = {
    parallelStartSocket(4, level = NA)
    make(plan)
    clean()
    parallelStop()},
  parallelization_both = {
    make(plan_mlr_parallel, jobs = 4, parallelism = "future")
    clean()
  },
  replications = 1,
  order = NULL
) -> bench


levels(bench$test) <- c("parallelization drake","no parallelization", "parallelization mlr", "parallelization both")
write.csv2(bench[, c("test", "elapsed")], "benchmark.csv")