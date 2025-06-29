require 'rails_helper'

RSpec.describe ToggleComponent, type: :component do
  it 'can be instantiated' do
    expect { ToggleComponent.new(id: 'id-wheel', name: 'wheel') }.not_to raise_error
  end

  it 'renders without errors' do
    component = ToggleComponent.new(id: 'id-wheel', name: 'wheel')
    expect { render_inline(component) }.not_to raise_error
  end
end
