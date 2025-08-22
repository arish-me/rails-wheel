require 'rails_helper'

RSpec.describe TabsComponent, type: :component do
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
    expect { described_class.new(active_tab: '') }.not_to raise_error
  end

  it 'renders without errors' do
    component = described_class.new(active_tab: '')
    expect { render_inline(component) }.not_to raise_error
  end
end
