class ItemFactura < ApplicationRecord
  self.table_name = "items_factura"
  
  belongs_to :factura

  validates :descripcion, presence: true
  validates :cantidad, presence: true, numericality: { greater_than: 0 }
  validates :precio_unitario, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :impuesto_porcentaje, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  before_save :calcular_subtotal

  def calcular_subtotal
    self.subtotal = cantidad * precio_unitario
  end
end

