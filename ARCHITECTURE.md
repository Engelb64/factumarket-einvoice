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

## 🔌 Integración Futura con Entidad Tributaria (DIAN)

### Preparación Arquitectónica

La arquitectura actual está diseñada para facilitar la integración futura con la entidad tributaria nacional (DIAN u organismo equivalente) sin requerir cambios estructurales mayores.

#### Patrón de Integración

El sistema ya utiliza el patrón de **HTTP Clients** en la capa de infraestructura (`app/clients/`), que puede extenderse para integrar servicios externos:

**Estructura actual:**
```
services/invoice-service/app/clients/
├── client_service_client.rb      # Integración con Client Service
└── audit_service_client.rb       # Integración con Audit Service
```

**Para DIAN se agregaría:**
```
services/invoice-service/app/clients/
└── dian_client.rb                # Integración con DIAN (futuro)
```

#### Punto de Integración

El servicio `EmitirFacturaService` es el punto natural donde se integraría DIAN:

```ruby
# Estructura actual (simplificada)
class EmitirFacturaService
  def ejecutar(factura_id)
    factura = Factura.find(factura_id)
    factura.emitir!  # Genera número de factura
    
    # 1. Registrar auditoría (actual)
    @audit_service_client.registrar_evento(...)
    
    # 2. Enviar a DIAN (futuro - aquí se agregaría)
    # @dian_client.enviar_factura(factura)
    
    factura
  end
end
```

#### Consideraciones de Implementación

**1. Formato de Datos:**
- Las facturas ya incluyen toda la información necesaria (cliente, items, totales, impuestos)
- Se requerirá mapear el formato interno al formato requerido por DIAN (XML, JSON, etc.)

**2. Validaciones Adicionales:**
- Validar que la factura cumple con requisitos de DIAN antes de enviar
- Manejar respuestas de DIAN (aprobada, rechazada, pendiente)

**3. Manejo de Estados:**
- Agregar estados adicionales: `pendiente_dian`, `aprobada_dian`, `rechazada_dian`
- Mantener el estado local mientras se procesa en DIAN

**4. Resiliencia:**
- Implementar retry en caso de fallos temporales
- Cola de reintentos para facturas no enviadas
- Logging detallado de intentos y respuestas

**5. Separación de Responsabilidades:**
- Crear un nuevo servicio: `EnviarFacturaDianService`
- Aislar la lógica de integración en el Client
- No afectar el flujo principal si DIAN está caído (opcional, según requerimientos)

#### Ejemplo de Implementación Futura

```ruby
# app/clients/dian_client.rb
class DianClient
  include HTTParty
  
  def initialize(base_url = nil)
    @base_url = base_url || ENV.fetch('DIAN_API_URL')
    self.class.base_uri @base_url
    self.class.headers 'Content-Type' => 'application/json'
  end
  
  def enviar_factura(factura)
    body = mapear_a_formato_dian(factura)
    response = self.class.post('/api/facturas', body: body.to_json)
    
    if response.success?
      { estado: 'enviada', numero_autorizacion: response['numero_autorizacion'] }
    else
      { estado: 'rechazada', error: response['mensaje'] }
    end
  rescue => e
    Rails.logger.error "Error enviando factura a DIAN: #{e.message}"
    { estado: 'error', error: e.message }
  end
  
  private
  
  def mapear_a_formato_dian(factura)
    {
      numero_factura: factura.numero_factura,
      fecha_emision: factura.fecha_emision,
      cliente: {
        nit: obtener_nit_cliente(factura.cliente_id),
        nombre: obtener_nombre_cliente(factura.cliente_id)
      },
      items: factura.items_factura.map { |item| ... },
      totales: {
        subtotal: factura.subtotal,
        impuestos: factura.impuestos,
        total: factura.total
      }
    }
  end
end

# app/services/enviar_factura_dian_service.rb
class EnviarFacturaDianService
  def initialize(dian_client: nil)
    @dian_client = dian_client || DianClient.new
  end
  
  def ejecutar(factura_id)
    factura = Factura.find(factura_id)
    resultado = @dian_client.enviar_factura(factura)
    
    factura.update(
      estado_dian: resultado[:estado],
      numero_autorizacion_dian: resultado[:numero_autorizacion],
      fecha_envio_dian: DateTime.current
    )
    
    resultado
  end
end

# Modificación en EmitirFacturaService
class EmitirFacturaService
  def ejecutar(factura_id)
    factura = Factura.find(factura_id)
    factura.emitir!
    
    # Auditoría
    @audit_service_client.registrar_evento(...)
    
    # Integración DIAN (futuro)
    if ENV['ENABLE_DIAN_INTEGRATION'] == 'true'
      EnviarFacturaDianService.new.ejecutar(factura.id)
    end
    
    factura
  end
end
```

#### Ventajas de la Arquitectura Actual

✅ **Separación de capas**: La lógica de integración estaría aislada en Clients (Infraestructura)
✅ **Services extensibles**: Los servicios pueden integrar nuevas funcionalidades sin cambiar lógica de negocio
✅ **Sin acoplamiento**: La integración con DIAN no afecta el funcionamiento interno
✅ **Testing facilitado**: Se pueden mockear los clients fácilmente
✅ **Despliegue gradual**: Se puede activar con variables de entorno

---

**Versión**: 1.0 
**Última actualización**: 2025
