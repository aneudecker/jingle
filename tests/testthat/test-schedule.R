context("Schedule audio playback")

test_that("Create schedule matrix", {
  expect_null(scheduleData(NULL))

  jingles <- data.table(
    file = c("jingleStart.mp3", "jingle5min.mp3"),
    offset = c(0, 45),
    length = c(60, 30),
    index = c(1, 2)
  )

  d <- scheduleData(
    jingles,
    slotLength = 60,
    slotCount = 2,
    date = Sys.Date(),
    start = "10:00",
    musicVolume = "70%",
    musicIndex = 3
  )

  expect_is(d, "data.frame")
  expect_named(
    d,
    c("time", "target", "action", "index", "volume", "file", "executed"),
    ignore.order = TRUE
  )
})
