FROM alpine:3.17.2 as base

# Godot shared environment Variables
ENV GODOT_VERSION "3.5.2"
ENV GODOT_EXPORT_PRESET "linux"

# Install tools for downloading
RUN apk add --no-cache \
    wget

# This is needed to run Godot on Alpine
RUN wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.31-r0/glibc-2.31-r0.apk && \
    apk add --allow-untrusted --force-overwrite glibc-2.31-r0.apk && \
    rm -f glibc-2.31-r0.apk

FROM base as builder

# Download Godot Headless and export templates, version is set from env variables
RUN wget https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}-stable/Godot_v${GODOT_VERSION}-stable_linux_headless.64.zip \
    && wget https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}-stable/Godot_v${GODOT_VERSION}-stable_export_templates.tpz \
    && mkdir ~/.cache \
    && mkdir -p ~/.config/godot \
    && mkdir -p ~/.local/share/godot/templates/${GODOT_VERSION}.stable \
    && unzip Godot_v${GODOT_VERSION}-stable_linux_headless.64.zip \
    && mv Godot_v${GODOT_VERSION}-stable_linux_headless.64 /usr/local/bin/godot-headless \
    && unzip Godot_v${GODOT_VERSION}-stable_export_templates.tpz \
    && mv templates/* ~/.local/share/godot/templates/${GODOT_VERSION}.stable \
    && rm -f Godot_v${GODOT_VERSION}-stable_export_templates.tpz Godot_v${GODOT_VERSION}-stable_linux_headless.64.zip

# Move to the build directory and export the .pck
WORKDIR /build
COPY . .
RUN godot-headless --path /build --export-pack ${GODOT_EXPORT_PRESET} server.pck

FROM base as runner

# Download Godot Server to run the exported .pck
RUN wget https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}-stable/Godot_v${GODOT_VERSION}-stable_linux_server.64.zip \
    && unzip Godot_v${GODOT_VERSION}-stable_linux_server.64.zip \
    && mv Godot_v${GODOT_VERSION}-stable_linux_server.64 /usr/local/bin/godot-server \
    && rm -f Godot_v${GODOT_VERSION}-stable_linux_server.64.zip

# Create links to the HTTPS certs which will be mounted when hosting
RUN mkdir -p ~/.local/share/godot/app_userdata/Flappy\ Race/certs \
    && ln -s /secrets/live/jibby.localhost/fullchain.pem ~/.local/share/godot/app_userdata/Flappy\ Race/certs/X509_certificate.crt \
    && ln -s /secrets/live/jibby.localhost/privkey.pem ~/.local/share/godot/app_userdata/Flappy\ Race/certs/X509_key.key

# Copy the exported .pck and run it
COPY --from=builder /build/server.pck server.pck
ENTRYPOINT [ "/usr/local/bin/godot-server", "--main-pack", "server.pck" ]