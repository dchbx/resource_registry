require 'dry-container'
# require "dry-auto_inject"

# # How to access namespaces: reference the block variable assigned to that namespace
# container.namespace('three') do |c|
#   c.register('four', c.resolve('one.two', namespaced: false))
# end

module ResourceRegistry
  class Repository
    include Dry::Container::Mixin

    attr_reader :namespace_root

    def initialize(root_name: nil)
      @namespace_root = build_namespace_root(root_name)

      yield self if block_given?
    end

    def build_namespace_root(namespace_name)
      if namespace_name == nil || namespace_name == ''
        nil
      else
        ns = load_namespace(namespace_name)
        ns.name 
      end
    end

    def load_namespaces(namespace_names)
      namespace_names.each { |name| load_namespace(name) }
    end

    def load_namespace(name)
      namespace = Dry::Container::Namespace.new(name) { register_namespace_procs(name) }
      self.import namespace
      namespace
    end

    def self.namespace_join(namespaces)
      if namespaces.length > 1
        namespaces.join('.').to_s
      else
        namespaces.size == 1 ? namespaces.first.to_s : ''
      end
    end

    # [level1a, [leve2a, level2b, [level3a]], level1b]

    # {  }

    # def load_ns(names)
    #   names.each do |name|
    #     self[name].is_a? Dry::Container::Namespace
    #     else
    #     end
    #   end
    # end

    # Create namespace-level procs that perform the following:
    # _all_keys: list of all keys in the namespace, including procs that start with and underscore ('_') character
    # _keys: list of all non-proc keys in the namespace
    # _pairs: list of key/value pairs in the namespace
    def register_namespace_procs(namespace_name)
      register('_all_keys') { ns_exp = /\A#{Regexp.quote(namespace_name)}./;   keys.reduce([]) { |list, key| list << key if ns_exp.match?(key, 0); list }}
      register('_keys')     { ns_exp = /\A#{Regexp.quote(namespace_name)}.[^_]/; keys.reduce([]) { |list, key| list << key if ns_exp.match?(key, 0); list }}
      register('_pairs')    { resolve("_keys").reduce([]) { |list, key| list <<  Hash("#{key}" => resolve("#{key.split('.').last}")) } }
    end

    # Recursively update values from a hash
    #
    # @param [Hash] values to set
    # @return [Config]
    def update(values)
      values.each do |key, value|
        if self[key].is_a?(Repository)
          self[key].update(value)
        else
          self[key] = value
        end
      end
      self
    end

    def dup
      if self.defined?
        self.class.new.define!(to_h)
      else
        self.class.new
      end
    end

    # Serialize config to a Hash
    #
    # @return [Hash]
    def to_h
      self.each_with_object({}) do |(key, value), hash|
        case value
        when Repository
          hash[key] = value.to_h
        else
          hash[key] = value
        end
      end
    end

    alias to_hash to_h

    private

    def build_cache(name)
      @data_store = ThreadSafe::Cache.new.tap do |ds|
        ds[name] = ThreadSafe::Array.new
      end
    end

  end
end
