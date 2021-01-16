library(readr)
library(RCurl)
library(jsonlite)

# update january 2021

# Load municipalities names
municip_nombres <- read_delim("data/cant_municios_nombres.csv", 
                              ";", escape_double = FALSE, locale = locale(encoding = "ISO-8859-1"), 
                              trim_ws = TRUE)

# Empty data frame to save results
cantabr_data_df <- data.frame(date = character(),
                               value = numeric(),
                               active = numeric(),
                               new_cases = numeric(),
                               new_deceased = numeric(),
                               incidence_14d = numeric(),
                               municip = character(),
                               stringsAsFactors=FALSE)

municip_index <- municip_nombres$compuesto[87]

for (municip_index in municip_nombres$compuesto){
  # active cases
  munic_active_url <- paste("https://covid19can-data.firebaseio.com/saludcantabria/municipios/",
                            municip_index,
                            "/activos.json",
                            sep = "")
  munic_active_url <- URLencode(munic_active_url)
  munic_active_json <- fromJSON(munic_active_url)
  munic_active_df <- as.data.frame(cbind(as.character(munic_active_json$dimension$Fecha$category$label),
                                         as.character(munic_active_json$value)))
  munic_active_df$date <- sort(as.Date(munic_active_df[,1], format = "%d-%m-%Y"))
  
  
  # daily new cases
  munic_dailycases_url <- paste("https://covid19can-data.firebaseio.com/saludcantabria/municipios/",
                            municip_index,
                            "/casos-diarios.json",
                            sep = "")
  munic_dailycases_url <- URLencode(munic_dailycases_url)
  munic_dailycases_json <- fromJSON(munic_dailycases_url)
  munic_dailycases_df <- as.data.frame(cbind(as.character(munic_dailycases_json$dimension$Fecha$category$label),
                                         as.character(munic_dailycases_json$value)))
  munic_dailycases_df$date <- sort(as.Date(munic_dailycases_df[,1], format = "%d-%m-%Y"))  
  

  # daily new deceased
  munic_dailydecea_url <- paste("https://covid19can-data.firebaseio.com/saludcantabria/municipios/",
                                municip_index,
                                "/fallecidos.json",
                                sep = "")
  munic_dailydecea_url <- URLencode(munic_dailydecea_url)
  munic_dailydecea_json <- fromJSON(munic_dailydecea_url)
  munic_dailydecea_df <- as.data.frame(cbind(as.character(munic_dailydecea_json$dimension$Fecha$category$label),
                                             as.character(munic_dailydecea_json$value)))
  munic_dailydecea_df$date <- sort(as.Date(munic_dailydecea_df[,1], format = "%d-%m-%Y"))  
  
  
  # incidence 14d
  munic_incidence_url <- paste("https://covid19can-data.firebaseio.com/saludcantabria/municipios/",
                                municip_index,
                                "/incidencia14.json",
                                sep = "")
  munic_incidence_url <- URLencode(munic_incidence_url)
  munic_incidence_json <- fromJSON(munic_incidence_url)
  munic_incidence_df <- as.data.frame(cbind(as.character(munic_incidence_json$dimension$Fecha$category$label),
                                             as.character(munic_incidence_json$value)))
  munic_incidence_df$date <- sort(as.Date(munic_incidence_df[,1], format = "%d-%m-%Y"))  
  
  
  # merge datasets
  municip_data_df <- Reduce(function(x, y) merge(x, y, by = "date"),
                           list(munic_active_df[,-1],
                                munic_dailycases_df[,-1],
                                munic_dailydecea_df[,-1],
                                munic_incidence_df[,-1]))
  colnames(municip_data_df) <- c("date", #common column
                                "active", #munic_active_df dataset
                                "new_cases", #munic_dailycases_df dataset
                                "new_deceased", #munic_dailydecea_df dataset
                                "incidence_14d") #munic_incidence_df
  
  # convert to numeric some variables
  municip_data_df$active <- as.numeric(municip_data_df$active)
  municip_data_df$new_cases <- as.numeric(municip_data_df$new_cases)
  municip_data_df$new_deceased <- as.numeric(municip_data_df$new_deceased)
  municip_data_df$incidence_14d <- as.numeric(municip_data_df$incidence_14d)
  # add municipality name
  municip_data_df$municip <- municip_index
  # bind data
  cantabr_data_df <- rbind(cantabr_data_df,
                            municip_data_df)
  
}


cantabr_data_df <- merge(x = cantabr_data_df, y = municip_nombres,
                          by.x = "municip", by.y = "compuesto",
                          all.x = FALSE, all.y = FALSE)

# categorise
cantabr_data_df$semaforo <- NA
cantabr_data_df$semaforo[cantabr_data_df$incidence_14d <=25] <- "Nueva normalidad"
cantabr_data_df$semaforo[cantabr_data_df$incidence_14d > 25 & cantabr_data_df$incidence_14d <=50] <- "Bajo"
cantabr_data_df$semaforo[cantabr_data_df$incidence_14d > 50 & cantabr_data_df$incidence_14d <=150] <- "Medio"
cantabr_data_df$semaforo[cantabr_data_df$incidence_14d > 150 & cantabr_data_df$incidence_14d <=250] <- "Alto"
cantabr_data_df$semaforo[cantabr_data_df$incidence_14d > 250] <- "Extremo"

write.csv2(cantabr_data_df, "data/municip_incidenc_evolut.csv")


# GRAFICOS TODOS LOS MUNICIPIOS SERIE TEMPORAL
library(ggplot2)
library(plyr)
fecha_dia_plot <- unique(cantabr_data_df$date)[length(unique(cantabr_data_df$date))]

# INCIDENCIA
ggplot(cantabr_data_df,
       aes(date, incidence_14d)) +
  geom_point(aes(colour = incidence_14d)) +
  scale_colour_gradientn(limits = c(0, 1250),
                         breaks = c(0, 250, 500, 1250),
                         colours = c("#bdbdbd", "#feb24c", "#de2d26", "#a50f15")) +
  coord_cartesian(xlim=c(cantabr_data_df$date[length(cantabr_data_df$date)]-60,cantabr_data_df$date[length(cantabr_data_df$date)]+1),
                  ylim = c(0,1200)) + 
  geom_hline(yintercept=500, alpha=.75, size=0.25, colour="#de2d26") +
  geom_hline(yintercept=250, alpha=.75, size=0.25, colour="#feb24c") +
  labs(title = paste("CASOS COVID19 (", fecha_dia_plot, ")", sep=""),
       subtitle = "(Incidencia acumulada a 14 días por cada 100.000 habitantes.)",
       caption = "Datos: ICANE. Gob. Cantabria. Elaboración: @covidcantabria",
       x = "Fecha",
       y = "Incidencia",
       colour = "Incidencia") +
  facet_wrap( ~ nombre_mun, ncol=6) + 
  theme(legend.position = "none")

ggsave("images/municip_incidenc_evolut.png",
       width = 30, height = 90, units = "cm")


# INCIDENCIA EN BOLOS
ggplot(cantabr_data_df,
       aes(x = date, reorder(nombre_mun, desc(nombre_mun)))) +
  geom_point(aes(colour = semaforo)) +
  scale_colour_manual(
    values = c("#31a354", "#fed976", "#feb24c", "#de2d26", "#a50f15"),
    breaks = c("Nueva normalidad", "Bajo", "Medio", "Alto", "Extremo"),
    labels = c("Nueva normalidad (menos de 25 casos)",
               "Bajo (entre 25 y 50 casos)",
               "Medio (entre 50 y 150 casos)",
               "Alto (entre 150 y 250 casos)",
               "Extremo (más de 250 casos)")) +
  coord_cartesian(xlim=c(cantabr_data_df$date[length(cantabr_data_df$date)]-60,cantabr_data_df$date[length(cantabr_data_df$date)]+1)) +
  labs(title = paste("CASOS COVID19 (", fecha_dia_plot, ")", sep=""),
       subtitle = "(Incidencia acumulada a 14 días por cada 100.000 habitantes.)",
       caption = "Datos: ICANE. Gob. Cantabria. Elaboración: @covidcantabria",
       x = "Fecha",
       y = "Municipio", 
       colour = "Nivel de riesgo") +
  guides(colour=guide_legend(nrow=5, byrow=TRUE)) +
  theme(legend.position = "bottom")

ggsave("images/municip_casos_bolos_evolut.png",
       width = 15, height = 45, units = "cm")
  

