require "test_helper"

class FacturaTest < ActiveSupport::TestCase
  test "should not save factura without cliente_id" do
    factura = Factura.new(estado: "borrador")
    assert_not factura.save, "Saved the factura without a cliente_id"
  end

  test "should save factura with valid attributes" do
    factura = Factura.new(cliente_id: "12345", estado: "borrador")
    assert factura.save, "Could not save valid factura"
  end

  test "should calculate total correctly" do
    factura = Factura.create(cliente_id: "12345", estado: "borrador")
    
    factura.items_factura.create!(
      descripcion: "Item 1",
      cantidad: 2,
      precio_unitario: 100.0,
      impuesto_porcentaje: 19.0
    )
    
    factura.items_factura.create!(
      descripcion: "Item 2",
      cantidad: 1,
      precio_unitario: 50.0,
      impuesto_porcentaje: 0.0
    )
    
    factura.reload
    factura.calcular_totales
    factura.save!
    
    assert_equal 250.0, factura.subtotal
    assert_equal 38.0, factura.impuestos
    assert_equal 288.0, factura.total
  end

  test "should not emit factura without items" do
    factura = Factura.create(cliente_id: "12345", estado: "borrador")
    assert_not factura.puede_emitir?, "Factura sin items no debería poder emitirse"
  end

  test "should emit factura with items" do
    factura = Factura.create(cliente_id: "12345", estado: "borrador")
    factura.items_factura.create!(
      descripcion: "Item 1",
      cantidad: 1,
      precio_unitario: 100.0
    )
    factura.reload
    
    assert factura.puede_emitir?, "Factura con items debería poder emitirse"
    factura.emitir!
    assert_equal "emitida", factura.estado
    assert_not_nil factura.numero_factura
    assert_not_nil factura.fecha_emision
  end

  test "should not anular factura in borrador" do
    factura = Factura.create(cliente_id: "12345", estado: "borrador")
    assert_not factura.puede_anular?, "Factura en borrador no debería poder anularse"
  end

  test "should anular factura emitida" do
    factura = Factura.create(cliente_id: "12345", estado: "borrador")
    factura.items_factura.create!(
      descripcion: "Item 1",
      cantidad: 1,
      precio_unitario: 100.0
    )
    factura.reload
    factura.emitir!
    
    assert factura.puede_anular?, "Factura emitida debería poder anularse"
    factura.anular!
    assert_equal "anulada", factura.estado
  end

  test "should generate unique numero_factura" do
    factura1 = Factura.create(cliente_id: "12345", estado: "borrador")
    factura1.items_factura.create!(descripcion: "Item", cantidad: 1, precio_unitario: 100.0)
    factura1.reload
    factura1.emitir!
    
    factura2 = Factura.create(cliente_id: "12345", estado: "borrador")
    factura2.items_factura.create!(descripcion: "Item", cantidad: 1, precio_unitario: 100.0)
    factura2.reload
    factura2.emitir!
    
    assert_not_equal factura1.numero_factura, factura2.numero_factura
  end
end

