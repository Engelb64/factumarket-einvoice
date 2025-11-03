class Factura < ApplicationRecord
  has_many :items_factura, class_name: 'ItemFactura', dependent: :destroy

  validates :cliente_id, presence: true
  validates :estado, inclusion: { in: %w[borrador emitida anulada] }
  validates :numero_factura, uniqueness: true, allow_nil: true

  before_save :calcular_totales

  ESTADOS = {
    borrador: "borrador",
    emitida: "emitida",
    anulada: "anulada"
  }.freeze

  def calcular_totales
    self.subtotal = items_factura.sum(&:subtotal)
    self.impuestos = items_factura.sum { |item| item.subtotal * (item.impuesto_porcentaje / 100.0) }
    self.total = subtotal + impuestos
  end

  def puede_emitir?
    estado == "borrador" && items_factura.any? && cliente_id.present?
  end

  def puede_anular?
    estado == "emitida"
  end

  def emitir!
    raise "La factura no puede ser emitida" unless puede_emitir?
    
    self.numero_factura ||= generar_numero_factura
    self.fecha_emision = Date.current
    self.estado = "emitida"
    save!
  end

  def anular!(motivo = nil)
    raise "La factura no puede ser anulada" unless puede_anular?
    
    self.estado = "anulada"
    self.updated_at = Time.current # Forzar actualización
    save!
  end

  private

  def generar_numero_factura
    year = Date.current.year
    ultima_factura = Factura.where("numero_factura LIKE ?", "FM-#{year}-%")
                            .where.not(numero_factura: nil)
                            .order(numero_factura: :desc)
                            .first
    
    if ultima_factura && ultima_factura.numero_factura.present?
      numero = ultima_factura.numero_factura.split("-").last.to_i + 1
    else
      numero = 1
    end
    
    nuevo_numero = "FM-#{year}-#{numero.to_s.rjust(6, '0')}"
    
    # Asegurar unicidad
    while Factura.exists?(numero_factura: nuevo_numero)
      numero += 1
      nuevo_numero = "FM-#{year}-#{numero.to_s.rjust(6, '0')}"
    end
    
    nuevo_numero
  end
end

