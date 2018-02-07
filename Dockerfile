# Start from the standard python image, which itself is based on debian and give
# us access to a wide range of packages and software for installation through
# apt-get.
FROM python

# Install exodus and arrange for exodus to be able to access musl for best
# binary performance.
RUN pip install exodus-bundler && \
    apt-get update && \
    apt-get install -y musl-tools

# Make exodus the entrypoing, but this is not really the point though.
ENTRYPOINT ["exodus"]

# All the magic will happen in images that are inherited from this one...