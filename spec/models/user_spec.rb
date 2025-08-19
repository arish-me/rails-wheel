require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:user)).to be_valid
    end

    it 'has a valid factory with default role' do
      expect(build(:user_with_default_role)).to be_valid
    end

    it 'has a valid admin factory' do
      expect(build(:admin)).to be_valid
    end

    it 'has a valid super admin factory' do
      expect(build(:super_admin)).to be_valid
    end

    it 'has a valid complete user factory' do
      expect(build(:complete_user)).to be_valid
    end
  end

  describe 'associations' do
    it { should have_many(:user_roles).dependent(:destroy) }
    it { should have_many(:roles).through(:user_roles) }
    it { should have_many(:categories).dependent(:destroy) }
    it { should belong_to(:company).optional }
    it { should have_many(:notifications).class_name("Noticed::Notification") }
    it { should have_one_attached(:profile_image) }
  end

  describe 'devise modules' do
    it 'includes database_authenticatable' do
      expect(User.devise_modules).to include(:database_authenticatable)
    end

    it 'includes registerable' do
      expect(User.devise_modules).to include(:registerable)
    end

    it 'includes recoverable' do
      expect(User.devise_modules).to include(:recoverable)
    end

    it 'includes rememberable' do
      expect(User.devise_modules).to include(:rememberable)
    end

    it 'includes validatable' do
      expect(User.devise_modules).to include(:validatable)
    end

    it 'includes lockable' do
      expect(User.devise_modules).to include(:lockable)
    end

    it 'includes timeoutable' do
      expect(User.devise_modules).to include(:timeoutable)
    end

    it 'includes trackable' do
      expect(User.devise_modules).to include(:trackable)
    end

    it 'includes confirmable' do
      expect(User.devise_modules).to include(:confirmable)
    end

    it 'includes omniauthable' do
      expect(User.devise_modules).to include(:omniauthable)
    end
  end

  describe 'enums' do
    it { should define_enum_for(:gender).with_values([ :he_she, :him_her, :they_them, :other ]) }
    it { should define_enum_for(:theme).with_values({ system: 0, light: 1, dark: 2 }).with_default(:system) }
    it { should define_enum_for(:user_type).with_values({ company: 0, user: 1, platform_admin: 99 }) }
  end

  describe 'validations' do
    subject { build(:user) }

    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }

    context 'when skip_password_validation is true' do
      before { subject.skip_password_validation = true }

      it 'does not require password' do
        subject.password = nil
        subject.password_confirmation = nil
        expect(subject).to be_valid
      end
    end

    context 'when skip_password_validation is false' do
      before { subject.skip_password_validation = false }

      it 'requires password' do
        subject.password = nil
        subject.password_confirmation = nil
        expect(subject).not_to be_valid
      end
    end
  end

  describe 'profile image validation' do
    let(:user) { build(:user) }

    context 'when profile image is too large' do
      before do
        user.profile_image.attach(
          io: StringIO.new('x' * 11.megabytes),
          filename: 'large_image.jpg',
          content_type: 'image/jpeg'
        )
      end

      it 'is invalid' do
        expect(user).not_to be_valid
        expect(user.errors[:profile_image]).to include('file size must be less than 10MB')
      end
    end

    context 'when profile image is valid size' do
      before do
        user.profile_image.attach(
          io: StringIO.new('x' * 1.megabyte),
          filename: 'valid_image.jpg',
          content_type: 'image/jpeg'
        )
      end

      it 'is valid' do
        expect(user).to be_valid
      end
    end
  end

  describe 'search functionality' do
    let!(:user1) { create(:user, email: 'admin@example.com') }
    let!(:user2) { create(:user, email: 'administrator@example.com') }
    let!(:user3) { create(:user, email: 'user@example.com') }

    it 'searches by email prefix' do
      results = User.search_by_email('admin')
      expect(results).to include(user1, user2)
      expect(results).not_to include(user3)
    end
  end

  describe 'instance methods' do
    let(:user) { create(:user, first_name: 'John', last_name: 'Doe', email: 'john@example.com') }

    describe '#display_name' do
      context 'when first_name and last_name are present' do
        it 'returns full name' do
          expect(user.display_name).to eq("John Doe")
        end
      end

      context 'when only first_name is present' do
        let(:user) { create(:user, first_name: 'John', last_name: nil) }

        it 'returns first_name' do
          expect(user.display_name).to eq('John')
        end
      end

      context 'when only last_name is present' do
        let(:user) { create(:user, first_name: nil, last_name: 'Doe') }

        it 'returns last_name' do
          expect(user.display_name).to eq('Doe')
        end
      end

      context 'when neither first_name nor last_name is present' do
        let(:user) { create(:user, first_name: nil, last_name: nil) }

        it 'returns email' do
          expect(user.display_name).to eq(user.email)
        end
      end
    end

    describe '#initial' do
      context 'when display_name is present' do
        it 'returns first character of display_name' do
          expect(user.initial).to eq('J')
        end
      end

      context 'when display_name is not present' do
        let(:user) { create(:user, email: "john@example.com", first_name: nil, last_name: nil) }

        it 'returns first character of email' do
          expect(user.initial).to eq('J')
        end
      end
    end

    describe '#initials' do
      context 'when both first_name and last_name are present' do
        it 'returns first characters of both names' do
          expect(user.initials).to eq('JD')
        end
      end

      context 'when only first_name is present' do
        let(:user) { create(:user, first_name: 'John', last_name: nil) }

        it 'returns first character of first_name' do
          expect(user.initials).to eq('J')
        end
      end

      context 'when only last_name is present' do
        let(:user) { create(:user, first_name: nil, last_name: 'Doe') }

        it 'returns first character of last_name' do
          expect(user.initials).to eq('D')
        end
      end
    end

    describe '#onboarded?' do
      context 'when onboarded_at is present' do
        let(:user) { create(:user, :onboarded) }

        it 'returns true' do
          expect(user.onboarded?).to be true
        end
      end

      context 'when onboarded_at is nil' do
        it 'returns false' do
          expect(user.onboarded?).to be false
        end
      end
    end

    describe '#needs_onboarding?' do
      context 'when user is onboarded' do
        let(:user) { create(:user, :onboarded) }

        it 'returns false' do
          expect(user.needs_onboarding?).to be false
        end
      end

      context 'when user is not onboarded' do
        it 'returns true' do
          expect(user.needs_onboarding?).to be true
        end
      end
    end

    describe '#lock_access!' do
      let(:user) { create(:user) }

      it 'locks the user account' do
        user.lock_access!
        user.reload

        expect(user.locked_at).to be_present
        expect(user.failed_attempts).to eq(0)
      end
    end

    describe '#attach_avatar' do
      let(:user) { create(:user) }
      let(:image_url) { 'https://example.com/avatar.jpg' }

      context 'when profile_image is already attached' do
        before do
          user.profile_image.attach(
            io: StringIO.new('existing image'),
            filename: 'existing.jpg',
            content_type: 'image/jpeg'
          )
        end

        it 'does not re-attach the avatar' do
          expect { user.attach_avatar(image_url) }.not_to change { user.profile_image.attached? }
        end

        it 'does not call URI.parse when already attached' do
          expect(URI).not_to receive(:parse)
          user.attach_avatar(image_url)
        end
      end

      context 'when URL is invalid' do
        it 'logs an error and does not attach avatar' do
          allow(URI).to receive(:parse).and_raise(StandardError.new('Invalid URL'))

          expect(Rails.logger).to receive(:error).with(/Failed to attach avatar/)
          expect { user.attach_avatar(image_url) }.not_to change { user.profile_image.attached? }
        end
      end

      context 'when URI.open raises an error' do
        it 'logs an error and does not attach avatar' do
          uri_double = double('uri')
          allow(URI).to receive(:parse).with(image_url).and_return(uri_double)
          allow(uri_double).to receive(:open).and_raise(StandardError.new('Network error'))

          expect(Rails.logger).to receive(:error).with(/Failed to attach avatar/)
          expect { user.attach_avatar(image_url) }.not_to change { user.profile_image.attached? }
        end
      end

      context 'when profile_image.attach raises an error' do
        it 'logs an error and handles the exception' do
          mock_file = double('avatar_file', content_type: 'image/jpeg')
          uri_double = double('uri')

          allow(URI).to receive(:parse).with(image_url).and_return(uri_double)
          allow(uri_double).to receive(:open).and_return(mock_file)
          allow(user.profile_image).to receive(:attach).and_raise(StandardError.new('Attachment failed'))

          expect(Rails.logger).to receive(:error).with(/Failed to attach avatar/)
          expect { user.attach_avatar(image_url) }.not_to raise_error
        end
      end
    end

    describe '#can?' do
      let(:user) { create(:user) }
      let(:role) { create(:role) }
      let(:permission) { create(:permission, name: 'read', resource: 'posts') }

      before do
        create(:user_role, user: user, role: role)
        create(:role_permission, role: role, permission: permission, action: 0)
      end

      it 'returns true when user has the permission' do
        expect(user.can?('read', 'posts')).to be true
      end

      it 'returns false when user does not have the permission' do
        expect(user.can?('write', 'posts')).to be false
      end

      it 'returns false when permission name is nil' do
        expect(user.can?(nil, 'posts')).to be false
      end

      it 'returns false when resource is nil' do
        expect(user.can?('read', nil)).to be false
      end

      it 'executes the joins query when checking permissions' do
        expect(user.roles).to receive(:joins).with(:role_permissions).and_call_original
        user.can?('read', 'posts')
      end
    end
  end

  describe 'constants' do
    it 'defines GENDER_DISPLAY constant' do
      expect(User::GENDER_DISPLAY).to eq({
        he_she: "He/Him",
        him_her: "Him/Her",
        they_them: "They/Them",
        other: "Other"
      })
    end

    it 'defines DATE_FORMATS constant correctly' do
      expect(User::DATE_FORMATS).to eq([
        [ "MM-DD-YYYY", "%m-%d-%Y" ],
        [ "DD.MM.YYYY", "%d.%m.%Y" ],
        [ "DD-MM-YYYY", "%d-%m-%Y" ],
        [ "YYYY-MM-DD", "%Y-%m-%d" ],
        [ "DD/MM/YYYY", "%d/%m/%Y" ],
        [ "YYYY/MM/DD", "%Y/%m/%d" ],
        [ "MM/DD/YYYY", "%m/%d/%Y" ],
        [ "D/MM/YYYY", "%e/%m/%Y" ],
        [ "YYYY.MM.DD", "%Y.%m.%d" ]
      ])
    end

    it 'has correct number of date formats' do
      expect(User::DATE_FORMATS.size).to eq(9)
    end
  end

  describe 'nested attributes' do
    it 'accepts nested attributes for user_roles' do
      expect(User.nested_attributes_options).to include(:user_roles)
    end
  end

  describe 'profile image variants' do
    let(:user) { create(:user, :with_profile_image) }

    it 'defines thumbnail variant' do
      expect(user.profile_image.variant(:thumbnail)).to be_present
    end

    it 'defines small variant' do
      expect(user.profile_image.variant(:small)).to be_present
    end
  end

  describe 'user_type changes' do
    let(:user) { create(:user, user_type: 'company') }

    context 'when user_type changes from company to user' do
      it 'creates a candidate record' do
        expect { user.update(user_type: 'user') }.to change(Candidate, :count).by(1)
        expect(user.candidate).to be_present
      end
    end

    context 'when user_type changes from user to company' do
      let(:user) { create(:user, user_type: 'user') }

      before do
        user.create_candidate
      end

      it 'destroys the candidate record' do
        expect { user.update(user_type: 'company') }.to change(Candidate, :count).by(-1)
        expect(user.candidate).to be_nil
      end
    end

    context 'when user_type changes but candidate already exists' do
      let(:user) { create(:user, user_type: 'user') }

      before do
        user.create_candidate
      end

      it 'does not create duplicate candidate' do
        expect { user.update(user_type: 'user') }.not_to change(Candidate, :count)
        expect(user.candidate).to be_present
      end
    end

    context 'when user_type changes but no candidate exists' do
      let(:user) { create(:user, user_type: 'company') }

      it 'does not try to destroy non-existent candidate' do
        expect { user.update(user_type: 'company') }.not_to change(Candidate, :count)
        expect(user.candidate).to be_nil
      end
    end
  end

  describe '#ensure_candidate' do
    let(:user) { create(:user, user_type: 'user') }

    context 'when user is user type and has no candidate' do
      it 'creates a candidate' do
        expect { user.ensure_candidate }.to change(Candidate, :count).by(1)
        expect(user.candidate).to be_present
      end
    end

    context 'when user is user type and already has a candidate' do
      before do
        user.create_candidate
      end

      it 'does not create duplicate candidate' do
        expect { user.ensure_candidate }.not_to change(Candidate, :count)
        expect(user.candidate).to be_present
      end
    end

    context 'when user is company type' do
      let(:user) { create(:user, user_type: 'company') }

      it 'does not create a candidate' do
        expect { user.ensure_candidate }.not_to change(Candidate, :count)
        expect(user.candidate).to be_nil
      end
    end
  end

  describe 'name validation during onboarding' do
    let(:oauth_user) { create(:user, user_type: 'user', provider: 'google_oauth2', uid: '123456') }

    context 'when OAuth user is in onboarding context' do
      before do
        oauth_user.in_onboarding_context = true
        oauth_user.update_column(:onboarded_at, nil) # Ensure user needs onboarding
      end

      it 'requires first_name during onboarding' do
        oauth_user.first_name = nil
        expect(oauth_user).not_to be_valid
        expect(oauth_user.errors[:first_name]).to include("is required to complete your profile")
      end

      it 'requires last_name during onboarding' do
        oauth_user.last_name = nil
        expect(oauth_user).not_to be_valid
        expect(oauth_user.errors[:last_name]).to include("is required to complete your profile")
      end

      it 'is valid when both names are present' do
        oauth_user.first_name = 'John'
        oauth_user.last_name = 'Doe'
        expect(oauth_user).to be_valid
      end
    end

    context 'when OAuth user is not in onboarding context' do
      before do
        oauth_user.in_onboarding_context = false
        oauth_user.update_column(:onboarded_at, Time.current) # Mark as onboarded
      end

      it 'allows empty first_name' do
        oauth_user.first_name = nil
        expect(oauth_user).to be_valid
      end

      it 'allows empty last_name' do
        oauth_user.last_name = nil
        expect(oauth_user).to be_valid
      end
    end

    context 'when non-OAuth user' do
      let(:regular_user) { create(:user, user_type: 'user') }

      it 'always requires first_name' do
        regular_user.first_name = nil
        expect(regular_user).not_to be_valid
        expect(regular_user.errors[:first_name]).to include("can't be blank")
      end

      it 'always requires last_name' do
        regular_user.last_name = nil
        expect(regular_user).not_to be_valid
        expect(regular_user.errors[:last_name]).to include("can't be blank")
      end
    end
  end

  describe '#has_complete_basic_profile?' do
    let(:user) { create(:user, first_name: 'John', last_name: 'Doe') }

    it 'returns true when both names are present' do
      expect(user.has_complete_basic_profile?).to be true
    end

    it 'returns false when first_name is missing' do
      user.first_name = nil
      expect(user.has_complete_basic_profile?).to be false
    end

    it 'returns false when last_name is missing' do
      user.last_name = nil
      expect(user.has_complete_basic_profile?).to be false
    end

    it 'returns false when both names are missing' do
      user.first_name = nil
      user.last_name = nil
      expect(user.has_complete_basic_profile?).to be false
    end
  end
end
