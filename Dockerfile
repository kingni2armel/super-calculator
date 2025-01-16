# Use an explicit version tag for the Golang base image
FROM golang:1.19-buster AS build

WORKDIR /app

# Use COPY instead of ADD
COPY go.mod ./
COPY go.sum ./
RUN go mod download

# Copy the source code
COPY . .

# Build the Go application
RUN go build -o /calculator

# Install curl with pinned version and avoid additional packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl=7.68.0-1ubuntu2.6 \
    && curl -sSL https://github.com/hadolint/hadolint/releases/download/v2.8.0/hadolint-Linux-x86_64 -o /usr/local/bin/hadolint \
    && chmod +x /usr/local/bin/hadolint \
    && rm -rf /var/lib/apt/lists/*  # Clean up to reduce image size

# Use a distroless base image, and specify the version
FROM gcr.io/distroless/base-debian10:latest

WORKDIR /

# Copy the compiled Go binary from the build stage
COPY --from=build /calculator /calculator

# Switch to a non-root user
USER nonroot:nonroot

# Set the entry point to the compiled Go binary
ENTRYPOINT ["/calculator"]
