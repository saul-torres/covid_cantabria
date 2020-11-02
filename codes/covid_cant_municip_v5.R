
library(readr)
library(RCurl)
library(jsonlite)

# Load municipalities names
municip_nombres <- read_delim("data/cant_municios_nombres.csv", 
                              ";", escape_double = FALSE, locale = locale(encoding = "ISO-8859-1"), 
                              trim_ws = TRUE)

# Empty data frame to save results
cantabr_datos_df <- data.frame(date = character(),
                               value = numeric(),
                               municipio = character(),
                               stringsAsFactors=FALSE)


for (municip_index in municip_nombres$compuesto){
  
  municip_datos_url <- paste("https://covid19can-data.firebaseio.com/saludcantabria/municipios/",
                             municip_index,
                             "/tasa.json",
                             sep = "")
  municip_datos_url <- URLencode(municip_datos_url)
  municip_datos_json <- fromJSON(municip_datos_url)
  municip_datos_df <- as.data.frame(cbind(as.character(municip_datos_json$dimension$Fecha$category$label),
                                          as.character(municip_datos_json$value)))
  municip_datos_df$municipio <- municip_index
  
  cantabr_datos_df <- rbind(cantabr_datos_df,
                            municip_datos_df)
  
}

colnames(cantabr_datos_df) <- c("fecha", "tasa_incid", "municip")

cantabr_datos_df <- merge(x = cantabr_datos_df, y = municip_nombres,
                          by.x = "municip", by.y = "compuesto",
                          all.x = FALSE, all.y = FALSE)

cantabr_datos_df$fecha <- as.Date(as.character(cantabr_datos_df$fecha), format = "%Y-%m-%d")
cantabr_datos_df$tasa_incid <- as.numeric(cantabr_datos_df$tasa_incid)

cantabr_datos_df$semaforo <- 0
cantabr_datos_df$semaforo[cantabr_datos_df$tasa_incid <=25] <- "Nueva normalidad"
cantabr_datos_df$semaforo[cantabr_datos_df$tasa_incid > 25 & cantabr_datos_df$tasa_incid <=50] <- "Bajo"
cantabr_datos_df$semaforo[cantabr_datos_df$tasa_incid > 50 & cantabr_datos_df$tasa_incid <=150] <- "Medio"
cantabr_datos_df$semaforo[cantabr_datos_df$tasa_incid > 150 & cantabr_datos_df$tasa_incid <=250] <- "Alto"
cantabr_datos_df$semaforo[cantabr_datos_df$tasa_incid > 250] <- "Extremo"

write.csv2(cantabr_datos_df, "data/municip_incidenc_evolut.csv")


# GRAFICOS TODOS LOS MUNICIPIOS SERIE TEMPORAL
library(ggplot2)
library(plyr)
fecha_dia_plot <- unique(cantabr_datos_df$fecha)[length(unique(cantabr_datos_df$fecha))]

# INCIDENCIA
ggplot(cantabr_datos_df,
       aes(fecha, tasa_incid)) +
  geom_point(aes(colour = tasa_incid)) +
  scale_colour_gradientn(limits = c(0, 1250),
                         breaks = c(0, 250, 500, 1250),
                         colours = c("#bdbdbd", "#feb24c", "#de2d26", "#a50f15")) +
  coord_cartesian(xlim=c(cantabr_datos_df$fecha[length(cantabr_datos_df$fecha)]-60,cantabr_datos_df$fecha[length(cantabr_datos_df$fecha)]+1),
                  ylim = c(0,1200)) + 
  geom_hline(yintercept=500, alpha=.75, size=0.25, colour="#de2d26") +
  geom_hline(yintercept=250, alpha=.75, size=0.25, colour="#feb24c") +
  labs(title = paste("INCIDENCIA COVID19 (", fecha_dia_plot, ")", sep=""),
       subtitle = "(Tasa bruta del número de casos activos por cada 100.000 habitantes.)",
       caption = "Datos: ICANE. Gob. Cantabria. Elaboración: Saúl Torres-Ortega.",
       x = "Fecha",
       y = "Incidencia",
       colour = "Incidencia") +
  facet_wrap( ~ nombre_mun, ncol=6) + 
  theme(legend.position = "none")

ggsave("images/municip_incidenc_evolut.png",
       width = 30, height = 90, units = "cm")


# INCIDENCIA EN BOLOS
y_lab_1 <- levels(cantabr_datos_df$nombre_mun)
y_lab_2 <- reorder(cantabr_datos_df$nombre_mun, desc(cantabr_datos_df$nombre_mun))

ggplot(cantabr_datos_df,
       aes(x = fecha, reorder(nombre_mun, desc(nombre_mun)))) +
  geom_point(aes(colour = semaforo)) +
  scale_colour_manual(
    values = c("#31a354", "#fed976", "#feb24c", "#de2d26", "#a50f15"),
    breaks = c("Nueva normalidad", "Bajo", "Medio", "Alto", "Extremo"),
    labels = c("Nueva normalidad (menos de 25 casos)",
               "Bajo (entre 25 y 50 casos)",
               "Medio (entre 50 y 150 casos)",
               "Alto (entre 150 y 250 casos)",
               "Extremo (más de 250 casos")) +
  coord_cartesian(xlim=c(cantabr_datos_df$fecha[length(cantabr_datos_df$fecha)]-60,cantabr_datos_df$fecha[length(cantabr_datos_df$fecha)]+1)) +
  labs(title = paste("CASOS COVID19 (", fecha_dia_plot, ")", sep=""),
       subtitle = "(Tasa bruta del número de casos activos
       por cada 100.000 habitantes.)",
       caption = "Datos: ICANE. Gob. Cantabria. Elaboración: Saúl Torres-Ortega.",
       x = "Fecha",
       y = "Municipio", 
       colour = "Nivel de riesgo") +
  guides(colour=guide_legend(nrow=5, byrow=TRUE)) +
  theme(legend.position = "bottom")

ggsave("images/municip_casos_bolos_evolut.png",
       width = 15, height = 45, units = "cm")
  

