class ClientSetupService
  DEFAULT_LAYOUTS = [
    {
      name: 'Header and Footer Layout',
      content: <<~LIQUID
        <!DOCTYPE html>
        <html>
        <head>
          <title>{{ client.name }}</title>
        </head>
        <body>
          <header>
            <h1>Welcome to {{ client.name }}</h1>
          </header>
          <main>
            {{ content }}
          </main>
          <footer>
            <p>&copy; {{ client.name }} - All rights reserved</p>
          </footer>
        </body>
        </html>
      LIQUID
    },
    {
      name: 'Full-Width Layout',
      content: <<~LIQUID
        <!DOCTYPE html>
        <html>
        <head>
          <title>{{ client.name }}</title>
        </head>
        <body>
          <main>
            {{ content }}
          </main>
        </body>
        </html>
      LIQUID
    }
  ]

  DEFAULT_TEMPLATES = [
    {
      name: 'Homepage Template',
      content: <<~LIQUID
        <h2>Welcome to {{ client.name }}'s Homepage</h2>
        <p>Here are some of our latest courses:</p>
        <ul>
          {% for course in courses %}
            <li>
              <h3>{{ course.title }}</h3>
              <p>{{ course.description }}</p>
            </li>
          {% endfor %}
        </ul>
      LIQUID
    },
    {
      name: 'Contact Page Template',
      content: <<~LIQUID
        <h2>Contact Us</h2>
        <p>If you have any questions, feel free to reach out to {{ client.name }}.</p>
        <p>Email: {{ client.email }}</p>
      LIQUID
    }
  ]

  def initialize(client)
    @client = client
  end

  def setup_defaults
    layouts = create_default_layouts
    create_default_templates(layouts.first)
  end

  private

  def create_default_layouts
    DEFAULT_LAYOUTS.map do |layout_data|
      @client.layouts.create!(layout_data)
    end
  end

  def create_default_templates(default_layout)
    DEFAULT_TEMPLATES.each do |template_data|
      @client.templates.create!(
        template_data.merge(layout: default_layout)
      )
    end
  end
end
