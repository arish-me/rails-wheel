require 'rails_helper'

RSpec.describe Tabs::PanelComponent, type: :component do
  let(:component) { described_class.new(tab_id: 'test-tab') }

  describe 'inheritance' do
    it 'inherits from ViewComponent::Base' do
      expect(described_class).to be < ViewComponent::Base
    end
  end

  describe '#initialize' do
    it 'sets the tab_id attribute' do
      expect(component.tab_id).to eq('test-tab')
    end
  end

  describe '#call' do
    it 'returns the content' do
      allow(component).to receive(:content).and_return('test content')
      expect(component.call).to eq('test content')
    end
  end
end 