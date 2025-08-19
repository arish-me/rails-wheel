require 'rails_helper'

RSpec.describe EmailDomainValidator do
  describe '.personal_domain?' do
    it 'returns true for personal email domains' do
      expect(EmailDomainValidator.personal_domain?('user@gmail.com')).to be true
      expect(EmailDomainValidator.personal_domain?('user@yahoo.com')).to be true
      expect(EmailDomainValidator.personal_domain?('user@hotmail.com')).to be true
      expect(EmailDomainValidator.personal_domain?('user@yopmail.com')).to be true
    end

    it 'returns false for business email domains' do
      expect(EmailDomainValidator.personal_domain?('user@company.com')).to be false
      expect(EmailDomainValidator.personal_domain?('user@startup.io')).to be false
      expect(EmailDomainValidator.personal_domain?('user@techcorp.org')).to be false
    end

    it 'returns false for nil or empty emails' do
      expect(EmailDomainValidator.personal_domain?(nil)).to be false
      expect(EmailDomainValidator.personal_domain?('')).to be false
    end
  end

  describe '.business_domain?' do
    it 'returns true for business email domains' do
      expect(EmailDomainValidator.business_domain?('user@company.com')).to be true
      expect(EmailDomainValidator.business_domain?('user@startup.io')).to be true
      expect(EmailDomainValidator.business_domain?('user@techcorp.org')).to be true
    end

    it 'returns false for personal email domains' do
      expect(EmailDomainValidator.business_domain?('user@gmail.com')).to be false
      expect(EmailDomainValidator.business_domain?('user@yahoo.com')).to be false
      expect(EmailDomainValidator.business_domain?('user@yopmail.com')).to be false
    end
  end

  describe '.validate_company_email' do
    it 'returns valid for business emails' do
      result = EmailDomainValidator.validate_company_email('user@company.com')
      expect(result[:valid]).to be true
      expect(result[:message]).to eq('Email domain is valid')
    end

    it 'returns invalid for personal emails' do
      result = EmailDomainValidator.validate_company_email('user@gmail.com')
      expect(result[:valid]).to be false
      expect(result[:message]).to include('business email address')
    end

    it 'returns invalid for nil email' do
      result = EmailDomainValidator.validate_company_email(nil)
      expect(result[:valid]).to be false
      expect(result[:message]).to eq('Email is required')
    end

    it 'returns invalid for empty email' do
      result = EmailDomainValidator.validate_company_email('')
      expect(result[:valid]).to be false
      expect(result[:message]).to eq('Email is required')
    end

    it 'returns invalid for malformed email' do
      result = EmailDomainValidator.validate_company_email('invalid-email')
      expect(result[:valid]).to be false
      expect(result[:message]).to eq('Invalid email format')
    end
  end

  describe '.extract_domain' do
    it 'extracts domain correctly' do
      expect(EmailDomainValidator.extract_domain('user@company.com')).to eq('company.com')
      expect(EmailDomainValidator.extract_domain('test@startup.io')).to eq('startup.io')
      expect(EmailDomainValidator.extract_domain('admin@techcorp.org')).to eq('techcorp.org')
    end

    it 'handles case insensitive domains' do
      expect(EmailDomainValidator.extract_domain('user@COMPANY.COM')).to eq('company.com')
      expect(EmailDomainValidator.extract_domain('user@Company.Com')).to eq('company.com')
    end

    it 'returns nil for invalid emails' do
      expect(EmailDomainValidator.extract_domain('invalid-email')).to be_nil
      expect(EmailDomainValidator.extract_domain('')).to be_nil
      expect(EmailDomainValidator.extract_domain(nil)).to be_nil
    end
  end
end
