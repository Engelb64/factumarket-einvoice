class AgregarMetricasService
  def initialize(fecha = Date.current)
    @fecha = fecha
  end

  def ejecutar
    # Obtener eventos del día desde MongoDB
    eventos = EventoAuditoria.where(
      timestamp: {
        '$gte' => @fecha.beginning_of_day,
        '$lte' => @fecha.end_of_day
      }
    )

    # Agregar cada evento (incrementar incrementa si existe o crea si no)
    eventos.each do |evento|
      ReporteMetricas.incrementar(
        fecha: @fecha,
        servicio: evento.servicio,
        evento: evento.evento
      )
    end

    { procesados: eventos.count }
  end
end

