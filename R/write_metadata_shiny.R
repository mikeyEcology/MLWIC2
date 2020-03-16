# shiny
server <- function(input, output, session) {
  
  # determine if Windows and create appropriate slashes
  if(Sys.info()["sysname"] == "Windows"){
    Windows <- TRUE
  } else {
    Windows <- FALSE
  }
  slash <- shiny::reactive({ifelse(Windows, "\\", "/")})
  os = ifelse(Windows, "Windows", "Mac")
  
  #- make file selection for some variables
  # base directory for fileChoose
  #volumes =  c(home = "") 
  volumes = shinyFiles::getVolumes()
  shinyFiles::shinyDirChoose(input, 'exiftool_loc', roots=volumes, session=session)
  dirname_exiftool_loc <- shiny::reactive({shinyFiles::parseDirPath(volumes, input$exiftool_loc)})
  # # Observe exiftool_loc changes
  shiny::observe({
    if(!is.null(dirname_exiftool_loc)){
      print(dirname_exiftool_loc())
      output$exiftool_loc <- shiny::renderText(dirname_exiftool_loc())
    }
  })
  
  # output_file
   shinyFiles::shinyFileChoose(input, "output_file", roots=volumes, session=session, filetypes=c('csv'))
   filename_output_file <- shiny::reactive({shinyFiles::parseFilePaths(volumes, input$output_file)[length(shinyFiles::parseFilePaths(volumes, input$output_file))]})
  
   # make printout
   output$print <- renderText({
     inFile <<- input$output_file
     if(is.integer(inFile)){
       return(NULL)
       #output_file_collapse <- ""
     } else{
       # on Windows deal with  issuefinding the right drive
       if(os == "Windows"){
         root <- inFile$root
         root1 <- gsub("\\(", "", root)
         root2 <- gsub("\\)", "", root1) # this gives [Drive]:
         output_file_collapse <- paste0(root2, paste0(inFile$files$`0`, collapse="/"))
       } else { # on not windows, we don't have to deal with this
         output_file_collapse <- paste0(inFile$files$`0`, collapse="/")
       }
     }
     paste0("write_metadata(output_file = '", output_file_collapse,
            "', model_type = '", input$model_type, "',",
            " show_sys_output = ", input$show_sys_output,
            ")")
   })
   
   
  # # run function
  shiny::observeEvent(input$runwrite_metadata, {
    #if(is.null(input$model_type) || is.null(input$show_sys_output) || is.integer(inFile)){return(NULL)}
    showModal(modalDialog("Running write_metadata function. Some output will appear in your R console during this process. Press Dimiss at any time"))
    inFile <<- input$output_file
    if(is.integer(inFile)){
      return(NULL)
      #output_file_collapse <- ""
    } else{
      # on Windows deal with  issuefinding the right drive
      if(os == "Windows"){
        root <- inFile$root
        root1 <- gsub("\\(", "", root)
        root2 <- gsub("\\)", "", root1) # this gives [Drive]:
        output_file_collapse <- paste0(root2, paste0(inFile$files$`0`, collapse="/"))
      } else { # on not windows, we don't have to deal with this
        output_file_collapse <- paste0(inFile$files$`0`, collapse="/")
      }
    }
    wm_list <<- list(output_file=output_file_collapse,
                    model_type = input$model_type,
                    exiftool_loc = gsub("\\\\", "/", normalizePath(dirname_exiftool_loc()))
                    )
    do.call(write_metadata, wm_list)
    # write_metadata( # if I skip this line there is no error, but it doesnt run
    #   #exiftool_loc = gsub("\\\\", "/", normalizePath(dirname_exiftool_loc())),
    #   output_file = output_file_collapse,
    #   model_type = input$model_type,
    #   show_sys_output = input$show_sys_output
    # )
    showModal(modalDialog("write_metadata function complete. Check you R console for information. You may press dismiss and close the Shiny window now."))
  })
}
ui <- shiny::fluidPage(
  
  # App title ----
  shiny::titlePanel("Write classifications from MLWIC2 to metadata ofimage files"),
  
  # Sidebar layout with input and output definitions ----
  shiny::sidebarLayout(
    
    shiny::sidebarPanel(
      shinyFiles::shinyFilesButton('output_file', "Output file from classify", title="Select the file containing predictions from classify. This is in your MLWIC2_helper_files folder unless you deviated from defaults. ", multiple=FALSE),
      shiny::helpText("You only need to select ExifTool location if your computer is having trouble finding it. Windows users will likely need to do this"),
      shinyFiles::shinyDirButton('exiftool_loc', 'ExifTool location', title='Select the directory where ExifTool is stored.'),
      shiny::selectInput('model_type', 'What type of model did you use for classification', c(
        "species model" = "species_model",
        "empty-animal model" = "empty_animal"
      )),
      shiny::selectInput("show_sys_output", "Do you want to show output from the Exiftool call in your R console? (Only for troubleshooting)", c(
        "No" = "FALSE",
        "Yes" = "TRUE"

      )),
      shiny::actionButton("runwrite_metadata", "Write metadata")
    ),
    
    shiny::mainPanel(
      shiny::helpText("Output for copying and pasting into console:"),
      shiny::textOutput("print")
    )
  )
)

shiny::shinyApp(ui, server)
