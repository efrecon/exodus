# Exodus


This project is both an image and a proof-of-concept to build extremely minimal
Docker images, but on top of the whole Debian catalog!  Building uses [exodus]
to create self-contained binaries with their entire library dependencies and
Docker [multi-stage] builds to squash away the original Debian context and
installation. This results in images that contain the bare minimal to run the
binary at hand. For example, packaging the `jq` binary takes 3.18MB instead of
80.3MB (on top of Debian Jessie) or 5.32MB (on top of Alpine, but this isn't a
fair comparison).

  [exodus]: https://github.com/intoli/exodus
  [multi-stage]: https://docs.docker.com/develop/develop-images/multistage-build/

## How-To

The steps to create such minimal images are as follows:

1. Inherit from `efrecon/exodus`, this image is based on the latest [python]
   image, itself based on top of Debian [jessie].
2. Add all the necessary software using regular `apt-get update` and `apt-get
   install` calls.
3. Use `exodus` to relocate the binaries to temporary tarballs.
4. Untar the tarballs into some available locations, e.g. the `HOME` directory
   for the root user or similar.
5. Restart a new build from the empty [scratch] image.
6. Copy back the binaries from the `HOME` directory directly into `/` (this is
   safe, the image will not contain anything else).

  [python]: https://hub.docker.com/_/python/
  [jessie]: https://hub.docker.com/_/debian/
  [scratch]: https://hub.docker.com/_/scratch/

### Example

The following exemplifies these steps on [jq](https://stedolan.github.io/jq/).

````
FROM efrecon/exodus

# Install whatever needed from debian
RUN apt-get update && \
    apt-get install -y jq

# Relocate the necessary binaries, and only those
RUN exodus --tarball jq --output /tmp/jq.tgz && \
    tar --strip 1 -C /root -zxvf /tmp/jq.tgz

# Restart from an empty image
FROM scratch

# Copy back the binaries, and maybe any configuration data or similar from the
# previous stage.
COPY --from=0 /root /

# You now have a minimal image!
ENTRYPOINT ["/bin/jq"]
````

Build this image using a command similar to:

````
docker build -t efrecon/jq .
````

On my system, the resulting image is 3.18MB, nothing more, nothing less...

### Size Matters

#### Debian

By comparison, a similar image based on the following Dockerfile is 80.3MB.

````
FROM debian:jessie-slim

RUN apt-get update && \
    apt-get install -y jq && \
    rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["jq"]
````

#### Alpine

Building on top of Alpine with the following Dockerfile leads to a 5.32MB image
instead.  However, Alpine is built on top of the [musl] library and has a
smaller set of software packages available. [exodus] uses [musl] to properly
relocate the binaries, but these will still depend of `libc`.

  [musl]: https://www.musl-libc.org/

````
FROM alpine

RUN apk --no-cache add jq

ENTRYPOINT ["jq"]
````

## Acknowledgements

Nothing would be possible without [exodus] and its ability to relocate binaries
and their library dependencies.