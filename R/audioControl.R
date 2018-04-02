getOS <- function(){
  Sys.info()["sysname"]
}

getSupportedOS <- function(){
  "Linux"
}

#' @export
isSupportedOS <- function(os = getOS()){
  os %in% getSupportedOS()
}

#' @export
testDeps <- function(os = getOS()){
  switch(
    os,
    Linux = testDepsLinux(),
    FALSE
  )
}

#' @export
getDeps <- function(os = getOS()){
  switch(
    os,
    Linux = getDepsLinux()
  )
}

getDepsLinux <- function(){
  c("pacmd and pactl need to be installed")
}

testDepsLinux <- function(){
  code1 <- system2("pacmd", args = "--version")
  code2 <- system2("pactl", args = "--version")

  return(code1 == 0 & code2 == 0)
}

#' @export
audioStreams <- function(){
  switch(
    getOS(),
    Linux = audioStreamsLinux(),
    FALSE
  )
}

audioStreamsLinux <- function(){
  out <- system2("pacmd", args = "list-sink-inputs",
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

#' @export
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
