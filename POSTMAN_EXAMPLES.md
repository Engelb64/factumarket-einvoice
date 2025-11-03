# Ejemplos para Postman - FactuMarket E-Invoice

Esta guía contiene ejemplos de requests para probar todos los endpoints de los microservicios usando Postman.

## 📋 Configuración Inicial

### Variables de Entorno en Postman

Crea un entorno en Postman con las siguientes variables:

| Variable | Valor |
|----------|-------|
| `base_url_client` | `http://localhost:3001` |
| `base_url_invoice` | `http://localhost:3002` |
| `base_url_audit` | `http://localhost:3003` |

**Configurar en Postman:**
1. Click en el ícono de engranaje (⚙️) en la esquina superior derecha
2. Click en "Add" para crear un nuevo entorno
3. Agrega las variables de la tabla anterior
4. Guarda y selecciona el entorno

---

## 🔵 Client Service (Puerto 3001)

### 1. Listar Todos los Clientes

**Método:** `GET`  
**URL:** `{{base_url_client}}/api/v1/clientes`

**Headers:**
```
Content-Type: application/json
```

**Ejemplo de Respuesta:**
```json
[
  {
    "id": 1,
    "nit": "12345678-9",
    "nombre": "Empresa ABC S.A.",
    "email": "contacto@abc.com",
    "telefono": "2222-3333",
    "direccion": "Calle Principal 123, Ciudad",
    "activo": true,
    "created_at": "2025-01-15T10:00:00.000Z",
    "updated_at": "2025-01-15T10:00:00.000Z"
  }
]
```

---

### 2. Obtener Cliente por ID

**Método:** `GET`  
**URL:** `{{base_url_client}}/api/v1/clientes/1`

**Headers:**
```
Content-Type: application/json
```

**Ejemplo de Respuesta:**
```json
{
  "id": 1,
  "nit": "12345678-9",
  "nombre": "Empresa ABC S.A.",
  "email": "contacto@abc.com",
  "telefono": "2222-3333",
  "direccion": "Calle Principal 123, Ciudad",
  "activo": true,
  "created_at": "2025-01-15T10:00:00.000Z",
  "updated_at": "2025-01-15T10:00:00.000Z"
}
```

---

### 3. Crear Cliente

**Método:** `POST`  
**URL:** `{{base_url_client}}/api/v1/clientes`

**Headers:**
```
Content-Type: application/json
```

**Body (JSON):**
```json
{
  "cliente": {
    "nit": "12345678-9",
    "nombre": "Empresa ABC S.A.",
    "email": "contacto@abc.com",
    "telefono": "2222-3333",
    "direccion": "Calle Principal 123, Ciudad"
  }
}
```

**Ejemplo de Respuesta (201 Created):**
```json
{
  "id": 1,
  "nit": "12345678-9",
  "nombre": "Empresa ABC S.A.",
  "email": "contacto@abc.com",
  "telefono": "2222-3333",
  "direccion": "Calle Principal 123, Ciudad",
  "activo": true,
  "created_at": "2025-01-15T10:00:00.000Z",
  "updated_at": "2025-01-15T10:00:00.000Z"
}
```

**Ejemplo de Error (422 Unprocessable Entity):**
```json
{
  "errors": ["Nit has already been taken"],
  "code": "VALIDATION_ERROR",
  "details": {
    "nit": ["has already been taken"]
  }
}
```

---

### 4. Actualizar Cliente

**Método:** `PUT`  
**URL:** `{{base_url_client}}/api/v1/clientes/1`

**Headers:**
```
Content-Type: application/json
```

**Body (JSON):**
```json
{
  "cliente": {
    "nombre": "Empresa ABC Actualizada S.A.",
    "email": "nuevo-email@abc.com",
    "telefono": "9999-8888",
    "direccion": "Nueva Dirección 456, Ciudad"
  }
}
```

**Ejemplo de Respuesta (200 OK):**
```json
{
  "id": 1,
  "nit": "12345678-9",
  "nombre": "Empresa ABC Actualizada S.A.",
  "email": "nuevo-email@abc.com",
  "telefono": "9999-8888",
  "activo": true,
  "updated_at": "2025-01-15T11:00:00.000Z"
}
```

---

### 5. Desactivar Cliente

**Método:** `DELETE`  
**URL:** `{{base_url_client}}/api/v1/clientes/1`

**Headers:**
```
Content-Type: application/json
```

**Ejemplo de Respuesta (200 OK):**
```json
{
  "id": 1,
  "nit": "12345678-9",
  "nombre": "Empresa ABC S.A.",
  "activo": false,
  "updated_at": "2025-01-15T12:00:00.000Z"
}
```

---

## 🟢 Invoice Service (Puerto 3002)

### 1. Listar Todas las Facturas

**Método:** `GET`  
**URL:** `{{base_url_invoice}}/api/v1/facturas`

**Headers:**
```
Content-Type: application/json
```

**Ejemplo de Respuesta:**
```json
[
  {
    "id": 1,
    "numero_factura": null,
    "cliente_id": 1,
    "estado": "borrador",
    "subtotal": 250.0,
    "impuestos": 32.5,
    "total": 282.5,
    "fecha_emision": null,
    "items_factura": [
      {
        "id": 1,
        "descripcion": "Producto A",
        "cantidad": 2,
        "precio_unitario": 100.0,
        "subtotal": 200.0,
        "impuesto_porcentaje": 13
      }
    ]
  }
]
```

---

### 2. Obtener Factura por ID

**Método:** `GET`  
**URL:** `{{base_url_invoice}}/api/v1/facturas/1`

**Headers:**
```
Content-Type: application/json
```

**Ejemplo de Respuesta:**
```json
{
  "id": 1,
  "numero_factura": "FM-2025-000001",
  "cliente_id": 1,
  "estado": "emitida",
  "subtotal": 250.0,
  "impuestos": 32.5,
  "total": 282.5,
  "fecha_emision": "2025-01-15",
  "items_factura": [
    {
      "id": 1,
      "descripcion": "Producto A",
      "cantidad": 2,
      "precio_unitario": 100.0,
      "subtotal": 200.0,
      "impuesto_porcentaje": 13
    }
  ]
}
```

---

### 3. Crear Factura (Borrador)

**Método:** `POST`  
**URL:** `{{base_url_invoice}}/api/v1/facturas`

**Headers:**
```
Content-Type: application/json
```

**Body (JSON):**
```json
{
  "factura": {
    "cliente_id": 1,
    "items_factura_attributes": [
      {
        "descripcion": "Producto A - Servicio de Consultoría",
        "cantidad": 2,
        "precio_unitario": 100.00,
        "impuesto_porcentaje": 13
      },
      {
        "descripcion": "Producto B - Licencia Mensual",
        "cantidad": 1,
        "precio_unitario": 50.00,
        "impuesto_porcentaje": 13
      }
    ]
  }
}
```

**Ejemplo de Respuesta (201 Created):**
```json
{
  "id": 1,
  "numero_factura": null,
  "cliente_id": 1,
  "estado": "borrador",
  "subtotal": 250.0,
  "impuestos": 32.5,
  "total": 282.5,
  "fecha_emision": null,
  "items_factura": [
    {
      "id": 1,
      "descripcion": "Producto A - Servicio de Consultoría",
      "cantidad": 2,
      "precio_unitario": 100.0,
      "subtotal": 200.0,
      "impuesto_porcentaje": 13
    },
    {
      "id": 2,
      "descripcion": "Producto B - Licencia Mensual",
      "cantidad": 1,
      "precio_unitario": 50.0,
      "subtotal": 50.0,
      "impuesto_porcentaje": 13
    }
  ]
}
```

**Ejemplo de Error (422 Unprocessable Entity):**
```json
{
  "error": "No se pudo validar el cliente. Intente más tarde.",
  "code": "BUSINESS_ERROR"
}
```

---

### 4. Emitir Factura

**Método:** `POST`  
**URL:** `{{base_url_invoice}}/api/v1/facturas/1/emitir`

**Headers:**
```
Content-Type: application/json
```

**Body (JSON):** *(vacío o {}*

**Ejemplo de Respuesta (200 OK):**
```json
{
  "id": 1,
  "numero_factura": "FM-2025-000001",
  "cliente_id": 1,
  "estado": "emitida",
  "subtotal": 250.0,
  "impuestos": 32.5,
  "total": 282.5,
  "fecha_emision": "2025-01-15",
  "items_factura": [...]
}
```

**Ejemplo de Error (422 Unprocessable Entity):**
```json
{
  "error": "La factura no puede ser emitida",
  "code": "FACTURA_NO_PUEDE_EMITIRSE",
  "details": {
    "estado": "emitida",
    "tiene_items": true,
    "tiene_cliente": true,
    "total_mayor_cero": true
  }
}
```

---

### 5. Anular Factura

**Método:** `POST`  
**URL:** `{{base_url_invoice}}/api/v1/facturas/1/anular`

**Headers:**
```
Content-Type: application/json
```

**Body (JSON):**
```json
{
  "motivo": "Error en datos del cliente"
}
```

**Ejemplo de Respuesta (200 OK):**
```json
{
  "id": 1,
  "numero_factura": "FM-2025-000001",
  "cliente_id": 1,
  "estado": "anulada",
  "subtotal": 250.0,
  "impuestos": 32.5,
  "total": 282.5,
  "fecha_emision": "2025-01-15"
}
```

**Ejemplo de Error (422 Unprocessable Entity):**
```json
{
  "error": "La factura no puede ser anulada. Solo se pueden anular facturas emitidas.",
  "code": "FACTURA_NO_PUEDE_ANULARSE",
  "details": {
    "estado": "borrador"
  }
}
```

---

## 🟡 Audit Service (Puerto 3003)

### 1. Listar Todos los Eventos de Auditoría

**Método:** `GET`  
**URL:** `{{base_url_audit}}/api/v1/auditoria/eventos`

**Headers:**
```
Content-Type: application/json
```

**Query Parameters (Opcionales):**
- `servicio`: Filtrar por servicio (ej: `invoice-service`)
- `evento`: Filtrar por tipo de evento (ej: `FacturaCreada`)
- `entidad_tipo`: Filtrar por tipo de entidad (ej: `Factura`)
- `entidad_id`: Filtrar por ID de entidad (ej: `1`)
- `desde`: Fecha desde (formato: `2025-01-15`)
- `hasta`: Fecha hasta (formato: `2025-01-16`)

**Ejemplo con Filtros:**
```
GET {{base_url_audit}}/api/v1/auditoria/eventos?servicio=invoice-service&evento=FacturaCreada
```

**Ejemplo de Respuesta:**
```json
[
  {
    "_id": {
      "$oid": "65a1b2c3d4e5f6g7h8i9j0k1"
    },
    "evento": "FacturaCreada",
    "timestamp": "2025-01-15T10:30:00Z",
    "servicio": "invoice-service",
    "entidad_tipo": "Factura",
    "entidad_id": "1",
    "usuario_id": null,
    "datos": {
      "cliente_id": 1,
      "estado": "borrador",
      "total": "250.00",
      "items_count": 2
    },
    "created_at": "2025-01-15T10:30:00.000Z"
  },
  {
    "_id": {
      "$oid": "65a1b2c3d4e5f6g7h8i9j0k2"
    },
    "evento": "FacturaEmitida",
    "timestamp": "2025-01-15T11:00:00Z",
    "servicio": "invoice-service",
    "entidad_tipo": "Factura",
    "entidad_id": "1",
    "usuario_id": null,
    "datos": {
      "numero_factura": "FM-2025-000001",
      "cliente_id": 1,
      "fecha_emision": "2025-01-15",
      "total": "250.00"
    },
    "created_at": "2025-01-15T11:00:00.000Z"
  }
]
```

---

### 2. Obtener Evento por ID

**Método:** `GET`  
**URL:** `{{base_url_audit}}/api/v1/auditoria/eventos/{id}`

**Headers:**
```
Content-Type: application/json
```

**Ejemplo de Respuesta:**
```json
{
  "_id": {
    "$oid": "65a1b2c3d4e5f6g7h8i9j0k1"
  },
  "evento": "FacturaCreada",
  "timestamp": "2025-01-15T10:30:00Z",
  "servicio": "invoice-service",
  "entidad_tipo": "Factura",
  "entidad_id": "1",
  "datos": {
    "cliente_id": 1,
    "estado": "borrador",
    "total": "250.00"
  }
}
```

---

### 3. Crear Evento de Auditoría

**Método:** `POST`  
**URL:** `{{base_url_audit}}/api/v1/auditoria/eventos`

**Headers:**
```
Content-Type: application/json
```

**Body (JSON):**
```json
{
  "evento": "FacturaCreada",
  "servicio": "invoice-service",
  "entidad_tipo": "Factura",
  "entidad_id": "1",
  "usuario_id": null,
  "datos": {
    "cliente_id": 1,
    "estado": "borrador",
    "total": "250.00",
    "items_count": 2
  }
}
```

**Ejemplo de Respuesta (201 Created):**
```json
{
  "_id": {
    "$oid": "65a1b2c3d4e5f6g7h8i9j0k1"
  },
  "evento": "FacturaCreada",
  "timestamp": "2025-01-15T10:30:00Z",
  "servicio": "invoice-service",
  "entidad_tipo": "Factura",
  "entidad_id": "1",
  "usuario_id": null,
  "datos": {
    "cliente_id": 1,
    "estado": "borrador",
    "total": "250.00",
    "items_count": 2
  }
}
```

---

### 4. Consultar Reportes (Métricas Agregadas)

**Método:** `GET`  
**URL:** `{{base_url_audit}}/api/v1/auditoria/reportes`

**Headers:**
```
Content-Type: application/json
```

**Query Parameters (Opcionales):**
- `desde`: Fecha desde (formato: `2025-01-15`) - **Requerido**
- `hasta`: Fecha hasta (formato: `2025-01-16`) - Opcional (default: hoy)
- `servicio`: Filtrar por servicio (ej: `invoice-service`)
- `evento`: Filtrar por tipo de evento (ej: `FacturaCreada`)

**Ejemplo:**
```
GET {{base_url_audit}}/api/v1/auditoria/reportes?desde=2025-01-15&servicio=invoice-service
```

**Ejemplo de Respuesta:**
```json
[
  {
    "id": 1,
    "fecha": "2025-01-15",
    "servicio": "invoice-service",
    "evento": "FacturaCreada",
    "cantidad": 5,
    "created_at": "2025-01-16T00:00:00.000Z",
    "updated_at": "2025-01-16T00:00:00.000Z"
  },
  {
    "id": 2,
    "fecha": "2025-01-15",
    "servicio": "invoice-service",
    "evento": "FacturaEmitida",
    "cantidad": 3,
    "created_at": "2025-01-16T00:00:00.000Z",
    "updated_at": "2025-01-16T00:00:00.000Z"
  },
  {
    "id": 3,
    "fecha": "2025-01-15",
    "servicio": "invoice-service",
    "evento": "FacturaAnulada",
    "cantidad": 1,
    "created_at": "2025-01-16T00:00:00.000Z",
    "updated_at": "2025-01-16T00:00:00.000Z"
  }
]
```

---

### 5. Consultar Resumen de Reportes

**Método:** `GET`  
**URL:** `{{base_url_audit}}/api/v1/auditoria/reportes/resumen`

**Headers:**
```
Content-Type: application/json
```

**Query Parameters:**
- `desde`: Fecha desde (formato: `2025-01-15`)
- `hasta`: Fecha hasta (formato: `2025-01-16`) - Opcional
- `servicio`: Filtrar por servicio - Opcional

**Ejemplo:**
```
GET {{base_url_audit}}/api/v1/auditoria/reportes/resumen?desde=2025-01-15
```

**Ejemplo de Respuesta:**
```json
{
  "total_eventos": 9,
  "por_servicio": {
    "invoice-service": 9
  },
  "por_evento": {
    "FacturaCreada": 5,
    "FacturaEmitida": 3,
    "FacturaAnulada": 1
  },
  "periodo": {
    "desde": "2025-01-15",
    "hasta": "2025-01-15"
  }
}
```

---

## 🔄 Flujo Completo de Ejemplo

### Paso 1: Crear un Cliente
```
POST {{base_url_client}}/api/v1/clientes
Body: {
  "cliente": {
    "nit": "12345678-9",
    "nombre": "Empresa ABC S.A.",
    "email": "contacto@abc.com"
  }
}
```
**Guardar el `id` del cliente en una variable de Postman**

### Paso 2: Crear una Factura
```
POST {{base_url_invoice}}/api/v1/facturas
Body: {
  "factura": {
    "cliente_id": 1,  // Usar el ID del paso 1
    "items_factura_attributes": [
      {
        "descripcion": "Producto A",
        "cantidad": 2,
        "precio_unitario": 100.00,
        "impuesto_porcentaje": 13
      }
    ]
  }
}
```
**Guardar el `id` de la factura**

### Paso 3: Emitir la Factura
```
POST {{base_url_invoice}}/api/v1/facturas/1/emitir
Body: {}
```
**Esto generará un número de factura y cambiará el estado a "emitida"**

### Paso 4: Verificar Eventos de Auditoría
```
GET {{base_url_audit}}/api/v1/auditoria/eventos?entidad_id=1
```
**Deberías ver eventos: "FacturaCreada" y "FacturaEmitida"**

---

## 📝 Notas Importantes

1. **Orden de Ejecución**: Algunos endpoints requieren que otros se ejecuten primero:
   - Crear factura requiere que exista un cliente
   - Emitir factura requiere que la factura esté en estado "borrador" con items
   - Anular factura requiere que la factura esté en estado "emitida"

2. **Validaciones**:
   - NIT debe ser único en Client Service
   - Facturas no pueden emitirse sin items o con total = 0
   - Solo facturas "emitidas" pueden anularse

3. **Códigos de Error Comunes**:
   - `404`: Recurso no encontrado
   - `422`: Error de validación o regla de negocio
   - `500`: Error interno del servidor

4. **Variables de Postman**: Puedes usar variables dinámicas en Postman:
   - Guardar el ID del cliente creado: `pm.environment.set("cliente_id", response.id)`
   - Guardar el ID de la factura: `pm.environment.set("factura_id", response.id)`
   - Luego usar: `{{cliente_id}}` y `{{factura_id}}` en otros requests

---

**Versión**: 1.0  
**Última actualización**: 2025

