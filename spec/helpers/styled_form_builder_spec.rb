require 'rails_helper'

RSpec.describe StyledFormBuilder, type: :helper do
  let(:template) { helper }
  let(:object) { double('object') }
  let(:object_name) { 'user' }
  let(:builder) { StyledFormBuilder.new(object_name, object, template, {}) }

  describe 'inheritance' do
    it 'inherits from ActionView::Helpers::FormBuilder' do
      expect(StyledFormBuilder).to be < ActionView::Helpers::FormBuilder
    end
  end
end 