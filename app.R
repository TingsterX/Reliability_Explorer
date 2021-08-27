library(shiny)
library(markdown)
library(knitr)
library(shinythemes)
library(rgl)
library(ggplot2)
library(DT)
library(bslib)
library(plotly)
if (!require(bslib)) remotes::install_github(c("rstudio/bslib", "rstudio/thematic"))
files.sources <- paste("reliability", list.files('reliability'), sep=.Platform$file.sep)
invisible(sapply(files.sources, source))


ui <- navbarPage("Reliability & Individual Difference", 
                 #theme = shinytheme("yeti"),
                 #theme = bs_theme(bootswatch = "solar", font_scale=2),
                 tabPanel("Introduction", 
                          navlistPanel(
                            tabPanel(title = "Tutorial",
                                     #includeMarkdown(rmarkdown::render("tutorial_reliability.md"))
                                     includeMarkdown("tutorial_reliability.md")
                            ),
                            tabPanel(title = "Intra-class correlation",
                                     #includeMarkdown(rmarkdown::render("tutorial_ICC.Rmd"))
                                     includeMarkdown("tutorial_ICC.md")
                            ),
                            tabPanel(title = "Run Tutorial Data",
                                     #actionButton("Tutorial", "Load Demo data"),
                                     #includeHTML("demo_ToyData1.html"),
                                     includeMarkdown("tutorial_HCP.md")
                            ),
                            tabPanel(title = "Reliability field map",
                                     #includeMarkdown(rmarkdown::render("Demo_ICC_FieldMap.Rmd"))
                                     #plotlyOutput("demo_iccFM", width=500, height=500),
                                     #actionButton("demo_data_load", "Load Demo data"),
                                     #plotlyOutput("demo_iccFM_demo", width=500, height=500)
                            )
                          )
                 ),
                 tabPanel("Variation Field Map & Gradient Flow", 
                          tabsetPanel(
                            tabPanel(title = "Tutorial",
                                     #includeMarkdown(rmarkdown::render("Demo_ICC_FieldMap.Rmd"))
                                     includeHTML("Demo_ICC_FieldMap.html")
                            ),
                            tabPanel(title = "Run Demo data",
                                     includeHTML("demo_ToyData1.html")
                            )
                          )
                 ),
                 tabPanel("Calculate Your Data",
                          tabsetPanel(
                            tabPanel(title = "Load Your Data",
                                     actionButton("Load", "Load Your Data"),
                                     plotOutput("unif")
                                     
                            ),
                            tabPanel(title = "Calculate the Reliability",
                                     actionButton("RunR", "Calculate"),
                                     plotOutput("RunRplot")
                                     
                            ),
                            tabPanel(title = "Download Results",
                                     radioButtons('format', 'Document format', c('PDF', 'HTML', 'Word'),
                                                  inline = TRUE),
                                     downloadButton('downloadReport')
                            )
                          )
                 ),
                 tabPanel("Download Code",
                          includeMarkdown("tutorial_download.md")
                 ),
                 tabPanel("About",
                          includeMarkdown("tutorial_about.md")
                 )
                 
)

server <- function(input, output) {
  
  df_load_icc_demo <- reactive({
    read.csv("./data/icc_demo_data.csv")
  })
  load_icc_cmap <- reactive({
    cmap_icc_list <- list(c(0, '#7b1c43'), c(0.1, '#7b1c43'), c(0.2, '#43435f'), c(0.3, "#5e5f91"), c(0.4, "#9493c8"), c(0.5, "#64bc46"), 
                          c(0.6, "#54b24c"), c(0.7, "#f6eb2b"), c(0.8, "#f5a829"), c(0.9, "#f07e27"), c(1, "#ec3625"))
    return(cmap_icc_list)
  })
  
  demo2.vFM.sigma2_w <- reactive({df_load_icc_demo()[,'sigma2_w']})
  demo2.vFM.sigma2_b <- reactive({df_load_icc_demo()[,'sigma2_b']})
  demo2.vFM.icc <- reactive({df_load_icc_demo()[,'icc']})
  
  output$demo_iccFM_demo <- renderPlotly(
    plot_ly(x = ~demo2.vFM.sigma2_w(),y = ~demo2.vFM.sigma2_b(), z = ~demo2.vFM.icc(),
                   marker = list(size = 4, color = ~demo2.vFM.icc(),
                                 colorscale = load_icc_cmap(),
                                 cauto = F, cmin = 0, cmax = 1,
                                 showscale = FALSE)
    ) %>% 
      add_markers() %>%  
      layout(
        scene = list(xaxis = list(title = 'within-individual variation'),
                     yaxis = list(title = 'between-individual variation'),
                     zaxis = list(title = 'ICC'),
                     camera = list(eye = list(x = 2, y = -2, z = 1))),
        annotations = list(x = 1,y = 1,
                           text = 'Individual Variation and estimated ICC (Demo Data)', 
                           xref = 'paper', yref = 'paper',showarrow = FALSE)
      ) 
  )
  
  # ICC theoretic ICC estimation (surface)
  demo.vFM.sigma2_w <- reactive({seq(0,1,length=100)})
  demo.vFM.sigma2_b <- reactive({seq(0,1,length=100)})
  demo.vFM.icc <- reactive({
    m <- pracma::meshgrid(demo.vFM.sigma2_w(),y=demo.vFM.sigma2_b())
    xx <- m$X; yy <- m$Y
    z <- yy/(yy+xx)
    return(z)
  })
    
  output$demo_iccFM <- renderPlotly(
    plot_ly() %>% 
      add_surface(x = ~demo.vFM.sigma2_w(), y = ~demo.vFM.sigma2_b(), z = ~demo.vFM.icc(),
                  colorscale = load_icc_cmap(),
                  cauto = F, cmin = 0, cmax = 1,
                  showscale = FALSE) %>% 
      layout(
        scene = list(xaxis = list(title = 'within-individual variation'),
                     yaxis = list(title = 'between-individual variation'),
                     zaxis = list(title = 'ICC'),
                     camera = list(eye = list(x = 2, y = -2, z = 1))),
        annotations = list(x = 1,y = 1,
                           text = 'Individual Variation and estimated ICC (Theory)', 
                           xref = 'paper', yref = 'paper', showarrow = FALSE)
      ) %>%
      colorbar(len = 1)
    
  ) 
  
  
  
  output$view <- renderTable({
    head(df_load_icc_demo())
  })
  
  
  
  output$downloadReport <- downloadHandler(
    filename = function() {
      paste('my-report', sep = '.', switch(
        input$format, PDF = 'pdf', HTML = 'html', Word = 'docx'
      ))
    },
    content = function(file) {
      src <- normalizePath('report.Rmd')
      
      # temporarily switch to the temp dir, in case you do not have write
      # permission to the current working directory
      owd <- setwd(tempdir())
      on.exit(setwd(owd))
      file.copy(src, 'report.Rmd', overwrite = TRUE)
      
      library(rmarkdown)
      out <- render('report.Rmd', switch(
        input$format,
        PDF = pdf_document(), HTML = html_document(), Word = word_document()
      ))
      file.rename(out, file)
    }
  )
  
}

shinyApp(server = server, ui = ui)

