# tvheadend-acestream-docker
Conexión Docker TVHeadend y Docker acestream

## Consideraciones previas

Aquí no vas a encontrar enlaces acestream, sólo como conectar contenedores acestream con tvheadend. Los enlaces acestream que aparecen en esta guía son enlaces inventados que no apuntan a ningún stream.

Tenemos que tener en cuenta que un usuario sólo puede ver en un enlace acestream en un momento dado, es decir, a un servidor acestream no le puedes enviar dos o más enlaces para verlos ya que sólo se visualizará el último que envíes.

Para poder grabar diferentes emisiones o para tener dos clientes visualizando dos o mas emisiones diferentes (canal A y canal B) simultáneamente necesitamos varios servidores acestream, tantos como emisiones simultaneas diferentes queramos tener. Para ello, vamos a utilizar tantos dockers de acestream como "sintonizadores" queramos tener. En mi caso usaré 6 dockers acestream, que cada uno use los que crea convenientes.

## Configurar los Contenedores acestream

Para iniciar el primer contenedor Acestream:

```bash
docker run --name docker-acestream1 -d -p 6878:6878 --restart unless-stopped tonika1/docker-acestream
```

Para iniciar el segundo contenedor Acestream:

```bash
docker run --name docker-acestream2 -d -p 6879:6878 --restart unless-stopped tonika1/docker-acestream
```

Para iniciar el tercer contenedor Acestream:

```bash
docker run --name docker-acestream3 -d -p 6880:6878 --restart unless-stopped tonika1/docker-acestream
```

Para iniciar el cuarto contenedor Acestream:

```bash
docker run --name docker-acestream4 -d -p 6881:6878 --restart unless-stopped tonika1/docker-acestream
```

Para iniciar el quinto contenedor Acestream:

```bash
docker run --name docker-acestream5 -d -p 6882:6878 --restart unless-stopped tonika1/docker-acestream
```

Para iniciar el sexto contenedor Acestream:

```bash
docker run --name docker-acestream6 -d -p 6883:6878 --restart unless-stopped tonika1/docker-acestream
```

Estos contenedores están hechos para procesadores amd64 pero puedes crear las imágenes tu mismo: https://github.com/tonika1/tvheadend-acestream-docker/tree/main/DockerAcestream


### Verificar la salud del contenedor acestream

Verifica el estado de salud de tu contenedor:

```bash
docker inspect --format='{{json .State.Health}}' docker-acestream[numero]
```
donde \[numero] es el numero de contenedor, en este caso, podria ser 1, 2, 3, 4, 5 o 6

O a través de la interfaz web: `http://localhost:[puerto]/webui/api/service?method=get_version`
donde \[puerto] es el puerto que usa cada contenedor, en este caso, podría ser 6878, 6879, 6880, 6881, 6882 o 6883


## Configurar el contenedor tvheadend

Para iniciar el contenedor tvheadend:

```bash
docker run -d   --name=tvheadend   -e PUID=1000   -e PGID=1000   -e TZ=Europe/Madrid  -p 9981:9981   -p 9982:9982 -v /home/user/tvheadend/data:/config   -v /home/user/tvheadend/grabaciones:/recordings   --restart unless-stopped   lscr.io/linuxserver/tvheadend:latest
```
Las opciones más destacadas son:
Directorio: /home/user/tvheadend/data es el directorio donde se guardará la configuración (debe existir)
Directorio: /home/user/tvheadend/grabaciones es el directorio donde se guardarán las grabaciones y el timneshift (debe existir)


## Configurar los contenedores tvheadend con la guia de Canales_dobleM

Si quieres instalar tvheadend con una guía xml de Canales_dobleM debes seguir los pasos de [Canales_dobleM](https://github.com/davidmuma/Canales_dobleM/blob/master/Varios/EPG/tvh_linux.md)  y enlazarla con tu contenedor de la siguiente forma:

```bash
docker run -d   --name=tvheadend   -e PUID=1000   -e PGID=1000   -e TZ=Europe/Madrid  -p 9981:9981   -p 9982:9982 -v /usr/bin/tv_grab_EPG_dobleM:/usr/bin/tv_grab_EPG_dobleM  -v /home/user/tvheadend/data:/config   -v /home/user/tvheadend/grabaciones:/recordings   --restart unless-stopped   lscr.io/linuxserver/tvheadend:latest
```
Donde:
Directorio: /home/user/tvheadend/data es el directorio donde se guardará la configuración (debe existir)
Directorio: /home/user/tvheadend/grabaciones es el directorio donde se guardarán las grabaciones y el timeshift (debe existir)
/usr/bin/tv_grab_EPG_dobleM es el script de la guía (debe existir y tener permisos de ejecución chmod +x /usr/bin/tv_grab_EPG_dobleM)


## Configurar del ficehro o los ficheros m3u con nuestros enlaces acestream para tvheadend

La primera fila siempre contiene #EXTM3U para identificar este archivo como una lista m3u de reproducción y opcionalmente se le puede añadir la guía que se va usar mediante url-tvg:

```bash
#EXTM3U url-tvg="https://raw.githubusercontent.com/davidmuma/EPG_dobleM/master/guiatv.xml"
```
Las filas restantes contienen dos filas distintas por canal, la primera: 
a) Comienza con #EXTINF que define las propiedades de un mux

```bash
#EXTINF:-1 group-title="grupo" tvg-id="Nombre del canal" tvg-name="Nombre del canal",Nombre del canal
```
Donde tvg-id="Nombre del canal" debe ser el nombre del canal de la guía, en mi caso, sería un canal de [EPG_DobleM](https://github.com/davidmuma/EPG_dobleM/blob/master/Varios/Canales_soportados.txt)

b) otro inmediatamente debajo de él que contiene la dirección del canal con la IP del servidor acestream (no puede ser 127.0.0.1) y el id del stream: 

```bash
pipe:///usr/bin/curl -s -L -N --output - http://XXX.XXX.XX.XXX:6879/ace/getstream?id=e6f06d697f66a8fa606c4d61236c24b0d604dabc
```

Por ejemplo, si tenemos nuestro servidor acestream en la ip 192.168.10.100 en el puerto 6878 tendríamos el siguiente fichero con 2 canales:

```bash
#EXTM3U url-tvg="https://raw.githubusercontent.com/davidmuma/EPG_dobleM/master/guiatv.xml"
#EXTINF:-1 group-title="infantil" tvg-id="Canal infantil" tvg-name="Canal infantil",Canal infantil
pipe:///usr/bin/curl -s -L -N --output - http://192.168.10.100:6878/ace/getstream?id=e6f06d697f66a8fa606c4d61236c24b0d604dabc
#EXTINF:-1 group-title="SERIES" tvg-id="Canal de series" tvg-name="Canal de series",Canal de series
pipe:///usr/bin/curl -s -L -N --output - http://192.168.10.100:6878/ace/getstream?id=e6f06d697f66a8fa606c4d61236c24b0d604d000
```

Creamos tantos ficheros  m3u como contenedores acestream tengamos, en nuestro caso 6 ficheros enlacesace1.m3u, enlacesace2.m3u, enlacesace3.m3u, enlacesace4.m3u, enlacesace5.m3u y enlacesace6.m3u.
El primer fichero enlacesace1.m3u contendrá en sus pipes la url http://XXX.XXX.XX.XXX:6878/ace/getstre... el segundo fichero contendrá enlacesace2.m3u en sus pipes la url http://XXX.XXX.XX.XXX:6878/ace/getstre... y lo mismo para el resto de ficheros


He probado varias opciones para que me coja los enlaces el servidor tvheadend, por si alguien cree que es mejor otra opción (la primera me parece que es mejor)

```bash
pipe:///usr/bin/curl -s -L -N --output - http://XXX.XXX.XX.XXX:6879/ace/getstream?id=e6f06d697f66a8fa606c4d61236c24b0d604dabc
```

```bash
pipe:///usr/bin/curl -s -L -N --output - http://XXX.XXX.XX.XXX:6879/ace/getstream?id=e6f06d697f66a8fa606c4d61236c24b0d604dabc pipe:1
```

```bash
pipe:///usr/bin/ffmpeg -loglevel fatal -fflags +genpts -i http://XXX.XXX.XX.XXX:6879/ace/getstream?id=e6f06d697f66a8fa606c4d61236c24b0d604dabc -vcodec copy -acodec copy -metadata service_provider=e6f06d697f66a8fa606c4d61236c24b0d604dabcv1 -metadata service_name=e6f06d697f66a8fa606c4d61236c24b0d604dabcENTRANCEv1 -f mpegts -tune zerolatency pipe:1
```
## Configurar un servidor web para dejar nuestros ficheros m3u

Vamos a alojar nuestros ficheros m3u en un servidor web

```bash
docker run --name some-nginx -d -p 8085:80 -v /home/user/servidorweb:/usr/share/nginx/html --restart unless-stopped nginx
```

Las opciones más destacadas son:
Directorio: /home/user/servidorweb este directorio debe existir y en el copiaras los ficheros acestreamr1.m3u, acestreamr2.m3u, acestreamr3.m3u, etc

Puedes probar que funciona abriendo un navegador y poniendo http://XXX.XXX.XX.XXX:8085/acestreamr1.m3u

## Configurar la aplicación tvheadend

### Creamos un usuario administrador:

![Captura de pantalla_2024-05-23_17-27-40](https://github.com/tonika1/tvheadend-acestream-docker/assets/36047512/d1e1cc50-39ff-41aa-a43c-9f3be0ca6b91)

Ponemos en Username el nombre de usuario que queramos.
En change parametres debes marcar todas las opciones.

### Creamos un usuario no administrador para usarlo luego con el kodi u otro media center:

![Captura de pantalla_2024-05-23_17-30-53](https://github.com/tonika1/tvheadend-acestream-docker/assets/36047512/ea7dd289-b5cf-4f6e-8fb0-84de677464f6)

Ponemos en Username el nombre de usuario que queramos.
En change parametres debes marcar todas las opciones.

### Ponemos contraseña a los dos usuarios que hemos creado

![Captura de pantalla_2024-05-23_17-35-26](https://github.com/tonika1/tvheadend-acestream-docker/assets/36047512/3cc8a307-1000-4099-abfb-7f89fdaeb44e)

Realizamos la misma acción para los dos usuarios


### Desactivamos el usuario por defecto

![Captura de pantalla_2024-05-23_17-32-48](https://github.com/tonika1/tvheadend-acestream-docker/assets/36047512/95503c40-2f72-4be6-ac7e-1a81923f976e)

Una vez desactivado hacemos logout y login.

### Deshabilitamos todos las EPGs modules excepto la de Canales_dobleM

![Captura de pantalla_2024-05-23_17-36-42](https://github.com/tonika1/tvheadend-acestream-docker/assets/36047512/bbaf4f67-ddd1-4b03-a842-39bba937ae7d)

### Modificamos el EPGs grabber

![Captura de pantalla_2024-05-23_17-39-35](https://github.com/tonika1/tvheadend-acestream-docker/assets/36047512/871da606-7f2c-4236-8df8-9ba2ae1f5fec)

En Internal Grabber Settings yo he puesto que las guías se refresquen todos los días a las 5:00, 9:00, 13:00, 17:00 y 21:00:

```bash
# A diario a las 5:00 | 9:00 | 13:00 |17:00 | 21:00
0 5 * * *
0 9 * * *
0 13 * * *
0 17 * * *
0 21 * * *
```
Guardamos y pulsamos sobre estas dos opciones:

![Captura de pantalla_2024-05-23_18-53-20](https://github.com/tonika1/tvheadend-acestream-docker/assets/36047512/e1607482-b33a-4a1a-91c4-9bb7964403bf)

### Modificamos el EPGs grabber Channels

Vamos a la esquina inferior derecha y seleccionamos "all":

![Captura de pantalla_2024-05-23_18-56-04](https://github.com/tonika1/tvheadend-acestream-docker/assets/36047512/b497ce61-c475-4141-a1d4-2e7debf32756)

Seleccionamos todas las lineas:

![Captura de pantalla_2024-05-23_18-57-10](https://github.com/tonika1/tvheadend-acestream-docker/assets/36047512/b6b9014d-323c-4154-b05f-0668720c5d99)


y pulsamos sobre edit y modificamos las opciones Once per auto channel y Channel update options:

![Captura de pantalla_2024-05-23_18-59-02](https://github.com/tonika1/tvheadend-acestream-docker/assets/36047512/bab2d49a-a20d-4daf-a0ff-2171c057d0dc)


### Modificamos las opciones generales

![Captura de pantalla_2024-05-23_17-44-58](https://github.com/tonika1/tvheadend-acestream-docker/assets/36047512/7801e9f4-e152-4773-b702-7347d400adf4)

Desactivamos la opción "Prefer picons over channel icons"

### Creamos las IPTV Automatic Network

![Captura de pantalla_2024-05-23_18-18-45](https://github.com/tonika1/tvheadend-acestream-docker/assets/36047512/4dbfeddb-36a6-458c-946b-5465908e9ef9)

Debemos crear una por cada fichero m3u que hemos creado, los ficheros m3u deben estar alojados en un servidor web, si has usado el docker de la guía 
debes poner la url http://XXX.XXX.XX.XXX:8085/enlacesace1.m3u

![Captura de pantalla_2024-05-23_18-29-51](https://github.com/tonika1/tvheadend-acestream-docker/assets/36047512/6db51b77-130b-44f2-b49f-bb500deb26a4)

Debemos repetir la misma acción para los otros 5 ficheros, por ejemplo, lo único que cambia para el segundo fichero sería:
Network name: netace2auto
URL: http://XXX.XXX.XX.XXX/enlacesace2.m3u o http://XXX.XXX.XX.XXX:8085/enlacesace2.m3u (si está en nuestro docker ngix)
Provider network name: netace2

Desconozco si en vez de URL puedes poner una ruta absoluta y dejar los m3u en un directorio, es decir, en tvheadend poner que el fichero está en /config/enlacesace2.m3u (en vez de http://XXX.XXX.XX.XXX:8085/enlacesace2.m3u), y en nuestro equipos dejar el fichero en  /home/user/tvheadend/data/enlacesace2.m3u

También tengo dudas con la opción "Idle scan muxes", yo por ahora la tengo desactivada.

### Modificamos los Bouquets

![Captura de pantalla_2024-05-23_18-38-40](https://github.com/tonika1/tvheadend-acestream-docker/assets/36047512/6ee8ea7a-9370-4eb9-8fd0-50af27ff9ace)

Debemos desactivar la opción "Auto-Map to channels:" y en la opción "Channel mapping options:" poner "Merge same name"

Hacemos los mismo con el Bouquet netace1auto, netace2auto, netace3auto, netace4auto, netace5auto y netace6auto

Creamos el Bouquet con name "Tvheadend Network" (creo que es importante ponerle este name) con las opciones que marca la imagen:

![Captura de pantalla_2024-05-23_18-42-56](https://github.com/tonika1/tvheadend-acestream-docker/assets/36047512/617df3b9-26ba-4a77-a281-2dbebaa7b807)

### Hacemos un force scan de las redes

Vamos a networks, las seleccionamos todas y hacemos un force scan, debería aparecer en muxes el número de canales que tenemos en nuestro fichero, en mi caso 76.

![Captura de pantalla_2024-05-23_18-46-27](https://github.com/tonika1/tvheadend-acestream-docker/assets/36047512/b6a3cbf7-002e-4c1b-9680-bab0758c208a)

### Comprobamos que se nos han agregado los canales 

Vamos a Channels y comprobamos que tenemos nuestros canales.

![Captura de pantalla_2024-05-23_19-02-55](https://github.com/tonika1/tvheadend-acestream-docker/assets/36047512/a44438bc-34d6-417b-a555-3d49a56acacc)

Los canales no deben estar repetidos, es decir, aunque tengamos 6 ficheros donde aparece canal A en cada uno de ellos (en cada fichero tendrá un puerto diferente), en Channels debe aparecer solo un canal A. Cuando conectemos al canal A, tvheadend elegirá un servidor acestream que no se esté usando en ese momento.

También es importante ver si nos ha mapeado el "User icon" con la guía, debería empezar por "https://raw.githubusercontent.com/davidmuma/picons_dobleM/master/icon/..."

### Comprobamos que en status no está escaneado

Nos vamos a status, esperamos 2 minutos en esta pantalla y deberá de estar vacía tal y como me aparece a mi.

![Captura de pantalla_2024-05-23_18-50-10](https://github.com/tonika1/tvheadend-acestream-docker/assets/36047512/a6ba7d34-cb4b-43f1-a142-38ad64ce428b)

Si te aparecen y desaparecen lineas es que esta haciendo un scanner de las muxes, en ese caso hay que seguir con la siguiente opción, en el caso de que no salga nada nos saltaremos el siguiente paso.

### Detener el scanner automatico (sólo si en el paso anterior te aprecian lineas)

Vamos a DVB Input -> Muxes 
 
Vamos a la esquina inferior derecha y seleccionamos "All" para que aparezcan todas las lineas.
 
![Captura de pantalla_2024-05-23_19-12-46](https://github.com/tonika1/tvheadend-acestream-docker/assets/36047512/659a6b59-a6ae-4a22-8c3c-9b6d45ebbc14)

Marcamos el check de "Scan status", lo ponemos a "IDLE" y pulsamos a "Save"

### Opciones interesantes de Recording

Asegurate que en "Storage path:" está puesto "/recordings/"

![Captura de pantalla_2024-05-23_19-14-00](https://github.com/tonika1/tvheadend-acestream-docker/assets/36047512/50e9e878-60e0-49a7-8e95-4d3759e4e333)

Activa el Timeshift si crees que los vas a usar.

Crea el directorio /home/user/tvheadend/data/timeshift en tu equipo

![Captura de pantalla_2024-05-23_19-18-36](https://github.com/tonika1/tvheadend-acestream-docker/assets/36047512/efd1f52e-e166-443e-90cf-944be3eca479)


He modificado la opción "Storage path:" a "/recordings/timeshift"




 
