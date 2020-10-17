---
title: COVID Cantabria
layout: default
filename: index.md
--- 
## RESUMEN DE LA SITUACIÓN ACTUAL EN CANTABRIA
![Resumen](https://raw.githubusercontent.com/saul-torres/covid_cantabria/master/images/regional_evolucion.jpg)

Este sitio web pretende ser un complemento (y no un sustituto) a la información recopilada por el Servicio Cántabro de Salud (SCS) en su web dedicada al [COVID19](https://www.scsalud.es/web/scs/coronavirus), así como la recopilada por el Instituto Cántabro de Estadística (ICANE) en su web [COVID19](https://www.icane.es/covid19/dashboard/home/home). Los datos que aquí se representan provienen principalmente de este último, aunque por cuestiones prácticas y de accesibilidad pueden estar tomados de otros repositorios que recopilan los datos oficiales y los transforman para hacer más accesibles.
### Fuentes de los datos
* Las series de datos están obtenidas de la web específica COVID19 del [Instituto Cántabro de Estadística  - ICANE](https://www.icane.es/covid19/dashboard/home/home).
* Los datos de población (a 1 de enero de 2020) están obtenidos del [Instituto Cántabro de Estadística  - ICANE](https://www.icane.es/data/municipal-register-gender-municipality#timeseries).
* Las áreas de salud se han obtenido del [Servicio Cántabro de Salud](http://saludcantabria.es/index.php/areas-y-zonas-basicas-de-salud).
* Otros repositorios accesibles:
  * [escovid19data](https://github.com/montera34/escovid19data)
  * [Datadista](https://github.com/datadista/datasets/tree/master/COVID%2019)


# REPRESENTACIÓN DE DATOS A NIVEL MUNICIPAL

### Tasa bruta del número de casos activos por cada 100.000 habitantes 

![Evolución de la tasa](https://raw.githubusercontent.com/saul-torres/covid_cantabria/master/images/municip_incidenc_evolut.jpg)


# Notas metodológicas
* Los datos del SCS generalmente atribuyen un número de casos a `39300 Otros`. Este dato en principio no se representa.
* En los mapas pueden aparecer algunos municipios en color gris. En estos municipios el dato representado se escapa del intervalo elegido para la representación de los datos. Se ha elegido esta escala para poder apreciar diferencias entre municipios. Ajustar a los *outliers* implicaría no poder apreciar a simple vista diferencias entre municipios.
* En las gráficas de evolución pasa algo similar: algunos municipios no muestran datos en la gráfica correspondiente. Estos datos se escapan del intervalo elegido para la representación.
* En los mapas aparece un hueco sin ningón tipo de representación. Se trata de la Mancomunidad de Campoo-Cabuérniga, que es un territorio *sui géneris*: es una unidad administrativa sin población que es gestionada de forma mancomunada por cuatro municipios diferentes: Hermandad de Campoo de Suso, Cabuérniga, Los Tojos y Ruente [(más info)](https://es.wikipedia.org/wiki/Mancomunidad_de_Campoo-Cabu%C3%A9rniga).
* Han aparecido ya algunos mapas con información detallada a escala municipal para todo el territorio nacional: por ejemplo este de El Mundo [(link)](https://www.elmundo.es/ciencia-y-salud/salud/2020/05/04/5eafdf41fdddffcc678b45bd.html).
* Los datos utilizados son obtenidos de la fuente anteriormente señalada y combinados en un único archivo que puede encontrarse en la carpeta `data` del [repositorio](https://github.com/saul-torres/covid_cantabria).
* El código de `R` utilizado se puede encontrar en la carpeta `codes` del [repositorio](https://github.com/saul-torres/covid_cantabria). No soy un experto programador: me considero más bien un aficionado. No esperen un código pulcro y lujoso, sino más bien uno funcional.

### Disclaimer
Esta web y análisis están realizados con fines docentes y de investigación. No deben tomarse los datos para fines de otro tipo que no sean los anteriores.
