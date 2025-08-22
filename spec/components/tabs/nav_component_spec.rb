require 'rails_helper'

RSpec.describe Tabs::NavComponent, type: :component do
  let(:component) do
    described_class.new(
      active_tab: 'tab1',
      classes: 'nav-class',
      active_btn_classes: 'active-class',
      inactive_btn_classes: 'inactive-class',
      btn_classes: 'btn-class'
    )
  end

  describe 'inheritance' do
    it 'inherits from ViewComponent::Base' do
      expect(described_class).to be < ViewComponent::Base
    end
  end

  describe '#initialize' do
    it 'sets all attributes correctly' do
      expect(component.active_tab).to eq('tab1')
      expect(component.classes).to eq('nav-class')
      expect(component.active_btn_classes).to eq('active-class')
      expect(component.inactive_btn_classes).to eq('inactive-class')
      expect(component.btn_classes).to eq('btn-class')
    end
  end

  describe 'renders_many :btns' do
    it 'can render buttons' do
      expect(component).to respond_to(:with_btn)
    end
  end
end
