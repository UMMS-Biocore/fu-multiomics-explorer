networkTabUI <- function(id) {
  ns <- NS(id)
  tagList(
    
    layout_columns(
      card(
        card_header(
          "Options"
        ),
        card_body(
          nodeSelectionUI(ns('node_selection')),
          visibilityUI(ns('visibility')),
          zoomUI(ns('zoom')),
          br(),
          br(),
          downloadButton(ns('download_file'), label = "Download Network for Cytoscape"),
          br(),
          br(),
          plotOutput(ns('legend'), height = "100px", width="100%")
        )
      ),
      card(
        card_header(
          "Network"
        ),
        card_body(
          cyjShinyOutput(ns('network'), width="100%", height=650)
        )
      ),
      col_widths = c(3,9)
    )
  )
}

networkTabServer <- function(id) {
  
  moduleServer(id, function(input, output, session) {
    
  	network_input = reactive({
  		paste(readLines(clean_data_path('full_network.cyjs')), collapse = '')
  	})
  	
  	nodes = reactive({
  		df = fromJSON(clean_data_path('full_network.cyjs'))
  		data.frame(id=df$elements$nodes$data$id, Label=df$elements$nodes$data$label)
  	})
  	
  	nodeSelectionServer('node_selection', nodes)
  	visibilityServer('visibility')
  	zoomServer('zoom')
  	
    output$network <- renderCyjShiny({
      cyjShiny(network_input(), layoutName="cola", styleFile = 'www/style.js')
    })
    
    output$legend <- renderPlot({
      ggplot(data.frame(x = 0, value = 0), aes(x, value, colour = value)) +
        geom_point(alpha = 0) +
        scale_colour_gradient2(
          low = "#4682B4",
          mid = "#F5F5F5",
          high = "#B22222",
          midpoint = 0,
          limits = c(-3.1, 3.1),
          breaks = c(-3, 0, 3),
          name = "Log2Fold Change",
          guide = guide_colourbar(
            title.position = "top",
            title.hjust = 0.5
          )) +
        theme_void() +
        theme(
          legend.position = "top",
          legend.background = element_blank(),
          legend.box.background = element_blank(),
          legend.key = element_blank(),
          plot.background = element_blank()
        )
    })
    
    output$download_file <- downloadHandler(
      filename = function() {
        "network.cys"
      },
      content = function(file) {
        file.copy(raw_data_path('A3.cys'), file)
      }
    )
    
  })
}