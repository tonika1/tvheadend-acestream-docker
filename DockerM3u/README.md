# Guardar m3u de zeronet

Este proyecto guarda cada X tiempo un fichero m3u de zeronet 



## Requisitos Previos

1. **Instalación de Docker**: Asegúrate de que Docker Desktop esté instalado en tu sistema.
   - [Página de productos de Docker](https://www.docker.com/products/docker-desktop)
   - [Documentación Oficial](https://docs.docker.com/get-docker/)

2. Zeronet funcionando en un docker en una red con dns activados

## Construir la Imagen

Este proyecto usa la imagen base **pythonxxx**. Debes clonar el proyecto completo primero.
Después, para construir tu imagen utiliza:

```bash
docker build --no-cache -t docker-m3u .
```