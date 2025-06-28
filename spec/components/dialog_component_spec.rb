require 'rails_helper'

RSpec.describe DialogComponent, type: :component do
  it 'can be instantiated' do
    expect { DialogComponent.new }.not_to raise_error
  end

  it 'renders without errors' do
    component = DialogComponent.new
    expect { render_inline(component) }.not_to raise_error
  end
end 