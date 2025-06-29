require 'rails_helper'

RSpec.describe DashboardController, type: :controller do
  let(:user) { create(:user) }
  let(:company) { create(:company) }

  before do
    user.update!(company: company)
    sign_in user
  end

  describe 'GET #index' do
    context 'when user has company' do
      before do
        ActsAsTenant.current_tenant = company
      end

      it 'returns http success' do
        get :index
        expect(response).to have_http_status(:success)
      end

      it 'assigns total_users' do
        get :index
        expect(assigns(:total_users)).to be_present
      end

      it 'assigns total_categories' do
        get :index
        expect(assigns(:total_categories)).to be_present
      end

      it 'assigns users_by_day' do
        get :index
        expect(assigns(:users_by_day)).to be_present
      end

      it 'assigns categories_by_day' do
        get :index
        expect(assigns(:categories_by_day)).to be_present
      end
    end

    context 'when user has no company' do
      before do
        user.update!(company: nil)
      end

      it 'returns http success' do
        get :index
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'authentication' do
    it 'requires user to be signed in' do
      sign_out user
      get :index
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
