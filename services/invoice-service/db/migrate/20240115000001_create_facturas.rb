class CreateFacturas < ActiveRecord::Migration[7.2]
  def change
    create_table :facturas do |t|
      t.string :numero_factura, null: true, index: { unique: true }
      t.string :cliente_id, null: false
      t.date :fecha_emision
      t.decimal :subtotal, precision: 10, scale: 2, default: 0.0
      t.decimal :impuestos, precision: 10, scale: 2, default: 0.0
      t.decimal :total, precision: 10, scale: 2, default: 0.0
      t.string :estado, default: "borrador", null: false

      t.timestamps
    end
  end
end

