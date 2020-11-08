---
layout: default
title: Tecnología
description: Cómo funciona @covidcantabria
---

## La tecnología detrás de @covidcantabria

Sirva esta sección para intentar destripar un poco la máquina que hace funcionar @covidcantabria. Decía por ahí en algún lado que para mí ha sido fundamental el poder buscar y replicar ejemplos de otras tantas personas que comparten sus códigos y sabiduría. Espero que esto le pueda servir igualmente a alguien.

### Lenguaje

Volvamos al inicio de todo. No soy programador. Pero programo. Utilizo [`R`](https://cran.r-project.org/doc/contrib/rdebuts_es.pdf) porque es lo que en los últimos años he aprendido a usar y lo que me saca las castañas del fuego siempre que lo necesito. ¿Se podría haber hecho con otro lenguaje? Estoy seguro. ¿Se podría hacer de una forma más fina y elegante? Sin lugar a dudas. ¿Funciona así tal y como está ahora mismo? Pues también.

Para programar con `R` uso [RStudio](https://rstudio.com/).

### Web scrapping

Los datos que utiliza @covidcantabria provienen de la web específica del [ICANE-COVID19](https://www.icane.es/covid19/dashboard/home/home). Es un panel interactivo (que internamente no sé cómo funciona) pero que muestra una serie de gráficas y datos.

En teoría (y en la práctica, no vamos a negarlo) permite descargar los datos con los que se genera cada una de las gráficas en formato `CSV`. Sin embargo, al menos hasta donde yo llego, no existe una url que apunte a ese archivo. Así que me puse a investigar.

Con la función "Desarrollador web -> Red" del Firefox pude comprobar que los datos estaban en distintos archivos `JSON` alojados bajo urls del tipo `https://covid19can-data.firebaseio.com/saludcantabria/municipios/39087%20-%20TORRELAVEGA/tasa.json`. Con lo cual, para acceder a los datos, lo único que hay que hacer es leer esos datos desde `R`.

Al lío.

```r
library(RCurl)
library(jsonlite)

# define access url
region_daily_url <- "https://covid19can-data.firebaseio.com/saludcantabria/daily-cases.json"
# ensure correct encoding
region_daily_url <- URLencode(region_daily_url)
# read data from JSON
region_daily_json <- fromJSON(region_daily_url)
# transform data into dataframe
region_daily_df <- as.data.frame(cbind(as.character(region_daily_json$dimension$Fecha$category$label),
                                       as.character(region_daily_json$value)))
```                                       

Hay diferentes accesos a direcciones `JSON` que apuntan a múltiples gráficas y que bajan un montón de datos. Algunas de las gráficas contienen distintas variables, y hay que ajustar ligeramente los datos para que se ordenen y emparejen correctamente con las variables.

```r
# define access url
region_hosp_url <- "https://covid19can-data.firebaseio.com/saludcantabria/hospitalizations.json"
# ensure correct encoding
region_hosp_url <- URLencode(region_hosp_url)
# read data from JSON
region_hosp_json <- fromJSON(region_hosp_url)

# transform data into dataframe
# split into different variables (5)
region_hosp_values <- as.data.frame(split(region_hosp_json$value, ceiling(seq_along(region_hosp_json$value)/5)))
# transpose rows into columns
region_hosp_values <- as.data.frame(t(region_hosp_values))
# final dataframe
region_hosp_df <- as.data.frame(cbind(as.character(region_hosp_json$dimension$Fecha$category$label),
                                      region_hosp_values))
# create new variable
region_hosp_df$total <- region_hosp_df$V1+region_hosp_df$V2+region_hosp_df$V3+region_hosp_df$V4+region_hosp_df$V5
```

### Data wrangling

Aunque los datos que se pueden obtener del [ICANE-COVID19](https://www.icane.es/covid19/dashboard/home/home) son abundantes y muy completos, hay algunas variables que no están computadas: por ejemplo número de casos activos, incidencia a 14 días o positividad de las pruebas realizadas.

```r
# active cases
region_datos_df$active <- region_datos_df$total_cases - region_datos_df$total_deceased - region_datos_df$total_recovered

# daily new tests
region_datos_df$new_antic <- region_datos_df$total_antic - c(0, region_datos_df$total_antic[-length(region_datos_df$total_antic)])
region_datos_df$new_pcr <- region_datos_df$total_pcr - c(0, region_datos_df$total_pcr[-length(region_datos_df$total_pcr)])

# positiv. rate
region_datos_df$positiv_rate_pcr <- region_datos_df$new_cases / region_datos_df$new_pcr

# incidence
serie_incid <- rep(0,14)
for (fecha_index in c(15:dim(region_datos_df)[1])){
  day_incid <- sum(region_datos_df$new_cases[(fecha_index-13):(fecha_index)])/(cant_popul/100000)
  serie_incid <- c(serie_incid, day_incid)
}
region_datos_df$incid_14d <- serie_incid

# average positiv. rate
serie_tasa_pcr_7d <- rep(0,7)
for (fecha_index in c(8:dim(region_datos_df)[1])){
  day_incid <- mean(region_datos_df$positiv_rate_pcr[(fecha_index-6):(fecha_index)], na.rm = TRUE)
  serie_tasa_pcr_7d <- c(serie_tasa_pcr_7d, day_incid)
}
region_datos_df$tasa_pcr_7d <- serie_tasa_pcr_7d*100
```

### Ploteo

El paquete `ggplot2` es, en mi opinión, una de las grandes maravillas de `R`. La calidad de los gráficos que se obtienen, así como las infinitas opciones que ofrece para mí lo están transformando poco a poco en imprescindible.

Todas las gráficas de @covidcantabria se realizan con `ggplot`.

```r
library(ggplot2)
require(gridExtra)
# set working date
fecha_dia_plot <- unique(region_datos_df$date)[length(unique(region_datos_df$date))]

# incidence
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
       colour = "Incidencia",
       caption = "Datos: ICANE. Gob. Cantabria. Elaboración: Saúl Torres-Ortega."") + 
  theme(legend.position = "none")
```

Se crea un conjunto de gráficas individuales para cada una de las variables que posteriormente se combinan en una sola (que es por ejemplo la que se publica en la web).

```r
# create unique graph
p_combine <- grid.arrange(p_incid, p_active, p_dailyd, p_test, p_pcr,  
                          ncol = 1, heights = c(1.1, 1, 1, 1.2, 1))

# save plot
ggsave("images/regional_summary.png", p_combine,
       width = 30, height = 40, units = "cm")
```

### Telegram bot

No es la primera vez que trabajo con un bot de [Telegram](). Y desde el principio me sorprendió lo relativamente fácil que es implementarlo en `R`. En ocasiones anteriores lo utilizaba para monitorizar ejecuciones que podían estar múltiples días. El bot nos avisaba (a mis compañeros, a mí y también al jefe) del proceso y mostraba incluso resultados preliminares.

Para ponerlo en marcha, [este tutorial](https://ebeneditos.github.io/telegram.bot/) lo explica estupendamente. Aunque en realidad, ahí se va mucho más allá. @covidcantabria no es en realidad un bot capaz de interpretar mensajes y responder, sino simplemente es un canal de Telegram en el que se lanzan mensajes.

Así que realmente lo que he realizado es lo siguiente:
- [x] Crear el bot. Guardar a buen recaudo el token correspondiente.
- [x] Crear un canal de difusión en Telegram.
- [x] Añadir como administrador a nuestro bot.
- [x] Obtener el `channel_id`.
- [x] Utilizar nuestro bot para lanzar mensajes al `channel_id`.

El único punto "peliagudo" es obtener nuestro `channel_id`. Aún a expensas de que haya formas mucho más sencillas, a mí esta me ha funcionado.

```r
library(telegram.bot)
# Initialize bot
bot <- Bot(token = "token")

# Get bot info
print(bot$getMe())

# Get updates
updates <- bot$getUpdates()

# Retrieve your chat id
# Note: you should text the bot before calling 'getUpdates'
chat_id <- updates[[7L]]$from_chat_id()
```

Una vez que tenemos tanto el `token` de nuestro bot como el `channel_id`, el resto es pan comido.

Para enviar los mensajes, y limpiar un poco el código, creo los mensajes como una cadena de texto previa.

```r
# Intro message
message_intro <- paste("\U0001F4E2 \U0001F4C5 Esta es la actualización de los datos correspondiente al ", fecha_dia_plot, ".", sep = "")

library(telegram.bot)

# Initialize TELEGRAM bot
telegram_bot <- Bot(token = "token")
## Channel ID
channel_id <- "channel""

# Send message
telegram_bot$sendMessage(chat_id = channel_id, text = message_intro)

# Send message with image
telegram_bot$sendPhoto(chat_id = channel_id, photo = "/images/regional_active.png")
```

### Twitter bot

Crear un bot de Twitter es relativamente sencillo también. Y de nuevo, en este caso, @covidcantabria no es un bot al uso que responde a mensajes y demás, sino que simplemente los difunde. Así que la cosa se vuelve a simplificar mucho.

En este caso, todos los parámetros nos los proporciona la propia web de Twitter, por lo que sin más, los metemos en nuestro código y lanzamos mensajes. Como tenemos la opción, creamos nuestros mensajes en forma de hilo respondiendo siempre al mensaje inmediatamente anterior.

```r
library(rtweet)
# Initialize TWITTER bot
## store api keys
api_key <- "api_key"
api_secret_key <- "api_secret_key"
access_token <- "access_token"
access_token_secret <- "access_token_secret"

## authenticate via web browser
token <- create_token(
  app = "covidcantabria",
  consumer_key = api_key,
  consumer_secret = api_secret_key,
  access_token = access_token,
  access_secret = access_token_secret)

# Send intro message
post_tweet(status = message_intro)

# Send message_info_1
## lookup status_id
my_timeline <- get_timeline(rtweet:::home_user())
## ID for reply
reply_id <- my_timeline$status_id[1]
## post reply
post_tweet(status = message_info_1,
           media = "/home/rstudio/covid_cantabria/images/regional_active.png",
           in_reply_to_status_id = reply_id)
```


### AWS server