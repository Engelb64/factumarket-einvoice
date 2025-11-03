# Seeds opcionales - Datos de ejemplo para desarrollo
# Nota: Los eventos de auditoría normalmente se crean automáticamente cuando se realizan acciones
# Este seed es opcional y solo para propósitos de demostración
# Ejecutar con: rails db:seed
# O con Docker: docker-compose exec audit-service bash -c "cd services/audit-service && rails db:seed"

puts "🌱 Sembrando datos de ejemplo en Audit Service..."

# Los eventos de auditoría normalmente se generan automáticamente cuando:
# - Se crean/emiten/anulan facturas
# - Se realizan operaciones importantes en el sistema
#
# Para generar eventos reales, ejecuta operaciones en los otros servicios:
# - Crea clientes en Client Service
# - Crea/emite facturas en Invoice Service
#
# Si deseas agregar eventos de ejemplo manualmente, puedes descomentar el siguiente código:

=begin
puts "\n📝 Creando eventos de ejemplo..."

eventos_data = [
  {
    evento: "FacturaCreada",
    timestamp: DateTime.current - 2.days,
    servicio: "invoice-service",
    entidad_tipo: "Factura",
    entidad_id: "1",
    usuario_id: nil,
    datos: {
      cliente_id: 1,
      estado: "borrador",
      total: "250.00"
    }
  },
  {
    evento: "FacturaEmitida",
    timestamp: DateTime.current - 1.day,
    servicio: "invoice-service",
    entidad_tipo: "Factura",
    entidad_id: "1",
    usuario_id: nil,
    datos: {
      numero_factura: "FM-2025-000001",
      cliente_id: 1,
      total: "250.00"
    }
  }
]

eventos_creados = 0

eventos_data.each do |evento_attrs|
  evento = EventoAuditoria.create(evento_attrs)
  if evento.persisted?
    eventos_creados += 1
    puts "  ✅ Evento creado: #{evento.evento} (#{evento.entidad_tipo} #{evento.entidad_id})"
  else
    puts "  ❌ Error creando evento: #{evento.errors.full_messages.join(', ')}"
  end
end

puts "\n📊 Resumen:"
puts "  - Eventos creados: #{eventos_creados}"
puts "  - Total en base de datos: #{EventoAuditoria.count}"
=end

puts "\nℹ️  Para generar eventos reales de auditoría:"
puts "  1. Ejecuta operaciones en Client Service (crear clientes)"
puts "  2. Ejecuta operaciones en Invoice Service (crear/emitir facturas)"
puts "  3. Los eventos se crearán automáticamente"
puts "\n✅ Seeds completados! (Sin eventos de ejemplo - se generan automáticamente)"
