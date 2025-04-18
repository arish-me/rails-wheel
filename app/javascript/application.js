// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "chartkick"
import "Chart.bundle"
import { DirectUpload } from "@rails/activestorage"
import * as ActiveStorage from "@rails/activestorage"

// Initialize ActiveStorage
ActiveStorage.start()

Turbo.StreamActions.redirect = function () {
  Turbo.visit(this.target);
};

