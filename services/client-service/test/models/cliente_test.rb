require "test_helper"

class ClienteTest < ActiveSupport::TestCase
  test "debe crear cliente con datos válidos" do
    cliente = Cliente.new(
      nit: "12345678-9",
      nombre: "Empresa Test",
      email: "test@example.com",
      telefono: "1234567890"
    )
    
    assert cliente.valid?
    assert cliente.save
  end

  test "debe requerir nit" do
    cliente = Cliente.new(nombre: "Test")
    assert_not cliente.valid?
    assert_includes cliente.errors[:nit], "can't be blank"
  end

  test "debe requerir nombre" do
    cliente = Cliente.new(nit: "12345678-9")
    assert_not cliente.valid?
    assert_includes cliente.errors[:nombre], "can't be blank"
  end

  test "nit debe ser único" do
    Cliente.create!(nit: "12345678-9", nombre: "Test 1")
    
    cliente2 = Cliente.new(nit: "12345678-9", nombre: "Test 2")
    assert_not cliente2.valid?
    assert_includes cliente2.errors[:nit], "has already been taken"
  end

  test "debe validar formato de email" do
    cliente = Cliente.new(nit: "12345678-9", nombre: "Test", email: "email_invalido")
    assert_not cliente.valid?
    assert_includes cliente.errors[:email], "is invalid"
  end

  test "scope activos debe retornar solo clientes activos" do
    cliente_activo = Cliente.create!(nit: "11111111-1", nombre: "Activo")
    cliente_inactivo = Cliente.create!(nit: "22222222-2", nombre: "Inactivo", activo: false)
    
    assert_includes Cliente.activos, cliente_activo
    assert_not_includes Cliente.activos, cliente_inactivo
  end
end

