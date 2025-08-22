require 'rails_helper'

RSpec.describe 'JobBoardProviders', type: :request do
  describe 'GET /index' do
    it 'returns http success' do
      get '/job_board_providers/index'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /show' do
    it 'returns http success' do
      get '/job_board_providers/show'
      expect(response).to have_http_status(:success)
    end
  end
end
