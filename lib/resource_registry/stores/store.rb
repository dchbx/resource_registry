module ResourceRegistry
  module Stores
    class Store

      attr_accessor :tenant, :configuration_set_name, :configuration_set

      def load
        raise NotImplementedError
      end

      def persist
      end

      def self.options_files(config_root, env)
        [
          File.join(config_root, 'options.yml').to_s,
          File.join(config_root, 'options', "#{env}.yml").to_s,
          File.join(config_root, 'environments', "#{env}.yml").to_s
        ].freeze
      end

      class << self
        def find(id)
          raise NotImplementedError
        end

        def find_by_tenant(tenant:)
          raise NotImplementedError
        end

        def find_by_collection_name(tenant:, collection_name:)
          raise NotImplementedError
        end
      end

    end

    class StoreSet
      attr_reader :stores

      def initialize
        @stores = Set.new
        add_store(store_files)
      end

      def store_files
        namespace = ResourceRegistry.module_parent_for(self.class)
        store_dir = ResourceRegistry.gem_file_path_for(namespace)
        store_file_pattern  = '*_store.rb'

        ResourceRegistry.file_kinds_for(file_pattern: store_file_pattern, dir_base: store_dir)
      end

      def add_store(stores)
        @stores += stores
      end
    end
  end
end
