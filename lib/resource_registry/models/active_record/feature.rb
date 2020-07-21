# frozen_string_literal: true
module ResourceRegistry
  module ActiveRecord
    class Feature < ::ActiveRecord::Base
      self.table_name = "resource_registry_features"

      has_one     :meta, as: :editable, class_name: '::ResourceRegistry::ActiveRecord::Meta', dependent: :destroy
      has_many    :settings, class_name: '::ResourceRegistry::ActiveRecord::Setting', dependent: :destroy

	    validates :key, uniqueness: true
      accepts_nested_attributes_for :meta, :settings

      def meta=(attrs)
        build_meta(attrs) if attrs.present?
      end

      def settings=(attrs)
        attrs.each do |setting_hash|
      	  settings.build(setting_hash)
        end
      end

      def item=(val)
        super(val.to_yaml)
      end

      def setting(key)
      	settings.detect{|setting| setting.key.to_s == key.to_s}
      end

      def item_value
        return nil if self.item.nil?
        value = YAML.parse(self.item)
        value.respond_to?(:transform) ? value.transform : value
      rescue Psych::SyntaxError
        item
      end

      def to_h
        attributes.merge({
          'meta' => meta&.to_h,
          'item'=> item_value,
          'settings' => settings.map(&:to_h)
        })
      end
    end
  end
end