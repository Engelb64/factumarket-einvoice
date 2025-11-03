# FactuMarket - Sistema de Facturación Electrónica

Sistema moderno de facturación electrónica desarrollado para **FactuMarket S.A.** utilizando Ruby on Rails con arquitectura multi-base de datos.

## 🎯 Objetivo del Proyecto

Modernizar el sistema de facturación electrónica de FactuMarket S.A., actualmente manual y monolítico, para:
- ✅ Agilizar la emisión de facturas
- ✅ Implementar control de auditoría
- ✅ Garantizar cumplimiento normativo con la autoridad tributaria

## 🏗️ Arquitectura

El sistema utiliza dos bases de datos:
- **Oracle Database**: Base de datos relacional para datos transaccionales y auditoría
- **MongoDB**: Base de datos NoSQL para documentos y logs de facturación

## 📋 Requisitos Previos

- Docker y Docker Compose instalados
- Git

## 🚀 Instalación y Despliegue

### 1. Clonar el repositorio

```bash
git clone <url-del-repositorio>
cd factumarket-einvoice
```

### 2. Configurar archivos de base de datos

Si los archivos de configuración no existen, cópialos desde los ejemplos:

```bash
# Configurar Oracle
cp config/database.yml.example config/database.yml

# Configurar MongoDB
cp config/mongoid.yml.example config/mongoid.yml
```

**Nota**: Si ya existen estos archivos, puedes omitir este paso.

### 3. Levantar los servicios con Docker Compose

```bash
docker-compose up --build
```

Este comando:
- Construye la imagen de la aplicación Rails (descarga Oracle Instant Client)
- Inicia Oracle Database (tardará ~2-3 minutos en estar listo)
- Inicia MongoDB
- Inicia la aplicación Rails

**Nota**: La primera vez puede tardar varios minutos mientras:
- Descarga las imágenes base (Oracle, MongoDB, Ruby)
- Descarga e instala Oracle Instant Client
- Construye la imagen de la aplicación
- Instala todas las gemas de Ruby

**Espera hasta ver**: "Listening on http://0.0.0.0:3000" en los logs.

### 4. Acceder a la aplicación

Una vez que todos los servicios estén corriendo, accede a:

- **Rails App**: http://localhost:3000
- **Oracle Database**: 
  - Host: `localhost`
  - Puerto: `1521`
  - Usuario: `system`
  - Contraseña: `oracle123`
  - Service Name: `XE`
- **MongoDB**: 
  - Host: `localhost`
  - Puerto: `27017`
  - Database: `my_rails_db`
- **Oracle EM Express**: http://localhost:5500

## ⚙️ Configuración de Bases de Datos

### Oracle Database

La configuración se encuentra en `config/database.yml` (si no existe, cópialo desde `config/database.yml.example`).

Las credenciales se pueden configurar mediante variables de entorno en `docker-compose.yml` o directamente en el archivo. Por defecto:

```yaml
username: system
password: oracle123
host: oracle
port: 1521
database: XE
```

**Nota**: Si `config/database.yml` no existe, cópialo desde el ejemplo:
```bash
cp config/database.yml.example config/database.yml
```

### MongoDB

La configuración se encuentra en `config/mongoid.yml` (si no existe, cópialo desde `config/mongoid.yml.example`).

Por defecto se conecta a:

```yaml
hosts:
  - mongodb:27017
database: my_rails_db
```

**Nota**: Si `config/mongoid.yml` no existe, cópialo desde el ejemplo:
```bash
cp config/mongoid.yml.example config/mongoid.yml
```

## 🔧 Variables de Entorno

Las variables de entorno están configuradas en `docker-compose.yml`. Puedes modificarlas según tus necesidades:

- `ORACLE_HOST`, `ORACLE_PORT`, `ORACLE_USER`, `ORACLE_PASSWORD`, `ORACLE_DATABASE`
- `MONGO_HOST`, `MONGO_PORT`, `MONGO_DATABASE`
- `RAILS_ENV`, `RAILS_LOG_TO_STDOUT`

## 📦 Estructura del Proyecto

```
.
├── app/                    # Código de la aplicación Rails
│   ├── controllers/        # Controladores
│   ├── models/             # Modelos (ActiveRecord para Oracle, Mongoid para MongoDB)
│   └── views/              # Vistas
├── config/                 # Configuración
│   ├── database.yml        # Configuración Oracle (ActiveRecord)
│   └── mongoid.yml         # Configuración MongoDB
├── docker-compose.yml      # Configuración Docker Compose
├── Dockerfile              # Imagen Docker de la aplicación
└── Gemfile                 # Dependencias Ruby
```

## 🛠️ Comandos Útiles

### Ver logs de los servicios

```bash
# Todos los servicios
docker-compose logs -f

# Solo la aplicación Rails
docker-compose logs -f app

# Solo Oracle
docker-compose logs -f oracle

# Solo MongoDB
docker-compose logs -f mongodb
```

### Ejecutar comandos Rails

```bash
# Consola de Rails
docker-compose exec app rails console

# Generar un modelo
docker-compose exec app rails generate model NombreModelo

# Ejecutar migraciones (Oracle)
docker-compose exec app rails db:migrate

# Instalar nuevas gemas
docker-compose exec app bundle install
docker-compose restart app
```

### Acceder a las bases de datos

```bash
# MongoDB shell
docker-compose exec mongodb mongosh my_rails_db

# Oracle SQL*Plus
docker-compose exec oracle sqlplus system/oracle123@XE
```

### Detener y reiniciar servicios

```bash
# Detener todos los servicios
docker-compose stop

# Reiniciar todos los servicios
docker-compose start

# Detener y eliminar contenedores (NO elimina volúmenes)
docker-compose down

# Detener y eliminar TODO incluyendo volúmenes (¡CUIDADO! Borra los datos)
docker-compose down -v

# Reiniciar solo la aplicación Rails
docker-compose restart app
```

## 📊 Uso de las Bases de Datos

### Modelos con ActiveRecord (Oracle)

```ruby
# app/models/producto.rb
class Producto < ApplicationRecord
  # Se conecta automáticamente a Oracle usando config/database.yml
end
```

### Modelos con Mongoid (MongoDB)

```ruby
# app/models/usuario.rb
class Usuario
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :nombre, type: String
  field :email, type: String
end
```

## ⚠️ Notas Importantes

1. **Oracle Database** requiere aproximadamente 2-3 minutos para inicializarse completamente la primera vez
2. Los health checks en `docker-compose.yml` esperan a que las bases de datos estén listas antes de iniciar Rails
3. Los volúmenes Docker mantienen los datos persistidos entre reinicios
4. Los cambios en código (controladores, modelos, vistas) se recargan automáticamente gracias al volumen montado

## 🔍 Troubleshooting

### Oracle no se conecta

- Espera al menos 2-3 minutos después de iniciar los contenedores
- Verifica el health check: `docker-compose ps oracle`
- Revisa los logs: `docker-compose logs oracle`

### MongoDB no se conecta

- Verifica que el contenedor esté corriendo: `docker-compose ps mongodb`
- Revisa los logs: `docker-compose logs mongodb`

### La aplicación no arranca

- Verifica que Oracle y MongoDB estén "healthy": `docker-compose ps`
- Revisa los logs de la aplicación: `docker-compose logs app`
- Verifica que las gemas estén instaladas: `docker-compose exec app bundle check`

### Puerto 3000 ya está en uso

Cambia el puerto en `docker-compose.yml`:

```yaml
ports:
  - "3001:3000"  # Cambia 3000 a 3001
```

## 🔐 Seguridad

⚠️ **IMPORTANTE**: Las credenciales por defecto son solo para desarrollo. Para producción:

1. Cambia las contraseñas en `docker-compose.yml`
2. Usa variables de entorno o un gestor de secretos
3. No subas archivos con credenciales a Git

## 📝 Desarrollo

### Hot Reload

Los cambios en controladores, modelos y vistas se recargan automáticamente. Solo necesitas reiniciar el servidor cuando:

- Agregas nuevas gemas al `Gemfile`
- Cambias archivos en `config/initializers/`
- Modificas `config/database.yml` o `config/mongoid.yml`

```bash
docker-compose restart app
```

## 🧪 Testing

```bash
# Ejecutar tests (si están configurados)
docker-compose exec app rails test
```

## 📚 Documentación Adicional

- [Ruby on Rails Guides](https://guides.rubyonrails.org/)
- [Mongoid Documentation](https://docs.mongodb.com/mongoid/)
- [Oracle Enhanced Adapter](https://github.com/rsim/oracle-enhanced)
- [Docker Compose Documentation](https://docs.docker.com/compose/)

## 👥 Desarrollado para

**FactuMarket S.A.**

## 📄 Licencia

[Especificar licencia si aplica]

---

> **Nota**: Este proyecto forma parte de una prueba técnica para la modernización del sistema de facturación electrónica.
