FROM rust:latest AS chef

WORKDIR /build

RUN cargo install cargo-chef && rustup component add clippy
RUN apt-get -y update
RUN apt-get -y install libgdal-dev gdal-bin

FROM chef AS planner

COPY . .

# By using cargo-chef, we can separate the layer that builds the
# dependencies from the layer that builds our actual crate.
# Since the dependencies rarely change, this saves us an
# enormous amount of time by caching the dependencies.
RUN cargo chef prepare --recipe-path recipe.json

#### Builder #################

FROM chef AS builder

COPY --from=planner /build/recipe.json recipe.json

# Builds the dependencies by reusing the recipe file from the previous image
RUN cargo chef cook --release --recipe-path recipe.json

COPY . .

RUN cargo build --release

#### Linter ##################

FROM builder AS linter

COPY . .

COPY --from=builder /build/target target

RUN cargo clippy --fix --release

#### Tests ###################

FROM builder AS tests

COPY . .

COPY --from=builder /build/target target

RUN cargo test --release