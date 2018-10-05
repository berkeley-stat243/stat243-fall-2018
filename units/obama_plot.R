library(dplyr)
library(chron)

setwd('/global/scratch/paciorek/wikistats/obama-counts')

dat <- read.csv('part-00000')

names(dat) <- c('date','time','lang','hits')
dat$date <- as.character(dat$date)
dat$time <- as.character(dat$time)
dat$time[dat$time %in%  c("0", "1")] <- "000000"
wh <- which(nchar(dat$time) == 5)
dat$time[wh] <- paste0("0", dat$time[wh])
dat$chron <- chron(dat$date, dat$time,
                  format = c(dates = 'ymd', times = "hms"))
dat$chron <- dat$chron - 5/24 # GMT -> EST

dat <- dat %>% filter(dat$lang == 'en')
sub <- dat %>% filter(dat$date < 20081110 & dat$date > 20081101)

pdf('obama-traffic.pdf', width = 5, height = 5)
par(mfrow = c(2, 1), mgp = c(1.8, 0.7, 0), mai = c(0.6, 0.6, 0.1, 0.1))
plot(dat$chron, dat$hits, type = 'l', xlab = 'time', ylab = 'hits')
plot(sub$chron, sub$hits, type = 'l', xlab = 'time', ylab = 'hits')
points(sub$chron, sub$hits)
dev.off()
