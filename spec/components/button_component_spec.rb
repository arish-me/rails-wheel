require 'rails_helper'

RSpec.describe ButtonComponent, type: :component do
  it 'inherits from ButtonishComponent' do
    expect(described_class).to be < ButtonishComponent
  end

  it 'can be instantiated' do
    expect { described_class.new }.not_to raise_error
  end

  it 'has a confirm attribute' do
    component = described_class.new(confirm: 'Are you sure?')
    expect(component.confirm).to eq('Are you sure?')
  end
end
