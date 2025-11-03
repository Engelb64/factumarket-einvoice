class CreateMetricasAuditoria < ActiveRecord::Migration[7.2]
  def change
    create_table :metricas_auditoria do |t|
      t.date :fecha, null: false
      t.string :servicio, null: false
      t.string :evento, null: false
      t.integer :cantidad, default: 0, null: false
      t.timestamps
    end

    add_index :metricas_auditoria, [:fecha, :servicio, :evento], unique: true, name: 'index_metricas_auditoria_unique'
    add_index :metricas_auditoria, :fecha
    add_index :metricas_auditoria, :servicio
    add_index :metricas_auditoria, :evento
  end
end

