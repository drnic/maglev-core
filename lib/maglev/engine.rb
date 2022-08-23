# frozen_string_literal: true
require 'vite_ruby'

module Maglev
  class Engine < ::Rails::Engine
    isolate_namespace Maglev

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot
      g.factory_bot dir: 'spec/factories'
    end

    config.assets.precompile += %w[maglev/logo.png maglev/favicon.png]

    initializer 'maglev.theme_reloader' do |app|
      require_relative './theme_filesystem_loader'
      theme_path = Rails.root.join('app/theme')
      theme_reloader = app.config.file_watcher.new([], { theme_path.to_s => ['.yml'] }) do
        theme_loader = Maglev::ThemeFilesystemLoader.new(
          Maglev.services(context: nil).fetch_section_screenshot_path
        )
        Maglev.local_themes = [theme_loader.call(theme_path)]
      end
      app.reloaders << theme_reloader

      config.to_prepare do
        # everytime the code of the app or the engine changes, we reload the themes
        # theme_reloader.execute
      end

      config.after_initialize do
        theme_reloader.execute
      end
    end

    initializer 'maglev.i18n' do |_app|
      Rails.application.config.i18n.load_path += Dir["#{config.root}/config/locales/**/*.yml"]
    end

    delegate :vite_ruby, to: :class

    def self.vite_ruby
      @vite_ruby ||= ::ViteRuby.new(root: root)
    end

    # Serves the engine's vite-ruby when requested
    initializer 'maglev.vite_rails.static' do |app|
      app.config.middleware.use(
        Rack::Static,
        urls: ["/#{ vite_ruby.config.public_output_dir }"],
        root: root.join(vite_ruby.config.public_dir)
      )
    end

    initializer 'maglev.vite_rails_engine.proxy' do |app|
      if vite_ruby.run_proxy?
        app.middleware.insert_before 0, 
          ViteRuby::DevServerProxy, 
          ssl_verify_none: true, 
          vite_ruby: vite_ruby
      end
    end

    initializer 'maglev.vite_rails_engine.logger' do
      config.after_initialize do
        vite_ruby.logger = Rails.logger
      end
    end

    # initializer 'maglev.webpacker.proxy' do |app|
    #   insert_middleware = begin
    #     Maglev.webpacker.config.dev_server.present?
    #   rescue StandardError
    #     nil
    #   end
    #   next unless insert_middleware

    #   app.middleware.insert_before(
    #     0, Webpacker::DevServerProxy,
    #     ssl_verify_none: true,
    #     webpacker: Maglev.webpacker
    #   )
    # end

    # Serves the engine's webpack when requested
    # initializer 'maglev.webpacker.static' do |app|
    #   app.config.middleware.use(
    #     Rack::Static,
    #     urls: ['/maglev-packs'],
    #     root: File.expand_path(File.join(__dir__, '..', '..', 'public'))
    #   )
    # end
  end
end
