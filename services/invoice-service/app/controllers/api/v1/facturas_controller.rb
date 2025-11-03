module Api
  module V1
    class FacturasController < ApplicationController
      before_action :set_factura, only: [:show, :update, :destroy, :emitir, :anular]

      def index
        @facturas = Factura.includes(:items_factura).all
        
        # Filtrar por rango de fechas si se proporcionan
        if params[:fechaInicio].present?
          fecha_inicio = Date.parse(params[:fechaInicio])
          @facturas = @facturas.where('fecha_emision >= ?', fecha_inicio)
        end
        
        if params[:fechaFin].present?
          fecha_fin = Date.parse(params[:fechaFin])
          @facturas = @facturas.where('fecha_emision <= ?', fecha_fin)
        end
        
        render json: @facturas, include: :items_factura
      rescue ArgumentError => e
        render json: { 
          error: 'Formato de fecha inválido. Use formato YYYY-MM-DD (ej: 2025-01-15)',
          code: 'INVALID_DATE_FORMAT'
        }, status: :bad_request
      end

      def show
        render json: @factura, include: :items_factura
      end

      def create
        service = CrearFacturaService.new
        @factura = service.ejecutar(factura_params)
        render json: @factura, include: :items_factura, status: :created
      end

      def update
        if @factura.update(factura_params.except(:estado))
          # Actualizar items si se proporcionaron
          if params[:factura][:items_factura]
            @factura.items_factura.destroy_all
            params[:factura][:items_factura].each do |item_params|
              @factura.items_factura.create!(item_params)
            end
            @factura.reload
            @factura.calcular_totales
            @factura.save!
          end
          render json: @factura, include: :items_factura
        else
          render json: @factura.errors, status: :unprocessable_entity
        end
      end

      def destroy
        if @factura.estado == 'borrador'
          @factura.destroy
          head :no_content
        else
          render json: { error: 'Solo se pueden eliminar facturas en borrador' }, status: :unprocessable_entity
        end
      end

      def emitir
        service = EmitirFacturaService.new
        @factura = service.ejecutar(@factura.id)
        render json: @factura, include: :items_factura
      end

      def anular
        service = AnularFacturaService.new
        motivo = params[:motivo] || params[:factura]&.[](:motivo)
        @factura = service.ejecutar(@factura.id, motivo)
        render json: @factura, include: :items_factura
      end

      private

      def set_factura
        @factura = Factura.find(params[:id])
      end

      def factura_params
        params.require(:factura).permit(:cliente_id, :estado, items_factura: [:descripcion, :cantidad, :precio_unitario, :impuesto_porcentaje])
      end
    end
  end
end

