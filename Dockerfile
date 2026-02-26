ARG GO_VERSION=1.26
FROM golang:${GO_VERSION} AS builder
WORKDIR /app
COPY . .
RUN make

FROM ubuntu:22.04

RUN apt-get update -y &&\
    apt-get install net-tools -y &&\
    apt-get install ca-certificates -y &&\
    apt-get install iptables -y


WORKDIR /app

COPY --from=builder /app/iptables-server .

ENTRYPOINT ["/app/iptables-server"]
