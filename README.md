# FactuMarket - Sistema de Facturación Electrónica

Sistema moderno de facturación electrónica desarrollado para **Prueba tecnica Double V Partners** utilizando Ruby on Rails con arquitectura multi-base de datos.

## 🎯 Objetivo del Proyecto

Modernizar el sistema de facturación electrónica de FactuMarket S.A., actualmente manual y monolítico, para:
- ✅ Agilizar la emisión de facturas
- ✅ Implementar control de auditoría
- ✅ Garantizar cumplimiento normativo con la autoridad tributaria

## 🏗️ Arquitectura

El sistema utiliza una **arquitectura de microservicios** basada en Ruby on Rails 7.2, donde cada microservicio es independiente y se comunica vía HTTP REST:

### Microservicios

1. **Client Service** (Puerto 3001)
   - Gestión de clientes (CRUD)
   - Base de datos: PostgreSQL (`client_service_development`)
   - Tabla: `clientes`

2. **Invoice Service** (Puerto 3002)
   - Gestión de facturas (crear, emitir, anular)
   - Validación de reglas de negocio
   - Base de datos: PostgreSQL (`invoice_service_development`)
   - Tablas: `facturas`, `items_factura`
   - Comunicación: Se comunica con Client Service y Audit Service

3. **Audit Service** (Puerto 3003)
   - Registro de eventos de auditoría
   - Reportes y métricas agregadas
   - Bases de datos:
     - MongoDB (`audit_service_development`) - Eventos raw
     - PostgreSQL (`audit_service_reports_development`) - Métricas agregadas
   - Colección/Tabla: `eventos_auditoria` / `metricas_auditoria`

### Bases de Datos

- **PostgreSQL 16**: Base de datos relacional multi-schema para datos transaccionales
  - Una base de datos por microservicio para datos transaccionales
  - Base adicional en Audit Service para reportes agregados
- **MongoDB 7.0**: Base de datos NoSQL para eventos de auditoría (raw events)

### 📐 Diagrama de Arquitectura

Para una vista detallada de la arquitectura del sistema, puedes consultar el diagrama interactivo en Lucidchart:

🔗 [Ver Diagrama de Arquitectura en Lucidchart](https://lucid.app/lucidchart/9eb7cb4c-87ee-4bc0-a473-edaee5888e47/edit?viewport_loc=3777%2C-2018%2C1970%2C1079%2C0_0&invitationId=inv_2f7e9ddf-dd90-4549-847c-df6ce3a729a2)

> **Nota histórica**: Inicialmente se intentó usar Oracle Database, pero debido a problemas con la descarga de Oracle Instant Client, se cambió a PostgreSQL. Las referencias a Oracle se mantienen comentadas en el código como registro histórico.

## 📋 Requisitos Previos

- Docker y Docker Compose instalados
- Git

## 🚀 Instalación y Despliegue

### 1. Clonar el repositorio

```bash
git clone <url-del-repositorio>
cd factumarket-einvoice
```

### 2. Levantar todos los microservicios con Docker Compose

```bash
docker-compose up --build
```

Este comando levanta todos los servicios:
- PostgreSQL Database (multi-database)
- MongoDB
- **Client Service** (Puerto 3001)
- **Invoice Service** (Puerto 3002)
- **Audit Service** (Puerto 3003)

#### Ejecutar microservicios individualmente

```bash
# Levantar solo Client Service y sus dependencias
docker-compose up client-service postgres

# Levantar solo Invoice Service y sus dependencias
docker-compose up invoice-service postgres client-service

# Levantar solo Audit Service y sus dependencias
docker-compose up audit-service postgres mongodb
```

**Nota**: Invoice Service depende de Client Service y Audit Service para funcionar completamente.

### 2.1. Cargar datos de ejemplo (Opcional)

Si deseas tener datos de ejemplo en la base de datos para probar el sistema rápidamente, puedes ejecutar los seeds:

```bash
# 1. Primero, cargar clientes de ejemplo
docker-compose exec client-service bash -c "cd services/client-service && rails db:seed"

# 2. Luego, cargar facturas de ejemplo (requiere clientes)
docker-compose exec invoice-service bash -c "cd services/invoice-service && rails db:seed"
```

**Nota**: Los seeds son completamente opcionales. El sistema funciona perfectamente sin ellos.

**Nota**: La primera vez puede tardar varios minutos mientras:
- Descarga las imágenes base (PostgreSQL, MongoDB, Ruby)
- Construye las imágenes de los microservicios
- Instala todas las gemas de Ruby en cada servicio

**Espera hasta ver en los logs**:
- `Client Service`: "Listening on http://0.0.0.0:3001"
- `Invoice Service`: "Listening on http://0.0.0.0:3002"
- `Audit Service`: "Listening on http://0.0.0.0:3003"

### 3. Verificar que todos los servicios están corriendo

```bash
docker-compose ps
```

Deberías ver los siguientes servicios con estado "Up (healthy)":
- `client-service` (Puerto 3001)
- `invoice-service` (Puerto 3002)
- `audit-service` (Puerto 3003)
- `postgres` (Puerto 5432)
- `mongodb` (Puerto 27017)

### 4. Acceder a los microservicios

Una vez que todos los servicios estén corriendo, puedes acceder a:

**Microservicios:**
- **Client Service**: http://localhost:3001
  - API: http://localhost:3001/api/v1/clientes
- **Invoice Service**: http://localhost:3002
  - API: http://localhost:3002/api/v1/facturas
- **Audit Service**: http://localhost:3003
  - API: http://localhost:3003/api/v1/auditoria/eventos
  - Reportes: http://localhost:3003/api/v1/auditoria/reportes

**Bases de Datos:**
- **PostgreSQL**: 
  - Host: `localhost`
  - Puerto: `5432`
  - Usuario: `postgres`
  - Contraseña: `postgres123`
  - Bases de datos:
    - `client_service_development`
    - `invoice_service_development`
    - `audit_service_reports_development`
- **MongoDB**: 
  - Host: `localhost`
  - Puerto: `27017`
  - Database: `audit_service_development`

## ⚙️ Configuración de Microservicios

### Variables de Entorno

Cada microservicio tiene sus propias variables de entorno configuradas en `docker-compose.yml`:

**Client Service:**
- `POSTGRES_*`: Configuración de PostgreSQL
- `DATABASE_URL`: URL de conexión a PostgreSQL
- `RAILS_ENV`: development

**Invoice Service:**
- `POSTGRES_*`: Configuración de PostgreSQL
- `DATABASE_URL`: URL de conexión a PostgreSQL
- `CLIENT_SERVICE_URL`: http://client-service:3001 (para comunicación con Client Service)
- `AUDIT_SERVICE_URL`: http://audit-service:3003 (para comunicación con Audit Service)
- `RAILS_ENV`: development

**Audit Service:**
- `MONGO_*`: Configuración de MongoDB (para eventos raw)
- `POSTGRES_*`: Configuración de PostgreSQL (para reportes agregados)
- `RAILS_ENV`: development

**Nota**: Las credenciales y URLs están configuradas en `docker-compose.yml`. Para cambiar la configuración, modifica las variables de entorno en ese archivo.

## 📦 Estructura del Proyecto

### Organización General

```
.
├── services/                    # Microservicios
│   ├── client-service/          # Puerto 3001
│   ├── invoice-service/         # Puerto 3002
│   └── audit-service/           # Puerto 3003
│
├── docker-compose.yml           # Configuración de todos los servicios
├── Dockerfile                   # Imagen Docker compartida
│
├── ARCHITECTURE.md              # Documentación de arquitectura
├── MICROSERVICES.md             # Responsabilidades e interacciones
├── COMMUNICATION_PATTERNS.md    # Flujos de comunicación
└── ARCHITECTURAL_PRINCIPLES.md  # Principios aplicados
```

### Estructura Interna de un Microservicio (Clean Architecture + MVC)

Cada microservicio sigue los principios de **Clean Architecture** y **MVC**:

```
services/invoice-service/
├── app/
│   ├── controllers/             # MVC - Capa de Presentación
│   │   └── api/v1/
│   │       └── facturas_controller.rb    # Recibe HTTP, delega a Services
│   │
│   ├── services/                # Clean Architecture - Capa de Aplicación
│   │   ├── crear_factura_service.rb      # Orquesta casos de uso
│   │   ├── emitir_factura_service.rb     # Coordina entre capas
│   │   └── anular_factura_service.rb
│   │
│   ├── models/                  # Clean Architecture - Capa de Dominio
│   │   ├── factura.rb                    # Lógica de negocio
│   │   └── item_factura.rb               # Validaciones y reglas
│   │
│   ├── clients/                 # Clean Architecture - Capa de Infraestructura
│   │   ├── client_service_client.rb      # Acceso a otros servicios
│   │   └── audit_service_client.rb
│   │
│   └── exceptions/              # Excepciones personalizadas
│       └── business_error.rb
│
├── config/                      # Configuración
│   └── database.yml             # PostgreSQL
│
└── db/
    └── migrate/                 # Migraciones
```

#### Aplicación de Clean Architecture

- **Controllers (MVC - Presentación)**: Reciben requests HTTP, validan entrada, delegan a Services
- **Services (Capa de Aplicación)**: Orquestan casos de uso, coordinan entre capas y servicios externos
- **Models (Capa de Dominio)**: Contienen lógica de negocio, validaciones y reglas del dominio
- **Clients (Capa de Infraestructura)**: Acceso a servicios externos y recursos externos

#### Flujo de Datos

```
HTTP Request → Controller → Service → Model → Database
                                      ↓
                                   Client (otros servicios)
```

**Ejemplo práctico**:
```ruby
# 1. Controller (MVC) recibe request
class FacturasController
  def create
    service = CrearFacturaService.new
    @factura = service.ejecutar(factura_params)  # Delega a Service
    render json: @factura
  end
end

# 2. Service (Aplicación) orquesta
class CrearFacturaService
  def ejecutar(params)
    # Valida con otro servicio (Infraestructura)
    cliente = @client_service_client.obtener_cliente(params[:cliente_id])
    
    # Crea entidad (Dominio)
    factura = Factura.new(params)
    factura.save!
    
    # Registra auditoría (Infraestructura)
    @audit_service_client.registrar_evento(...)
    
    factura
  end
end

# 3. Model (Dominio) contiene lógica de negocio
class Factura < ApplicationRecord
  def puede_emitir?
    estado == "borrador" && items_factura.any? && total > 0
  end
end
```

## 🛠️ Comandos Útiles

### Ver logs de los servicios

```bash
# Todos los servicios
docker-compose logs -f

# Logs de un microservicio específico
docker-compose logs -f client-service
docker-compose logs -f invoice-service
docker-compose logs -f audit-service

# Logs de bases de datos
docker-compose logs -f postgres
docker-compose logs -f mongodb
```

### Ejecutar comandos Rails en microservicios

```bash
# Consola de Rails en Client Service
docker-compose exec client-service bash -c "cd services/client-service && rails console"

# Consola de Rails en Invoice Service
docker-compose exec invoice-service bash -c "cd services/invoice-service && rails console"

# Consola de Rails en Audit Service
docker-compose exec audit-service bash -c "cd services/audit-service && rails console"

# Ejecutar migraciones en un microservicio específico
docker-compose exec client-service bash -c "cd services/client-service && rails db:migrate"
docker-compose exec invoice-service bash -c "cd services/invoice-service && rails db:migrate"
docker-compose exec audit-service bash -c "cd services/audit-service && rails db:migrate"

# Crear base de datos (si es necesario)
docker-compose exec audit-service bash -c "cd services/audit-service && rails db:create db:migrate"

# Cargar datos de ejemplo (seeds) - OPCIONAL
docker-compose exec client-service bash -c "cd services/client-service && rails db:seed"
docker-compose exec invoice-service bash -c "cd services/invoice-service && rails db:seed"
# Nota: Los seeds de invoice-service requieren que client-service tenga clientes
# Los seeds de audit-service son informativos (los eventos se generan automáticamente)

# Instalar nuevas gemas en un microservicio
docker-compose exec client-service bash -c "cd services/client-service && bundle install"
docker-compose restart client-service
```

### Acceder a las bases de datos

```bash
# MongoDB shell
docker-compose exec mongodb mongosh audit_service_development

# PostgreSQL psql - Client Service
docker-compose exec postgres psql -U postgres -d client_service_development

# PostgreSQL psql - Invoice Service
docker-compose exec postgres psql -U postgres -d invoice_service_development

# PostgreSQL psql - Audit Service (Reportes)
docker-compose exec postgres psql -U postgres -d audit_service_reports_development
```

### Detener y reiniciar servicios

```bash
# Detener todos los servicios
docker-compose stop

# Iniciar todos los servicios
docker-compose start

# Reiniciar todos los servicios
docker-compose restart

# Reiniciar un microservicio específico
docker-compose restart client-service
docker-compose restart invoice-service
docker-compose restart audit-service

# Detener y eliminar contenedores (NO elimina volúmenes)
docker-compose down

# Detener y eliminar TODO incluyendo volúmenes (¡CUIDADO! Borra los datos)
docker-compose down -v

# Ver estado de los servicios
docker-compose ps
```

### Health Checks

```bash
# Verificar health de todos los servicios
docker-compose ps

# Verificar si un servicio específico está healthy
docker-compose ps client-service
docker-compose ps invoice-service
docker-compose ps audit-service
```

## 📊 Comunicación entre Microservicios

Los microservicios se comunican mediante HTTP REST:

### Invoice Service → Client Service

```ruby
# En Invoice Service
client = ClientServiceClient.new
cliente = client.obtener_cliente(cliente_id)
```

**Endpoint utilizado**: `GET http://client-service:3001/api/v1/clientes/:id`

### Invoice Service → Audit Service

```ruby
# En Invoice Service
audit = AuditServiceClient.new
audit.registrar_evento('FacturaCreada', 'invoice-service', 'Factura', factura_id, datos)
```

**Endpoint utilizado**: `POST http://audit-service:3003/api/v1/auditoria/eventos`

### Ejemplos de uso de la API

#### Client Service

**1. Crear un cliente:**
```bash
curl -X POST http://localhost:3001/api/v1/clientes \
  -H "Content-Type: application/json" \
  -d '{
    "cliente": {
      "nit": "12345678-9",
      "nombre": "Empresa ABC S.A.",
      "email": "contacto@abc.com",
      "telefono": "2222-3333",
      "direccion": "Calle Principal 123, Ciudad"
    }
  }'
```

**Respuesta esperada:**
```json
{
  "id": 1,
  "nit": "12345678-9",
  "nombre": "Empresa ABC S.A.",
  "email": "contacto@abc.com",
  "telefono": "2222-3333",
  "direccion": "Calle Principal 123, Ciudad",
  "activo": true
}
```

**2. Listar todos los clientes:**
```bash
curl http://localhost:3001/api/v1/clientes
```

**3. Obtener cliente por ID:**
```bash
curl http://localhost:3001/api/v1/clientes/1
```

---

#### Invoice Service

**1. Crear una factura (borrador):**
```bash
curl -X POST http://localhost:3002/api/v1/facturas \
  -H "Content-Type: application/json" \
  -d '{
    "factura": {
      "cliente_id": 1,
      "items_factura_attributes": [
        {
          "descripcion": "Producto A",
          "cantidad": 2,
          "precio_unitario": 100.00,
          "impuesto_porcentaje": 13
        },
        {
          "descripcion": "Producto B",
          "cantidad": 1,
          "precio_unitario": 50.00,
          "impuesto_porcentaje": 13
        }
      ]
    }
  }'
```

**Respuesta esperada:**
```json
{
  "id": 1,
  "numero_factura": null,
  "cliente_id": 1,
  "estado": "borrador",
  "subtotal": 250.00,
  "impuestos": 32.50,
  "total": 282.50,
  "items_factura": [...]
}
```

**2. Emitir factura:**
```bash
curl -X POST http://localhost:3002/api/v1/facturas/1/emitir \
  -H "Content-Type: application/json"
```

**Respuesta esperada:**
```json
{
  "id": 1,
  "numero_factura": "FM-2025-000001",
  "estado": "emitida",
  "fecha_emision": "2025-01-15",
  "total": 282.50
}
```

**3. Listar facturas:**
```bash
# Todas las facturas
curl http://localhost:3002/api/v1/facturas

# Filtrar por rango de fechas
curl "http://localhost:3002/api/v1/facturas?fechaInicio=2025-01-15&fechaFin=2025-01-31"
```

**4. Anular factura:**
```bash
curl -X POST http://localhost:3002/api/v1/facturas/1/anular \
  -H "Content-Type: application/json" \
  -d '{"motivo": "Error en datos del cliente"}'
```

---

#### Audit Service

**1. Consultar eventos de auditoría:**
```bash
curl http://localhost:3003/api/v1/auditoria/eventos
```

**Respuesta esperada:**
```json
[
  {
    "id": "...",
    "evento": "FacturaCreada",
    "servicio": "invoice-service",
    "entidad_tipo": "Factura",
    "entidad_id": "1",
    "timestamp": "2025-01-15T10:30:00Z",
    "datos": {...}
  }
]
```

**2. Consultar reportes (métricas agregadas):**
```bash
curl "http://localhost:3003/api/v1/auditoria/reportes?desde=2025-01-15&servicio=invoice-service"
```

**Respuesta esperada:**
```json
[
  {
    "fecha": "2025-01-15",
    "servicio": "invoice-service",
    "evento": "FacturaCreada",
    "cantidad": 5
  },
  {
    "fecha": "2025-01-15",
    "servicio": "invoice-service",
    "evento": "FacturaEmitida",
    "cantidad": 3
  }
]
```

**3. Resumen de reportes:**
```bash
curl http://localhost:3003/api/v1/auditoria/reportes/resumen?desde=2025-01-15
```

## ⚠️ Notas Importantes

1. **Orden de inicio**: Docker Compose espera a que PostgreSQL y MongoDB estén "healthy" antes de iniciar los microservicios
2. **PostgreSQL** se inicializa rápidamente (10-20 segundos)
3. **MongoDB** puede tardar un poco más (20-30 segundos en el primer inicio)
4. Los volúmenes Docker mantienen los datos persistidos entre reinicios
5. Los cambios en código se recargan automáticamente gracias al volumen montado (hot reload)
6. Cada microservicio tiene su propia base de datos PostgreSQL para independencia
7. El Audit Service usa ambas bases de datos: MongoDB para eventos raw y PostgreSQL para métricas agregadas

## 🔍 Troubleshooting

### PostgreSQL no se conecta

- Verifica que el contenedor esté corriendo: `docker-compose ps postgres`
- Verifica el health check: `docker-compose ps postgres`
- Revisa los logs: `docker-compose logs postgres`
- Verifica las credenciales en `docker-compose.yml`

### MongoDB no se conecta

- Verifica que el contenedor esté corriendo: `docker-compose ps mongodb`
- Revisa los logs: `docker-compose logs mongodb`

### Un microservicio no arranca

- Verifica que PostgreSQL y MongoDB estén "healthy": `docker-compose ps`
- Revisa los logs del microservicio: `docker-compose logs -f client-service` (o el servicio que falle)
- Verifica que las gemas estén instaladas:
  ```bash
  docker-compose exec client-service bash -c "cd services/client-service && bundle check"
  ```
- Verifica la conexión a la base de datos:
  ```bash
  docker-compose exec client-service bash -c "cd services/client-service && rails db:version"
  ```

### Error de comunicación entre microservicios

- Verifica que ambos microservicios estén corriendo: `docker-compose ps`
- Verifica las variables de entorno en `docker-compose.yml`:
  - `CLIENT_SERVICE_URL` en invoice-service debe ser: `http://client-service:3001`
  - `AUDIT_SERVICE_URL` en invoice-service debe ser: `http://audit-service:3003`
- Verifica que los servicios estén en la misma red Docker (por defecto se crean automáticamente)

### Puerto ya está en uso

Si algún puerto (3001, 3002, 3003, 5432, 27017) ya está en uso, cambia el mapeo en `docker-compose.yml`:

```yaml
ports:
  - "3001:3001"  # Cambia el primer número (host) al puerto disponible
```

## 🔐 Seguridad

⚠️ **IMPORTANTE**: Las credenciales por defecto son solo para desarrollo. Para producción:

1. Cambia las contraseñas en `docker-compose.yml`
2. Usa variables de entorno o un gestor de secretos
3. No subas archivos con credenciales a Git

## 📝 Desarrollo

### Hot Reload

Los cambios en controladores, modelos y vistas se recargan automáticamente en todos los microservicios. Solo necesitas reiniciar cuando:

- Agregas nuevas gemas al `Gemfile` de algún microservicio
- Cambias archivos en `config/initializers/`
- Modificas `config/database.yml` o `config/mongoid.yml`

```bash
# Reiniciar un microservicio específico
docker-compose restart client-service
docker-compose restart invoice-service
docker-compose restart audit-service

# O reiniciar todos
docker-compose restart
```

### Trabajar con un microservicio específico

```bash
# Acceder al shell del contenedor
docker-compose exec client-service bash

# Desde dentro del contenedor, navegar al microservicio
cd services/client-service

# Ejecutar comandos Rails
rails console
rails generate model NombreModelo
rails db:migrate
```

## 🧪 Testing

```bash
# Ejecutar tests (si están configurados)
docker-compose exec app rails test
```

## 📚 Documentación Adicional

### Guías de Uso

- **[POSTMAN_EXAMPLES.md](POSTMAN_EXAMPLES.md)** - Ejemplos completos para Postman
  - Configuración de variables de entorno
  - Todos los endpoints de cada microservicio
  - Ejemplos de requests y respuestas
  - Flujos completos de ejemplo
  - Códigos de error y validaciones

### Documentación de Arquitectura

- **[ARCHITECTURE.md](ARCHITECTURE.md)** - Documentación general de la arquitectura del sistema
  - Microservicios principales
  - Estrategia de persistencia
  - Clean Architecture aplicada
  - Validaciones de negocio
  - Manejo de errores

- **[MICROSERVICES.md](MICROSERVICES.md)** - Responsabilidades e interacciones de cada microservicio
  - Client Service: Gestión de clientes
  - Invoice Service: Gestión de facturas y reglas de negocio
  - Audit Service: Auditoría y reportes
  - Comunicación entre microservicios
  - Flujos principales

- **[COMMUNICATION_PATTERNS.md](COMMUNICATION_PATTERNS.md)** - Flujos de comunicación y consistencia
  - Estrategia de comunicación (REST síncrono)
  - Garantía de consistencia entre servicios
  - Manejo de errores en comunicación

- **[ARCHITECTURAL_PRINCIPLES.md](ARCHITECTURAL_PRINCIPLES.md)** - Principios arquitectónicos aplicados
  - Microservicios: Independencia, escalabilidad, despliegue autónomo
  - Clean Architecture: Separación de capas (dominio, aplicación, infraestructura)
  - MVC: Organización en la capa de exposición

### Diagramas

- [Diagrama de Arquitectura Interactivo (Lucidchart)](https://lucid.app/lucidchart/9eb7cb4c-87ee-4bc0-a473-edaee5888e47/edit?viewport_loc=3777%2C-2018%2C1970%2C1079%2C0_0&invitationId=inv_2f7e9ddf-dd90-4549-847c-df6ce3a729a2) - Vista interactiva de la arquitectura completa

### Tecnologías Utilizadas
- [Ruby on Rails Guides](https://guides.rubyonrails.org/)
- [Mongoid Documentation](https://docs.mongodb.com/mongoid/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)

---

## 🔌 Integración Futura con DIAN

El sistema está preparado arquitectónicamente para integrarse con la entidad tributaria nacional (DIAN u organismo equivalente) sin requerir cambios estructurales mayores.

### Preparación Actual

- ✅ **Patrón de Clients**: La arquitectura ya utiliza HTTP Clients para comunicación entre servicios, que puede extenderse para DIAN
- ✅ **Punto de integración**: El servicio `EmitirFacturaService` es el lugar natural para agregar la integración
- ✅ **Separación de capas**: La lógica de integración se aislaría en la capa de Infraestructura (Clients)
- ✅ **Sin acoplamiento**: La integración no afectaría el funcionamiento interno actual

### Implementación Futura

Para más detalles sobre cómo se implementaría la integración con DIAN, consulta la sección **"Integración Futura con Entidad Tributaria (DIAN)"** en [`ARCHITECTURE.md`](ARCHITECTURE.md).

**Resumen de lo que se requeriría:**
1. Crear `DianClient` en `app/clients/` siguiendo el patrón de `ClientServiceClient` y `AuditServiceClient`
2. Crear `EnviarFacturaDianService` para orquestar el envío a DIAN
3. Agregar estados adicionales a las facturas: `pendiente_dian`, `aprobada_dian`, etc.
4. Mapear el formato interno de facturas al formato requerido por DIAN
5. Implementar retry y manejo de errores para resiliencia

---

## 📝 Nota Histórica sobre Oracle

> Inicialmente se intentó usar Oracle Database para esta aplicación, pero debido a problemas con la descarga de Oracle Instant Client, se decidió cambiar a PostgreSQL. 
> Las referencias a Oracle se mantienen comentadas en los siguientes archivos como registro histórico:
> - `docker-compose.yml` - Configuración del servicio Oracle (comentado)
> - `Dockerfile` - Instalación de Oracle Instant Client (comentado)
> - `Gemfile` - Gemas de Oracle (comentado)
> - `config/database.yml` - Configuración de Oracle (comentado)

## 👥 Desarrollado para

**Prueba tecnica Double V Partners**
> **Nota**: Este proyecto forma parte de una prueba técnica para la modernización del sistema de facturación electrónica.
