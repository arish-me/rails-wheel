require 'rails_helper'

RSpec.describe CompaniesController, type: :controller do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe 'GET #index' do
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #new' do
    it 'returns http success' do
      get :new
      expect(response).to have_http_status(:success)
    end

    it 'assigns a new company' do
      get :new
      expect(assigns(:company)).to be_a_new(Company)
    end
  end

  describe 'GET #show' do
    it 'returns http success' do
      get :show
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    let(:valid_params) { { company: { name: 'Test Company', subdomain: 'test', website: 'https://test.com' } } }

    context 'with valid params' do
      context 'when user needs onboarding' do
        before do
          allow(user).to receive(:needs_onboarding?).and_return(true)
        end

        it 'creates a new company' do
          expect {
            post :create, params: valid_params
          }.to change(Company, :count).by(1)
        end

        it 'updates user company association' do
          post :create, params: valid_params
          expect(user.reload.company).to eq(Company.last)
        end

        it 'redirects to preferences onboarding' do
          post :create, params: valid_params
          expect(response).to redirect_to(preferences_onboarding_path)
        end

        it 'sets flash notice' do
          post :create, params: valid_params
          expect(flash[:notice]).to eq("Company was successfully created.")
        end
      end

      context 'when user does not need onboarding' do
        before do
          allow(user).to receive(:needs_onboarding?).and_return(false)
        end

        it 'redirects to company show page' do
          post :create, params: valid_params
          expect(response).to redirect_to(Company.last)
        end
      end
    end

    context 'with invalid params' do
      let(:invalid_params) { { company: { name: '' } } }

      context 'when user needs onboarding' do
        before do
          allow(user).to receive(:needs_onboarding?).and_return(true)
        end

        it 'redirects to onboarding with alert' do
          post :create, params: invalid_params
          expect(response).to redirect_to(onboarding_path)
        end
      end

      context 'when user does not need onboarding' do
        before do
          allow(user).to receive(:needs_onboarding?).and_return(false)
        end

        it 'renders new template' do
          post :create, params: invalid_params
          expect(response).to render_template(:new)
        end
      end
    end
  end

  describe 'PATCH #update' do
    let(:company) { create(:company) }
    let(:valid_params) { { company: { name: 'Updated Company' } } }

    before do
      user.update!(company: company)
    end

    context 'with valid params' do
      context 'when user needs onboarding' do
        before do
          allow(user).to receive(:needs_onboarding?).and_return(true)
        end

        it 'updates the company' do
          patch :update, params: valid_params
          expect(company.reload.name).to eq('Updated Company')
        end

        it 'redirects to preferences onboarding' do
          patch :update, params: valid_params
          expect(response).to redirect_to(preferences_onboarding_path)
        end
      end

      context 'when user does not need onboarding' do
        before do
          allow(user).to receive(:needs_onboarding?).and_return(false)
        end

        it 'redirects to company show page' do
          patch :update, params: valid_params
          expect(response).to redirect_to(company)
        end
      end
    end

    context 'with invalid params' do
      let(:invalid_params) { { company: { name: '' } } }

      context 'when user needs onboarding' do
        before do
          allow(user).to receive(:needs_onboarding?).and_return(true)
        end

        it 'redirects to onboarding with alert' do
          patch :update, params: invalid_params
          expect(response).to redirect_to(onboarding_path)
        end
      end

      context 'when user does not need onboarding' do
        before do
          allow(user).to receive(:needs_onboarding?).and_return(false)
        end

        it 'renders new template' do
          patch :update, params: invalid_params
          expect(response).to render_template(:new)
        end
      end
    end
  end

  describe 'private methods' do
    describe '#set_company' do
      let(:company) { create(:company) }

      before do
        user.update!(company: company)
      end

      it 'sets @company to current user company' do
        controller.send(:set_company)
        expect(assigns(:company)).to eq(company)
      end
    end

    describe '#company_params' do
      it 'permits correct parameters' do
        params = ActionController::Parameters.new(
          company: { name: 'Test', subdomain: 'test', website: 'https://test.com', invalid: 'param' }
        )
        allow(controller).to receive(:params).and_return(params)
        
        permitted_params = controller.send(:company_params)
        expect(permitted_params).to include(:name, :subdomain, :website)
        expect(permitted_params).not_to include(:invalid)
      end
    end
  end
end 