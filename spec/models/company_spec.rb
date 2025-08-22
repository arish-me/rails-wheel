require 'rails_helper'

RSpec.describe Company, type: :model do
  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:company)).to be_valid
    end
  end

  describe 'associations' do
    it { is_expected.to have_many(:users) }
  end

  describe 'validations' do
    subject { build(:company) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
    it { is_expected.to validate_presence_of(:subdomain) }
    it { is_expected.to validate_uniqueness_of(:subdomain).case_insensitive }
  end

  describe 'search functionality' do
    let!(:company1) { create(:company, name: 'Apple Inc') }
    let!(:company2) { create(:company, name: 'Microsoft Corp') }
    let!(:company3) { create(:company, name: 'Google LLC') }

    it 'searches by name prefix' do
      results = described_class.search_by_name('App')
      expect(results).to include(company1)
      expect(results).not_to include(company2, company3)
    end
  end

  describe '#assign_default_roles' do
    let(:company) { build(:company) }
    let(:seeder) { double('seeder') }

    before do
      allow(SeedData::MainSeeder).to receive(:new).and_return(seeder)
      allow(seeder).to receive(:seed_initial_data)
      allow(ActsAsTenant).to receive(:with_tenant).and_yield
    end

    it 'calls seed_initial_data within tenant context' do
      expect(ActsAsTenant).to receive(:with_tenant).with(company)
      expect(seeder).to receive(:seed_initial_data)
      company.assign_default_roles
    end
  end

  describe 'callbacks' do
    it 'calls assign_default_roles after create' do
      company = build(:company)
      expect(company).to receive(:assign_default_roles)
      company.run_callbacks(:create)
    end
  end
end
