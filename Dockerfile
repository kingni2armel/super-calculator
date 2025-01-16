FROM golang:1.19-buster AS build

WORKDIR /app

COPY go.mod ./
COPY go.sum ./
RUN go mod download

COPY . .

RUN go build -o /calculator

RUN apt-get install -y curl=7.68.0-1ubuntu2.6 \
    curl \
    && curl -sSL https://github.com/hadolint/hadolint/releases/download/v2.8.0/hadolint-Linux-x86_64 -o /usr/local/bin/hadolint \
    && chmod +x /usr/local/bin/hadolint
FROM gcr.io/distroless/base-debian10

WORKDIR /

COPY --from=build /calculator /calculator

USER nonroot:nonroot

ENTRYPOINT ["/calculator"]
