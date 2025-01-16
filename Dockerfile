# Use a specific version for Golang image
FROM golang:1.19-buster AS build

WORKDIR /app

# COPY should be used instead of ADD for files and folders
COPY go.mod ./
COPY go.sum ./
RUN go mod download

COPY . .

RUN go build -o /calculator

# Install specific version of curl and use --no-install-recommends
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl=7.68.0-1ubuntu2.6 && \
    curl -sSL https://github.com/hadolint/hadolint/releases/download/v2.8.0/hadolint-Linux-x86_64 -o /usr/local/bin/hadolint && \
    chmod +x /usr/local/bin/hadolint

# Use a specific version for the distroless image
FROM gcr.io/distroless/base-debian10:latest

WORKDIR /

# Copy the built binary from the build stage
COPY --from=build /calculator /calculator

# Use non-root user
USER nonroot:nonroot

# Set the entry point for the container
ENTRYPOINT ["/calculator"]
