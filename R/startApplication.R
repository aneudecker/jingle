#' Start Application
#'
#' @export
startApplication <- function() {
  runApp(
    system.file("app", package = "jingle"),
    port = 4242,
    host = "0.0.0.0"
  )
}
