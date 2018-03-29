library(jingle)

fluidPage(
  title = "Schedule Jingles",
  theme = shinythemes::shinytheme("slate"),
  shinyjs::useShinyjs(),
  titlePanel(
    "Schedule Jingles"
  ),
  sidebarPanel(
    numericInput("slotLength", "Slot Length (min)", min = 1, value = 60),
    numericInput("slotCount", "Number of Slots", min = 1, value = 1),
    dateInput("date", "Date of Tournament"),
    shinyTime::timeInput("start", "Begin of first slot", seconds = FALSE),
    sliderInput("musicVolume", "Volume of Music", min = 0, max = 100, step = 5, value = 70),
    selectInput("musicIndex", "Audio Source", choices = NULL, selected = NULL),
    br(),
    actionButton("play", "Play")
  ),
  mainPanel(
    fluidRow(
      fileInput("audioFile", "Add Audio File"),
      div(id = "jingles")
    ),
    fluidRow(
      h2("Schedule"),
      dataTableOutput("schedule")
    )
  )
)
