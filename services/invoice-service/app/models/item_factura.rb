class ItemFactura < ApplicationRecord
  self.table_name = "items_factura"
  
  belongs_to :factura

  validates :descripcion, presence: true, length: { maximum: 500 }
  validates :cantidad, presence: true, numericality: { greater_than: 0, less_than: 1_000_000 }
  validates :precio_unitario, presence: true, numericality: { greater_than_or_equal_to: 0, less_than: 1_000_000_000 }
  validates :impuesto_porcentaje, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validate :validar_factura_no_emitida, on: :create
  validate :validar_factura_no_emitida, on: :update, if: :factura_id_changed?

  before_save :calcular_subtotal

  def calcular_subtotal
    self.subtotal = cantidad * precio_unitario
  end

  private

  def validar_factura_no_emitida
    return unless factura

    if factura.emitida?
      errors.add(:base, "No se pueden agregar o modificar items de una factura ya emitida")
    end

    if factura.anulada?
      errors.add(:base, "No se pueden agregar o modificar items de una factura anulada")
    end
  end
end

