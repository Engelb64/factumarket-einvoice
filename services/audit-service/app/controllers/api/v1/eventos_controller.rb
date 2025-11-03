module Api
  module V1
    class EventosController < ApplicationController
      def create
        @evento = EventoAuditoria.new(evento_params)
        
        if @evento.save
          render json: @evento, status: :created
        else
          render json: { errors: @evento.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def index
        eventos = EventoAuditoria.all.order_by(timestamp: :desc)
        
        # Filtros opcionales
        eventos = eventos.where(servicio: params[:servicio]) if params[:servicio].present?
        eventos = eventos.where(evento: params[:evento]) if params[:evento].present?
        eventos = eventos.where(entidad_tipo: params[:entidad_tipo]) if params[:entidad_tipo].present?
        eventos = eventos.where(entidad_id: params[:entidad_id]) if params[:entidad_id].present?
        
        # Paginación básica
        limit = params[:limit]&.to_i || 50
        limit = [limit, 100].min # Máximo 100
        
        @eventos = eventos.limit(limit)
        render json: @eventos
      end

      def show
        @evento = EventoAuditoria.find(params[:id])
        render json: @evento
      rescue Mongoid::Errors::DocumentNotFound
        render json: { error: "Evento no encontrado" }, status: :not_found
      end

      private

      def evento_params
        params.require(:evento).permit(:evento, :timestamp, :servicio, :entidad_tipo, :entidad_id, :usuario_id, datos: {})
      end
    end
  end
end

