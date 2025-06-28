require 'rails_helper'

RSpec.describe PermissionsController, type: :controller do
  let(:user) { create(:user) }
  let(:company) { create(:company) }
  let(:permission) { create(:permission) }

  before do
    user.update!(company: company)
    sign_in user
  end

  describe 'GET #index' do
    let!(:permissions) { create_list(:permission, 3) }

    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end

    it 'assigns paginated permissions' do
      get :index
      expect(assigns(:permissions)).to be_present
    end

    context 'with search query' do
      it 'filters permissions by name' do
        get :index, params: { query: permissions.first.name }
        expect(assigns(:permissions)).to include(permissions.first)
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
      get :show, params: { id: permission.id }
      expect(response).to have_http_status(:success)
    end

    it 'assigns the requested permission' do
      get :show, params: { id: permission.id }
      expect(assigns(:permission)).to eq(permission)
    end
  end

  describe 'GET #new' do
    it 'returns http success' do
      get :new
      expect(response).to have_http_status(:success)
    end

    it 'assigns a new permission' do
      get :new
      expect(assigns(:permission)).to be_a_new(Permission)
    end
  end

  describe 'GET #edit' do
    it 'returns http success' do
      get :edit, params: { id: permission.id }
      expect(response).to have_http_status(:success)
    end

    it 'assigns the requested permission' do
      get :edit, params: { id: permission.id }
      expect(assigns(:permission)).to eq(permission)
    end
  end

  describe 'POST #create' do
    let(:valid_params) { { permission: { name: 'New Permission', resource: 'posts' } } }

    context 'with valid params' do
      it 'creates a new permission' do
        expect {
          post :create, params: valid_params
        }.to change(Permission, :count).by(1)
      end

      it 'assigns the newly created permission' do
        post :create, params: valid_params
        expect(assigns(:permission)).to be_persisted
      end

      it 'sets flash notice' do
        post :create, params: valid_params
        expect(flash[:notice]).to eq("Permission was successfully created.")
      end

      it 'redirects to the created permission' do
        post :create, params: valid_params
        expect(response).to redirect_to(Permission.last)
      end
    end

    context 'with invalid params' do
      let(:invalid_params) { { permission: { name: '' } } }

      it 'does not create a new permission' do
        expect {
          post :create, params: invalid_params
        }.not_to change(Permission, :count)
      end

      it 'renders new template' do
        post :create, params: invalid_params
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'PATCH #update' do
    let(:valid_params) { { id: permission.id, permission: { name: 'Updated Permission' } } }

    context 'with valid params' do
      it 'updates the requested permission' do
        patch :update, params: valid_params
        expect(permission.reload.name).to eq('Updated Permission')
      end

      it 'sets flash notice' do
        patch :update, params: valid_params
        expect(flash[:notice]).to eq("Permission was successfully updated.")
      end

      it 'redirects to the permission' do
        patch :update, params: valid_params
        expect(response).to redirect_to(permission)
      end
    end

    context 'with invalid params' do
      let(:invalid_params) { { id: permission.id, permission: { name: '' } } }

      it 'renders edit template' do
        patch :update, params: invalid_params
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:permission_to_delete) { create(:permission) }

    it 'destroys the requested permission' do
      expect {
        delete :destroy, params: { id: permission_to_delete.id }
      }.to change(Permission, :count).by(-1)
    end

    it 'redirects to permissions list' do
      delete :destroy, params: { id: permission_to_delete.id }
      expect(response).to redirect_to(permissions_path)
    end

    it 'sets flash notice' do
      delete :destroy, params: { id: permission_to_delete.id }
      expect(flash[:notice]).to eq("Permission was successfully destroyed.")
    end
  end

  describe 'POST #bulk_destroy' do
    let!(:permissions) { create_list(:permission, 3) }
    let(:valid_params) { { bulk_delete: { resource_ids: permissions.map(&:id) } } }

    context 'with valid resource_ids' do
      it 'destroys multiple permissions' do
        expect {
          post :bulk_destroy, params: valid_params
        }.to change(Permission, :count).by(-3)
      end

      it 'redirects to permissions path' do
        post :bulk_destroy, params: valid_params
        expect(response).to redirect_to(permissions_path)
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
    describe '#set_permission' do
      it 'sets @permission to the requested permission' do
        controller.send(:set_permission, permission.id)
        expect(assigns(:permission)).to eq(permission)
      end
    end

    describe '#authorize_resource' do
      it 'authorizes the permission' do
        allow(controller).to receive(:authorize)
        controller.send(:authorize_resource)
        expect(controller).to have_received(:authorize).with(permission)
      end
    end

    describe '#permission_params' do
      it 'permits correct parameters' do
        params = ActionController::Parameters.new(
          permission: { name: 'Test', resource: 'posts', invalid: 'param' }
        )
        allow(controller).to receive(:params).and_return(params)
        
        permitted_params = controller.send(:permission_params)
        expect(permitted_params).to include(:name, :resource)
        expect(permitted_params).not_to include(:invalid)
      end
    end

    describe '#bulk_delete_params' do
      it 'permits resource_ids array' do
        params = ActionController::Parameters.new(
          bulk_delete: { resource_ids: ['1', '2'], invalid: 'param' }
        )
        allow(controller).to receive(:params).and_return(params)
        
        permitted_params = controller.send(:bulk_delete_params)
        expect(permitted_params[:resource_ids]).to eq(['1', '2'])
        expect(permitted_params).not_to include(:invalid)
      end
    end
  end
end 