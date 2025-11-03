module Api
  module V1
    class ClientesController < ApplicationController
      before_action :set_cliente, only: [:show, :update, :destroy]

      # GET /api/v1/clientes
      def index
        clientes = Cliente.all.order(created_at: :desc)
        render json: clientes, status: :ok
      end

      # GET /api/v1/clientes/:id
      def show
        render json: @cliente, status: :ok
      end

      # POST /api/v1/clientes
      def create
        cliente = Cliente.new(cliente_params)

        if cliente.save
          render json: cliente, status: :created
        else
          render json: { errors: cliente.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PUT /api/v1/clientes/:id
      def update
        if @cliente.update(cliente_params)
          render json: @cliente, status: :ok
        else
          render json: { errors: @cliente.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/clientes/:id
      def destroy
        @cliente.desactivar!
        render json: { message: 'Cliente desactivado exitosamente' }, status: :ok
      end

      private

      def set_cliente
        @cliente = Cliente.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Cliente no encontrado' }, status: :not_found
      end

      def cliente_params
        params.require(:cliente).permit(:nit, :nombre, :email, :telefono, :direccion, :activo)
      end
    end
  end
end

