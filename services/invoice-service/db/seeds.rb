# Seeds opcionales - Datos de ejemplo para desarrollo
# IMPORTANTE: Requiere que Client Service esté corriendo y tenga clientes
# Ejecutar con: rails db:seed
# O con Docker: docker-compose exec invoice-service bash -c "cd services/invoice-service && rails db:seed"

require 'httparty'

puts "🌱 Sembrando datos de ejemplo en Invoice Service..."

# Configuración para comunicarse con Client Service
CLIENT_SERVICE_URL = ENV.fetch('CLIENT_SERVICE_URL', 'http://client-service:3001')

def obtener_cliente_por_nit(nit)
  begin
    response = HTTParty.get("#{CLIENT_SERVICE_URL}/api/v1/clientes", {
      query: { nit: nit },
      timeout: 5
    })
    
    if response.success? && response.parsed_response.is_a?(Array) && response.parsed_response.any?
      response.parsed_response.first['id']
    elsif response.success? && response.parsed_response['id']
      response.parsed_response['id']
    else
      nil
    end
  rescue => e
    puts "  ⚠️  No se pudo obtener cliente con NIT #{nit}: #{e.message}"
    nil
  end
end

# Obtener clientes del Client Service
puts "\n📡 Obteniendo clientes del Client Service..."
cliente_abc = obtener_cliente_por_nit("12345678-9")
cliente_xyz = obtener_cliente_por_nit("98765432-1")

if cliente_abc.nil? && cliente_xyz.nil?
  puts "  ⚠️  No se encontraron clientes. Ejecuta primero los seeds del Client Service:"
  puts "     docker-compose exec client-service bash -c 'cd services/client-service && rails db:seed'"
  puts "  ℹ️  Los seeds se saltarán por ahora."
  exit
end

facturas_creadas = 0
facturas_existentes = 0

# Factura 1: Borrador con items (usar CrearFacturaService para registrar eventos de auditoría)
if cliente_abc
  # Verificar si ya existe una factura borrador para este cliente
  factura_existente = Factura.where(cliente_id: cliente_abc, estado: 'borrador', numero_factura: nil).first
  
  unless factura_existente
    begin
      service = CrearFacturaService.new
      params = {
        cliente_id: cliente_abc,
        items_factura: [
          {
            descripcion: "Producto A - Servicio de Consultoría",
            cantidad: 2,
            precio_unitario: 100.00,
            impuesto_porcentaje: 13
          },
          {
            descripcion: "Producto B - Licencia Mensual",
            cantidad: 1,
            precio_unitario: 50.00,
            impuesto_porcentaje: 13
          }
        ]
      }
      
      factura = service.ejecutar(params)
      facturas_creadas += 1
      puts "  ✅ Factura borrador creada: ID #{factura.id} (Total: $#{factura.total}) - Evento de auditoría registrado"
    rescue => e
      puts "  ❌ Error creando factura: #{e.message}"
    end
  else
    facturas_existentes += 1
    puts "  ⏭️  Factura ya existe: ID #{factura_existente.id}"
  end
end

# Factura 2: Emitida (requiere generar número)
if cliente_abc
  # Verificar si ya existe una factura emitida para este cliente con estos items
  factura_existente = Factura.where(cliente_id: cliente_abc, estado: 'emitida')
                              .where.not(numero_factura: nil).first
  
  unless factura_existente
    begin
      # Crear factura usando el servicio (registra evento FacturaCreada)
      service = CrearFacturaService.new
      params = {
        cliente_id: cliente_abc,
        items_factura: [
          {
            descripcion: "Producto Premium - Suscripción Anual",
            cantidad: 3,
            precio_unitario: 200.00,
            impuesto_porcentaje: 13
          },
          {
            descripcion: "Servicio de Soporte Técnico",
            cantidad: 1,
            precio_unitario: 150.00,
            impuesto_porcentaje: 13
          }
        ]
      }
      
      factura = service.ejecutar(params)
      
      # Emitir la factura usando el servicio (registra evento FacturaEmitida)
      emitir_service = EmitirFacturaService.new
      factura = emitir_service.ejecutar(factura.id)
      
      facturas_creadas += 1
      puts "  ✅ Factura emitida creada: ID #{factura.id} (#{factura.numero_factura} - Total: $#{factura.total}) - Eventos de auditoría registrados"
    rescue => e
      puts "  ⚠️  Error creando/emitiendo factura: #{e.message}"
    end
  else
    facturas_existentes += 1
    puts "  ⏭️  Factura ya existe: ID #{factura_existente.id} (#{factura_existente.numero_factura})"
  end
end

# Factura 3: Borrador simple
if cliente_xyz
  factura_existente = Factura.where(cliente_id: cliente_xyz, estado: 'borrador', numero_factura: nil).first
  
  unless factura_existente
    begin
      service = CrearFacturaService.new
      params = {
        cliente_id: cliente_xyz,
        items_factura: [
          {
            descripcion: "Producto C - Servicio de Desarrollo",
            cantidad: 5,
            precio_unitario: 80.00,
            impuesto_porcentaje: 19
          }
        ]
      }
      
      factura = service.ejecutar(params)
      facturas_creadas += 1
      puts "  ✅ Factura borrador creada: ID #{factura.id} (Total: $#{factura.total}) - Evento de auditoría registrado"
    rescue => e
      puts "  ❌ Error creando factura: #{e.message}"
    end
  else
    facturas_existentes += 1
    puts "  ⏭️  Factura ya existe: ID #{factura_existente.id}"
  end
end

puts "\n📊 Resumen:"
puts "  - Facturas creadas: #{facturas_creadas}"
puts "  - Facturas existentes: #{facturas_existentes}"
puts "  - Total en base de datos: #{Factura.count}"
puts "\n✅ Seeds completados!"
