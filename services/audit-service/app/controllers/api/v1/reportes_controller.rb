module Api
  module V1
    class ReportesController < ApplicationController
      def index
        desde = params[:desde] ? Date.parse(params[:desde]) : Date.current
        hasta = params[:hasta] ? Date.parse(params[:hasta]) : desde

        metricas = ReporteMetricas.por_fecha(desde, hasta)
        metricas = metricas.por_servicio(params[:servicio]) if params[:servicio].present?
        metricas = metricas.por_evento(params[:evento]) if params[:evento].present?

        render json: {
          desde: desde,
          hasta: hasta,
          metricas: metricas.order(:fecha, :servicio, :evento),
          total: metricas.sum(:cantidad)
        }
      end

      def resumen
        desde = params[:desde] ? Date.parse(params[:desde]) : 30.days.ago.to_date
        hasta = params[:hasta] ? Date.parse(params[:hasta]) : Date.current

        metricas = ReporteMetricas.por_fecha(desde, hasta)
        metricas = metricas.por_servicio(params[:servicio]) if params[:servicio].present?

        resumen = metricas.group(:servicio, :evento)
                          .sum(:cantidad)
                          .map { |(servicio, evento), cantidad|
                            { servicio: servicio, evento: evento, cantidad: cantidad }
                          }

        render json: {
          desde: desde,
          hasta: hasta,
          resumen: resumen,
          total: metricas.sum(:cantidad)
        }
      end
    end
  end
end

