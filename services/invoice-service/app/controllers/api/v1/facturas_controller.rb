module Api
  module V1
    class FacturasController < ApplicationController
      before_action :set_factura, only: [:show, :update, :destroy, :emitir, :anular]

      def index
        @facturas = Factura.includes(:items_factura).all
        render json: @facturas, include: :items_factura
      end

      def show
        render json: @factura, include: :items_factura
      end

      def create
        service = CrearFacturaService.new
        @factura = service.ejecutar(factura_params)
        render json: @factura, include: :items_factura, status: :created
      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
      rescue StandardError => e
        render json: { error: e.message }, status: :unprocessable_entity
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
      rescue StandardError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      def anular
        service = AnularFacturaService.new
        motivo = params[:motivo] || params[:factura]&.[](:motivo)
        @factura = service.ejecutar(@factura.id, motivo)
        render json: @factura, include: :items_factura
      rescue StandardError => e
        render json: { error: e.message }, status: :unprocessable_entity
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

