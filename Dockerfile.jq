FROM efrecon/exodus

# Install whatever needed from debian
RUN apt-get update && \
    apt-get install -y jq

# Relocate the necessary binaries, and only those
RUN exodus --tarball jq --output /tmp/jq.tgz && \
    tar --strip 1 -C /root -zxvf /tmp/jq.tgz

# Restart from an empty image
FROM scratch

# Copy back the binaries, and maybe any configuration data or similar from
# the previous stage.
COPY --from=0 /root /

# You now have a minimal image!
ENTRYPOINT ["/bin/jq"]
