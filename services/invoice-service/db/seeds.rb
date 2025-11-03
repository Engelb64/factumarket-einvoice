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

# Factura 1: Borrador con items
if cliente_abc
  factura = Factura.find_or_initialize_by(
    cliente_id: cliente_abc,
    estado: 'borrador',
    numero_factura: nil
  )
  
  if factura.new_record?
    factura.save(validate: false)
    
    factura.items_factura.build(
      descripcion: "Producto A - Servicio de Consultoría",
      cantidad: 2,
      precio_unitario: 100.00,
      impuesto_porcentaje: 13
    )
    
    factura.items_factura.build(
      descripcion: "Producto B - Licencia Mensual",
      cantidad: 1,
      precio_unitario: 50.00,
      impuesto_porcentaje: 13
    )
    
    if factura.save
      factura.calcular_totales
      factura.save
      facturas_creadas += 1
      puts "  ✅ Factura borrador creada: ID #{factura.id} (Total: $#{factura.total})"
    else
      puts "  ❌ Error creando factura: #{factura.errors.full_messages.join(', ')}"
    end
  else
    facturas_existentes += 1
    puts "  ⏭️  Factura ya existe: ID #{factura.id}"
  end
end

# Factura 2: Emitida (requiere generar número)
if cliente_abc
  factura = Factura.find_or_initialize_by(
    cliente_id: cliente_abc,
    estado: 'emitida'
  )
  
  if factura.new_record?
    factura.save(validate: false)
    
    factura.items_factura.build(
      descripcion: "Producto Premium - Suscripción Anual",
      cantidad: 3,
      precio_unitario: 200.00,
      impuesto_porcentaje: 13
    )
    
    factura.items_factura.build(
      descripcion: "Servicio de Soporte Técnico",
      cantidad: 1,
      precio_unitario: 150.00,
      impuesto_porcentaje: 13
    )
    
    if factura.save
      factura.calcular_totales
      # Emitir la factura (genera número)
      begin
        factura.emitir!
        facturas_creadas += 1
        puts "  ✅ Factura emitida creada: ID #{factura.id} (#{factura.numero_factura} - Total: $#{factura.total})"
      rescue => e
        puts "  ⚠️  Error emitiendo factura: #{e.message}"
      end
    end
  else
    facturas_existentes += 1
    puts "  ⏭️  Factura ya existe: ID #{factura.id} (#{factura.numero_factura})"
  end
end

# Factura 3: Borrador simple
if cliente_xyz
  factura = Factura.find_or_initialize_by(
    cliente_id: cliente_xyz,
    estado: 'borrador'
  )
  
  if factura.new_record?
    factura.save(validate: false)
    
    factura.items_factura.build(
      descripcion: "Producto C - Servicio de Desarrollo",
      cantidad: 5,
      precio_unitario: 80.00,
      impuesto_porcentaje: 19
    )
    
    if factura.save
      factura.calcular_totales
      factura.save
      facturas_creadas += 1
      puts "  ✅ Factura borrador creada: ID #{factura.id} (Total: $#{factura.total})"
    end
  else
    facturas_existentes += 1
    puts "  ⏭️  Factura ya existe: ID #{factura.id}"
  end
end

puts "\n📊 Resumen:"
puts "  - Facturas creadas: #{facturas_creadas}"
puts "  - Facturas existentes: #{facturas_existentes}"
puts "  - Total en base de datos: #{Factura.count}"
puts "\n✅ Seeds completados!"
