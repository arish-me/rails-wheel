# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "@hotwired--stimulus.js" # @3.2.2
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin "@rails/activestorage", to: "@rails--activestorage.js" # @8.0.100
pin "chartkick", to: "chartkick.js"
pin "Chart.bundle", to: "Chart.bundle.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin_all_from "app/components", under: "controllers", to: ""

pin "@shoelace-style/shoelace", to: "@shoelace-style--shoelace.js" # @2.20.1
pin "@ctrl/tinycolor", to: "@ctrl--tinycolor.js" # @4.1.0
pin "@floating-ui/core", to: "@floating-ui--core.js" # @1.6.9
pin "@floating-ui/dom", to: "@floating-ui--dom.js" # @1.6.13
pin "@floating-ui/utils", to: "@floating-ui--utils.js" # @0.2.9
pin "@floating-ui/utils/dom", to: "@floating-ui--utils--dom.js" # @0.2.9
pin "@lit/reactive-element", to: "@lit--reactive-element.js" # @2.1.0
pin "@github/hotkey", to: "@github--hotkey.js" # @3.1.1
pin "@rails/actioncable", to: "@rails--actioncable.js" # @8.0.200
pin_all_from "app/javascript/channels", under: "channels" # This is important for ActionCable channels
pin "stimulus-places-autocomplete" # @0.5.0
