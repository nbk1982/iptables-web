BIN_FILE=iptables-server
VERSION=1.1.4
GO_VERSION=$(shell awk '/^go / {print $$2}' go.mod)

SRCS=./

# git commit hash
COMMIT_HASH=$(shell git rev-parse --short HEAD || echo "GitNotFound")
# git tag
# VERSION_TAG=$(shell git describe --tags `git rev-list --tags --max-count=1`)

# Build date
BUILD_DATE=$(shell date '+%Y-%m-%d %H:%M:%S')

# Build flags
CFLAGS = -ldflags "-s -w -X \"main.BuildVersion=${COMMIT_HASH}\" -X \"main.BuildDate=$(BUILD_DATE)\""
# CFLAGS = -ldflags "-s -w -X \"main.BuildDate=$(BUILD_DATE)\""


# GOPROXY=https://goproxy.cn,direct

release:
	go build $(CFLAGS) -o $(BIN_FILE) $(SRCS)

run:
	go run main.go

images:
	docker build --build-arg GO_VERSION=$(GO_VERSION) -t nbk1982/iptables-web:$(VERSION) -t nbk1982/iptables-web:latest .
# 	docker push

clean:
	rm -f $(BIN_FILE)