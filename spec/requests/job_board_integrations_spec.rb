require 'rails_helper'

RSpec.describe 'JobBoardIntegrations', type: :request do
  describe 'GET /index' do
    it 'returns http success' do
      get '/job_board_integrations/index'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /show' do
    it 'returns http success' do
      get '/job_board_integrations/show'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /new' do
    it 'returns http success' do
      get '/job_board_integrations/new'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /create' do
    it 'returns http success' do
      get '/job_board_integrations/create'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /edit' do
    it 'returns http success' do
      get '/job_board_integrations/edit'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /update' do
    it 'returns http success' do
      get '/job_board_integrations/update'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /destroy' do
    it 'returns http success' do
      get '/job_board_integrations/destroy'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /test_connection' do
    it 'returns http success' do
      get '/job_board_integrations/test_connection'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /sync_job' do
    it 'returns http success' do
      get '/job_board_integrations/sync_job'
      expect(response).to have_http_status(:success)
    end
  end
end
