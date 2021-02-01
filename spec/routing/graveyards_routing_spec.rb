require "rails_helper"

RSpec.describe GraveyardsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/graveyards").to route_to("graveyards#index")
    end

    it "routes to #new" do
      expect(get: "/graveyards/new").to route_to("graveyards#new")
    end

    it "routes to #show" do
      expect(get: "/graveyards/1").to route_to("graveyards#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/graveyards/1/edit").to route_to("graveyards#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/graveyards").to route_to("graveyards#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/graveyards/1").to route_to("graveyards#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/graveyards/1").to route_to("graveyards#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/graveyards/1").to route_to("graveyards#destroy", id: "1")
    end
  end
end
