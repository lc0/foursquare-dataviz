DOCKER_REPO=sergii/foursquare-dataviz
TAG=latest


build:
	docker build -t ${DOCKER_REPO}:${TAG} .


run:
	docker run -i -t -p 80:80 \
		-e FOURSQUARE_TOKEN=${FOURSQUARE_TOKEN} ${DOCKER_REPO}

push:
	docker push ${DOCKER_REPO}:${TAG}

.PHONY: build run push