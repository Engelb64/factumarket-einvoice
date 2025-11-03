# Arquitectura del Sistema FactuMarket S.A.

## 🎯 Objetivo

Sistema de facturación electrónica basado en microservicios, Clean Architecture y MVC, enfocado en MVP con implementación pragmática.

---

## 🏗️ Microservicios

### 1. Client Service (Puerto 3001)

**Responsabilidades:**
- Gestión de clientes (CRUD)
- Validación de datos (NIT, email, etc.)

**Base de datos:** PostgreSQL (`client_service_development`)

---

### 2. Invoice Service (Puerto 3002)

**Responsabilidades:**
- Crear, emitir y anular facturas
- Validar reglas de negocio
- Calcular totales e impuestos

**Base de datos:** PostgreSQL (`invoice_service_development`)

**Comunicación:**
- Consulta Client Service para validar clientes
- Envía eventos a Audit Service

---

### 3. Audit Service (Puerto 3003)

**Responsabilidades:**
- Registrar eventos de auditoría
- Generar reportes y métricas agregadas

**Bases de datos:**
- MongoDB: Eventos raw (`audit_service_development`)
- PostgreSQL: Métricas agregadas (`audit_service_reports_development`)

---

## 🔄 Comunicación

**Tipo:** HTTP REST síncrono

**Flujos:**
- Invoice Service → Client Service: Validar cliente (bloqueante, crítico)
- Invoice Service → Audit Service: Registrar eventos (no bloqueante)

**Ejemplo - Crear Factura:**
```
1. Validar cliente con Client Service
2. Crear factura en PostgreSQL
3. Registrar evento en Audit Service (si falla, se loggea pero continúa)
```

---

## 💾 Persistencia

**PostgreSQL:** Datos transaccionales
- Client Service: `clientes`
- Invoice Service: `facturas`, `items_factura`
- Audit Service: `metricas_auditoria` (reportes agregados)

**MongoDB:** Eventos de auditoría raw
- Audit Service: `eventos_auditoria` (eventos completos con toda la información)

---

## 🏛️ Clean Architecture

**Estructura por capas:**

```
Controllers → Services → Models → Database
   (MVC)      (App)      (Domain)  (Infra)
```

- **Controllers:** Reciben HTTP, delegan a Services
- **Services:** Orquestan casos de uso, coordinan entre servicios
- **Models:** Contienen lógica de negocio y validaciones
- **Clients:** Acceso a otros microservicios (Infraestructura)

---

## 📐 Diagrama de Arquitectura (Simplificado)

```
┌─────────────────────────────────────┐
│         Clientes / Apps             │
└──────────────────┬──────────────────┘
                   │
                   │ HTTP/REST
                   │
    ┌──────────────┴──────────────┐
    │                             │
    ▼                             ▼
┌──────────────┐          ┌──────────────┐
│ Client       │          │ Invoice      │
│ Service      │          │ Service      │
│ Port: 3001   │          │ Port: 3002   │
│              │          │              │
│ Controllers  │◄─────────┤ Controllers  │
│ Services     │  REST    │ Services     │
│ Models       │          │ Models       │
│              │          │              │
│ PostgreSQL   │          │ PostgreSQL   │
└──────────────┘          └──────┬───────┘
                                 │
                                 │ POST REST
                                 │
                                 ▼
                          ┌──────────────┐
                          │ Audit        │
                          │ Service      │
                          │ Port: 3003   │
                          │              │
                          │ Controllers  │
                          │              │
                          │ MongoDB      │
                          └──────────────┘
```

---

## 🗺️ Plan de Implementación (MVP)

### Fase 1: Setup Base (1 día) ✅
- [x] Configurar 3 servicios Rails en Docker Compose
- [x] Setup PostgreSQL y MongoDB
- [x] Estructura básica de carpetas

### Fase 2: Client Service (1 día) ✅
- [x] Modelo Cliente (PostgreSQL)
- [x] CRUD básico (Controllers)
- [x] Tests básicos

### Fase 3: Invoice Service (2 días) ✅
- [x] Modelos Factura e Items (PostgreSQL)
- [x] Servicios: crear, emitir, anular
- [x] Integración con Client Service (REST)
- [x] Tests básicos

### Fase 4: Audit Service (1 día) ✅
- [x] Modelo EventoAuditoria (MongoDB)
- [x] Endpoint para registrar eventos
- [x] Integración desde Invoice Service
- [x] Tests básicos

### Fase 5: Validaciones y Mejoras (1 día) ✅
- [x] Validaciones de negocio
- [x] Manejo de errores
- [x] Documentación básica

**Total estimado: ~5 días**

---

## 🔧 Stack Tecnológico (Minimalista)

- **Framework**: Ruby on Rails 7.2+
- **Bases de Datos**: PostgreSQL 16 + MongoDB 7.0
- **ORM**: ActiveRecord (PostgreSQL) + Mongoid (MongoDB)
- **Contenedores**: Docker Compose
- **Testing**: RSpec (tests básicos)
- **Sin Message Broker inicial** (REST directo)

---

## ✅ Principios Aplicados (Simplificados)

### Microservicios
- ✅ Separación por responsabilidad (Clientes, Facturas, Auditoría)
- ✅ Despliegue independiente (Docker Compose)
- ✅ Base de datos propia por servicio

### Clean Architecture (Ligera)
- ✅ Separación de capas (Controllers → Services → Models → Repositories)
- ✅ Lógica de negocio en Services y Models
- ✅ Infraestructura aislada en Repositories

### MVC
- ✅ Controllers: Reciben HTTP, llaman Services
- ✅ Models: Entidades con validaciones
- ✅ Views: JSON serializers (para APIs REST)

---

## 📝 Decisiones de Simplificación

1. **Solo REST**: Sin eventos asíncronos inicialmente (se agregan después si es necesario)
2. **Sin Saga Pattern**: Transacciones simples, compensación manual si falla
3. **Sin CQRS**: Lectura y escritura en las mismas tablas
4. **Sin Event Sourcing**: Auditoría como eventos simples, no como fuente de verdad
5. **Enfoque MVP**: Funcionalidades esenciales primero, mejoras después

---

---

## ✅ Validaciones de Negocio

### Cliente
- NIT: Único, formato válido (8-20 caracteres)
- Nombre: Requerido (3-200 caracteres)
- Email: Formato válido (opcional)

### Factura
- Estado: Solo `borrador`, `emitida`, `anulada`
- Reglas: Solo borradores pueden emitirse, solo emitidas pueden anularse
- Items: Requeridos antes de emitir, no modificables si está emitida/anulada

### Item Factura
- Cantidad: > 0
- Precio: >= 0
- Impuesto: 0-100%

---

## 🔧 Manejo de Errores

**Errores centralizados** en `ApplicationController`:
- `BusinessError`: Errores de negocio con código y detalles
- `RecordNotFound`: 404
- `RecordInvalid`: 422 con detalles de validación
- `StandardError`: 500 (solo detalles en desarrollo)

**Códigos principales:**
- `FACTURA_NO_PUEDE_EMITIRSE` / `FACTURA_NO_PUEDE_ANULARSE`
- `VALIDATION_ERROR` / `NOT_FOUND` / `INTERNAL_ERROR`

---

**Versión**: 1.0 
**Última actualización**: 2025
