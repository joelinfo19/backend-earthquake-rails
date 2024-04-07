Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*' # Permite a todas las URL acceder a tu API. Puedes restringir esto según tus necesidades.
    resource '*', headers: :any, methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end