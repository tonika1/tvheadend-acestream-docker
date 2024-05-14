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
donde numero es el numero de contenedor, en este caso, podria ser 1, 2, 3, 4, 5 o 6

O a través de la interfaz web: `http://localhost:[puerto]/webui/api/service?method=get_version`
donde puerto es el puerto que usa cada contenedor, en este caso, podría ser 6878, 6879, 6880, 6881, 6882 o 6883
