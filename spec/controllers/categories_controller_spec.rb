require 'rails_helper'

RSpec.describe CategoriesController, type: :controller do
  let(:company) { create(:company) }
  let(:super_admin_role) { create(:role, company: company) }
  let(:user) { create(:user, :onboarded) }
  let(:category) { create(:category, user: user) }
  let(:category_permission) { Permission.find_by(resource: 'Category') }

  before do
    # Set up user with company and super admin role
    user.update!(company: company)
    ActsAsTenant.current_tenant = company
    create(:user_role, user: user, role: super_admin_role)
    # Create edit permission for Category resource
    create(:role_permission, :edit, role: super_admin_role, permission: category_permission, company: company)
    sign_in user
  end

  describe 'GET #index' do
    let!(:categories) { create_list(:category, 3, user: user) }

    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end

    it 'assigns paginated categories' do
      get :index
      expect(assigns(:categories)).to be_present
    end

    context 'with search query' do
      it 'filters categories by name' do
        get :index, params: { query: categories.first.name }
        expect(assigns(:categories)).to include(categories.first)
      end
    end

    context 'with per_page parameter' do
      it 'respects per_page limit' do
        get :index, params: { per_page: '5' }
        expect(assigns(:pagy).limit).to eq(5)
      end
    end
  end

  describe 'GET #show' do
    it 'returns http success' do
      get :show, params: { id: category.id }
      expect(response).to have_http_status(:success)
    end

    it 'assigns the requested category' do
      get :show, params: { id: category.id }
      expect(assigns(:category)).to eq(category)
    end
  end

  describe 'GET #new' do
    it 'returns http success' do
      get :new
      expect(response).to have_http_status(:success)
    end

    it 'assigns a new category for current user' do
      get :new
      expect(assigns(:category)).to be_a_new(Category)
      expect(assigns(:category).user).to eq(user)
    end
  end

  describe 'GET #edit' do
    it 'returns http success' do
      get :edit, params: { id: category.id }
      expect(response).to have_http_status(:success)
    end

    it 'assigns the requested category' do
      get :edit, params: { id: category.id }
      expect(assigns(:category)).to eq(category)
    end
  end

  describe 'POST #create' do
    let(:valid_params) { { category: { name: 'New Category', description: 'Description' } } }

    context 'with valid params' do
      it 'creates a new category' do
        expect do
          post :create, params: valid_params
        end.to change(Category, :count).by(1)
      end

      it 'assigns the newly created category' do
        post :create, params: valid_params
        expect(assigns(:category)).to be_persisted
      end

      it 'sets flash notice' do
        post :create, params: valid_params
        expect(flash[:notice]).to eq('Category was successfully created.')
      end

      it 'redirects to the created category' do
        post :create, params: valid_params
        expect(response).to redirect_to(Category.last)
      end
    end

    context 'with invalid params' do
      let(:invalid_params) { { category: { name: '' } } }

      it 'does not create a new category' do
        expect do
          post :create, params: invalid_params
        end.not_to change(Category, :count)
      end

      it 'renders new template' do
        post :create, params: invalid_params
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'PATCH #update' do
    let(:valid_params) { { id: category.id, category: { name: 'Updated Category' } } }

    context 'with valid params' do
      it 'updates the requested category' do
        patch :update, params: valid_params
        expect(category.reload.name).to eq('Updated Category')
      end

      it 'sets flash notice' do
        patch :update, params: valid_params
        expect(flash[:notice]).to eq('Category was successfully updated.')
      end

      it 'redirects to the category' do
        patch :update, params: valid_params
        expect(response).to redirect_to(category)
      end
    end

    context 'with invalid params' do
      let(:invalid_params) { { id: category.id, category: { name: '' } } }

      it 'renders edit template' do
        patch :update, params: invalid_params
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:category_to_delete) { create(:category, user: user) }

    it 'destroys the requested category' do
      expect do
        delete :destroy, params: { id: category_to_delete.id }
      end.to change(Category, :count).by(-1)
    end

    it 'redirects to categories list' do
      delete :destroy, params: { id: category_to_delete.id }
      expect(response).to redirect_to(categories_path)
    end

    it 'sets flash notice' do
      delete :destroy, params: { id: category_to_delete.id }
      expect(flash[:notice]).to eq('Category was successfully destroyed.')
    end
  end

  describe 'POST #bulk_destroy' do
    let!(:categories) { create_list(:category, 3, user: user) }
    let(:valid_params) { { bulk_delete: { resource_ids: categories.map(&:id) } } }

    context 'with valid resource_ids' do
      it 'destroys multiple categories' do
        expect do
          post :bulk_destroy, params: valid_params
        end.to change(Category, :count).by(-3)
      end

      it 'redirects to categories path' do
        post :bulk_destroy, params: valid_params
        expect(response).to redirect_to(categories_path)
      end
    end

    context 'with empty resource_ids' do
      let(:invalid_params) { { bulk_delete: { resource_ids: [ 123 ] } } }

      it 'renders new template' do
        post :bulk_destroy, params: invalid_params
        expect(response).to redirect_to(categories_path)
      end
    end
  end
end
