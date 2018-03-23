getOS <- function(){
  Sys.info()["sysname"]
}

audioStreams <- function(){
  switch(
    getOS(),
    Linux = audioStreamsLinux(),
    FALSE
  )
}

audioStreamsLinux <- function(){
  out <- system2("/usr/bin/pacmd", args = "list-sink-inputs",
                 stdout = TRUE)

  pattern <- "[ ]*index: ([0-9]+)"
  matched <- grep(pattern, out, value = TRUE)
  index <- sub(pattern, "\\1", matched)
  index <- as.numeric(index)

  pattern <- "[ ]*application.name = (.+)"
  matched <- grep(pattern, out, value = TRUE)
  app <- sub(pattern, "\\1", matched)
  app <- gsub("\\t", "", app)
  app <- gsub("\"", "", app)

  data.frame(
    index = index,
    name = app,
    stringsAsFactors = FALSE
  )
}

setVolume <- function(...){
  switch(
    getOS(),
    Linux = setVolumeLinux(...),
    FALSE
  )
}

setVolumeLinux <- function(index, volume = "100%"){
  code <- system2(
    "pactl",
    args = c("set-sink-input-volume", index, volume)
  )
  return(code == 0)
}
