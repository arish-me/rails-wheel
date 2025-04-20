
# Rails Wheel: Production-Ready Ruby on Rails Starter

<p align="center">
  <h1 align="center">Rails Wheel</h1>
</p>

<p align="center">
  <a href="https://github.com/arish-me/rails-wheel/stargazers"><img src="https://img.shields.io/github/stars/arish-me/rails-wheel" alt="GitHub stars"></a>
  <a href="https://github.com/arish-me/rails-wheel/network/members"><img src="https://img.shields.io/github/forks/arish-me/rails-wheel" alt="GitHub forks"></a>
  <a href="https://github.com/arish-me/rails-wheel/issues"><img src="https://img.shields.io/github/issues/arish-me/rails-wheel" alt="GitHub issues"></a>
  <a href="https://github.com/arish-me/rails-wheel/blob/main/LICENSE"><img src="https://img.shields.io/github/license/arish-me/rails-wheel" alt="License"></a>
</p>

## 🚀 Overview

**Rails Wheel** is a comprehensive, production-ready  starter template for building modern web applications with Ruby on Rails.

Perfect for:
- SaaS Applications
- Internal Tools
- MVPs and Prototypes
- Full-featured Web Applications

## ✨ Key Features

### 🔐 Authentication & User Management
- **Devise Integration**: Email/password authentication ready out of the box
- **OAuth Support**: Google authentication with easy expansion to other providers
- **Role-based Access Control**: Pundit integration for authorization
- **User Impersonation**: Admin tools for debugging user experiences

### 🎨 Modern UI with TailwindCSS
- **Responsive Design**: Mobile-first responsive layouts
- **Dark Mode**: Built-in theme toggling with user preference persistence
- **Component Library**: Pre-built UI components following best practices
- **Utility-first CSS**: Rapid UI development with TailwindCSS

### ⚡ Hotwire & Modern Rails Stack
- **Turbo Drive/Frames/Streams**: SPA-like experience with server-rendered HTML
- **Stimulus Controllers**: Enhanced client-side interactivity
- **Importmap**: Simplified JavaScript module management without complex bundlers
- **Hotwire Combobox**: Accessible form components

### 🛠️ Developer Experience
- **PostgreSQL**: Powerful database with advanced querying capabilities
- **Background Jobs**: Ready for ActiveJob implementation
- **Internationalization**: i18n setup for multi-language support
- **Testing Suite**: RSpec configured with Capybara for feature testing

## 📋 Prerequisites

- Ruby 3.2+
- PostgreSQL 14+
- Node.js 18+ (for TailwindCSS)
- Yarn or npm

## 🔧 Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/arish-me/rails-wheel.git your-app-name
   cd your-app-name
   ```

2. **Install dependencies**
   ```bash
   bundle install
   ```

3. **Set up the database**
   ```bash
   rails db:create db:migrate db:seed
   ```

4. **Start the development server**
   ```bash
   bin/dev
   ```
   Visit http://localhost:3000 to see your application in action!

5. **Run tests**
   ```bash
   bundle exec rspec
   ```

## 🧩 Project Structure

Rails Wheel follows Rails conventions with some enhancements:

- `/app/components` - Reusable view components
- `/app/controllers` - Application controllers with Pundit integration
- `/app/javascript/controllers` - Stimulus controllers
- `/app/views/layouts/navs` - Navigation components
- `/config/locales` - Internationalization files

## 🧪 Testing

Rails Wheel comes with a comprehensive testing suite using RSpec:

```bash
# Run all tests
bundle exec rspec

# Run only feature tests
bundle exec rspec spec/features

# Run only model tests
bundle exec rspec spec/models
```

## 🤝 Contributing

We welcome contributions to Rails Wheel! Here's how you can help:

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Commit your changes**: `git commit -m 'Add some amazing feature'`
4. **Push to the branch**: `git push origin feature/amazing-feature`
5. **Open a Pull Request**

Please make sure your PR follows our contribution guidelines.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📚 Resources

- [Ruby on Rails Guides](https://guides.rubyonrails.org/)
- [TailwindCSS Documentation](https://tailwindcss.com/docs)
- [Hotwire Documentation](https://hotwired.dev/)
- [Stimulus Handbook](https://stimulus.hotwired.dev/handbook/introduction)

---

<p align="center">
  Built with ❤️ by <a href="https://github.com/arish-me">Arish</a>
</p>

