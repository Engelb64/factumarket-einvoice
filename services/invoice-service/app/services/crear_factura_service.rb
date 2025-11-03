class CrearFacturaService
  def initialize(client_service_client: nil, audit_service_client: nil)
    @client_service_client = client_service_client || ClientServiceClient.new
    @audit_service_client = audit_service_client || AuditServiceClient.new
  end

  def ejecutar(params)
    # Validar que el cliente existe y está activo
    cliente_id = params[:cliente_id] || params['cliente_id']
    unless @client_service_client.cliente_activo?(cliente_id)
      raise ActiveRecord::RecordInvalid.new(
        Factura.new.tap { |f| f.errors.add(:cliente_id, 'no existe o está inactivo') }
      )
    end

    # Crear la factura en estado borrador
    factura_params = params.except(:items_factura, 'items_factura')
    factura = Factura.new(factura_params)
    factura.estado = 'borrador'

    if factura.save
      # Crear los items si se proporcionaron
      if params[:items_factura] || params['items_factura']
        items = params[:items_factura] || params['items_factura']
        items.each do |item_params|
          factura.items_factura.create!(item_params)
        end
        factura.reload
        factura.calcular_totales
        factura.save!
      end

      # Registrar evento de auditoría
      @audit_service_client.registrar_evento(
        'FacturaCreada',
        'invoice-service',
        'Factura',
        factura.id,
        {
          cliente_id: factura.cliente_id,
          estado: factura.estado,
          total: factura.total.to_s,
          items_count: factura.items_factura.count
        }
      )

      factura
    else
      raise ActiveRecord::RecordInvalid.new(factura)
    end
  end
end

