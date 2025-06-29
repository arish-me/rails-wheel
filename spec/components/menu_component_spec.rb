require 'rails_helper'

RSpec.describe MenuComponent, type: :component do
  it 'can be instantiated' do
    expect { MenuComponent.new }.not_to raise_error
  end

  it 'renders without errors' do
    component = MenuComponent.new
    expect { render_inline(component) }.not_to raise_error
  end
end
