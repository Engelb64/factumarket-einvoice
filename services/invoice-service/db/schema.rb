# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2024_01_15_000002) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "facturas", force: :cascade do |t|
    t.string "numero_factura"
    t.string "cliente_id", null: false
    t.date "fecha_emision"
    t.decimal "subtotal", precision: 10, scale: 2, default: "0.0"
    t.decimal "impuestos", precision: 10, scale: 2, default: "0.0"
    t.decimal "total", precision: 10, scale: 2, default: "0.0"
    t.string "estado", default: "borrador", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["numero_factura"], name: "index_facturas_on_numero_factura", unique: true
  end

  create_table "items_factura", force: :cascade do |t|
    t.bigint "factura_id", null: false
    t.string "descripcion", null: false
    t.integer "cantidad", default: 1, null: false
    t.decimal "precio_unitario", precision: 10, scale: 2, null: false
    t.decimal "subtotal", precision: 10, scale: 2, null: false
    t.decimal "impuesto_porcentaje", precision: 5, scale: 2, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["factura_id"], name: "index_items_factura_on_factura_id"
  end

  add_foreign_key "items_factura", "facturas"
end
