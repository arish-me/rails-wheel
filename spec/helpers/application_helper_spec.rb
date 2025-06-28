require 'rails_helper'
require "pundit/rspec"

RSpec.describe ApplicationHelper, type: :helper do
  describe '#locale_name' do
    it 'returns English for :en' do
      expect(helper.locale_name(:en)).to eq('English')
    end

    it 'returns Español for :es' do
      expect(helper.locale_name(:es)).to eq('Español')
    end

    it 'returns Français for :fr' do
      expect(helper.locale_name(:fr)).to eq('Français')
    end

    it 'returns uppercase for unknown locale' do
      expect(helper.locale_name(:de)).to eq('DE')
    end

    it 'handles string input' do
      expect(helper.locale_name('en')).to eq('English')
    end
  end

  describe '#previous_path' do
    context 'when session has return_to' do
      before do
        session[:return_to] = '/dashboard'
      end

      it 'returns session return_to path' do
        expect(helper.previous_path).to eq('/dashboard')
      end
    end

    context 'when session has no return_to' do
      before do
        session[:return_to] = nil
      end

      it 'returns fallback path' do
        expect(helper.previous_path).to eq(helper.fallback_path)
      end
    end
  end

  describe '#fallback_path' do
    it 'returns root_path' do
      expect(helper.fallback_path).to eq(root_path)
    end
  end

  describe '#title' do
    it 'sets content for title' do
      helper.title('Test Title')
      expect(helper.content_for(:title)).to eq('Test Title')
    end
  end

  describe '#header_title' do
    it 'sets content for header_title' do
      helper.header_title('Header Title')
      expect(helper.content_for(:header_title)).to eq('Header Title')
    end
  end

  describe '#icon' do
    # context 'with custom icon' do
    #   it 'renders inline svg when custom is true' do
    #     allow(helper).to receive(:inline_svg_tag).and_return('<svg></svg>')
    #     result = helper.icon('test', custom: true)
    #     expect(helper).to have_received(:inline_svg_tag).with('test.svg', class: include('shrink-0'), size: 'md', color: 'default')
    #   end
    # end

    context 'with button icon' do
      it 'renders button component when as_button is true' do
        allow(helper).to receive(:render).and_return('<button></button>')
        result = helper.icon('test', as_button: true)
        expect(helper).to have_received(:render)
      end
    end

    context 'with default icon' do
      it 'renders lucide icon by default' do
        allow(helper).to receive(:lucide_icon).and_return('<svg></svg>')
        result = helper.icon('test')
        expect(helper).to have_received(:lucide_icon).with('test', class: include('shrink-0'))
      end
    end

    context 'with different sizes' do
      it 'applies correct size classes' do
        allow(helper).to receive(:lucide_icon).and_return('<svg></svg>')
        helper.icon('test', size: 'lg')
        expect(helper).to have_received(:lucide_icon).with('test', class: include('w-6 h-6'))
      end
    end

    context 'with different colors' do
      it 'applies correct color classes' do
        allow(helper).to receive(:lucide_icon).and_return('<svg></svg>')
        helper.icon('test', color: 'success')
        expect(helper).to have_received(:lucide_icon).with('test', class: include('text-success'))
      end
    end
  end

  # describe '#impersonating?' do
  #   context 'when current_user equals true_user' do
  #     before do
  #       allow(helper).to receive(:current_user).and_return(double('user'))
  #       allow(helper).to receive(:true_user).and_return(double('user'))
  #     end

  #     it 'returns false' do
  #       expect(helper.impersonating?).to be false
  #     end
  #   end

  #   context 'when current_user differs from true_user' do
  #     before do
  #       allow(helper).to receive(:current_user).and_return(double('user1'))
  #       allow(helper).to receive(:true_user).and_return(double('user2'))
  #     end

  #     it 'returns true' do
  #       expect(helper.impersonating?).to be true
  #     end
  #   end
  # end

  describe '#page_active?' do
    context 'when current page matches path' do
      before do
        allow(helper).to receive(:current_page?).with('/test').and_return(true)
      end

      it 'returns true' do
        expect(helper.page_active?('/test')).to be true
      end
    end

    context 'when request path starts with path' do
      before do
        allow(helper).to receive(:current_page?).with('/test').and_return(false)
        allow(helper.request).to receive(:path).and_return('/test/subpage')
      end

      it 'returns true' do
        expect(helper.page_active?('/test')).to be true
      end
    end

    context 'when path is root and request is root' do
      before do
        allow(helper).to receive(:current_page?).with('/').and_return(false)
        allow(helper.request).to receive(:path).and_return('/')
      end

      it 'returns false' do
        expect(helper.page_active?('/')).to be false
      end
    end
  end

  describe '#modal' do
    it 'renders modal partial with content' do
      allow(helper).to receive(:render).and_return('<div></div>')
      helper.modal { 'content' }
      expect(helper).to have_received(:render).with(partial: 'shared/modal', locals: { content: 'content', classes: nil })
    end

    it 'passes classes option' do
      allow(helper).to receive(:render).and_return('<div></div>')
      helper.modal(classes: 'test-class') { 'content' }
      expect(helper).to have_received(:render).with(partial: 'shared/modal', locals: { content: 'content', classes: 'test-class' })
    end
  end

  describe '#drawer' do
    it 'renders drawer partial with content' do
      allow(helper).to receive(:render).and_return('<div></div>')
      helper.drawer { 'content' }
      expect(helper).to have_received(:render).with(partial: 'shared/drawer', locals: { content: 'content', reload_on_close: false })
    end

    it 'passes reload_on_close option' do
      allow(helper).to receive(:render).and_return('<div></div>')
      helper.drawer(reload_on_close: true) { 'content' }
      expect(helper).to have_received(:render).with(partial: 'shared/drawer', locals: { content: 'content', reload_on_close: true })
    end
  end

  describe '#custom_pagy_url_for' do
    let(:pagy) { double('pagy') }

    context 'when current_path is blank' do
      it 'calls pagy_url_for' do
        allow(helper).to receive(:pagy_url_for).and_return('/page/2')
        result = helper.custom_pagy_url_for(pagy, 2)
        expect(helper).to have_received(:pagy_url_for).with(pagy, 2)
      end
    end

    context 'when current_path is provided' do
      it 'builds URL with page parameter' do
        result = helper.custom_pagy_url_for(pagy, 2, current_path: '/test?param=value')
        expect(result).to eq('/test?param=value&page=2')
      end

      it 'removes page parameter for page 1' do
        result = helper.custom_pagy_url_for(pagy, 1, current_path: '/test?param=value&page=3')
        expect(result).to eq('/test?param=value')
      end

      it 'handles path without query parameters' do
        result = helper.custom_pagy_url_for(pagy, 2, current_path: '/test')
        expect(result).to eq('/test?page=2')
      end
    end
  end

  # describe '#can?' do
  #   let(:user) { create(:user) }
  #   let(:record) { double('record') }
  #   let(:policy) { double('policy') }

  #   before do
  #     allow(helper).to receive(:current_user).and_return(user)
  #     allow(helper).to receive(:policy).and_return(policy)
  #   end

  #   context 'when policy allows action' do
  #     before do
  #       allow(policy).to receive(:read?).and_return(true)
  #     end

  #     it 'returns true' do
  #       expect(helper.can?(:read, record)).to be true
  #     end
  #   end

  #   context 'when policy denies action' do
  #     before do
  #       allow(policy).to receive(:read?).and_return(false)
  #     end

  #     it 'returns false' do
  #       expect(helper.can?(:read, record)).to be false
  #     end
  #   end

  #   context 'when policy raises NotAuthorizedError' do
  #     before do
  #       allow(policy).to receive(:read?).and_raise(Pundit::NotAuthorizedError)
  #     end

  #     it 'returns false' do
  #       expect(helper.can?(:read, record)).to be false
  #     end
  #   end

  #   context 'with custom policy class' do
  #     let(:custom_policy) { double('custom_policy') }

  #     before do
  #       allow(custom_policy).to receive(:read?).and_return(true)
  #     end

  #     it 'uses custom policy class' do
  #       expect(helper.can?(:read, record, policy_class: custom_policy)).to be true
  #     end
  #   end
  # end
end 