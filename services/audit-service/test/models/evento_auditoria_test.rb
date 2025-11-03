require "test_helper"

class EventoAuditoriaTest < ActiveSupport::TestCase
  test "should not save evento without evento name" do
    evento = EventoAuditoria.new(
      servicio: "invoice-service",
      entidad_tipo: "Factura",
      entidad_id: "123"
    )
    assert_not evento.save, "Saved the evento without evento name"
  end

  test "should not save evento without servicio" do
    evento = EventoAuditoria.new(
      evento: "FacturaCreada",
      entidad_tipo: "Factura",
      entidad_id: "123"
    )
    assert_not evento.save, "Saved the evento without servicio"
  end

  test "should save evento with valid attributes" do
    evento = EventoAuditoria.new(
      evento: "FacturaCreada",
      servicio: "invoice-service",
      entidad_tipo: "Factura",
      entidad_id: "123",
      datos: { total: "100.0" }
    )
    assert evento.save, "Could not save valid evento"
  end

  test "should have timestamp by default" do
    evento = EventoAuditoria.new(
      evento: "FacturaCreada",
      servicio: "invoice-service",
      entidad_tipo: "Factura",
      entidad_id: "123"
    )
    evento.save
    assert_not_nil evento.timestamp
  end

  test "should store datos as hash" do
    datos_hash = { total: "100.0", cliente_id: "1" }
    evento = EventoAuditoria.new(
      evento: "FacturaCreada",
      servicio: "invoice-service",
      entidad_tipo: "Factura",
      entidad_id: "123",
      datos: datos_hash
    )
    evento.save
    assert_equal datos_hash, evento.datos
  end
end

