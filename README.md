# tvheadend-acestream-docker
Conexión Docker TVHeadend y Docker acestream

Tenemos que tener en cuenta que un usuario sólo puede ver en un enlace acestream en un momento dado, es decir, a un servidor acestream no le puedes enviar dos o mas enlaces para verlos ya que sólo se visualizará el último que envies.

Para poder grabar diferentes emisiones o para tener dos clientes visualizando dos o mas emisiones diferentes (canal A y canal B) simultanieamente necesitamos varios servidores acestream, tantos como emisiones simultaneas queramos tener. Para ello, vamos a utilizar tantos dockers de acestream como "sintonizadores" queramos tener. En mi caso usaré 6 dockers acestream, que cada uno use los que crea convenientes.


## Ejecutar los Contenedores acestream

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


## Ejecutar el contenedor tvheadend

Para iniciar el contenedor tvheadend:

```bash
docker run -d   --name=tvheadend   -e PUID=1000   -e PGID=1000   -e TZ=Europe/Madrid  -p 9981:9981   -p 9982:9982 -v /home/user/tvheadend/data:/config   -v /home/user/tvheadend/grabaciones:/recordings   --restart unless-stopped   lscr.io/linuxserver/tvheadend:latest
```
Las opciones más destacadas son:
Directorio: /home/user/tvheadend/data es el directorio donde se guardará la configuración (debe existir)
Directorio: /home/user/tvheadend/grabaciones es el directorio donde se guardarán las grabaciones y el timneshift (debe existir)


## Ejecutar el contenedores tvheadend con la guia de Canales_dobleM

Si quieres instalar tvheadend con una guia xml de Canales_dobleM debes seguir los pasos de [Canales_dobleM](https://github.com/davidmuma/Canales_dobleM/blob/master/Varios/EPG/tvh_linux.md)  y enlazarla con tu contenedor de la siguiente forma:

```bash
docker run -d   --name=tvheadend   -e PUID=1000   -e PGID=1000   -e TZ=Europe/Madrid  -p 9981:9981   -p 9982:9982 -v /usr/bin/tv_grab_EPG_dobleM:/usr/bin/tv_grab_EPG_dobleM  -v /home/user/tvheadend/data:/config   -v /home/user/tvheadend/grabaciones:/recordings   --restart unless-stopped   lscr.io/linuxserver/tvheadend:latest
```
Donde:
Directorio: /home/user/tvheadend/data es el directorio donde se guardará la configuración (debe existir)
Directorio: /home/user/tvheadend/grabaciones es el directorio donde se guardarán las grabaciones y el timneshift (debe existir)
/usr/bin/tv_grab_EPG_dobleM es el script de la guia (debe existir y tener permisos de ejecución chmod +x /usr/bin/tv_grab_EPG_dobleM)


## Creamos el o los ficheros m3u con nuestros enlaces acestream para tvheadend

La primera fila siempre contiene #EXTM3U para identificar este archivo como una lista m3u de reproducción y opcionalmente se le puede añadir la guia que se va usar mediante url-tvg:

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

Por ejemplo, si tenemos nuestro servidor acestream en la ip 192.168.10.100 en el puerto 6878:

```bash
#EXTINF:-1 group-title="infantil" tvg-id="Canal infantil" tvg-name="Canal infantil",Canal infantil
pipe:///usr/bin/curl -s -L -N --output - http://192.168.10.100:6878/ace/getstream?id=e6f06d697f66a8fa606c4d61236c24b0d604dabc
#EXTINF:-1 group-title="SERIES" tvg-id="Canal de series" tvg-name="Canal de series",Canal de series
pipe:///usr/bin/curl -s -L -N --output - http://192.168.10.100:6878/ace/getstream?id=e6f06d697f66a8fa606c4d61236c24b0d604d000
```

```bash
#EXTINF:-1 group-title="grupo" tvg-id="Nombre del canal" tvg-name="Nombre del canal",Nombre del canal

Creamos tantos ficheros  m3u como contenedores acestream tengamos, en nuestro caso 6 ficheros enlacesace1.m3u, enlacesace2.m3u, enlacesace3.m3u, enlacesace4.m3u, enlacesace5.m3u y enlacesace6.m3u.
El primer fichero enlacesace1.m3u contendrá en sus pipes la url http://XXX.XXX.XX.XXX:6878/ace/getstre... el segundo fichero contendrá enlacesace2.m3u en sus pipes la url http://XXX.XXX.XX.XXX:6878/ace/getstre... y lo mismo para el resto de ficheros
```

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


## Configurar tvheadend

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

En Internal Grabber Settings yo he puesto que las guias se refresquen todos los dias a las 5:00, 9:00, 13:00, 17:00 y 21:00:

```bash
# A diario a las 5:00 | 9:00 | 13:00 |17:00 | 21:00
0 5 * * *
0 9 * * *
0 13 * * *
0 17 * * *
0 21 * * *
```

### Modificamos las opciones generales

![Captura de pantalla_2024-05-23_17-44-58](https://github.com/tonika1/tvheadend-acestream-docker/assets/36047512/7801e9f4-e152-4773-b702-7347d400adf4)

Desactivamos la opción "Prefer picons over channel icons"

### Creamos las IPTV Automatic Network

![Captura de pantalla_2024-05-23_18-18-45](https://github.com/tonika1/tvheadend-acestream-docker/assets/36047512/4dbfeddb-36a6-458c-946b-5465908e9ef9)

Debemos crear una por cada fichero m3u que hemos creado, los ficheros m3u deben estar alojados en un servidor web (puedes crearte un docker para el servidor web...completaré la guia con esto):

![Captura de pantalla_2024-05-23_18-29-51](https://github.com/tonika1/tvheadend-acestream-docker/assets/36047512/6db51b77-130b-44f2-b49f-bb500deb26a4)

Debemos repetir la misma acción para los otros 5 ficheros, por ejemplo, lo único que cambia para el segundo fichero sería:
Network name: netace2auto
URL: http://XXX.XXX.XX.XXX/enlacesace2.m3u
Provider network name: netace2

Desconozco si en vez de URL puedes poner una ruta absoluta y dejar los m3u en un directorio, es decir, en tvheadend poner que el fichero está en /config/enlacesace1.m3u (en vez de http://XXX.XXX.XX.XXX/enlacesace1.m3u), y en nuestro equipos dejar el fichero en  /home/user/tvheadend/data/enlacesace1.m3u

También tengo dudas con la opción "Idle scan muxes", yo por ahora la tengo desactivada.

### Modificamos los Bouquets

![Captura de pantalla_2024-05-23_18-38-40](https://github.com/tonika1/tvheadend-acestream-docker/assets/36047512/6ee8ea7a-9370-4eb9-8fd0-50af27ff9ace)

Debemos desactivar la opción "Auto-Map to channels:" y en la opción "Channel mapping options:" poner "Merge same name"

Hacemos los mismo con el Bouquet netace1auto, netace2auto, netace3auto, netace4auto, netace5auto y netace6auto

Creamos el Bouquet con name "Tvheadend Network" (creo que es importante ponerle este name) con las opciones que marca la imagen:

![Captura de pantalla_2024-05-23_18-42-56](https://github.com/tonika1/tvheadend-acestream-docker/assets/36047512/617df3b9-26ba-4a77-a281-2dbebaa7b807)

