require 'rails_helper'

RSpec.describe FilledIconComponent, type: :component do
  it 'can be instantiated' do
    expect { FilledIconComponent.new }.not_to raise_error
  end

  it 'renders without errors' do
    component = FilledIconComponent.new
    expect { render_inline(component) }.not_to raise_error
  end
end
