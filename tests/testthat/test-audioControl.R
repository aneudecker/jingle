context("Communicate with audio interfaces")

test_that("List audio streams", {
  streams <- audioStreams()

  expect_is(streams, "data.frame")
  expect_named(streams, c("index", "name"), ignore.order = TRUE)
  expect_is(streams$index, "numeric")
  expect_is(streams$name, "character")
})

test_that("Change Volume", {
  streams <- audioStreams()

  expect_false(setVolume(9999, "100%"))

  skip_if_not(nrow(streams) > 0, "No stream running")

  index <- sample(1:nrow(streams), 1)
  expect_true(setVolume(streams$index[index]))
})

test_that("OS Support", {
  expect_is(getOS(), "character")
  expect_is(getSupportedOS(), "character")
  expect_is(isSupportedOS(getOS()), "logical")
})

test_that("Audio Support Linux", {
  skip_if_not(getOS() == "Linux")
  expect_is(testDepsLinux(), "logical")
  expect_is(getDepsLinux(), "character")
})
