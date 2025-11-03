require 'httparty'

class AuditServiceClient
  include HTTParty

  def initialize(base_url = nil)
    @base_url = base_url || ENV.fetch('AUDIT_SERVICE_URL', 'http://audit-service:3003')
    self.class.base_uri @base_url
    self.class.headers 'Content-Type' => 'application/json'
  end

  def registrar_evento(evento, servicio, entidad_tipo, entidad_id, datos = {}, usuario_id = nil)
    body = {
      evento: {
        evento: evento,
        servicio: servicio,
        entidad_tipo: entidad_tipo,
        entidad_id: entidad_id.to_s,
        usuario_id: usuario_id,
        datos: datos,
        timestamp: Time.current.iso8601
      }
    }

    response = self.class.post("/api/v1/auditoria/eventos", body: body.to_json)
    
    if response.success?
      response.parsed_response
    else
      Rails.logger.error "Error al registrar evento de auditoría: #{response.code} - #{response.body}"
      # No lanzamos excepción para no interrumpir el flujo principal
      nil
    end
  rescue HTTParty::Error, StandardError => e
    Rails.logger.error "Error comunicándose con Audit Service: #{e.message}"
    # No lanzamos excepción para no interrumpir el flujo principal
    nil
  end
end

