FROM --platform=$BUILDPLATFORM rust:slim-buster as builder

ARG TARGETPLATFORM
RUN case "$TARGETPLATFORM" in \
  "linux/amd64") echo -n x86_64-unknown-linux-musleabihf > /rust_target.txt ;; \
  "linux/arm64/v8") echo -n aarch64-unknown-linux-musleabihf > /rust_target.txt ;; \
  "linux/arm64") echo -n aarch64-unknown-linux-musleabihf > /rust_target.txt ;; \
  "linux/arm/v7") echo -n armv7-unknown-linux-musleabihf > /rust_target.txt ;; \
  *) exit 1 ;; \
esac


RUN echo ">>>>>>> Building for arch: ${ARCH}"
RUN rustup update
RUN rustup target add $(cat /rust_target.txt)
RUN rustup toolchain install stable

RUN apt-get update && \
    apt-get install -y libssl-dev pkg-config && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/myapp
COPY . .

#ENV RUSTFLAGS="-C target-feature=+crt-static"
RUN cargo build --release --locked


FROM scratch
COPY --from=builder /usr/src/myapp/target/release/simprox /simprox
CMD ["/simprox"]
