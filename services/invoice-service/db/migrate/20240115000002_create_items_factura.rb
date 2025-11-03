class CreateItemsFactura < ActiveRecord::Migration[7.2]
  def change
    create_table :items_factura do |t|
      t.references :factura, null: false, foreign_key: true
      t.string :descripcion, null: false
      t.integer :cantidad, null: false, default: 1
      t.decimal :precio_unitario, precision: 10, scale: 2, null: false
      t.decimal :subtotal, precision: 10, scale: 2, null: false
      t.decimal :impuesto_porcentaje, precision: 5, scale: 2, default: 0.0

      t.timestamps
    end
  end
end

