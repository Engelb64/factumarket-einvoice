class CreateClientes < ActiveRecord::Migration[7.2]
  def change
    create_table :clientes do |t|
      t.string :nit, null: false, index: { unique: true }
      t.string :nombre, null: false
      t.string :email
      t.string :telefono
      t.boolean :activo, default: true, null: false

      t.timestamps
    end
  end
end

