require 'rails_helper'

RSpec.describe TabComponent, type: :component do
  let(:tabs) do
    [
      {
        label: 'Users',
        path: '/users',
        id: 'users-tab'
      }
    ]
  end

  it 'can be instantiated' do
    expect { described_class.new(tabs:, current_path: '/users') }.not_to raise_error
  end

  it 'renders without errors' do
    component = described_class.new(tabs:, current_path: '/user')
    expect { render_inline(component) }.not_to raise_error
  end
end
