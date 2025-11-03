class EmitirFacturaService
  def initialize
  end

  def ejecutar(factura_id)
    factura = Factura.find(factura_id)
    
    unless factura.puede_emitir?
      raise StandardError, 'La factura no puede ser emitida. Debe estar en borrador, tener items y un cliente válido.'
    end

    factura.emitir!
    factura
  end
end

