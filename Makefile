NS ?= andrey01
NAME ?= steam
VERSION ?= 0.1

default: build

build:
	docker build --pull -t $(NS)/$(NAME):$(VERSION) -t $(NS)/$(NAME):latest -f Dockerfile .

publish:
	docker push $(NS)/$(NAME):$(VERSION)
	docker push $(NS)/$(NAME):latest

check:
	docker run --rm -i $(NS)/$(NAME):$(VERSION) sh -c "set -x; exit 0"

console:
	docker run --rm -ti --entrypoint sh $(NS)/$(NAME):$(VERSION)

clean:
	docker rmi $(NS)/$(NAME):$(VERSION) $(NS)/$(NAME):latest
