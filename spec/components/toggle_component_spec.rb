require 'rails_helper'

RSpec.describe ToggleComponent, type: :component do
  it 'can be instantiated' do
    expect { described_class.new(id: 'id-wheel', name: 'wheel') }.not_to raise_error
  end

  it 'renders without errors' do
    component = described_class.new(id: 'id-wheel', name: 'wheel')
    expect { render_inline(component) }.not_to raise_error
  end
end
