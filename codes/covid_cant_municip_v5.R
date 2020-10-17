
library(readr)
library(RCurl)
library(jsonlite)

#setwd("E:/Onedrive/OneDrive - Universidad de Cantabria/07 - R Code/covid_cantabria/")
setwd("C:/Users/Saul/OneDrive - Universidad de Cantabria/07 - R Code/covid_cantabria/")


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

write.csv2(cantabr_datos_df, "data/municip_incidenc_evolut.csv")


# GRAFICOS TODOS LOS MUNICIPIOS SERIE TEMPORAL
library(ggplot2)
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

ggsave("images/municip_incidenc_evolut.jpg",
       width = 30, height = 90, units = "cm")