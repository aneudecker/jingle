#' @export
executeJob <- function(action, ...){
  switch(
    action,
    play = executePlay(...)
  )
}

executePlay <- function(index, ...){
  id <- paste0("#jingle", index)
  jsReset <- paste0("$('", id, "').get(0).currentTime = 0;")
  jsPlay <- paste0("$('", id, "').trigger('play');")

  shinyjs::runjs(paste(jsReset, jsPlay))
}
