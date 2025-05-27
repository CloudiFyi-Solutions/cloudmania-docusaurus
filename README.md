# Website

This website is built using [Docusaurus](https://docusaurus.io/), a modern static website generator.

### Installation

```
$ npm install
```

### Local Development

```
$ npm run start
```

This command starts a local development server and opens up a browser window. Most changes are reflected live without having to restart the server.


### Docker Build

```bash
# Build image
docker build --platform=linux/amd64 -t cloudmania/docusaurus-site:latest .

docker run --platform=linux/amd64 -d -p 8080:80 --name docusaurus-test cloudmania/docusaurus-site:latest


# Push to Docker Hub (or ACR, etc.)
docker push cloudmania/docusaurus-site:latest
```
