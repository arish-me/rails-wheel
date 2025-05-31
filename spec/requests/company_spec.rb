require 'rails_helper'

RSpec.describe "Companies", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/company/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/company/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/company/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      get "/company/update"
      expect(response).to have_http_status(:success)
    end
  end
end
