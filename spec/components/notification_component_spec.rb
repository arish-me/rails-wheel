require 'rails_helper'

RSpec.describe NotificationComponent, type: :component do
  let(:user) { create(:user) }

  it 'can be instantiated' do
    expect { described_class.new(current_user: user) }.not_to raise_error
  end

  it 'renders without errors' do
    component = described_class.new(current_user: user)
    expect { render_inline(component) }.not_to raise_error
  end
end
