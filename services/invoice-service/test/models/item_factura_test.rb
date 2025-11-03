require "test_helper"

class ItemFacturaTest < ActiveSupport::TestCase
  test "should not save item without descripcion" do
    factura = Factura.create(cliente_id: "12345", estado: "borrador")
    item = factura.items_factura.new(cantidad: 1, precio_unitario: 100.0)
    assert_not item.save, "Saved the item without a descripcion"
  end

  test "should not save item without cantidad" do
    factura = Factura.create(cliente_id: "12345", estado: "borrador")
    item = factura.items_factura.new(descripcion: "Item 1", precio_unitario: 100.0)
    assert_not item.save, "Saved the item without cantidad"
  end

  test "should not save item with cantidad zero" do
    factura = Factura.create(cliente_id: "12345", estado: "borrador")
    item = factura.items_factura.new(descripcion: "Item 1", cantidad: 0, precio_unitario: 100.0)
    assert_not item.save, "Saved the item with cantidad zero"
  end

  test "should calculate subtotal correctly" do
    factura = Factura.create(cliente_id: "12345", estado: "borrador")
    item = factura.items_factura.create!(
      descripcion: "Item 1",
      cantidad: 3,
      precio_unitario: 50.0
    )
    
    assert_equal 150.0, item.subtotal
  end

  test "should save item with valid attributes" do
    factura = Factura.create(cliente_id: "12345", estado: "borrador")
    item = factura.items_factura.new(
      descripcion: "Item 1",
      cantidad: 2,
      precio_unitario: 100.0,
      impuesto_porcentaje: 19.0
    )
    assert item.save, "Could not save valid item"
  end
end

