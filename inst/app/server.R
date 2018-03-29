library(jingle)

function(input, output, session){
  observeEvent(input$play, {
    shinyjs::runjs("$('#jingle').get(0).currentTime = 0; $('#jingle').trigger('play');")
  })

  #####
  stack <- reactiveValues(
    c = 0,
    jingles = list(),
    schedule = NULL
  )

  observeEvent(input$audioFile, {
    audio <- input$audioFile

    if (is.null(audio))
      return(NULL)

    file.copy(audio$datapath, paste0("www/", audio$name))

    c <- stack$c + 1

    insertUI(
      "#jingles",
      "beforeEnd",
      div(
        style = "border:1px white solid; padding: 10px; border-radius:5px;",
        div(audio$name),
        numericInput(paste0("offset", c), "Offset", min = 0, value = 0),
        div("Length", 0),
        tags$audio(src = audio$name, type = "audio/mp3",
                   controls = TRUE, id = paste0("jingle", c)),
        div(
          actionButton(
            paste0("remove", c),
            paste("Remove", c)
          )
        )
      )
    )

    stack$jingles[[length(stack$jingles) + 1]] <- reactive({
      offset <- if (is.null(input[[paste0("offset", c)]])) 0
                else input[[paste0("offset", c)]]

      list(
        file = audio$name,
        offset = offset,
        length = 0,
        index = c
      )
    })

    stack$c <- c
  })

  jingles <- reactive({
    if (length(stack$jingles) == 0)
      return(NULL)

    data.table::rbindlist(lapply(stack$jingles, do.call, args = list()))
  })

  observe({
    index <- if (input$musicIndex == "") NULL
             else input$musicIndex

    stack$schedule <- scheduleData(
      jingles(),
      slotLength = input$slotLength,
      slotCount = input$slotCount,
      date = input$date,
      start = format(input$start, "%H:%M"),
      musicVolume = paste0(input$musicVolume, "%"),
      musicIndex = index
   )
  })

  output$schedule <- renderDataTable({stack$schedule})

  observe({
    invalidateLater(1000, session)

    isolate({
      activ <- which(
        stack$schedule$time <= Sys.time() + 1 &
        stack$schedule$executed == FALSE
      )

      lapply(activ, function(i){
        do.call(executeJob, as.list(stack$schedule[i]))
      })

      stack$schedule$executed[activ] <- TRUE
    })
  })
}
