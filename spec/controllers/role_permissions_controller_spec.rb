require 'rails_helper'

RSpec.describe RolePermissionsController, type: :controller do
  let(:user) { create(:user) }
  let(:company) { create(:company) }
  let(:role) { create(:role, company: company) }
  let(:permission) { create(:permission) }
  let(:role_permission) { create(:role_permission, role: role, permission: permission) }

  before do
    user.update!(company: company)
    sign_in user
  end

  describe 'GET #index' do
    let!(:role_permissions) { create_list(:role_permission, 3, role: role) }

    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end

    it 'assigns paginated role_permissions' do
      get :index
      expect(assigns(:role_permissions)).to be_present
    end

    context 'with search query' do
      it 'filters role_permissions by role name' do
        get :index, params: { query: role.name }
        expect(assigns(:role_permissions)).to include(role_permissions.first)
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
      get :show, params: { id: role_permission.id }
      expect(response).to have_http_status(:success)
    end

    it 'assigns the requested role_permission' do
      get :show, params: { id: role_permission.id }
      expect(assigns(:role_permission)).to eq(role_permission)
    end
  end

  describe 'GET #new' do
    it 'returns http success' do
      get :new
      expect(response).to have_http_status(:success)
    end

    it 'assigns a new role_permission' do
      get :new
      expect(assigns(:role_permission)).to be_a_new(RolePermission)
    end
  end

  describe 'GET #edit' do
    it 'returns http success' do
      get :edit, params: { id: role_permission.id }
      expect(response).to have_http_status(:success)
    end

    it 'assigns the requested role_permission' do
      get :edit, params: { id: role_permission.id }
      expect(assigns(:role_permission)).to eq(role_permission)
    end
  end

  describe 'POST #create' do
    let(:valid_params) { { role_permission: { role_id: role.id, permission_id: permission.id, action: 'view' } } }

    context 'with valid params' do
      it 'creates a new role_permission' do
        expect do
          post :create, params: valid_params
        end.to change(RolePermission, :count).by(1)
      end

      it 'assigns the newly created role_permission' do
        post :create, params: valid_params
        expect(assigns(:role_permission)).to be_persisted
      end

      it 'sets flash notice' do
        post :create, params: valid_params
        expect(flash[:notice]).to eq('Role permission was successfully created.')
      end

      it 'redirects to the created role_permission' do
        post :create, params: valid_params
        expect(response).to redirect_to(RolePermission.last)
      end
    end

    context 'with invalid params' do
      let(:invalid_params) { { role_permission: { role_id: nil } } }

      it 'does not create a new role_permission' do
        expect do
          post :create, params: invalid_params
        end.not_to change(RolePermission, :count)
      end

      it 'renders new template' do
        post :create, params: invalid_params
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'PATCH #update' do
    let(:valid_params) { { id: role_permission.id, role_permission: { action: 'edit' } } }

    context 'with valid params' do
      it 'updates the requested role_permission' do
        patch :update, params: valid_params
        expect(role_permission.reload.action).to eq('edit')
      end

      it 'sets flash notice' do
        patch :update, params: valid_params
        expect(flash[:notice]).to eq('Role permission was successfully updated.')
      end

      it 'redirects to the role_permission' do
        patch :update, params: valid_params
        expect(response).to redirect_to(role_permission)
      end
    end

    context 'with invalid params' do
      let(:invalid_params) { { id: role_permission.id, role_permission: { role_id: nil } } }

      it 'renders edit template' do
        patch :update, params: invalid_params
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:role_permission_to_delete) { create(:role_permission, role: role) }

    it 'destroys the requested role_permission' do
      expect do
        delete :destroy, params: { id: role_permission_to_delete.id }
      end.to change(RolePermission, :count).by(-1)
    end

    it 'redirects to role_permissions list' do
      delete :destroy, params: { id: role_permission_to_delete.id }
      expect(response).to redirect_to(role_permissions_path)
    end

    it 'sets flash notice' do
      delete :destroy, params: { id: role_permission_to_delete.id }
      expect(flash[:notice]).to eq('Role permission was successfully destroyed.')
    end
  end

  describe 'POST #bulk_destroy' do
    let!(:role_permissions) { create_list(:role_permission, 3, role: role) }
    let(:valid_params) { { bulk_delete: { resource_ids: role_permissions.map(&:id) } } }

    context 'with valid resource_ids' do
      it 'destroys multiple role_permissions' do
        expect do
          post :bulk_destroy, params: valid_params
        end.to change(RolePermission, :count).by(-3)
      end

      it 'redirects to role_permissions path' do
        post :bulk_destroy, params: valid_params
        expect(response).to redirect_to(role_permissions_path)
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
    describe '#set_role_permission' do
      it 'sets @role_permission to the requested role_permission' do
        controller.send(:set_role_permission, role_permission.id)
        expect(assigns(:role_permission)).to eq(role_permission)
      end
    end

    describe '#authorize_resource' do
      it 'authorizes the role_permission' do
        allow(controller).to receive(:authorize)
        controller.send(:authorize_resource)
        expect(controller).to have_received(:authorize).with(role_permission)
      end
    end

    describe '#role_permission_params' do
      it 'permits correct parameters' do
        params = ActionController::Parameters.new(
          role_permission: { role_id: '1', permission_id: '2', action: 'view', invalid: 'param' }
        )
        allow(controller).to receive(:params).and_return(params)

        permitted_params = controller.send(:role_permission_params)
        expect(permitted_params).to include(:role_id, :permission_id, :action)
        expect(permitted_params).not_to include(:invalid)
      end
    end
  end
end
