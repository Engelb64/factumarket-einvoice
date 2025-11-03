class ReporteMetricas < ApplicationRecord
  self.table_name = 'metricas_auditoria'

  validates :fecha, presence: true
  validates :servicio, presence: true
  validates :evento, presence: true
  validates :cantidad, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :por_fecha, ->(desde, hasta = nil) {
    hasta ||= desde
    where(fecha: desde..hasta)
  }

  scope :por_servicio, ->(servicio) { where(servicio: servicio) }
  scope :por_evento, ->(evento) { where(evento: evento) }

  # Agregar o incrementar métrica
  def self.incrementar(fecha:, servicio:, evento:)
    metrica = find_or_initialize_by(fecha: fecha, servicio: servicio, evento: evento)
    metrica.cantidad += 1
    metrica.save!
    metrica
  end
end

