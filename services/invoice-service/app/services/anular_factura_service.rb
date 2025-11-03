class AnularFacturaService
  def initialize
  end

  def ejecutar(factura_id, motivo = nil)
    factura = Factura.find(factura_id)
    
    unless factura.puede_anular?
      raise StandardError, 'La factura no puede ser anulada. Solo se pueden anular facturas emitidas.'
    end

    factura.anular!(motivo)
    factura
  end
end

