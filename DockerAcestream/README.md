# Dockerized Acestream

This project deploys Acestream within a Docker container using Ubuntu 22.04 and Python 3.10 for compatibility.

Acestream is a platform for live streaming via peer-to-peer networks. Dockerizing Acestream simplifies its setup and
provides isolated environments.

## Prerequisites

1. **Docker Installation**: Ensure Docker Desktop is installed on your system.
   - [Docker Products Page](https://www.docker.com/products/docker-desktop)
   - [Official Documentation](https://docs.docker.com/get-docker/)

## Building the Image

This project uses the **ubuntu:22.04** base image. You must clone the project first.
Then, to build the image use:

```bash
docker build --no-cache -t docker-acestream .
```

## Running the Container

To start a container and run Acestream:

```bash
docker run --name docker-acestream -d -p 6878:6878 --restart unless-stopped docker-acestream
```

## Docker Compose

1. **Start the Container**: Use `docker-compose` to start the container:

   ```bash
   docker-compose up -d
   ```

2. **Update the Image**: To get the latest image version:

   ```bash
   docker-compose pull && docker-compose up -d
   ```

## Verifying Container Health

Check the health status:

```bash
docker inspect --format='{{json .State.Health}}' docker-acestream
```

Or via the web interface: `http://localhost:6878/webui/api/service?method=get_version`.

## Contributions

We welcome contributions. Fork, make changes, and submit a pull request for review.

## License

This project is under the MIT License. See [LICENSE](LICENSE) for more details.
