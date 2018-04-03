# Schedule Jingles in R
This is an `R` package to schedule audio execution. It can
- Play audio at regular recurring times via the HTML5 audio tag
- Mute and unmute an external audio source when jingles are played - this is currently supported in Linux only.

## Prerequisites
Muting and Unmuting external audio is currently only supported in Linux. You need to use `pulseaudio` for audio control and have `pacmd` and `pactl` installed (Debian/Ubuntu: Package `pulseaudio-utils`)

## Install
Use `devtools` and `install_github` to install package and all dependencies.
```
install.packages("devtools")
devtools::install_github("aneudecker/jingle")
```

## Run
```
library(jingle)
startApplication()
```
