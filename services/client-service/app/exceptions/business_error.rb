# Excepción personalizada para errores de negocio
class BusinessError < StandardError
  attr_reader :code, :details

  def initialize(message, code: 'BUSINESS_ERROR', details: {})
    super(message)
    @code = code
    @details = details
  end

  def to_json
    {
      error: message,
      code: code,
      details: details
    }
  end
end

