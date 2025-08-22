# RestrictedAreaComponent

A flexible, reusable view component for restricting access to certain areas of your application with customizable overlays, blur effects, and action buttons.

## Features

- ✅ **Blur Effect**: Optional blur effect on restricted content
- ✅ **Overlay**: Customizable overlay with icons and messages
- ✅ **Action Buttons**: Built-in login, upgrade, and trial buttons
- ✅ **Customizable**: Fully customizable messages, actions, and styling
- ✅ **Reusable**: Use anywhere in your application
- ✅ **Helper Methods**: Simple helper methods for common use cases

## Basic Usage

### Using the Component Directly

```erb
<%= render RestrictedAreaComponent.new(show_login_button: !user_signed_in?) do %>
  <div class="restricted-content">
    <!-- Your content here -->
  </div>
<% end %>
```

### Using Helper Methods (Recommended)

```erb
<%= restricted_for_login do %>
  <div class="filters-section">
    <!-- Filters content -->
  </div>
<% end %>
```

## Helper Methods

### 1. `restricted_for_login`

Restricts content for non-logged-in users.

```erb
<%= restricted_for_login(message: "Sign in to access filters") do %>
  <div class="advanced-filters">
    <!-- Filter content -->
  </div>
<% end %>
```

### 2. `restricted_for_trial`

Restricts content for users who haven't started a trial.

```erb
<%= restricted_for_trial do %>
  <div class="premium-features">
    <!-- Premium features -->
  </div>
<% end %>
```

### 3. `restricted_for_upgrade`

Restricts content for users with expired trials.

```erb
<%= restricted_for_upgrade do %>
  <div class="job-posting-form">
    <!-- Job posting form -->
  </div>
<% end %>
```

### 4. `restricted_for_subscription`

Restricts content for users with expired subscriptions.

```erb
<%= restricted_for_subscription do %>
  <div class="subscription-content">
    <!-- Subscription-required content -->
  </div>
<% end %>
```

### 5. `restricted_for_admin`

Restricts content for non-admin users.

```erb
<%= restricted_for_admin do %>
  <div class="admin-panel">
    <!-- Admin-only content -->
  </div>
<% end %>
```

### 6. `restricted_area`

Generic restriction helper for custom conditions.

```erb
<%= restricted_area(
  condition: current_user&.company&.plan == 'free',
  message: "Upgrade to Pro for this feature",
  action_text: "Upgrade Now",
  action_url: pricing_path
) do %>
  <div class="pro-feature">
    <!-- Pro feature content -->
  </div>
<% end %>
```

## Component Options

### Basic Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `message` | String | Auto-generated | Custom message to display |
| `action_text` | String | Auto-generated | Custom action button text |
| `action_url` | String | Auto-generated | Custom action button URL |
| `action_method` | Symbol | `:get` | HTTP method for action button |
| `blur` | Boolean | `true` | Whether to blur the content |
| `overlay` | Boolean | `true` | Whether to show overlay |
| `custom_class` | String | `nil` | Additional CSS classes for overlay |

### Preset Options

| Option | Type | Description |
|--------|------|-------------|
| `show_login_button` | Boolean | Shows login button and message |
| `show_upgrade_button` | Boolean | Shows upgrade button and message |
| `show_trial_button` | Boolean | Shows trial button and message |

## Use Cases

### 1. Filter Restrictions (Public Jobs)

```erb
<%= restricted_for_login(message: "Sign in to access advanced filters") do %>
  <div class="filters-sidebar">
    <!-- Filter controls -->
  </div>
<% end %>
```

### 2. Trial Expired (Job Posting)

```erb
<%= restricted_for_upgrade(message: "Your trial has expired. Upgrade to continue posting jobs.") do %>
  <div class="job-posting-form">
    <!-- Job posting form -->
  </div>
<% end %>
```

### 3. Premium Features

```erb
<%= restricted_for_trial(message: "Start your free trial to unlock premium features") do %>
  <div class="premium-dashboard">
    <!-- Premium dashboard -->
  </div>
<% end %>
```

### 4. Admin-Only Content

```erb
<%= restricted_for_admin(message: "Admin access required") do %>
  <div class="admin-settings">
    <!-- Admin settings -->
  </div>
<% end %>
```

### 5. Subscription Required

```erb
<%= restricted_for_subscription do %>
  <div class="subscription-features">
    <!-- Subscription-required features -->
  </div>
<% end %>
```

### 6. Custom Restriction

```erb
<%= restricted_area(
  condition: current_user&.company&.jobs_count >= 10,
  message: "You've reached your job posting limit",
  action_text: "Upgrade Plan",
  action_url: upgrade_path
) do %>
  <div class="job-posting-form">
    <!-- Job posting form -->
  </div>
<% end %>
```

## Styling

### Default Styling

The component uses Tailwind CSS classes and includes:
- Blur effect with `filter blur-sm`
- Semi-transparent overlay with backdrop blur
- Gradient buttons with hover effects
- Responsive design
- Proper z-index layering

### Custom Styling

```erb
<%= render RestrictedAreaComponent.new(
  custom_class: "bg-gradient-to-r from-purple-500 to-pink-500"
) do %>
  <!-- Content -->
<% end %>
```

### Disabling Effects

```erb
<!-- No blur, just overlay -->
<%= render RestrictedAreaComponent.new(blur: false) do %>
  <!-- Content -->
<% end %>

<!-- No overlay, just blur -->
<%= render RestrictedAreaComponent.new(overlay: false) do %>
  <!-- Content -->
<% end %>
```

## Icons

The component automatically shows appropriate icons based on the restriction type:

- **Login**: `log-in` icon
- **Upgrade**: `crown` icon  
- **Trial**: `gift` icon
- **Default**: `lock` icon

## Testing

The component includes comprehensive tests covering:
- Blur effects
- Overlay rendering
- Button functionality
- Custom messages and actions
- Helper methods

Run tests with:
```bash
bundle exec rspec spec/components/restricted_area_component_spec.rb
```

## Best Practices

1. **Use Helper Methods**: Prefer helper methods over direct component usage for common cases
2. **Clear Messages**: Provide clear, actionable messages
3. **Consistent Styling**: Use consistent styling across your application
4. **Test Conditions**: Always test the conditions that trigger restrictions
5. **Accessibility**: The component includes proper ARIA attributes and keyboard navigation

## Examples in Your App

### Public Job Filters
```erb
<%= restricted_for_login(message: "Sign in to access advanced filters") do %>
  <!-- Filter sidebar content -->
<% end %>
```

### Company Dashboard
```erb
<%= restricted_for_upgrade(message: "Upgrade to access analytics") do %>
  <!-- Analytics dashboard -->
<% end %>
```

### Admin Panel
```erb
<%= restricted_for_admin do %>
  <!-- Admin panel content -->
<% end %>
```
