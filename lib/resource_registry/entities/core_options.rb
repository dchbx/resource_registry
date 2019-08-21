# frozen_string_literal: true

require "yaml"

module ResourceRegistry
  module Entities
    class CoreOptions < Dry::Struct

      # include DryStructSetters
      # transform_keys(&:to_sym)

      attribute :store,                 Types::RequiredString
      attribute :serializer,            Types::RequiredString
      attribute :container,             Types::String

      def self.load_attr(root, name)
        # TODO: change this to our serialization/store model

        path = root.join("config").join("#{name}.yml").realpath
        yaml = File.exist?(path) ? YAML.load_file(path) : {}

        dict = schema.keys.each_with_object({}) do |key, memo|
          value = yaml.dig(key.name.to_s)
          memo[key.name.to_sym] = value
        end

        new(dict)
      end

    end
  end
end