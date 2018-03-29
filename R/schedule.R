#' @export
scheduleData <- function(jingles, slotLength = 60, slotCount = 2,
                         date = Sys.Date(), start = "08:00",
                         musicVolume = "80%", musicIndex = NULL){
  if (is.null(jingles))
    return(NULL)

  if (is.na(as.numeric(slotCount)) | slotCount <= 0)
    return(NULL)

  if (is.na(as.numeric(slotLength)) | slotLength <= 0)
    return(NULL)

  stopifnot(is.data.table(jingles))

  start <- as.POSIXct(paste(date, start))

  startSlot <- start + seq(0, length.out = slotCount) * slotLength * 60

  dPlay <- jingles[, .(time = startSlot + offset * 60,
                       action = "play",
                       target = "file",
                       volume = NA,
                       index = index), by = file]

  if (!is.null(musicIndex)){
    dMute <- jingles[, .(time = startSlot + offset * 60,
                         action = "mute",
                         target = "stream",
                         volume = NA,
                         index = musicIndex), by = file]
    dMute[, file := NA]

    dUnmute <- jingles[, .(time = startSlot + offset * 60 + length,
                           action = "unmute",
                           target = "stream",
                           index = musicIndex,
                           volume = musicVolume), by = file]
    dUnmute[, file := NA]

    d <- rbind(dPlay, dMute, dUnmute)
  } else {
    d <- dPlay
  }

  d[, executed := time < Sys.time()]

  setcolorder(d, c("time", "target", "action",
                   "index", "volume", "file", "executed"))



  d[order(time, action)]
}
