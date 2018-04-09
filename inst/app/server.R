library(jingle)

function(input, output, session){
  observeEvent(input$updateSources, {
    streams <- audioStreams()

    if (is.null(streams))
      return(NULL)

    choices <- streams$index
    names(choices) <- paste0("Index ", choices, ": ", streams$name)

    updateSelectInput(
      session,
      "musicIndex",
      choices = choices
    )
  })

  observeEvent(input$setVolume, {
    if (input$musicIndex == "")
      return(NULL)

    else
      setVolume(
        input$musicIndex,
        paste0(input$musicVolume, "%")
      )
  })

  stack <- reactiveValues(
    c = 0,
    jingles = list(),
    remove = list(),
    index = list(),
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
        class = "jingle-box",
        id = paste0("jingle-box-", c),
        h4(audio$name),
        div(
          class = "offset-input",
          numericInput(paste0("offset", c), "Offset (min)", min = 0, value = 0)
        ),
        div(
          class = "length-input",
          numericInput(paste0("length", c), "Length (sec)", min = 0, value = 0)
        ),
        tags$audio(src = audio$name, type = "audio/mp3",
                   controls = TRUE, id = paste0("jingle", c)),
        div(
          actionButton(
            paste0("remove", c),
            paste("Remove")
          )
        )
      ),
      immediate = TRUE
    )

    shinyjs::runjs(paste0("$('audio').on('canplay', function(){
      $('#length", c, "').val(Math.round(this.duration));
      $('#length", c, "').change();
    })"));

    stack$jingles[[length(stack$jingles) + 1]] <- reactive({
      offset <- if (is.null(input[[paste0("offset", c)]])) 0
                else input[[paste0("offset", c)]]

      ll <- if (is.null(input[[paste0("length", c)]])) 0
            else input[[paste0("length", c)]]

      list(
        file = audio$name,
        offset = offset,
        length = ll,
        index = c
      )
    })

    stack$remove[[length(stack$remove) + 1]] <- observeEvent(
      input[[paste0("remove", c)]],
    {
      index <- which(unlist(lapply(stack$index, "==", c)))

      removeUI(paste0("#jingle-box-", c))
      stack$jingles[index] <- NULL
      stack$remove[index] <- NULL
      stack$index[index] <- NULL
    })

    stack$index[[length(stack$index) + 1]] <- c
    stack$c <- c
  })

  jingles <- reactive({
    if (length(stack$jingles) == 0)
      return(NULL)

    data.table::rbindlist(lapply(stack$jingles, do.call, args = list()))
  })

  observe({
    if (!input$running)
      return(NULL)

    index <- if (is.null(input$musicIndex) || input$musicIndex == "") NULL
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
