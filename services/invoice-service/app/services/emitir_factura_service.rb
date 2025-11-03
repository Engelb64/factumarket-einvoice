class EmitirFacturaService
  def initialize(audit_service_client: nil)
    @audit_service_client = audit_service_client || AuditServiceClient.new
  end

  def ejecutar(factura_id)
    factura = Factura.find(factura_id)
    
    # La validación ya se hace en factura.emitir! con BusinessError
    factura.emitir!
    
    # Registrar evento de auditoría
    @audit_service_client.registrar_evento(
      'FacturaEmitida',
      'invoice-service',
      'Factura',
      factura.id,
      {
        numero_factura: factura.numero_factura,
        cliente_id: factura.cliente_id,
        fecha_emision: factura.fecha_emision.to_s,
        total: factura.total.to_s,
        items_count: factura.items_factura.count
      }
    )
    
    factura
  end
end

