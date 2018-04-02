library(jingle)

audioControlUI <- function(){
  if (!isSupportedOS()){
    return(div(
      class = "warning",
      "Your opperating system ist not supported"
    ))
  }

  if (!testDeps()){
    return(div(
      class = "warning",
      getDeps()
    ))
  }

  tagList(
    selectInput("musicIndex", "Audio Source", choices = NULL, selected = NULL),
    div(
      class = "form-group",
      actionButton("updateSources", "Update Sources")
    ),
    sliderInput("musicVolume", "Volume of Music", min = 0, max = 100, step = 5, value = 70),
    div(
      class = "form-group",
      actionButton("setVolume", "Set Volume")
    )
  )
}

fluidPage(
  title = "Schedule Jingles",
  theme = shinythemes::shinytheme("slate"),
  shinyjs::useShinyjs(),
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
  ),
  titlePanel(
    "Schedule Jingles"
  ),
  sidebarPanel(
    h4("Tournament"),
    numericInput("slotLength", "Slot Length (min)", min = 1, value = 60),
    numericInput("slotCount", "Number of Slots", min = 1, value = 1),
    dateInput("date", "Date of Tournament"),
    shinyTime::timeInput("start", "Begin of first slot", seconds = FALSE),
    h4("Control External Audio"),
    audioControlUI(),
    tags$hr(),
    div(
      class = "form-group",
      tags$label("Script running ... ", class = "control-label"),
      shinyWidgets::switchInput("running", value = FALSE)
    )
  ),
  mainPanel(
    fluidRow(
      h2("Jingles"),
      fileInput("audioFile", "Add Audio File"),
      div(id = "jingles")
    ),
    fluidRow(
      h2("Schedule"),
      dataTableOutput("schedule")
    )
  )
)
