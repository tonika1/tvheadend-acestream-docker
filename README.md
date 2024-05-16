# tvheadend-acestream-docker
Conexión Docker TVHeadend y Docker acestream

Un usuario sólo puede ver en un enlace acestream en un momento dado, es decir, a un servidor acestream no le puedes enviar dos o mas enlaces para verlos ya que sólo se visualizará el último.
Para poder grabar diferentes emisiones o para tener dos clientes visualizando dos o mas emisiones simultanieamente necesitamos varios servidores acestream, tantos como emisiones sumultaneas queramos tener.

Vamos a utilizar tantos dockers de acestream como "sintonizadores" queramos tener. En mi caso usaré 6 dockers acestream.

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

## Verificar la Salud del Contenedor

Verifica el estado de salud:

```bash
docker inspect --format='{{json .State.Health}}' docker-acestream[numero]
```
donde \[numero] es el numero de contenedor, en este caso, podria ser 1, 2, 3, 4, 5 o 6

O a través de la interfaz web: `http://localhost:[puerto]/webui/api/service?method=get_version`
donde \[puerto] es el puerto que usa cada contenedor, en este caso, podría ser 6878, 6879, 6880, 6881, 6882 o 6883


## Ejecutar el contenedores tvheadend

Para iniciar el contenedor tvheadend:

```bash
docker run -d   --name=tvheadend   -e PUID=1000   -e PGID=1000   -e TZ=Europe/Madrid  -p 9981:9981   -p 9982:9982 -v /usr/bin/tv_grab_EPG_dobleM:/usr/bin/tv_grab_EPG_dobleM  -v /home/user/tvheadend/data:/config   -v /home/user/tvheadend/grabaciones:/recordings   --restart unless-stopped   lscr.io/linuxserver/tvheadend:latest
```

## Crear fichero m3u

La primera fila siempre contiene #EXTM3U para identificar este archivo como una lista m3u de reproducción y opcionalmente se le puede añadir la guia que se va usar mediante url-tvg:

```bash
#EXTM3U url-tvg="https://urlguia/guiaiptv.xml"
```
Las filas restantes contienen dos filas distintas por canal, la primera: 
a) Comienza con #EXTINF:que define las propiedades de un mux

```bash
#EXTINF:-1 group-title="grupo" tvg-id="Nombre del canal" tvg-name="Nombre del canal",Nombre del canal
```
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
```

Tres opciones (parece que es mejor la primera)

```bash
pipe:///usr/bin/curl -s -L -N --output - http://XXX.XXX.XX.XXX:6879/ace/getstream?id=e6f06d697f66a8fa606c4d61236c24b0d604dabc
```

```bash
pipe:///usr/bin/curl -s -L -N --output - http://XXX.XXX.XX.XXX:6879/ace/getstream?id=e6f06d697f66a8fa606c4d61236c24b0d604dabc pipe:1
```

```bash
pipe:///usr/bin/ffmpeg -loglevel fatal -fflags +genpts -i http://XXX.XXX.XX.XXX:6879/ace/getstream?id=e6f06d697f66a8fa606c4d61236c24b0d604dabc -vcodec copy -acodec copy -metadata service_provider=e6f06d697f66a8fa606c4d61236c24b0d604dabcv1 -metadata service_name=e6f06d697f66a8fa606c4d61236c24b0d604dabcENTRANCEv1 -f mpegts -tune zerolatency pipe:1
```
