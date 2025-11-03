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
    libpq-dev \
    libgmp-dev \
    wget \
    pkg-config && \
    rm -rf /var/lib/apt/lists/*

# ============================================================================
# INSTALACIÓN ORACLE INSTANT CLIENT (COMENTADO - Registro histórico)
# ============================================================================
# Se intentó usar Oracle Database inicialmente, pero debido a problemas con
# la descarga de Oracle Instant Client (bloqueado en Venezuela), se cambió
# a PostgreSQL. Se mantiene esta sección como registro histórico.
#
# Instala Oracle Instant Client (intentará descargar, si falla se instalará manualmente después)
# RUN mkdir -p /usr/local/instantclient && \
#     cd /tmp && \
#     echo "Descargando Oracle Instant Client basic..." && \
#     (wget --quiet --no-check-certificate --timeout=60 \
#     --header "Cookie: oraclelicense=accept-securebackup-cookie" \
#     https://download.oracle.com/otn_software/linux/instantclient/instantclient-basic-linux.x64-21.8.0.0.0dbru.zip -O basic.zip || \
#     wget --quiet --no-check-certificate --timeout=60 \
#     --header "Cookie: oraclelicense=accept-securebackup-cookie" \
#     https://download.oracle.com/otn_software/linux/instantclient/instantclient-basic-linux.x64-21.3.0.0.0dbru.zip -O basic.zip || \
#     echo "⚠ No se pudo descargar basic.zip - se instalará manualmente después") && \
#     (wget --quiet --no-check-certificate --timeout=60 \
#     --header "Cookie: oraclelicense=accept-securebackup-cookie" \
#     https://download.oracle.com/otn_software/linux/instantclient/instantclient-sdk-linux.x64-21.8.0.0.0dbru.zip -O sdk.zip || \
#     wget --quiet --no-check-certificate --timeout=60 \
#     --header "Cookie: oraclelicense=accept-securebackup-cookie" \
#     https://download.oracle.com/otn_software/linux/instantclient/instantclient-sdk-linux.x64-21.3.0.0.0dbru.zip -O sdk.zip || \
#     echo "⚠ No se pudo descargar sdk.zip - se instalará manualmente después") && \
#     if [ -f basic.zip ] && [ -f sdk.zip ]; then \
#         echo "Extrayendo archivos..." && \
#         unzip -q basic.zip -d /usr/local/instantclient && \
#         unzip -q sdk.zip -d /usr/local/instantclient && \
#         rm -f /tmp/*.zip && \
#         cd /usr/local/instantclient && \
#         INSTANTCLIENT_DIR=$(find . -maxdepth 1 -type d -name "instantclient_*" | head -1) && \
#         if [ -n "$INSTANTCLIENT_DIR" ]; then \
#             echo "Moviendo archivos desde $INSTANTCLIENT_DIR..." && \
#             mv "$INSTANTCLIENT_DIR"/* . && rmdir "$INSTANTCLIENT_DIR"; \
#         fi && \
#         echo "Creando enlaces simbólicos..." && \
#         CLNTSH_FILE=$(ls libclntsh.so.* 2>/dev/null | head -1) && \
#         if [ -n "$CLNTSH_FILE" ]; then \
#             ln -sf "$CLNTSH_FILE" libclntsh.so && \
#             echo "✓ Creado enlace: libclntsh.so -> $CLNTSH_FILE"; \
#         fi && \
#         OCCI_FILE=$(ls libocci.so.* 2>/dev/null | head -1) && \
#         if [ -n "$OCCI_FILE" ]; then \
#             ln -sf "$OCCI_FILE" libocci.so && \
#             echo "✓ Creado enlace: libocci.so -> $OCCI_FILE"; \
#         fi && \
#         echo "✓ Oracle Instant Client instalado correctamente"; \
#     else \
#         echo "⚠ Oracle Instant Client NO se descargó durante el build."; \
#         echo "   Se instalará manualmente después del build con VPN activa."; \
#         echo "   Instrucciones:"; \
#         echo "   1. Activa tu VPN"; \
#         echo "   2. Ejecuta: docker-compose exec app bash"; \
#         echo "   3. Descarga e instala Oracle Instant Client manualmente"; \
#     fi && \
#     rm -f /tmp/*.zip 2>/dev/null || true
#
# Configura variables de entorno para Oracle
# ENV ORACLE_HOME=/usr/local/instantclient
# ENV LD_LIBRARY_PATH=/usr/local/instantclient:$LD_LIBRARY_PATH
# ENV PATH=$ORACLE_HOME:$PATH
# ============================================================================

# Configura el directorio de trabajo (debe coincidir con docker-compose.yml)
WORKDIR /usr/src/app

# Instala bundler
RUN gem install bundler

# Copia el Gemfile primero
COPY Gemfile Gemfile.lock* ./

# Configura bundle para ruby-oci8 (COMENTADO - se cambió a PostgreSQL)
# RUN bundle config build.ruby-oci8 --with-instant-client=/usr/local/instantclient

# Instala las gems
RUN bundle config set --local without 'production' && \
    bundle install

# Copia el resto de la aplicación
COPY . .

# Expone el puerto 3000
EXPOSE 3000

# Comando por defecto
CMD ["bash", "-c", "bundle check || bundle install && bundle exec rails s -p 3000 -b '0.0.0.0'"]
