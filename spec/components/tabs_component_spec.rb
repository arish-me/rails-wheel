require 'rails_helper'

RSpec.describe TabsComponent, type: :component do
  let(:tabs) {
    [
    {
      label: "Users",
      path: "/users",
      id: "users-tab"
    }
  ]
  }
  it 'can be instantiated' do
    expect { TabsComponent.new(active_tab: "") }.not_to raise_error
  end

  it 'renders without errors' do
    component = TabsComponent.new(active_tab: "")
    expect { render_inline(component) }.not_to raise_error
  end
end
