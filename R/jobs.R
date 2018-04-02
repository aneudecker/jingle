#' @export
executeJob <- function(action, ...){
  switch(
    action,
    play = executePlay(...),
    mute = executeMute(...),
    unmute = executeUnmute(...)
  )
}
tar
executePlay <- function(index, ...){
  id <- paste0("#jingle", index)
  jsReset <- paste0("$('", id, "').get(0).currentTime = 0;")
  jsPlay <- paste0("$('", id, "').trigger('play');")

  shinyjs::runjs(paste(jsReset, jsPlay))
}

executeMute <- function(index, ...){
  setVolume(index, "0%")
}

executeUnmute <- function(index, volume, ...){
  setVolume(index, volume)
}

