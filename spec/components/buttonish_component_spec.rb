require 'rails_helper'

RSpec.describe ButtonishComponent, type: :component do
  it 'can be instantiated' do
    expect { described_class.new }.not_to raise_error
  end

  it 'responds to container method' do
    component = described_class.new
    expect(component).to respond_to(:call)
  end
end
