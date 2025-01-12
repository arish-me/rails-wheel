// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import 'flowbite';
import "controllers"
import "chartkick"
import "Chart.bundle"
Turbo.StreamActions.redirect = function () {
  Turbo.visit(this.target);
};

