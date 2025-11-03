class AnularFacturaService
  def initialize(audit_service_client: nil)
    @audit_service_client = audit_service_client || AuditServiceClient.new
  end

  def ejecutar(factura_id, motivo = nil)
    factura = Factura.find(factura_id)
    
    unless factura.puede_anular?
      raise StandardError, 'La factura no puede ser anulada. Solo se pueden anular facturas emitidas.'
    end

    factura.anular!(motivo)
    
    # Registrar evento de auditoría
    @audit_service_client.registrar_evento(
      'FacturaAnulada',
      'invoice-service',
      'Factura',
      factura.id,
      {
        numero_factura: factura.numero_factura,
        cliente_id: factura.cliente_id,
        motivo: motivo,
        total: factura.total.to_s
      }
    )
    
    factura
  end
end

