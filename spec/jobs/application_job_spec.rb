require 'rails_helper'

RSpec.describe ApplicationJob, type: :job do
  it 'inherits from ActiveJob::Base' do
    expect(described_class).to be < ActiveJob::Base
  end

  it 'can be instantiated' do
    expect { described_class.new }.not_to raise_error
  end

  it 'raises NotImplementedError when performed' do
    expect { described_class.perform_now }.to raise_error(NotImplementedError)
  end
end
