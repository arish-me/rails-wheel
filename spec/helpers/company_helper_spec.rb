require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the CompanyHelper. For example:
#
# describe CompanyHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe CompanyHelper, type: :helper do
  it 'is a module' do
    expect(defined?(CompanyHelper)).to eq('constant')
    expect(CompanyHelper).to be_a(Module)
  end
end
