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

conexion = ActiveRecord::Base.connection
creados = 0
existentes = 0

clientes_data.each do |c|
  sql = <<~SQL
    INSERT INTO clientes (nit, nombre, email, telefono, direccion, activo, created_at, updated_at)
    VALUES ($$#{c[:nit]}$$, $$#{c[:nombre]}$$, $$#{c[:email]}$$, $$#{c[:telefono]}$$, $$#{c[:direccion]}$$, #{c[:activo] ? 'TRUE' : 'FALSE'}, NOW(), NOW())
    ON CONFLICT (nit) DO NOTHING;
  SQL

  begin
    resultado = conexion.execute(sql)
    # Para saber si insertó, consultamos por NIT
    inserted = conexion.exec_query("SELECT id FROM clientes WHERE nit = $1", "SQL", [[nil, c[:nit]]]).rows.any?
    if inserted
      # Si ya existía, no contamos como creado
      if resultado.cmd_tuples.to_i > 0
        creados += 1
        puts "  ✅ Cliente insertado: #{c[:nombre]} (NIT: #{c[:nit]})"
      else
        existentes += 1
        puts "  ⏭️  Cliente ya existía: #{c[:nombre]} (NIT: #{c[:nit]})"
      end
    end
  rescue => e
    puts "  ❌ Error insertando cliente #{c[:nombre]} (NIT: #{c[:nit]}): #{e.message}"
  end
end

total = conexion.exec_query("SELECT COUNT(*) AS total FROM clientes").rows.first.first

puts "\n📊 Resumen:"
puts "  - Clientes creados: #{creados}"
puts "  - Clientes existentes: #{existentes}"
puts "  - Total en base de datos: #{total}"
puts "\n✅ Seeds completados!"
