library(readr)
library(RCurl)
library(jsonlite)

# Regional population
cant_popul <- 581078
hosp_beds <- 1551
ucis_beds <- 115


# DATA SCRAPPING
region_daily_url <- "https://covid19can-data.firebaseio.com/saludcantabria/daily-cases.json"
region_daily_url <- URLencode(region_daily_url)
region_daily_json <- fromJSON(region_daily_url)
region_daily_df <- as.data.frame(cbind(as.character(region_daily_json$dimension$Fecha$category$label),
                                       as.character(region_daily_json$value)))

region_deceased_url <- "https://covid19can-data.firebaseio.com/saludcantabria/daily-deceases.json"
region_deceased_url <- URLencode(region_deceased_url)
region_deceased_json <- fromJSON(region_deceased_url)
region_deceased_df <- as.data.frame(cbind(as.character(region_deceased_json$dimension$Fecha$category$label),
                                          as.character(region_deceased_json$value)))

region_recovered_url <- "https://covid19can-data.firebaseio.com/saludcantabria/daily-discharged.json"
region_recovered_url <- URLencode(region_recovered_url)
region_recovered_json <- fromJSON(region_recovered_url)
region_recovered_df <- as.data.frame(cbind(as.character(region_recovered_json$dimension$Fecha$category$label),
                                           as.character(region_recovered_json$value)))

region_accumulat_url <- "https://covid19can-data.firebaseio.com/saludcantabria/accumulated.json"
region_accumulat_url <- URLencode(region_accumulat_url)
region_accumulat_json <- fromJSON(region_accumulat_url)
region_accumulat_values <- as.data.frame(split(region_accumulat_json$value, ceiling(seq_along(region_accumulat_json$value)/4)))
region_accumulat_values <- as.data.frame(t(region_accumulat_values))
region_accumulat_df <- as.data.frame(cbind(as.character(region_accumulat_json$dimension$Fecha$category$label),
                                           region_accumulat_values))

region_test_url <- "https://covid19can-data.firebaseio.com/saludcantabria/test.json"
region_test_url <- URLencode(region_test_url)
region_test_json <- fromJSON(region_test_url)
region_test_values <- as.data.frame(split(region_test_json$value, ceiling(seq_along(region_test_json$value)/2)))
region_test_values <- as.data.frame(t(region_test_values))
region_test_df <- as.data.frame(cbind(as.character(region_test_json$dimension$Fecha$category$label),
                                      region_test_values))

region_hosp_url <- "https://covid19can-data.firebaseio.com/saludcantabria/hospitalizations.json"
region_hosp_url <- URLencode(region_hosp_url)
region_hosp_json <- fromJSON(region_hosp_url)
region_hosp_values <- as.data.frame(split(region_hosp_json$value, ceiling(seq_along(region_hosp_json$value)/5)))
region_hosp_values <- as.data.frame(t(region_hosp_values))
region_hosp_df <- as.data.frame(cbind(as.character(region_hosp_json$dimension$Fecha$category$label),
                                      region_hosp_values))
region_hosp_df$total <- region_hosp_df$V1+region_hosp_df$V2+region_hosp_df$V3+region_hosp_df$V4+region_hosp_df$V5

region_ucis_url <- "https://covid19can-data.firebaseio.com/saludcantabria/ucis.json"
region_ucis_url <- URLencode(region_ucis_url)
region_ucis_json <- fromJSON(region_ucis_url)
region_ucis_values <- as.data.frame(split(region_ucis_json$value, ceiling(seq_along(region_ucis_json$value)/2)))
region_ucis_values <- as.data.frame(t(region_ucis_values))
region_ucis_df <- as.data.frame(cbind(as.character(region_ucis_json$dimension$Fecha$category$label),
                                      region_ucis_values))
region_ucis_df$total <- region_ucis_df$V1+region_ucis_df$V2


region_datos_df <- cbind(region_accumulat_df,
                         region_daily_df[2],
                         region_deceased_df[2],
                         region_recovered_df[2],
                         region_test_df[c(2,3)],
                         region_hosp_df$total,
                         region_ucis_df$total)

colnames(region_datos_df) <- c("date", "total_cases", "total_deceased", "total_recovered",
                               "uci_cases",
                               "new_cases", "new_deceased", "new_recovered",
                               "total_antic", "total_pcr",
                               "daily_hosp", "daily_uci")
region_datos_df$date <- as.Date(region_datos_df$date, format = "%Y-%m-%d")
region_datos_df$uci_cases <- as.numeric(region_datos_df$uci_cases)
region_datos_df$new_cases <- as.numeric(region_datos_df$new_cases)
region_datos_df$new_deceased <- as.numeric(region_datos_df$new_deceased)
region_datos_df$new_recovered <- as.numeric(region_datos_df$new_recovered)
region_datos_df$total_antic <- as.numeric(region_datos_df$total_antic)
region_datos_df$total_pcr <- as.numeric(region_datos_df$total_pcr)

region_datos_df$active <- region_datos_df$total_cases - region_datos_df$total_deceased - region_datos_df$total_recovered

region_datos_df$new_antic <- region_datos_df$total_antic - c(0, region_datos_df$total_antic[-length(region_datos_df$total_antic)])
region_datos_df$new_pcr <- region_datos_df$total_pcr - c(0, region_datos_df$total_pcr[-length(region_datos_df$total_pcr)])

region_datos_df$positiv_rate_pcr <- region_datos_df$new_cases / region_datos_df$new_pcr

serie_incid <- rep(0,14)
for (fecha_index in c(15:dim(region_datos_df)[1])){
  day_incid <- sum(region_datos_df$new_cases[(fecha_index-13):(fecha_index)])/(cant_popul/100000)
  serie_incid <- c(serie_incid, day_incid)
}
region_datos_df$incid_14d <- serie_incid


serie_tasa_pcr_7d <- rep(0,7)
for (fecha_index in c(8:dim(region_datos_df)[1])){
  day_incid <- mean(region_datos_df$positiv_rate_pcr[(fecha_index-6):(fecha_index)], na.rm = TRUE)
  serie_tasa_pcr_7d <- c(serie_tasa_pcr_7d, day_incid)
}
region_datos_df$tasa_pcr_7d <- serie_tasa_pcr_7d*100

region_datos_df$tasa_hosp_ocup <- 100*region_datos_df$daily_hosp/hosp_beds
region_datos_df$tasa_ucis_ocup <- 100*region_datos_df$daily_uci/ucis_beds


write.csv2(region_datos_df, "data/regional_data.csv")







#### GRAFICOS
library(ggplot2)
fecha_dia_plot <- unique(region_datos_df$date)[length(unique(region_datos_df$date))]
require(gridExtra)

# INCIDENCIA
p_incid <- ggplot(region_datos_df, aes(date, incid_14d)) +
  geom_point(aes(colour = incid_14d)) +
  scale_colour_gradientn(limits = c(0, 600),
                         breaks = c(0, 250, 500, 1250),
                         colours = c("#bdbdbd", "#feb24c", "#de2d26", "#a50f15")) +
  geom_hline(yintercept=500, alpha=.75, size=0.25, colour="#de2d26") +
  geom_hline(yintercept=250, alpha=.75, size=0.25, colour="#feb24c") +
  coord_cartesian(xlim=c(region_datos_df$date[length(region_datos_df$date)]-60,region_datos_df$date[length(region_datos_df$date)]+1),
                  ylim=c(0,600)) +
  labs(title = paste("EVOLUCIÓN COVID19 EN CANTABRIA (", fecha_dia_plot, ")", sep=""),
       subtitle = "INCIDENCIA (acumulado 14 días)",
       x = "",
       y = "Incidencia",
       colour = "Incidencia") + 
  theme(legend.position = "none")

# CASOS ACTIVOS
p_active <- ggplot(region_datos_df, aes(date, active)) +
  geom_point(aes(colour = active)) +
  scale_colour_gradientn(limits = c(0,3000),
                         breaks = c(0, 1250, 2500, 1250),
                         colours = c("#bdbdbd", "#feb24c", "#de2d26", "#a50f15")) +
  coord_cartesian(xlim=c(region_datos_df$date[length(region_datos_df$date)]-60,region_datos_df$date[length(region_datos_df$date)]+1),
                  ylim=c(0,3000)) +
  labs(subtitle = "CASOS ACTIVOS",
       x = "",
       y = "Casos activos",
       colour = "Casos activos") + 
  theme(legend.position = "none")

# MUERTES DIARIAS
p_dailyd <- ggplot(region_datos_df, aes(date, new_deceased)) +
  geom_point(aes(colour = new_deceased)) +
  scale_colour_gradientn(limits = c(0,20),
                         colours=c("#636363", "#bdbdbd", "#de2d26")) +
  coord_cartesian(xlim=c(region_datos_df$date[length(region_datos_df$date)]-60,region_datos_df$date[length(region_datos_df$date)]+1),
                  ylim=c(0,20)) +
  labs(subtitle = "FALLECIMIENTOS DIARIOS",
       #caption = "Datos: ICANE",
       x = "",
       y = "Fallecimientos",
       colour = "Casos activos") + 
  theme(legend.position = "none")

# PCR
p_pcr <- ggplot(region_datos_df, aes(date, tasa_pcr_7d)) +
  geom_point(aes(colour = tasa_pcr_7d)) +
  scale_colour_gradientn(limits = c(0,20),
                         breaks = c(0, 10, 20, 30),
                         colours = c("#bdbdbd", "#feb24c", "#de2d26", "#a50f15")) +
  coord_cartesian(xlim=c(region_datos_df$date[length(region_datos_df$date)]-60,region_datos_df$date[length(region_datos_df$date)]+1),
                  ylim=c(0,20)) +
  labs(subtitle = "% de test PCR positivos (promedio 7 días)",
       x = "",
       y = "Porc.",
       colour = "Tasa",
       caption = "Datos: ICANE. Gob. Cantabria. Elaboración: Saúl Torres-Ortega.") + 
  theme(legend.position = "none")


# número de test
library(reshape)
test_data <- melt(region_datos_df[,c(1,13,12)], id="date")

p_test <- ggplot(test_data, aes(x=date, y=value, fill=variable)) + 
  geom_bar(position="stack", stat="identity") + 
  scale_fill_manual(labels = c("PCR", "Otros"), values=c("#de2d26", "#bdbdbd")) +
  coord_cartesian(xlim=c(region_datos_df$date[length(region_datos_df$date)]-60,region_datos_df$date[length(region_datos_df$date)]+1)) +
  labs(subtitle = "Número de pruebas realizadas",
       x = "Fecha",
       y = "Número de pruebas",
       fill = "Tipo de prueba") +  
  theme(legend.position = "bottom")

# ocupación de camas
beds_data <- melt(region_datos_df[,c(1,19,20)], id="date")

p_beds <- ggplot(beds_data, aes(x=date, y=value, colour=variable)) + 
  geom_point() + 
  scale_colour_manual(labels = c("Hospitalizados", "UCIS"), values=c("#bdbdbd", "#de2d26")) +
  coord_cartesian(xlim=c(region_datos_df$date[length(region_datos_df$date)]-60,region_datos_df$date[length(region_datos_df$date)]+1)) +
  labs(subtitle = "Porcentaje de camas ocupadas",
       x = "Fecha",
       y = "Porcentaje de ocupación",
       fill = "Tipo de cama") +  
  theme(legend.position = "bottom")

p_combine <- grid.arrange(p_incid, p_active, p_dailyd, p_test, p_pcr,  
                          ncol = 1, heights = c(1.1, 1, 1, 1.2, 1))

ggsave("images/regional_summary.png", p_combine,
       width = 30, height = 40, units = "cm")

### INDIVIDUAL GRAPHS

# INCIDENCIA
p_incid_indiv <- ggplot(region_datos_df, aes(date, incid_14d)) +
  geom_point(aes(colour = incid_14d)) +
  scale_colour_gradientn(limits = c(0, 600),
                         breaks = c(0, 250, 500, 1250),
                         colours = c("#bdbdbd", "#feb24c", "#de2d26", "#a50f15")) +
  geom_hline(yintercept=500, alpha=.75, size=0.25, colour="#de2d26") +
  geom_hline(yintercept=250, alpha=.75, size=0.25, colour="#feb24c") +
  coord_cartesian(xlim=c(region_datos_df$date[length(region_datos_df$date)]-60,region_datos_df$date[length(region_datos_df$date)]+1),
                  ylim=c(0,600)) +
  labs(title = paste("EVOLUCIÓN COVID19 EN CANTABRIA (", fecha_dia_plot, ")", sep=""),
       subtitle = "INCIDENCIA (acumulado 14 días)",
       x = "",
       y = "Incidencia",
       colour = "Incidencia",
       caption = "Datos: ICANE. Gob. Cantabria. Elaboración: Saúl Torres-Ortega.") + 
  theme(legend.position = "none")

# CASOS ACTIVOS
p_active_indiv <- ggplot(region_datos_df, aes(date, active)) +
  geom_point(aes(colour = active)) +
  scale_colour_gradientn(limits = c(0,3000),
                         breaks = c(0, 1250, 2500, 1250),
                         colours = c("#bdbdbd", "#feb24c", "#de2d26", "#a50f15")) +
  coord_cartesian(xlim=c(region_datos_df$date[length(region_datos_df$date)]-60,region_datos_df$date[length(region_datos_df$date)]+1),
                  ylim=c(0,3000)) +
  labs(title = paste("EVOLUCIÓN COVID19 EN CANTABRIA (", fecha_dia_plot, ")", sep=""),
       subtitle = "CASOS ACTIVOS",
       x = "",
       y = "Casos activos",
       colour = "Casos activos",
       caption = "Datos: ICANE. Gob. Cantabria. Elaboración: Saúl Torres-Ortega.") + 
  theme(legend.position = "none")


# CAMAS OCUPADAS
p_beds_indiv <- ggplot(beds_data, aes(x=date, y=value, colour=variable)) + 
  geom_point() + 
  scale_colour_manual(labels = c("Hospitalizados", "UCIS"), values=c("#bdbdbd", "#de2d26")) +
  coord_cartesian(xlim=c(region_datos_df$date[length(region_datos_df$date)]-60,region_datos_df$date[length(region_datos_df$date)]+1)) +
  labs(subtitle = "Porcentaje de camas ocupadas",
       x = "Fecha",
       y = "Porcentaje de ocupación",
       fill = "Tipo de cama") +  
  theme(legend.position = "bottom")



ggsave("images/regional_incid.png", p_incid_indiv,
       width = 30, height = 8, units = "cm")
ggsave("images/regional_active.png", p_active_indiv,
       width = 30, height = 8, units = "cm")
ggsave("images/regional_beds.png", p_beds_indiv,
       width = 30, height = 8, units = "cm")


