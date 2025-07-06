# Candidate Edit Mode

## Overview

The candidate edit mode is a two-tab interface that allows candidates to manage their professional information and work preferences in a seamless flow.

## Structure

### Tab 1: Professional Information
- **Path**: `/candidates/:id/profiles/:profile_id/edit`
- **Controller**: `Candidates::ProfilesController`
- **Models**: 
  - `Candidate::Profile` (headline, candidate_role_id)
  - `User` (personal details, profile_image, cover_image)
  - `SocialLink` (social media links)

**Sections**:
1. **Upload Section**: Profile image and cover image uploads
2. **Personal Details**: First name, last name, gender, phone, date of birth
3. **Professional Information**: Headline and candidate role
4. **Social Links**: Website, GitHub, LinkedIn, Twitter

### Tab 2: Work Preferences
- **Path**: `/candidates/:id/work_preferences/:id/edit`
- **Controller**: `Candidates::WorkPreferencesController`
- **Models**: 
  - `Candidate::WorkPreference` (search_status)
  - `RoleType` (part_time_contract, full_time_contract, full_time_employment)
  - `RoleLevel` (junior, mid, senior, principal, c_level)

## Navigation Flow

1. **Default Tab**: Professional Information is the default tab
2. **Next Button**: From Professional Information → Work Preferences
3. **Previous Button**: From Work Preferences → Professional Information
4. **Tab Navigation**: Users can click on tabs to switch between sections

## Implementation Details

### Controllers

#### `Candidates::ProfilesController`
- Handles professional information, personal details, and social links updates
- Uses nested attributes through the candidate model
- Ensures associated models are built before rendering form
- Redirects back to edit page after successful update
- Shows appropriate success/error messages

#### `Candidates::WorkPreferencesController`
- Handles work preferences, role types, and role levels
- Uses nested attributes through the candidate model
- Ensures associated models are built before rendering form
- Properly handles validation errors and displays them to users

### Views

#### Tab Navigation (`_candidate_tab.html.erb`)
- Simplified to show only Professional Information and Work Preferences
- Uses `TabComponent` for consistent styling
- Highlights current active tab

#### Professional Information Form (`profiles/_form.html.erb`)
- **Upload Section**: Profile and cover image uploads with drag-and-drop functionality
- **Personal Details**: User information (name, gender, phone, date of birth)
- **Professional Information**: Headline and candidate role selection
- **Social Links**: Social media profile links with proper URL formatting
- Includes "Next" button to navigate to work preferences
- Save button for immediate updates

#### Work Preferences Form (`work_preferences/_form.html.erb`)
- Single form handling all work preference data
- Uses nested attributes for role_type and role_level
- Includes "Previous" button for navigation back
- Save button for all work preference data
- **Validation Error Display**: Shows validation errors for role_type and role_level sections

### Models

#### Associations
```ruby
class Candidate < ApplicationRecord
  has_one :profile, class_name: "Candidate::Profile"
  has_one :work_preference, class_name: "Candidate::WorkPreference"
  has_one :role_type, class_name: "RoleType"
  has_one :role_level, class_name: "RoleLevel"
  has_one :social_link, as: :linkable, dependent: :destroy
  belongs_to :user
  
  accepts_nested_attributes_for :profile
  accepts_nested_attributes_for :work_preference
  accepts_nested_attributes_for :role_type, update_only: true
  accepts_nested_attributes_for :role_level, update_only: true
  accepts_nested_attributes_for :social_link, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :user
end
```

#### Validation Rules

##### `Candidate::WorkPreference`
- `search_status`: Required field (enum validation)

##### `RoleType`
- **Custom Validation**: At least one role type must be selected
- Options: part_time_contract, full_time_contract, full_time_employment

##### `RoleLevel`
- **Custom Validation**: At least one role level must be selected
- Options: junior, mid, senior, principal, c_level

##### `User`
- `first_name`, `last_name`: Required on update
- `profile_image`: File size validation (max 10MB)

#### Validation Error Messages
- **RoleType**: "Please select at least one role type"
- **RoleLevel**: "Please select at least one role level"
- Error messages are internationalized and can be customized in locale files

## Usage

1. Navigate to candidate edit mode
2. **Professional Information Tab**:
   - Upload profile and cover images
   - Fill out personal details (name, gender, phone, date of birth)
   - Add professional information (headline, role)
   - Add social media links (website, GitHub, LinkedIn, Twitter)
3. Click "Next" to proceed to Work Preferences
4. Configure search status, role types, and role levels
   - **Note**: At least one role type and one role level must be selected
5. Save all work preferences
6. Use tab navigation to switch between sections as needed

## Validation Behavior

- **Work Preferences**: Search status is required
- **Role Types**: At least one option must be selected (part-time contract, full-time contract, or full-time employment)
- **Role Levels**: At least one option must be selected (junior, mid, senior, principal, or c-level)
- **User Details**: First name and last name are required on update
- **File Uploads**: Profile image size limited to 10MB
- **Error Display**: Validation errors are shown directly under the relevant form sections
- **Form Persistence**: When validation fails, the form retains user input and displays specific error messages

## File Upload Features

- **Profile Image**: Supports PNG, JPG, JPEG formats with automatic resizing
- **Cover Image**: Supports PNG, JPG, JPEG, GIF formats
- **Direct Upload**: Files are uploaded directly to cloud storage
- **Image Variants**: Automatic generation of thumbnail and small variants
- **Error Handling**: Proper error messages for upload failures

## Routes

```ruby
resources :candidates do
  resources :profiles, module: :candidates
  resources :work_preferences, module: :candidates
end
```

This creates the necessary nested routes for both tabs. 