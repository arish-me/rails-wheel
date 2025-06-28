require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    def index
      render plain: 'OK'
    end
  end

  describe 'inheritance' do
    it 'inherits from ActionController::Base' do
      expect(ApplicationController).to be < ActionController::Base
    end
  end

  describe 'includes' do
    it 'includes Breadcrumbable' do
      expect(ApplicationController.included_modules).to include(Breadcrumbable)
    end

    it 'includes Notifiable' do
      expect(ApplicationController.included_modules).to include(Notifiable)
    end

    it 'includes Onboardable' do
      expect(ApplicationController.included_modules).to include(Onboardable)
    end

    it 'includes Pagy::Backend' do
      expect(ApplicationController.included_modules).to include(Pagy::Backend)
    end

    it 'includes Pundit::Authorization' do
      expect(ApplicationController.included_modules).to include(Pundit::Authorization)
    end
  end


  describe 'before_actions' do
    it 'sets locale from session or params' do
      expect(ApplicationController._process_action_callbacks.map(&:filter)).to include(:set_locale_from_session_or_params)
    end

    it 'sets active storage url options' do
      expect(ApplicationController._process_action_callbacks.map(&:filter)).to include(:set_active_storage_url_options)
    end

    it 'sets tenant' do
      expect(ApplicationController._process_action_callbacks.map(&:filter)).to include(:set_tenent)
    end
  end

  describe '#user_not_authorized' do
    let(:user) { create(:user) }

    before do
      sign_in user, scope: :user 
      allow(controller).to receive(:request).and_return(double(referrer: '/previous'))
    end

    it 'sets flash alert' do
      controller.send(:user_not_authorized)
      expect(flash[:alert]).to eq("You are not authorized to perform this action.")
    end

    it 'redirects to referrer' do
      controller.send(:user_not_authorized)
      expect(response).to redirect_to('/previous')
    end
  end

  describe '#set_tenent' do
    let(:user) { create(:user) }
    let(:company) { create(:company) }

    before do
      user.update!(company: company)
      sign_in user, scope: :user 
    end

    it 'sets current tenant to user company' do
      controller.send(:set_tenent)
      expect(ActsAsTenant.current_tenant).to eq(company)
    end
  end
end 