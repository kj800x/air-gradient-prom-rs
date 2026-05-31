# Build Stage
FROM rust:1.96 AS builder

WORKDIR /usr/src
RUN USER=root cargo new --vcs none air-gradient-prom-rs
WORKDIR /usr/src/air-gradient-prom-rs

# Pre-cache dependencies
COPY Cargo.toml Cargo.lock ./
RUN cargo build --release

# Copy actual source and rebuild
COPY src ./src
RUN touch src/main.rs && cargo build --release

# Runtime Stage
FROM debian:trixie-slim AS runtime
RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates libssl3 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/src/air-gradient-prom-rs/target/release/air-gradient-prom-rs /usr/local/bin/air-gradient-prom-rs

CMD ["air-gradient-prom-rs"]
