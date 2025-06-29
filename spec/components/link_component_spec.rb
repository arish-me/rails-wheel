require 'rails_helper'

RSpec.describe LinkComponent, type: :component do
  it 'can be instantiated' do
    expect { LinkComponent.new }.not_to raise_error
  end

  it 'renders without errors' do
    component = LinkComponent.new(href: "/users")
    expect { render_inline(component) }.not_to raise_error
  end
end
