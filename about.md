---
layout: default
title: Historia del proyecto
description: Quienes somos, a donde vamos, de donde venimos
---

## ¿Quiénes somos? ¿De dónde venimos? ¿A dónde vamos?

### Parte I. Introducción

Me llamo Saúl Torres-Ortega, soy profesor de Administración de Empresas en la Universidad de Cantabria e investigador del Instituto de Hidráulica Ambiental (IHCantabria). Por razones varias (unas laborales, otras más personales) he acabado trabajando con datos. Al igual que en otros ámbitos de nuestro alrededor, cada vez con más y más datos. Muchos datos. Demasiados datos. Cuando trabajas con muchos datos y tienes que comunicar a alguien te cae un marronazo del copón. Comunicar con datos (con muchos datos) es difícil. Con el tiempo, he aprendido (y sigo aprendiendo) cómo hacerlo. Y me gusta rebanarme los sesos pensando en cómo representar un conjunto de datos de la mejor forma posible. Eliminando el ruido. Destacando el mensaje.

Cuando en marzo de 2020 nos encontramos en plena crisis de la COVID19, los datos sobre la pandemia empezaron a aparecer por todos lados. Todos (yo el primero) buscábamos esos datos, los intentábamos entender, queríamos saber la situación en la que nos encontrábamos, etc. Queríamos saber. Y demasiadas veces los datos eran simplemente eso, datos, y otras muchas veces las posibles representaciones y explicaciones que encontrábamos de esos datos nos resultaban complejas, difíciles de entender. Y yo quería y necesitaba entender...

### Parte II. Los inicios

En Cantabria los datos nos empezaron a llegar a través del [Sistema Cántabro de Salud](https://www.scsalud.es) y su página web dedicada al [CORONAVIRUS](https://www.scsalud.es/web/scs/coronavirus). Las primeras visualizaciones en las que ver la evolución de la pandemia también estaban ahí. Número de casos diario, el acumulado...

Pero había mucho más dato, mucha más chicha. Por ejemplo, Cantabria fue una de las primeras comunidades autónomas (hasta donde yo me sé) que empezó a publicar los datos a nivel municipal. El [visor](https://experience.arcgis.com/experience/9fc123d100e540dda44529d5aff5fd67) del SCS lo sigue haciendo. Pero, ¿y la evolución municipal de las tasas?

Durante aquel tiempo del confinamiento nació esta web. Y empecé a analizar la evolución de la incidencia y del número de casos tanto para toda la región como para cada uno de los municipios de Cantabria.
<img src="https://raw.githubusercontent.com/saul-torres/covid_cantabria/main/images/municip_incidenc_evolut.png" width="250">

En aquella época (y así sigue siendo actualmente) el SCS publicaba diariamente los datos en formato CSV y Excel. Servidor se encargaba diariamente de acceder, descargar los datos, reejecutar las gráficas, subirlas a GitHub, y asegurarse que todo salía correcto. Un ligero engorro de 10-15 minutos al día que no me suponían mayor problema.

Hasta que la publicación de los datos (especialmente los municipales) dejó de ser diaria. Este hecho implicó que las series de datos empezaban a tener discontinuidades. Y las representaciones y análisis que hacía con ellos, empezaban a dar problemas. Como aquello no tenía visos de solución (el mismísimo Ministerio publica los datos sólo de lunes a viernes, porque total, el fin de semana es fin de semana) dejé de actualizar mis representaciones y mi web. La cerré. Y me dispuse a disfrutar del verano. Porque ya era verano.

### Parte III. Vuelta a empezar

En septiembre todo parecía indicar que volvíamos a la ola. Los casos volvían a subir. Todo parecía volver a complicarse. Todo iba a peor. Y los datos (y sus representaciones, y la comunicación en general) seguían siendo (en mi humilde opinión) mejorables.

Debo reconocer que algo habíamos mejorado. El Instituto Cántabro de Estadística (ICANE)[https://www.icane.es/] había creado su propia web para controlar la Situación epidemiológica del Coronavirus (COVID-19) en Cantabria ([ésta es su web](https://www.icane.es/covid19/dashboard/home/home)). Y reconozco igualmente que está muy bien. Tiene mucha información, bastantes representaciones, detalle a nivel municipal... Sin embargo, yo me había ya habituado a *mis* representaciones.

Me sorprendió que la web del ICANE mostraba sus representaciones a nivel municipal y diario. Sin saltos en las series. Todos los días (¡incluso los fines de semana). ¿Dónde estaban esos datos? ¿Por qué no estaban abiertos, publicados para utilizarlos? Bueno, aunque eso era un problema (datos públicos, abiertos y en formatos accesibles por favor) no era nada que no pudiéramos solucionar con un poco de [*web scrapping*](https://es.wikipedia.org/wiki/Web_scraping).

Tenía los datos, volvía a tener ganas... La página volvió a funcionar.

### Parte IV. Un paso más allá

Volví a mi ligero engorro de 10-15 minutos al día que no me suponían mayor problema. Pero sin embargo, en mi interior surgieron dos cuestiones:
1. ¿Puedo automatizar todo esto?
2. ¿Puedo hacer algo más que una web?

Respuesta a ambas cuestiones: sí.

Y llegamos a la situación actual de este pequeño proyecto que va creciendo por momentos:
* un servidor web dedicado, sobre el que corre un script diariamente que se encarga de recoger los datos, hacer las representaciones y lanzar los mensajes y actualizaciones pertinentes,
* y un canal de Telegram y una cuenta de Twitter en el que se van publicando esas actualizaciones.

### Parte V. ¿A dónde vamos?

Bueno... Quién sabe. Día tras día se me ocurren nuevas formas de mejorar todo esto. Nuevas gráficas, nuevos datos que analizar. Lo que sin duda tengo pendiente (y posiblemente sea ahora mismo mi prioridad) es describir bien todo el proceso que he seguido. Paso a paso. Y abierto. Porque igual que yo un día me lié la manta a la cabeza y empecé este pequeño proyecto, puede que alguien se anime y realice algo similar en algún otro lugar del mundo. O cualquier otra movida. Y al igual que yo me he nutrido del trabajo de muchos otros (bendito Google, bendita comunidad de `R`), otros pueden llegar a alimentarse del mío. Es lo mínimo.
