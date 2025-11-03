# Usa una imagen base de Ruby
FROM ruby:3.2.2-slim-bullseye

# Instala dependencias del sistema operativo
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    git \
    nodejs \
    npm \
    default-jre \
    unzip \
    libaio1 \
    libaio-dev \
    libgmp-dev \
    wget \
    pkg-config && \
    rm -rf /var/lib/apt/lists/*

# Instala Oracle Instant Client
RUN mkdir -p /usr/local/instantclient && \
    cd /tmp && \
    wget --quiet --no-check-certificate --timeout=30 \
    --header "Cookie: oraclelicense=accept-securebackup-cookie" \
    https://download.oracle.com/otn_software/linux/instantclient/instantclient-basic-linux.x64-21.8.0.0.0dbru.zip -O basic.zip || \
    wget --quiet --no-check-certificate --timeout=30 \
    --header "Cookie: oraclelicense=accept-securebackup-cookie" \
    https://download.oracle.com/otn_software/linux/instantclient/instantclient-basic-linux.x64-21.3.0.0.0dbru.zip -O basic.zip || \
    echo "WARNING: No se pudo descargar Oracle Instant Client basic" && \
    wget --quiet --no-check-certificate --timeout=30 \
    --header "Cookie: oraclelicense=accept-securebackup-cookie" \
    https://download.oracle.com/otn_software/linux/instantclient/instantclient-sdk-linux.x64-21.8.0.0.0dbru.zip -O sdk.zip || \
    wget --quiet --no-check-certificate --timeout=30 \
    --header "Cookie: oraclelicense=accept-securebackup-cookie" \
    https://download.oracle.com/otn_software/linux/instantclient/instantclient-sdk-linux.x64-21.3.0.0.0dbru.zip -O sdk.zip || \
    echo "WARNING: No se pudo descargar Oracle Instant Client SDK" && \
    if [ -f basic.zip ] && [ -f sdk.zip ]; then \
        unzip -q basic.zip -d /usr/local/instantclient && \
        unzip -q sdk.zip -d /usr/local/instantclient && \
        rm -f /tmp/*.zip && \
        cd /usr/local/instantclient && \
        INSTANTCLIENT_DIR=$(find . -maxdepth 1 -type d -name "instantclient_*" | head -1) && \
        if [ -n "$INSTANTCLIENT_DIR" ]; then \
            mv "$INSTANTCLIENT_DIR"/* . && rmdir "$INSTANTCLIENT_DIR"; \
        fi && \
        ln -sf libclntsh.so.* libclntsh.so 2>/dev/null || true && \
        ln -sf libocci.so.* libocci.so 2>/dev/null || true; \
    fi

# Configura variables de entorno para Oracle
ENV ORACLE_HOME=/usr/local/instantclient
ENV LD_LIBRARY_PATH=/usr/local/instantclient:$LD_LIBRARY_PATH
ENV PATH=$ORACLE_HOME:$PATH

# Configura el directorio de trabajo (debe coincidir con docker-compose.yml)
WORKDIR /usr/src/app

# Instala bundler
RUN gem install bundler

# Copia el Gemfile primero
COPY Gemfile Gemfile.lock* ./

# Configura bundle para ruby-oci8 (necesita Oracle Instant Client)
RUN bundle config build.ruby-oci8 --with-instant-client=/usr/local/instantclient

# Instala las gems
RUN bundle config set --local without 'production' && \
    bundle install

# Copia el resto de la aplicación
COPY . .

# Expone el puerto 3000
EXPOSE 3000

# Comando por defecto
CMD ["bash", "-c", "bundle check || bundle install && bundle exec rails s -p 3000 -b '0.0.0.0'"]
