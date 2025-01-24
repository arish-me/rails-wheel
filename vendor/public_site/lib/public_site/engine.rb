require 'liquid'

module PublicSite
  class Engine < ::Rails::Engine
    isolate_namespace PublicSite
    config.paths.add 'app/models', eager_load: true
    initializer :append_migrations do |app|
      unless app.root.to_s.match? root.to_s
        config.paths['db/migrate'].expanded.each do |expanded_path|
          app.config.paths['db/migrate'] << expanded_path
        end
      end
    end
  end
end
