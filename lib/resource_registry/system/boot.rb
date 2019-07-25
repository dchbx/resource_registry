# Initialize container with core system settings

require 'dry/system/container'

module ResourceRegistry
  class CoreContainer < Dry::System::Container

    configure do |config|
      config.name = :core
      config.default_namespace = :core
      config.root = Pathname.pwd.join('lib').realpath.freeze
      config.system_dir = "resource_registry/system"
      # config.root = Pathname.pwd.join('lib').join('resource_registry').realpath.freeze

      config.auto_register = %w[resource_registry/serializers resource_registry/stores]
    end

    load_paths!('resource_registry')
  end

  require_relative "local_dependencies/auto_inject"
  require_relative "local_dependencies/persistence"

  require_relative "local_dependencies/configuration"
  CoreContainer.namespace(:options) do |container|
    path = container.config.root.join(container.config.system_dir)
    obj = Configuration.load_attr(path, "config")
    obj.to_hash.each_pair { |key, value| container.register("#{key}".to_sym, "#{value}") }
  end

  CoreContainer.finalize!(freeze: true)
end
