# Principios Arquitectónicos Aplicados

## 📋 Índice

- [Microservicios](#microservicios)
- [Clean Architecture](#clean-architecture)
- [MVC](#mvc)

---

## 🔧 Microservicios

### Independencia

**¿Cómo se aplica?**

Cada microservicio es completamente independiente:

- ✅ **Base de datos propia:** Cada servicio tiene su propia base de datos PostgreSQL
  - `client_service_development` → Client Service
  - `invoice_service_development` → Invoice Service
  - `audit_service_reports_development` → Audit Service (para reportes)
  - `audit_service_development` (MongoDB) → Audit Service (para eventos)

- ✅ **Código independiente:** Cada servicio está en su propia carpeta
  ```
  services/
    ├── client-service/     # Aplicación Rails independiente
    ├── invoice-service/    # Aplicación Rails independiente
    └── audit-service/      # Aplicación Rails independiente
  ```

- ✅ **Puerto propio:** Cada servicio corre en su propio puerto
  - Client Service: 3001
  - Invoice Service: 3002
  - Audit Service: 3003

**Ejemplo práctico:**
```yaml
# docker-compose.yml
client-service:
  ports: ["3001:3001"]
  environment:
    POSTGRES_DATABASE: client_service_development

invoice-service:
  ports: ["3002:3002"]
  environment:
    POSTGRES_DATABASE: invoice_service_development
```

---

### Escalabilidad

**¿Cómo se aplica?**

Cada servicio puede escalarse independientemente:

- ✅ **Escalado horizontal:** Puedes levantar múltiples instancias de un servicio
  ```bash
  # Escalar solo Invoice Service a 3 instancias
  docker-compose up -d --scale invoice-service=3
  ```

- ✅ **Recursos independientes:** Cada servicio puede tener límites de CPU/RAM diferentes
  ```yaml
  invoice-service:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 2G
  ```

- ✅ **Carga distribuida:** Si Invoice Service tiene más carga, puedes escalarlo sin afectar Client Service

**Ejemplo práctico:**
- Client Service: 1 instancia (baja carga)
- Invoice Service: 3 instancias (alta carga)
- Audit Service: 1 instancia (carga media)

---

### Despliegue Autónomo

**¿Cómo se aplica?**

Cada servicio puede desplegarse sin afectar a otros:

- ✅ **Despliegue independiente:** Puedes actualizar un servicio sin tocar los otros
  ```bash
  # Reiniciar solo Invoice Service
  docker-compose restart invoice-service
  ```

- ✅ **Migraciones independientes:** Cada servicio gestiona sus propias migraciones
  ```bash
  # Migrar solo Client Service
  docker-compose exec client-service bash -c \
    "cd services/client-service && rails db:migrate"
  ```

- ✅ **Versionado independiente:** Cada servicio puede tener versiones diferentes de dependencias

**Ejemplo práctico:**
```ruby
# services/client-service/Gemfile
gem 'rails', '7.2.0'

# services/invoice-service/Gemfile
gem 'rails', '7.2.1'  # Versión diferente, no afecta a Client Service
```

---

## 🏛️ Clean Architecture

### Separación de Capas

**Estructura aplicada:**

```
app/
├── controllers/      # Capa de Presentación (Entrada)
├── services/         # Capa de Aplicación (Casos de Uso)
├── models/           # Capa de Dominio (Entidades y Lógica de Negocio)
└── clients/          # Capa de Infraestructura (Acceso a Servicios Externos)
```

### Capa de Dominio (Models)

**Responsabilidad:** Lógica de negocio y reglas del dominio

```ruby
# services/invoice-service/app/models/factura.rb
class Factura < ApplicationRecord
  # Lógica de negocio
  def puede_emitir?
    estado == "borrador" && items_factura.any? && total.to_f > 0
  end
  
  def emitir!
    raise BusinessError unless puede_emitir?
    self.numero_factura ||= generar_numero_factura
    self.estado = "emitida"
    save!
  end
  
  # Reglas de dominio
  validates :estado, inclusion: { in: %w[borrador emitida anulada] }
end
```

**Características:**
- ✅ Contiene la lógica de negocio
- ✅ No depende de infraestructura
- ✅ Validaciones y reglas del dominio

---

### Capa de Aplicación (Services)

**Responsabilidad:** Orquestar casos de uso, coordinar entre capas

```ruby
# services/invoice-service/app/services/crear_factura_service.rb
class CrearFacturaService
  def initialize(client_service_client: nil, audit_service_client: nil)
    @client_service_client = client_service_client || ClientServiceClient.new
    @audit_service_client = audit_service_client || AuditServiceClient.new
  end
  
  def ejecutar(params)
    # 1. Validar con otro servicio (Infraestructura)
    cliente = @client_service_client.obtener_cliente(params[:cliente_id])
    
    # 2. Crear entidad (Dominio)
    factura = Factura.new(params)
    factura.save!
    
    # 3. Registrar auditoría (Infraestructura)
    @audit_service_client.registrar_evento('FacturaCreada', ...)
    
    factura
  end
end
```

**Características:**
- ✅ Coordina entre capas
- ✅ Orquesta casos de uso
- ✅ No contiene lógica de negocio (delega al modelo)

---

### Capa de Infraestructura (Clients, Database)

**Responsabilidad:** Acceso a recursos externos

```ruby
# services/invoice-service/app/clients/client_service_client.rb
class ClientServiceClient
  include HTTParty
  
  def obtener_cliente(cliente_id)
    # Acceso a servicio externo
    response = self.class.get("/api/v1/clientes/#{cliente_id}")
    response.parsed_response
  end
end
```

**Características:**
- ✅ Acceso a servicios externos
- ✅ Configuración de conexiones
- ✅ Aislado del dominio

---

### Capa de Presentación (Controllers)

**Responsabilidad:** Recibir requests HTTP, validar entrada, llamar servicios

```ruby
# services/invoice-service/app/controllers/api/v1/facturas_controller.rb
class Api::V1::FacturasController < ApplicationController
  def create
    # 1. Validar entrada
    # 2. Llamar servicio (Aplicación)
    service = CrearFacturaService.new
    @factura = service.ejecutar(factura_params)
    
    # 3. Responder (Presentación)
    render json: @factura, status: :created
  rescue BusinessError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end
end
```

**Características:**
- ✅ Solo maneja HTTP
- ✅ Valida parámetros de entrada
- ✅ Delega lógica a servicios

---

## 🎨 MVC

### Organización en la Capa de Exposición

El patrón MVC se aplica específicamente en la **capa de presentación** (exposición de APIs):

```
app/
├── controllers/     # Controllers (MVC)
│   └── api/v1/
│       └── facturas_controller.rb
├── models/          # Models (MVC + Domain)
│   └── factura.rb
└── views/           # Views (MVC - JSON)
    └── api/v1/
        └── facturas/
            └── show.json.jbuilder
```

### Controllers (MVC)

**Responsabilidad:** Recibir requests, validar, orquestar, responder

```ruby
# services/invoice-service/app/controllers/api/v1/facturas_controller.rb
class Api::V1::FacturasController < ApplicationController
  before_action :set_factura, only: [:show, :emitir, :anular]
  
  def index
    @facturas = Factura.includes(:items_factura).all
    render json: @facturas, include: :items_factura
  end
  
  def create
    service = CrearFacturaService.new
    @factura = service.ejecutar(factura_params)
    render json: @factura, status: :created
  end
  
  def emitir
    service = EmitirFacturaService.new
    @factura = service.ejecutar(@factura.id)
    render json: @factura
  end
end
```

**Aplicación MVC:**
- ✅ **M**anages HTTP requests
- ✅ **V**alidates input
- ✅ **C**oordinates with services

---

### Models (MVC + Domain)

**Responsabilidad:** Representar datos y lógica de negocio

```ruby
# services/invoice-service/app/models/factura.rb
class Factura < ApplicationRecord
  # Relaciones (ActiveRecord)
  has_many :items_factura, dependent: :destroy
  
  # Validaciones (ActiveRecord)
  validates :cliente_id, presence: true
  validates :estado, inclusion: { in: %w[borrador emitida anulada] }
  
  # Lógica de negocio (Domain)
  def puede_emitir?
    estado == "borrador" && items_factura.any? && total.to_f > 0
  end
  
  def calcular_totales
    self.subtotal = items_factura.sum(&:subtotal)
    self.total = subtotal + impuestos
  end
end
```

**Aplicación MVC:**
- ✅ **M**odels representan datos
- ✅ Contienen lógica de negocio
- ✅ Validaciones de dominio

---

### Views (MVC - JSON Serialization)

**Responsabilidad:** Formatear respuesta JSON

```ruby
# services/invoice-service/app/views/api/v1/facturas/show.json.jbuilder
json.id @factura.id
json.numero_factura @factura.numero_factura
json.estado @factura.estado
json.total @factura.total
json.cliente_id @factura.cliente_id
json.fecha_emision @factura.fecha_emision

json.items_factura @factura.items_factura do |item|
  json.descripcion item.descripcion
  json.cantidad item.cantidad
  json.precio_unitario item.precio_unitario
  json.subtotal item.subtotal
end
```

**O usando ActiveRecord directamente:**
```ruby
# En el controller
render json: @factura, include: :items_factura
```

**Aplicación MVC:**
- ✅ **V**iews formatean la respuesta
- ✅ Separación de presentación
- ✅ Pueden cambiar sin afectar lógica

---

## 📊 Resumen de Aplicación

| Principio | Cómo se Aplica | Ejemplo |
|-----------|---------------|---------|
| **Microservicios - Independencia** | Base de datos y código separados | Cada servicio en `services/` con su propia DB |
| **Microservicios - Escalabilidad** | Escalado por servicio | `docker-compose up --scale invoice-service=3` |
| **Microservicios - Despliegue Autónomo** | Deploy independiente | `docker-compose restart client-service` |
| **Clean Architecture - Dominio** | Models con lógica de negocio | `Factura#puede_emitir?`, `Factura#emitir!` |
| **Clean Architecture - Aplicación** | Services orquestan casos de uso | `CrearFacturaService#ejecutar` |
| **Clean Architecture - Infraestructura** | Clients para servicios externos | `ClientServiceClient`, `AuditServiceClient` |
| **MVC - Controllers** | Manejan HTTP y delegan | `FacturasController#create` llama a service |
| **MVC - Models** | Datos y lógica de negocio | `Factura` con validaciones y métodos |
| **MVC - Views** | Formatean JSON | Jbuilder o `render json:` |

---

**Versión**: 1.0  
**Última actualización**: 2025

