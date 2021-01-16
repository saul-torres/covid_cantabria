library(readr)
library(RCurl)
library(jsonlite)

# update january 2021

# Regional population
cant_popul <- 581078
hosp_beds <- 1551
ucis_beds <- 115

### DATA SCRAPPING
# daily cases
region_daily_url <- "https://covid19can-data.firebaseio.com/saludcantabria/daily-cases.json"
region_daily_url <- URLencode(region_daily_url)
region_daily_json <- fromJSON(region_daily_url)
region_daily_df <- as.data.frame(cbind(as.character(region_daily_json$dimension$Fecha$category$label),
                                       as.character(region_daily_json$value)))
region_daily_df$date <- sort(as.Date(region_daily_df[,1], format = "%d-%m-%Y"))


# daily deceased
region_deceased_url <- "https://covid19can-data.firebaseio.com/saludcantabria/daily-deceases.json"
region_deceased_url <- URLencode(region_deceased_url)
region_deceased_json <- fromJSON(region_deceased_url)
region_deceased_df <- as.data.frame(cbind(as.character(region_deceased_json$dimension$Fecha$category$label),
                                          as.character(region_deceased_json$value)))
region_deceased_df$date <- sort(as.Date(region_deceased_df[,1], format = "%d-%m-%Y"))

# daily recovered
region_recovered_url <- "https://covid19can-data.firebaseio.com/saludcantabria/daily-discharged.json"
region_recovered_url <- URLencode(region_recovered_url)
region_recovered_json <- fromJSON(region_recovered_url)
region_recovered_df <- as.data.frame(cbind(as.character(region_recovered_json$dimension$Fecha$category$label),
                                           as.character(region_recovered_json$value)))
region_recovered_df$date <- sort(as.Date(region_recovered_df[,1], format = "%d-%m-%Y"))

# total accumulated
region_accumulat_url <- "https://covid19can-data.firebaseio.com/saludcantabria/accumulated.json"
region_accumulat_url <- URLencode(region_accumulat_url)
region_accumulat_json <- fromJSON(region_accumulat_url)
region_accumulat_values <- as.data.frame(split(region_accumulat_json$value, ceiling(seq_along(region_accumulat_json$value)/4)))
region_accumulat_values <- as.data.frame(t(region_accumulat_values))
region_accumulat_df <- as.data.frame(cbind(as.character(region_accumulat_json$dimension$Fecha$category$label),
                                           region_accumulat_values))
region_accumulat_df$date <- sort(as.Date(region_accumulat_df[,1], format = "%d-%m-%Y"))

# daily tests
region_test_url <- "https://covid19can-data.firebaseio.com/saludcantabria/daily-test.json"
region_test_url <- URLencode(region_test_url)
region_test_json <- fromJSON(region_test_url)
region_test_values <- as.data.frame(split(region_test_json$value, ceiling(seq_along(region_test_json$value)/3)))
region_test_values <- as.data.frame(t(region_test_values))
region_test_df <- as.data.frame(cbind(as.character(region_test_json$dimension$Fecha$category$label),
                                      region_test_values))
region_test_df$date <- sort(as.Date(region_test_df[,1], format = "%d-%m-%Y"))

# hospital. cases
region_hosp_url <- "https://covid19can-data.firebaseio.com/saludcantabria/hospitalizations.json"
region_hosp_url <- URLencode(region_hosp_url)
region_hosp_json <- fromJSON(region_hosp_url)
region_hosp_values <- as.data.frame(split(region_hosp_json$value, ceiling(seq_along(region_hosp_json$value)/5)))
region_hosp_values <- as.data.frame(t(region_hosp_values))
region_hosp_df <- as.data.frame(cbind(as.character(region_hosp_json$dimension$Fecha$category$label),
                                      region_hosp_values))
region_hosp_df$total <- region_hosp_df$V1+region_hosp_df$V2+region_hosp_df$V3+region_hosp_df$V4+region_hosp_df$V5
region_hosp_df$date <- sort(as.Date(region_hosp_df[,1], format = "%d-%m-%Y"))

# uci cases
region_ucis_url <- "https://covid19can-data.firebaseio.com/saludcantabria/ucis.json"
region_ucis_url <- URLencode(region_ucis_url)
region_ucis_json <- fromJSON(region_ucis_url)
region_ucis_values <- as.data.frame(split(region_ucis_json$value, ceiling(seq_along(region_ucis_json$value)/2)))
region_ucis_values <- as.data.frame(t(region_ucis_values))
region_ucis_df <- as.data.frame(cbind(as.character(region_ucis_json$dimension$Fecha$category$label),
                                      region_ucis_values))
region_ucis_df$total <- region_ucis_df$V1+region_ucis_df$V2
region_ucis_df$date <- sort(as.Date(region_ucis_df[,1], format = "%d-%m-%Y"))

# incidence
region_incidence_url <- "https://covid19can-data.firebaseio.com/saludcantabria/incidence.json"
region_incidence_url <- URLencode(region_incidence_url)
region_incidence_json <- fromJSON(region_incidence_url)
region_incidence_df <- as.data.frame(cbind(as.character(region_incidence_json$dimension$Fecha$category$label),
                                          as.character(region_incidence_json$value)))
region_incidence_df$date <- sort(as.Date(region_incidence_df[,1], format = "%d-%m-%Y"))



# merge datasets
region_data_df <- Reduce(function(x, y) merge(x, y, by = "date"),
                         list(region_accumulat_df[,-1],
                              region_daily_df[,-1],
                              region_deceased_df[,-1],
                              region_recovered_df[,-1],
                              region_incidence_df[,-1],
                              region_test_df[,-1],
                              region_hosp_df[,-1],
                              region_ucis_df[,-1]))
colnames(region_data_df) <- c("date", #common column
                              "total_cases", "total_deceased", "total_recovered", "uci_cases", #region_accumulat_df dataset
                              "new_cases", #region_daily_df dataset
                              "new_deceased", #region_deceased_df dataset
                              "new_recovered", #region_recovered_df dataset
                              "incidence_14d", #region_incidence_df
                              "daily_antic", "daily_antig", "daily_pcr", #region_test_df dataset
                              "daily_hosp_lar", "daily_hosp_lie", "daily_hosp_sie", "daily_hosp_3ma", "daily_hosp_val", "daily_hosp_total", #region_hosp_df dataset
                              "daily_uci_sie", "daily_uci_val", "daily_uci_total") #region_ucis_df dataset

# convert to numeric some variables
region_data_df$new_cases <- as.numeric(region_data_df$new_cases)
region_data_df$new_deceased <- as.numeric(region_data_df$new_deceased)
region_data_df$new_recovered <- as.numeric(region_data_df$new_recovered) 
region_data_df$incidence_14d <- as.numeric(region_data_df$incidence_14d) 

# obtain new variables
region_data_df$active <- region_data_df$total_cases - region_data_df$total_deceased - region_data_df$total_recovered
region_data_df$daily_test <- region_data_df$daily_antic + region_data_df$daily_antig + region_data_df$daily_pcr
region_data_df$daily_positiv <- region_data_df$new_cases / region_data_df$daily_test

serie_tasa_pcr_7d <- rep(0,7)
for (fecha_index in c(8:dim(region_data_df)[1])){
  day_incid <- mean(region_data_df$daily_positiv[(fecha_index-6):(fecha_index)], na.rm = TRUE)
  serie_tasa_pcr_7d <- c(serie_tasa_pcr_7d, day_incid)
}
region_data_df$rate_pcr_7d <- serie_tasa_pcr_7d*100

region_data_df$rate_hosp_ocup <- 100*region_data_df$daily_hosp_total/hosp_beds
region_data_df$rate_ucis_ocup <- 100*region_data_df$daily_uci_total/ucis_beds


### SAVE DATA
write.csv2(region_data_df, "data/regional_data.csv")


#### GRAPHS
library(ggplot2)
fecha_dia_plot <- unique(region_data_df$date)[length(unique(region_data_df$date))]
library(gridExtra)

# INCIDENCIA
p_incid <- ggplot(region_data_df, aes(date, incidence_14d)) +
  geom_point(aes(colour = incidence_14d)) +
  scale_colour_gradientn(limits = c(0, 600),
                         breaks = c(0, 250, 500, 1250),
                         colours = c("#bdbdbd", "#feb24c", "#de2d26", "#a50f15")) +
  geom_hline(yintercept=500, alpha=.75, size=0.25, colour="#de2d26") +
  geom_hline(yintercept=250, alpha=.75, size=0.25, colour="#feb24c") +
  coord_cartesian(xlim=c(region_data_df$date[length(region_data_df$date)]-90,region_data_df$date[length(region_data_df$date)]+1),
                  ylim=c(0,600)) +
  labs(title = paste("EVOLUCIÓN COVID19 EN CANTABRIA (", fecha_dia_plot, ")", sep=""),
       subtitle = "INCIDENCIA (acumulado 14 días)",
       x = "",
       y = "Incidencia",
       colour = "Incidencia") + 
  theme(legend.position = "none")

# CASOS ACTIVOS
p_active <- ggplot(region_data_df, aes(date, active)) +
  geom_point(aes(colour = active)) +
  scale_colour_gradientn(limits = c(0,5000),
                         breaks = c(0, 1250, 2500, 1250),
                         colours = c("#bdbdbd", "#feb24c", "#de2d26", "#a50f15")) +
  coord_cartesian(xlim=c(region_data_df$date[length(region_data_df$date)]-90,region_data_df$date[length(region_data_df$date)]+1),
                  ylim=c(0,5000)) +
  labs(subtitle = "CASOS ACTIVOS",
       x = "",
       y = "Casos activos",
       colour = "Casos activos") + 
  theme(legend.position = "none")

# MUERTES DIARIAS
p_dailyd <- ggplot(region_data_df, aes(date, new_deceased)) +
  geom_point(aes(colour = new_deceased)) +
  scale_colour_gradientn(limits = c(0,20),
                         colours=c("#636363", "#bdbdbd", "#de2d26")) +
  coord_cartesian(xlim=c(region_data_df$date[length(region_data_df$date)]-90,region_data_df$date[length(region_data_df$date)]+1),
                  ylim=c(0,20)) +
  labs(subtitle = "FALLECIMIENTOS DIARIOS",
       #caption = "Datos: ICANE",
       x = "",
       y = "Fallecimientos",
       colour = "Casos activos") + 
  theme(legend.position = "none")

# positivity
p_positiv <- ggplot(region_data_df, aes(date, rate_pcr_7d)) +
  geom_point(aes(colour = rate_pcr_7d)) +
  scale_colour_gradientn(limits = c(0,20),
                         breaks = c(0, 10, 20, 30),
                         colours = c("#bdbdbd", "#feb24c", "#de2d26", "#a50f15")) +
  coord_cartesian(xlim=c(region_data_df$date[length(region_data_df$date)]-90,region_data_df$date[length(region_data_df$date)]+1),
                  ylim=c(0,20)) +
  labs(subtitle = "% de test positivos (promedio 7 días)",
       x = "",
       y = "Porc.",
       colour = "Tasa",
       caption = "Datos: ICANE. Gob. Cantabria. Elaboración: Saúl Torres-Ortega.") + 
  theme(legend.position = "none")


# número de test
p_test <- ggplot(region_data_df, aes(x=date, y=daily_test)) + 
  geom_col(fill = "#de2d26") +
  coord_cartesian(xlim=c(region_data_df$date[length(region_data_df$date)]-90,region_data_df$date[length(region_data_df$date)]+1)) +
  labs(subtitle = "Número de pruebas realizadas",
       x = "Fecha",
       y = "Número de pruebas") +  
  theme(legend.position = "bottom")

# ocupación de camas
library(reshape)
beds_data <- melt(region_data_df[,c(1,26,27)], id="date")

p_beds <- ggplot(beds_data, aes(x=date, y=value, colour=variable)) + 
  geom_point() + 
  scale_colour_manual(labels = c("Hospitalizados", "UCIS"), values=c("#bdbdbd", "#de2d26")) +
  coord_cartesian(xlim=c(region_data_df$date[length(region_data_df$date)]-90,region_data_df$date[length(region_data_df$date)]+1)) +
  labs(subtitle = "Porcentaje de camas ocupadas",
       x = "Fecha",
       y = "Porcentaje de ocupación",
       colour = "Tipo de cama") +  
  theme(legend.position = "bottom")

p_combine <- grid.arrange(p_incid, p_active, p_dailyd, p_beds, p_test, p_positiv,  
                          ncol = 1, heights = c(1.1, 1, 1, 1.2, 1, 1.05))

ggsave("images/regional_summary.png", p_combine,
       width = 30, height = 40, units = "cm")

### INDIVIDUAL GRAPHS

# INCIDENCIA
p_incid_indiv <- ggplot(region_data_df, aes(date, incidence_14d)) +
  geom_point(aes(colour = incidence_14d)) +
  scale_colour_gradientn(limits = c(0, 600),
                         breaks = c(0, 250, 500, 1250),
                         colours = c("#bdbdbd", "#feb24c", "#de2d26", "#a50f15")) +
  geom_hline(yintercept=500, alpha=.75, size=0.25, colour="#de2d26") +
  geom_hline(yintercept=250, alpha=.75, size=0.25, colour="#feb24c") +
  coord_cartesian(xlim=c(region_data_df$date[length(region_data_df$date)]-90,region_data_df$date[length(region_data_df$date)]+1),
                  ylim=c(0,600)) +
  labs(title = paste("EVOLUCIÓN COVID19 EN CANTABRIA (", fecha_dia_plot, ")", sep=""),
       subtitle = "INCIDENCIA (acumulado 14 días)",
       x = "",
       y = "Incidencia",
       colour = "Incidencia",
       caption = "Datos: ICANE. Gob. Cantabria. Elaboración: Saúl Torres-Ortega.") + 
  theme(legend.position = "none")

# CASOS ACTIVOS
p_active_indiv <- ggplot(region_data_df, aes(date, active)) +
  geom_point(aes(colour = active)) +
  scale_colour_gradientn(limits = c(0,5000),
                         breaks = c(0, 1250, 2500, 1250),
                         colours = c("#bdbdbd", "#feb24c", "#de2d26", "#a50f15")) +
  coord_cartesian(xlim=c(region_data_df$date[length(region_data_df$date)]-90,region_data_df$date[length(region_data_df$date)]+1),
                  ylim=c(0,5000)) +
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
  coord_cartesian(xlim=c(region_data_df$date[length(region_data_df$date)]-90,region_data_df$date[length(region_data_df$date)]+1)) +
  labs(subtitle = "Porcentaje de camas ocupadas",
       x = "Fecha",
       y = "Porcentaje de ocupación",
       fill = "Tipo de cama") +  
  theme(legend.position = "bottom")


# POSITIVIDAD
p_pcr_indiv <- ggplot(region_data_df, aes(date, rate_pcr_7d)) +
  geom_point(aes(colour = rate_pcr_7d)) +
  scale_colour_gradientn(limits = c(0,20),
                         breaks = c(0, 10, 20, 30),
                         colours = c("#bdbdbd", "#feb24c", "#de2d26", "#a50f15")) +
  coord_cartesian(xlim=c(region_datos_df$date[length(region_datos_df$date)]-90,region_datos_df$date[length(region_datos_df$date)]+1),
                  ylim=c(0,20)) +
  labs(title = paste("EVOLUCIÓN COVID19 EN CANTABRIA (", fecha_dia_plot, ")", sep=""),
       subtitle = "% de test PCR positivos (promedio 7 días)",
       x = "",
       y = "Porc.",
       colour = "Tasa",
       caption = "Datos: ICANE. Gob. Cantabria. Elaboración: @covidcantabria") + 
  theme(legend.position = "none")



ggsave("images/regional_incid.png", p_incid_indiv,
       width = 30, height = 8, units = "cm")
ggsave("images/regional_active.png", p_active_indiv,
       width = 30, height = 8, units = "cm")
ggsave("images/regional_beds.png", p_beds_indiv,
       width = 30, height = 8, units = "cm")
ggsave("images/regional_positiv.png", p_pcr_indiv,
       width = 30, height = 8, units = "cm")


