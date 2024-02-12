FROM node:18-bullseye-slim AS builder

# Specify the version of Litestream CLI
ENV LITESTREAM_VERSION=v0.3.13

# Install utilities
RUN apt-get update --fix-missing && apt-get install -y python build-essential && apt-get clean

# Install Litestream CLI
ADD https://github.com/benbjohnson/litestream/releases/download/$LITESTREAM_VERSION/litestream-$LITESTREAM_VERSION-linux-amd64.tar.gz /tmp/litestream.tar.gz
RUN tar -C /usr/local/bin -xzf /tmp/litestream.tar.gz

FROM node:18-bullseye-slim AS runner
WORKDIR /usr/src/lhci

# Install certificates
RUN apt-get update && apt-get install -y ca-certificates

# Copy Litestream CLI
COPY --from=builder /usr/local/bin/litestream /usr/local/bin/litestream

# Copy litestream configuration file and execution script
COPY litestream.yml /etc/litestream.yml
COPY run.sh ./

# Set up lhci server
COPY package.json .
COPY lighthouserc.json .
RUN npm install

EXPOSE 9001
CMD ["/bin/sh", "run.sh"]