source("drake-project/libraries.R")
source("drake-project/my_functions.R")

# data source: pbiecek/DALEX appartments.csv

plan <- drake_plan(
  raw_data = read.csv(file_in("drake-project/appartments.csv")),
  prepared_data = prepare(raw_data),
  plot1 = make_plot1(prepared_data),
  regression = lm(m2.price ~ ., prepared_data),
  plot2 = make_plot2(prepared_data, regression),
  report = render(
    knitr_in("drake-project/report.Rmd"),
    output_file = file_out("report.html")
  )
)

make(plan)
readd(raw_data)
readd(plot1)

config <- drake_config(plan)
vis_drake_graph(config, 
                build_times = "none", 
                targets_only = TRUE, 
                navigationButtons = FALSE)

plan <- drake_plan(
  raw_data = read.csv(file_in("drake-project/appartments.csv")),
  prepared_data = prepare(raw_data),
  plot1 = make_plot1(prepared_data),
  regression = lm(m2.price~., prepared_data, weights = c(2,3,4,5,1)),
  plot2 = make_plot2(prepared_data, regression),
  report = render(
    knitr_in("drake-project/report.Rmd"),
    output_file = file_out("report.html"),
    quiet = TRUE
  )
)

config <- drake_config(plan)

vis_drake_graph(cofig, 
                build_times = "none", 
                targets_only = TRUE, 
                navigationButtons = FALSE)

vis_drake_graph(config,  
                targets_only = TRUE, 
                navigationButtons = FALSE)
