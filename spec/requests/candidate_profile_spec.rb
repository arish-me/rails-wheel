require 'rails_helper'

RSpec.describe 'CandidateProfiles', type: :request do
  describe 'GET /index' do
    it 'returns http success' do
      get '/candidate_profile/index'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /show' do
    it 'returns http success' do
      get '/candidate_profile/show'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /update' do
    it 'returns http success' do
      get '/candidate_profile/update'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /edit' do
    it 'returns http success' do
      get '/candidate_profile/edit'
      expect(response).to have_http_status(:success)
    end
  end
end
