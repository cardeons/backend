Rails.application.config.middleware.insert_before 0, Rack::Cors do
    allow do
        origin "http://localhost:3000"
        resource "*", headers: :any, methods: [:get, :post, :put, :patch, :delete, :options, :head], credentials: true
    end

    #frontend domain hier :)
    #allow do
        #frontend domain hier :)
        #origin "http://cardeons.com"
        #resource "*", headers: :any, methods: [:get, :post, :put, :patch, :delete, :options, :head], credentials: true
    #end
end