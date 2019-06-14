version=1.2.4

.PHONY: all

all: build run

mvn-package:
	cd .. && mvn -T8C -DskipTests package && cd -

build: mvn-package
	docker build --build-arg RHEAKV_VERSION=${version} -t rheakv .

build-only:
	docker build --build-arg RHEAKV_VERSION=${version} -t rheakv .
run:
	docker run -p 18181:18181 --user 1000:1000 --name=rheakv-container --rm -t rheakv:latest

# force-stop, just in case; container auto remove when stopped
stop:
	docker stop -t 1 rheakv-container
	docker rm rheakv-container
	docker stop -t 1 `docker ps -q --filter="ancestor=rheakv:latest"`
bash:
	docker run -it rheakv:latest bash
attach:
	docker exec -it --user 1000:1000 rheakv-container bash
clean:
	cd .. && mvn clean && cd -
