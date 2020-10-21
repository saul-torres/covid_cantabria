library(readr)
library(RCurl)
library(jsonlite)

# Regional population
cant_popul <- 581078



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

region_datos_df <- cbind(region_accumulat_df,
                         region_daily_df[2],
                         region_deceased_df[2],
                         region_recovered_df[2],
                         region_test_df[c(2,3)])

colnames(region_datos_df) <- c("date", "total_cases", "total_deceased", "total_recovered",
                               "uci_cases",
                               "new_cases", "new_deceased", "new_recovered",
                               "total_antic", "total_pcr")
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
  geom_vline(xintercept=as.Date("04/05/2020", format = "%d/%m/%Y"), colour="#a50f15") +
  geom_vline(xintercept=as.Date("11/05/2020", format = "%d/%m/%Y"), colour="#de2d26") +
  geom_vline(xintercept=as.Date("25/05/2020", format = "%d/%m/%Y"), colour="#fb6a4a") +
  geom_vline(xintercept=as.Date("08/06/2020", format = "%d/%m/%Y"), colour="#fc9272") +
  geom_vline(xintercept=as.Date("19/06/2020", format = "%d/%m/%Y"), colour="#addd8e") +
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
  geom_vline(xintercept=as.Date("04/05/2020", format = "%d/%m/%Y"), colour="#a50f15") +
  geom_vline(xintercept=as.Date("11/05/2020", format = "%d/%m/%Y"), colour="#de2d26") +
  geom_vline(xintercept=as.Date("25/05/2020", format = "%d/%m/%Y"), colour="#fb6a4a") +
  geom_vline(xintercept=as.Date("08/06/2020", format = "%d/%m/%Y"), colour="#fc9272") +
  geom_vline(xintercept=as.Date("19/06/2020", format = "%d/%m/%Y"), colour="#addd8e") +
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
  geom_vline(xintercept=as.Date("04/05/2020", format = "%d/%m/%Y"), colour="#a50f15") +
  geom_vline(xintercept=as.Date("11/05/2020", format = "%d/%m/%Y"), colour="#de2d26") +
  geom_vline(xintercept=as.Date("25/05/2020", format = "%d/%m/%Y"), colour="#fb6a4a") +
  geom_vline(xintercept=as.Date("08/06/2020", format = "%d/%m/%Y"), colour="#fc9272") +
  geom_vline(xintercept=as.Date("19/06/2020", format = "%d/%m/%Y"), colour="#addd8e") +
  geom_text(x=as.Date("04/05/2020", format = "%d/%m/%Y"), y=17.5,
            label="Inicio Fase 0", colour="#a50f15",
            angle = 90, vjust = "inward", hjust = "inward") + 
  geom_text(x=as.Date("11/05/2020", format = "%d/%m/%Y"), y=17.5,
            label="Inicio Fase 1", colour="#de2d26",
            angle = 90, vjust = "inward", hjust = "inward") + 
  geom_text(x=as.Date("25/05/2020", format = "%d/%m/%Y"), y=17.5,
            label="Inicio Fase 2", colour="#fb6a4a",
            angle = 90, vjust = "inward", hjust = "inward") + 
  geom_text(x=as.Date("08/06/2020", format = "%d/%m/%Y"), y=17.5,
            label="Inicio Fase 3", colour="#fc9272",
            angle = 90, vjust = "inward", hjust = "inward") + 
  geom_text(x=as.Date("19/06/2020", format = "%d/%m/%Y"), y=17.5,
            label="Nueva normalidad", colour="#addd8e",
            angle = 90, vjust = "inward", hjust = "inward") + 
  labs(subtitle = "FALLECIMIENTOS DIARIOS",
       #caption = "Datos: ICANE",
       #x = "Fecha",
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
  geom_vline(xintercept=as.Date("04/05/2020", format = "%d/%m/%Y"), colour="#a50f15") +
  geom_vline(xintercept=as.Date("11/05/2020", format = "%d/%m/%Y"), colour="#de2d26") +
  geom_vline(xintercept=as.Date("25/05/2020", format = "%d/%m/%Y"), colour="#fb6a4a") +
  geom_vline(xintercept=as.Date("08/06/2020", format = "%d/%m/%Y"), colour="#fc9272") +
  geom_vline(xintercept=as.Date("19/06/2020", format = "%d/%m/%Y"), colour="#addd8e") +
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
  geom_vline(xintercept=as.Date("04/05/2020", format = "%d/%m/%Y"), colour="#a50f15") +
  geom_vline(xintercept=as.Date("11/05/2020", format = "%d/%m/%Y"), colour="#de2d26") +
  geom_vline(xintercept=as.Date("25/05/2020", format = "%d/%m/%Y"), colour="#fb6a4a") +
  geom_vline(xintercept=as.Date("08/06/2020", format = "%d/%m/%Y"), colour="#fc9272") +
  geom_vline(xintercept=as.Date("19/06/2020", format = "%d/%m/%Y"), colour="#addd8e") +
  labs(subtitle = "Número de pruebas realizadas",
       x = "Fecha",
       y = "Número de pruebas",
       fill = "Tipo de prueba") +  
  theme(legend.position = "bottom")


p_combine <- grid.arrange(p_incid, p_active, p_dailyd, p_test, p_pcr,  
                          ncol = 1, heights = c(1.1, 1, 1, 1.2, 1))

ggsave("images/regional_evolucion.jpg", p_combine,
       width = 30, height = 40, units = "cm")

