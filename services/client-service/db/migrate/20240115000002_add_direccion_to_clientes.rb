class AddDireccionToClientes < ActiveRecord::Migration[7.2]
  def change
    add_column :clientes, :direccion, :string, limit: 500, null: true
  end
end

