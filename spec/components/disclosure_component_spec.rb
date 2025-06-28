require 'rails_helper'

RSpec.describe DisclosureComponent, type: :component do
  it 'can be instantiated' do
    expect { DisclosureComponent.new(title: "Test Title") }.not_to raise_error
  end

  it 'renders without errors' do
    component = DisclosureComponent.new(title: "Test Title")
    expect { render_inline(component) }.not_to raise_error
  end
end 