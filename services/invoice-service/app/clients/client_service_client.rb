require 'httparty'

class ClientServiceClient
  include HTTParty

  def initialize(base_url = nil)
    @base_url = base_url || ENV.fetch('CLIENT_SERVICE_URL', 'http://client-service:3001')
    self.class.base_uri @base_url
    self.class.headers 'Content-Type' => 'application/json'
  end

  def obtener_cliente(cliente_id)
    response = self.class.get("/api/v1/clientes/#{cliente_id}")
    
    if response.success?
      response.parsed_response
    elsif response.code == 404
      nil
    else
      raise "Error al obtener cliente: #{response.code} - #{response.body}"
    end
  rescue HTTParty::Error, StandardError => e
    Rails.logger.error "Error comunicándose con Client Service: #{e.message}"
    raise "No se pudo comunicar con el servicio de clientes: #{e.message}"
  end

  def cliente_activo?(cliente_id)
    cliente = obtener_cliente(cliente_id)
    cliente && cliente['activo'] == true
  end
end

