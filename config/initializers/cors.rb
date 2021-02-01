Rails.application.config.middleware.insert_before 0, Rack::Cors do
    allow do
        origins "http://localhost:*"
        resource "*", headers: :any, methods: [:get, :post, :put, :patch, :delete, :options, :head], credentials: true
    end

    #frontend domain hier :)
    #allow do
        #frontend domain hier :)
        #origins "https://cardeons-develop.netlify.app/" 
        #resource "*", headers: :any, methods: [:get, :post, :put, :patch, :delete, :options, :head], credentials: true
    #end
end