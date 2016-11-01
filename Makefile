DOCKER_REPO=sergii/foursquare-dataviz
DOCKER_TAG=latest
DOCKER_NAME=foursquare-dataviz


build:
	docker build -t ${DOCKER_REPO}:${DOCKER_TAG} .


run:
	docker run -it --name ${DOCKER_NAME} -p 80:80 \
		-e FOURSQUARE_TOKEN=${FOURSQUARE_TOKEN} ${DOCKER_REPO}

push:
	docker push ${DOCKER_REPO}:${DOCKER_TAG}

restore:
	docker start -ai ${DOCKER_NAME}

.PHONY: build run push restore