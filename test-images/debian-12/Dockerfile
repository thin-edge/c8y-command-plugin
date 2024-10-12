FROM ghcr.io/thin-edge/tedge-demo-main-systemd:latest

# FIXME: Remove once thin-edge.io 1.4.0 is released
RUN wget -O - thin-edge.io/install.sh | sh -s -- --channel main

# FIXME: Remove this requirement
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        jq

RUN tedge config unset c8y.proxy.client.host \
    && tedge config unset mqtt.client.host \
    && tedge config unset http.client.host

COPY dist/c8y-command-plugin_*.deb /tmp/
RUN DEBIAN_FRONTEND=noninteractive apt-get install --allow-downgrades -y --no-install-recommends /tmp/*.deb
