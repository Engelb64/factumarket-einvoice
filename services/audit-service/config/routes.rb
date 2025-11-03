Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # API Routes
  namespace :api do
    namespace :v1 do
      scope path: 'auditoria' do
        resources :eventos, only: [:index, :show, :create], controller: 'eventos'
        resources :reportes, only: [:index], controller: 'reportes' do
          collection do
            get :resumen
          end
        end
        
        # Endpoint específico para consultar eventos por facturaId
        get 'factura/:factura_id', to: 'eventos#por_factura', as: :eventos_por_factura
      end
    end
  end
end
