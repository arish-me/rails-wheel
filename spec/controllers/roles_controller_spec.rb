require 'rails_helper'

RSpec.describe RolesController, type: :controller do
  let(:user) { create(:user) }
  let(:company) { create(:company) }
  let(:role) { create(:role, company: company) }

  before do
    user.update!(company: company)
    sign_in user
  end

  describe 'GET #index' do
    let!(:roles) { create_list(:role, 3, company: company) }

    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end

    it 'assigns paginated roles' do
      get :index
      expect(assigns(:roles)).to be_present
    end

    context 'with search query' do
      it 'filters roles by name' do
        get :index, params: { query: roles.first.name }
        expect(assigns(:roles)).to include(roles.first)
      end
    end

    context 'with per_page parameter' do
      it 'respects per_page limit' do
        get :index, params: { per_page: '5' }
        expect(assigns(:pagy).items).to eq(5)
      end
    end
  end

  describe 'GET #show' do
    it 'returns http success' do
      get :show, params: { id: role.id }
      expect(response).to have_http_status(:success)
    end

    it 'assigns the requested role' do
      get :show, params: { id: role.id }
      expect(assigns(:role)).to eq(role)
    end
  end

  describe 'GET #new' do
    it 'returns http success' do
      get :new
      expect(response).to have_http_status(:success)
    end

    it 'assigns a new role' do
      get :new
      expect(assigns(:role)).to be_a_new(Role)
    end
  end

  describe 'GET #edit' do
    it 'returns http success' do
      get :edit, params: { id: role.id }
      expect(response).to have_http_status(:success)
    end

    it 'assigns the requested role' do
      get :edit, params: { id: role.id }
      expect(assigns(:role)).to eq(role)
    end
  end

  describe 'POST #create' do
    let(:valid_params) { { role: { name: 'New Role', is_default: false } } }

    context 'with valid params' do
      it 'creates a new role' do
        expect {
          post :create, params: valid_params
        }.to change(Role, :count).by(1)
      end

      it 'assigns the newly created role' do
        post :create, params: valid_params
        expect(assigns(:role)).to be_persisted
      end

      it 'sets flash notice' do
        post :create, params: valid_params
        expect(flash[:notice]).to eq("Role was successfully created.")
      end

      it 'redirects to the created role' do
        post :create, params: valid_params
        expect(response).to redirect_to(Role.last)
      end
    end

    context 'with invalid params' do
      let(:invalid_params) { { role: { name: '' } } }

      it 'does not create a new role' do
        expect {
          post :create, params: invalid_params
        }.not_to change(Role, :count)
      end

      it 'renders new template' do
        post :create, params: invalid_params
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'PATCH #update' do
    let(:valid_params) { { id: role.id, role: { name: 'Updated Role' } } }

    context 'with valid params' do
      it 'updates the requested role' do
        patch :update, params: valid_params
        expect(role.reload.name).to eq('Updated Role')
      end

      it 'sets flash notice' do
        patch :update, params: valid_params
        expect(flash[:notice]).to eq("Role was successfully updated.")
      end

      it 'redirects to the role' do
        patch :update, params: valid_params
        expect(response).to redirect_to(role)
      end
    end

    context 'with invalid params' do
      let(:invalid_params) { { id: role.id, role: { name: '' } } }

      it 'renders edit template' do
        patch :update, params: invalid_params
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:role_to_delete) { create(:role, company: company) }

    it 'destroys the requested role' do
      expect {
        delete :destroy, params: { id: role_to_delete.id }
      }.to change(Role, :count).by(-1)
    end

    it 'redirects to roles list' do
      delete :destroy, params: { id: role_to_delete.id }
      expect(response).to redirect_to(roles_path)
    end

    it 'sets flash notice' do
      delete :destroy, params: { id: role_to_delete.id }
      expect(flash[:notice]).to eq("Role was successfully destroyed.")
    end
  end

  describe 'POST #bulk_destroy' do
    let!(:roles) { create_list(:role, 3, company: company) }
    let(:valid_params) { { bulk_delete: { resource_ids: roles.map(&:id) } } }

    context 'with valid resource_ids' do
      it 'destroys multiple roles' do
        expect {
          post :bulk_destroy, params: valid_params
        }.to change(Role, :count).by(-3)
      end

      it 'redirects to roles path' do
        post :bulk_destroy, params: valid_params
        expect(response).to redirect_to(roles_path)
      end
    end

    context 'with empty resource_ids' do
      let(:invalid_params) { { bulk_delete: { resource_ids: [] } } }

      it 'renders new template' do
        post :bulk_destroy, params: invalid_params
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'private methods' do
    describe '#set_role' do
      it 'sets @role to the requested role' do
        controller.send(:set_role, role.id)
        expect(assigns(:role)).to eq(role)
      end
    end

    describe '#authorize_resource' do
      it 'authorizes the role' do
        allow(controller).to receive(:authorize)
        controller.send(:authorize_resource)
        expect(controller).to have_received(:authorize).with(role)
      end
    end

    describe '#role_params' do
      it 'permits correct parameters' do
        params = ActionController::Parameters.new(
          role: { name: 'Test', is_default: false, invalid: 'param' }
        )
        allow(controller).to receive(:params).and_return(params)

        permitted_params = controller.send(:role_params)
        expect(permitted_params).to include(:name, :is_default)
        expect(permitted_params).not_to include(:invalid)
      end
    end

    describe '#bulk_delete_params' do
      it 'permits resource_ids array' do
        params = ActionController::Parameters.new(
          bulk_delete: { resource_ids: [ '1', '2' ], invalid: 'param' }
        )
        allow(controller).to receive(:params).and_return(params)

        permitted_params = controller.send(:bulk_delete_params)
        expect(permitted_params[:resource_ids]).to eq([ '1', '2' ])
        expect(permitted_params).not_to include(:invalid)
      end
    end
  end
end
