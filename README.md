# Rails Wheel

A starter template for building modern web applications with Ruby on Rails. This project integrates the following technologies to provide a robust foundation:

## Features

- **Ruby on Rails**: Backend framework for building scalable and maintainable applications.
- **PostgreSQL**: Database for storing application data with powerful querying capabilities.
- **TailwindCSS**: Utility-first CSS framework for fast and responsive UI design.
- **Turbo (Hotwire)**: Framework for building real-time, interactive front-end experiences without JavaScript fatigue.
- **Importmap**: Simplified JavaScript module management, allowing you to avoid bundlers like Webpack.
- **Hotwire Combobox**: Accessible and customizable combobox component for form inputs.

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/arish-me/rails-wheel.git
   cd rails-wheel
   ```

2. Install dependencies:
   ```bash
   bundle install
   ```

3. Set up the database:
   ```bash
   rails db:create db:migrate
   ```

4. Start the development server:
   ```bash
   bin/dev
   ```
5. Run Capybara Specs:
   ```bash
   bundle exec rspec spec/features
   ```

## Usage

This project is preconfigured with the following tools:

- **TailwindCSS**: Customize your application’s styling using TailwindCSS utility classes. Configuration is located in `tailwind.config.js`.
- **Turbo (Hotwire)**: Build interactive components without complex JavaScript. Turbo and Stimulus controllers are set up for you.
- **Hotwire Combobox**: Use accessible combobox components in your forms. Import it into your JavaScript using Importmap.

## Contributing

1. Fork the repository.
2. Create a feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request.

## License

This project is licensed under the MIT License. See the LICENSE file for details.

