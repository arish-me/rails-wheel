require 'rails_helper'

RSpec.describe FormsHelper, type: :helper do
  describe '#styled_form_with' do
    it 'sets the builder to StyledFormBuilder' do
      expect(helper).to receive(:form_with).with(hash_including(builder: StyledFormBuilder))
      helper.styled_form_with(url: '/test') {}
    end
  end

  describe '#modal_form_wrapper' do
    it 'renders the modal_form partial' do
      allow(helper).to receive(:render)
      helper.modal_form_wrapper(title: 'Test') { 'content' }
      expect(helper).to have_received(:render).with(partial: 'shared/modal_form', locals: hash_including(title: 'Test'))
    end
  end
end 