require "mongoid"
require "dry/inflector"
require 'dry-container'
require 'resource_registry/repository'
require 'resource_registry/options'
require 'resource_registry/service'
require 'resource_registry/configuration'
require 'resource_registry/stores'
require 'resource_registry/error'
require 'resource_registry/feature_check'
require 'resource_registry/version'

# require 'resource_registry/stores/store'

module ResourceRegistry
  include Dry::Core::Constants

  CONFIG_PATH = '/config/initializers/resource_registry.rb'
  Inflector = Dry::Inflector.new

  class << self

    def configure
      configuration = ResourceRegistry::Configuration.config
      yield(configuration)
      configuration.to_h.each {|key, value| container.register key.to_sym, value }
      container.freeze
    end

    def setup
      yield self unless @_ran_once
      @_ran_once = true
    end

    def load_options
      repository = ResourceRegistry::Services::CreateOptionRepository.call
      # ResourceRegistry::Services::FileLoad.call(repository: option_repository)
      # option_repository
    end
    
    def load_feature_select
      feature_repository = ResourceRegistry::Services::CreateFeatureSelectRepository

      ResourceRegistry::Services::FileLoad.call(repository: feature_repository)
      feature_repository
    end

    def reload!
      Object.const_get(ResourceRegistry.const_name).reload!
    end

    # Determines the namespace parent for the passed module or class constant
    # If the passed constant is top of the namespace, returns that constant
    def module_parent_for(child_module)
      list = child_module.to_s.split('::')
      if list.size > 1
        parents = list.slice(0, list.size - 1)

        const_get(parents.join('::'))
      else
        list.size == 1 ? child_module : nil
      end
    end

    def gem_file_path_for(namespace)
      namespace_str = Inflector.underscore(namespace)
      './lib/' + namespace_str
    end

    def file_kinds_for(file_pattern:, dir_base:)
      list = []
      Dir.glob(file_pattern, base: dir_base) do |file_name|
        upper_bound = file_name.length - file_pattern.length
        list << file_name[0..upper_bound].to_sym
      end
      list
    end

    def container
      @@container
    end

    def root
      File.dirname __dir__
    end

    def services_path
      root + "/lib/resource_registry/services/"
    end

    def engines
      [Rails] + Rails::Engine.subclasses.select do |engine|
        File.exists?(engine.root.to_s + CONFIG_PATH)
      end
    end
  end

  private

  @@container = Dry::Container.new
  Config = Dry::AutoInject(@@container)
  Dir.glob(ResourceRegistry.services_path + '*', &method(:require))
end
