# Microservicios - Responsabilidades e Interacciones

## 📋 Índice

- [Arquitectura General](#arquitectura-general)
- [Microservicios](#microservicios)
- [Comunicación entre Microservicios](#comunicación-entre-microservicios)
- [Flujos Principales](#flujos-principales)

---

## 🏗️ Arquitectura General

Arquitectura de microservicios donde cada servicio:
- ✅ Tiene su propia base de datos
- ✅ Se comunica vía HTTP REST
- ✅ Puede escalarse y desplegarse independientemente

---

## 🔧 Microservicios

### 1. Client Service

**Puerto:** 3001  
**Base de Datos:** PostgreSQL (`client_service_development`)  
**ORM:** ActiveRecord

#### Responsabilidades

- Gestión de clientes (CRUD completo)
- Validación de datos (NIT único, formato email, etc.)
- Consultas y filtros (activos/inactivos)

#### Endpoints

```
GET    /api/v1/clientes          # Listar
GET    /api/v1/clientes/:id      # Obtener
POST   /api/v1/clientes          # Crear
PUT    /api/v1/clientes/:id      # Actualizar
DELETE /api/v1/clientes/:id      # Desactivar
```

#### Dependencias

- ❌ No depende de otros servicios
- ✅ Consumido por Invoice Service

---

### 2. Invoice Service

**Puerto:** 3002  
**Base de Datos:** PostgreSQL (`invoice_service_development`)  
**ORM:** ActiveRecord

#### Responsabilidades

- Gestión completa de facturas (crear, emitir, anular)
- Validación de reglas de negocio
- Cálculo automático de totales e impuestos
- Integración con Client Service (validar cliente)
- Integración con Audit Service (registrar eventos)

#### Endpoints

```
GET    /api/v1/facturas              # Listar
GET    /api/v1/facturas/:id          # Obtener
POST   /api/v1/facturas              # Crear (borrador)
POST   /api/v1/facturas/:id/emitir   # Emitir
POST   /api/v1/facturas/:id/anular   # Anular
```

#### Servicios Clave

- `CrearFacturaService`: Valida cliente, crea factura, registra auditoría
- `EmitirFacturaService`: Valida reglas, genera número, cambia estado
- `AnularFacturaService`: Valida y anula factura

#### Dependencias

- ✅ Depende de Client Service y Audit Service
- ✅ Consumido por aplicaciones externas

---

### 3. Audit Service

**Puerto:** 3003  
**Bases de Datos:** 
- MongoDB (`audit_service_development`) - Eventos raw
- PostgreSQL (`audit_service_reports_development`) - Métricas agregadas  
**ORMs:** Mongoid (MongoDB) + ActiveRecord (PostgreSQL)

#### Responsabilidades

- Registrar eventos de auditoría de todos los servicios
- Almacenar eventos raw en MongoDB
- Agregar métricas en PostgreSQL para reportes eficientes
- Consultar eventos y generar reportes

#### Endpoints Principales

```
POST   /api/v1/auditoria/eventos                # Registrar evento (interno)
GET    /api/v1/auditoria/eventos                # Listar eventos (con filtros)
GET    /api/v1/auditoria/eventos/:id            # Obtener evento por ID
GET    /api/v1/auditoria/reportes               # Métricas detalladas
GET    /api/v1/auditoria/reportes/resumen       # Resumen agregado
```

#### Modelos

- **EventoAuditoria** (MongoDB - Mongoid):
  - Campos: `evento`, `timestamp`, `servicio`, `entidad_tipo`, `entidad_id`, `usuario_id`, `datos`
  - Índices: evento, servicio, entidad_tipo+entidad_id, timestamp
  - Propósito: Almacenamiento de eventos raw con información completa

- **ReporteMetricas** (PostgreSQL - ActiveRecord):
  - Campos: `fecha`, `servicio`, `evento`, `cantidad`, `datos_adicionales`
  - Métodos: `incrementar(fecha, servicio, evento, cantidad, datos)`
  - Scopes: `por_fecha`, `por_servicio`, `por_evento`
  - Propósito: Métricas agregadas para reportes eficientes

#### Servicios (Service Objects)

- **AgregarMetricasService**: Servicio ETL para agregación de métricas
  - Lee eventos del día desde MongoDB
  - Agrega e incrementa métricas en PostgreSQL
  - Maneja duplicados (incrementa si existe, crea si no)

#### Eventos Registrados

El sistema registra los siguientes eventos:

- **FacturaCreada**: Cuando se crea una nueva factura
  - Servicio: `invoice-service`
  - Datos: `cliente_id`, `estado`, `total`, `items_count`

- **FacturaEmitida**: Cuando se emite una factura
  - Servicio: `invoice-service`
  - Datos: `numero_factura`, `cliente_id`, `fecha_emision`, `total`, `items_count`

- **FacturaAnulada**: Cuando se anula una factura
  - Servicio: `invoice-service`
  - Datos: `numero_factura`, `cliente_id`, `motivo`, `total`

#### Dependencias

- ❌ **No depende de otros microservicios**
- ✅ **Es consumido por:** Invoice Service (y potencialmente otros servicios en el futuro)

---

## 🔄 Comunicación entre Microservicios

### Estrategia de Comunicación

El sistema utiliza **comunicación síncrona HTTP REST** entre microservicios. Esta decisión se tomó por:

- ✅ Simplicidad de implementación (MVP)
- ✅ Facilidad de debugging y trazabilidad
- ✅ No requiere infraestructura adicional (message broker)
- ✅ Adecuado para el volumen esperado inicial

### Patrón de Comunicación

```
┌─────────────────┐
│ Invoice Service │
└────────┬────────┘
         │
         │ HTTP REST (Síncrono)
         │
    ┌────┴────┐
    │         │
    ▼         ▼
┌─────────┐ ┌─────────┐
│ Client  │ │  Audit  │
│ Service │ │ Service │
└─────────┘ └─────────┘
```

### Flujos de Comunicación

#### 1. Invoice Service → Client Service

**Propósito:** Validar que un cliente existe y está activo antes de crear una factura

**Método HTTP:** `GET`  
**Endpoint:** `/api/v1/clientes/:id`  
**Cuándo se usa:**
- Al crear una nueva factura
- Durante la validación en `CrearFacturaService`

**Ejemplo:**
```ruby
# En Invoice Service
client = ClientServiceClient.new
cliente = client.obtener_cliente(cliente_id)

# Si el cliente no existe o está inactivo, se lanza un error
unless client.cliente_activo?(cliente_id)
  raise BusinessError.new("Cliente no existe o está inactivo")
end
```

**Manejo de Errores:**
- Si el cliente no existe: Error 404 → Invoice Service lanza `BusinessError`
- Si el cliente está inactivo: Invoice Service valida y rechaza la operación
- Si Client Service está caído: Invoice Service debería manejar el timeout (actualmente lanza error)

---

#### 2. Invoice Service → Audit Service

**Propósito:** Registrar eventos de auditoría cuando ocurren acciones importantes

**Método HTTP:** `POST`  
**Endpoint:** `/api/v1/auditoria/eventos`  
**Cuándo se usa:**
- Al crear una factura → Evento: `FacturaCreada`
- Al emitir una factura → Evento: `FacturaEmitida`
- Al anular una factura → Evento: `FacturaAnulada`

**Ejemplo:**
```ruby
# En Invoice Service
audit = AuditServiceClient.new
audit.registrar_evento(
  'FacturaCreada',
  'invoice-service',
  'Factura',
  factura.id,
  {
    cliente_id: factura.cliente_id,
    estado: factura.estado,
    total: factura.total.to_s,
    items_count: factura.items_factura.count
  }
)
```

**Características:**
- **No bloqueante**: Si Audit Service falla, no interrumpe el flujo principal
- **Fire and forget**: Se registra el evento pero no se espera confirmación crítica
- **Resiliente**: Los errores se loggean pero no afectan la operación principal

**Manejo de Errores:**
- Si Audit Service está caído: Se loggea el error pero la operación continúa
- Si hay timeout: Se loggea y continúa
- La factura se crea/emite/anula independientemente del resultado de auditoría

---

## 📊 Flujos Principales

### Crear Factura
1. Validar cliente con Client Service
2. Crear factura en PostgreSQL
3. Registrar evento en Audit Service

### Emitir Factura
1. Validar reglas de negocio
2. Generar número de factura único
3. Actualizar estado a "emitida"
4. Registrar evento de auditoría

### Anular Factura
1. Validar que está emitida
2. Cambiar estado a "anulada"
3. Registrar evento con motivo

### Consultar Reportes
1. Consultar métricas agregadas en PostgreSQL
2. O consultar eventos raw en MongoDB
3. Aplicar filtros por fecha/servicio/evento

---

**Versión**: 1.0  
**Última actualización**: 2025

