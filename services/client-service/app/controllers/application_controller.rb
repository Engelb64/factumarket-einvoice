class ApplicationController < ActionController::API
  # Manejo de errores globales
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity
  rescue_from BusinessError, with: :render_business_error
  rescue_from StandardError, with: :render_internal_error

  private

  def render_not_found(exception)
    render json: {
      error: exception.message || 'Recurso no encontrado',
      code: 'NOT_FOUND'
    }, status: :not_found
  end

  def render_unprocessable_entity(exception)
    render json: {
      errors: exception.record.errors.full_messages,
      code: 'VALIDATION_ERROR',
      details: exception.record.errors.as_json
    }, status: :unprocessable_entity
  end

  def render_business_error(exception)
    render json: {
      error: exception.message,
      code: exception.code,
      details: exception.details
    }, status: :unprocessable_entity
  end

  def render_internal_error(exception)
    # En producción, no exponer detalles del error interno
    error_message = Rails.env.development? ? exception.message : 'Error interno del servidor'
    error_backtrace = Rails.env.development? ? exception.backtrace : nil

    Rails.logger.error "Error interno: #{exception.message}"
    Rails.logger.error exception.backtrace.join("\n") if error_backtrace

    render json: {
      error: error_message,
      code: 'INTERNAL_ERROR',
      backtrace: error_backtrace
    }, status: :internal_server_error
  end
end
