DOCKER_IMAGE = riv

build:
	cargo build --release

lint:
	cargo clippy --release

test:
	cargo test --release

docker-clean:
	docker rmi $(DOCKER_IMAGE):latest -f || exit 0

docker:
	docker build -t $(DOCKER_IMAGE):latest --target builder .

docker-lint:
	docker build -t $(DOCKER_IMAGE):latest --target linter .

docker-test:
	docker build -t $(DOCKER_IMAGE):latest --target tests .