require 'rails_helper'

RSpec.describe MenuItemComponent, type: :component do
  it 'can be instantiated' do
    expect { MenuItemComponent.new(variant: "link") }.not_to raise_error
  end

  it 'renders without errors' do
    component = MenuItemComponent.new(variant: "button", href: "/users")
    expect { render_inline(component) }.not_to raise_error
  end
end 