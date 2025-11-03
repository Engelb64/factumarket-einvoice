# Seeds opcionales - Datos de ejemplo para desarrollo
# Ejecutar con: rails db:seed
# O con Docker: docker-compose exec client-service bash -c "cd services/client-service && rails db:seed"

puts "🌱 Sembrando datos de ejemplo en Client Service..."

clientes_data = [
  {
    nit: "12345678-9",
    nombre: "Empresa ABC S.A.",
    email: "contacto@abc.com",
    telefono: "2222-3333",
    direccion: "Calle Principal 123, Oficina 456, Ciudad",
    activo: true
  },
  {
    nit: "98765432-1",
    nombre: "Comercial XYZ Ltda.",
    email: "ventas@xyz.com",
    telefono: "4444-5555",
    direccion: "Avenida Central 789, Sector Norte",
    activo: true
  },
  {
    nit: "11223344-5",
    nombre: "Servicios Integrales S.A.S.",
    email: "info@serviciosintegrales.com",
    telefono: "6666-7777",
    direccion: "Zona Industrial, Edificio 2, Piso 3",
    activo: true
  },
  {
    nit: "55667788-9",
    nombre: "Distribuidora del Norte",
    email: "ventas@distribuidoranorte.com",
    telefono: "8888-9999",
    direccion: "Carretera Norte Km 12.5, Bodega 5",
    activo: false
  }
]

clientes_creados = 0
clientes_existentes = 0

clientes_data.each do |cliente_attrs|
  cliente = Cliente.find_or_initialize_by(nit: cliente_attrs[:nit])
  
  if cliente.new_record?
    cliente.assign_attributes(cliente_attrs)
    if cliente.save
      clientes_creados += 1
      puts "  ✅ Cliente creado: #{cliente.nombre} (NIT: #{cliente.nit})"
    else
      puts "  ❌ Error creando cliente #{cliente_attrs[:nombre]}: #{cliente.errors.full_messages.join(', ')}"
    end
  else
    clientes_existentes += 1
    puts "  ⏭️  Cliente ya existe: #{cliente.nombre} (NIT: #{cliente.nit})"
  end
end

puts "\n📊 Resumen:"
puts "  - Clientes creados: #{clientes_creados}"
puts "  - Clientes existentes: #{clientes_existentes}"
puts "  - Total en base de datos: #{Cliente.count}"
puts "\n✅ Seeds completados!"
