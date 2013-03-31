require 'katakuchi/version'

class Katakuchi::Railtie < ::Rails::Railtie
  initializer 'katakuchi' do |app|
    app.config.paths.add('app/roles', eager_load: true)
  end
end
