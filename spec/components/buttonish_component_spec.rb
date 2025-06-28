require 'rails_helper'

RSpec.describe ButtonishComponent, type: :component do
  it 'can be instantiated' do
    expect { ButtonishComponent.new }.not_to raise_error
  end

  it 'responds to container method' do
    component = ButtonishComponent.new
    expect(component).to respond_to(:call)
  end
end 