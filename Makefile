DOCKER_REPO=lc0/foursquare-dataviz
TAG=latest


build:
	docker build -t ${DOCKER_REPO}:${TAG} .


run:
	docker run -i -t -p 80:80 ${DOCKER_REPO}

push:
	docker push ${DOCKER_REPO}:${TAG}

.PHONY: build run push