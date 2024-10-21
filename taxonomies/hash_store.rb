# frozen_string_literal: true

require 'deep_merge/rails_compat'

module ResourceRegistry
  module Stores
    module Operations
      class HashStore

        include Dry::Transaction::Operation

        def call(input)
          if defined? ResourceRegistry::AppSettings
            DeepMerge.deeper_merge!(
              input.to_h,
              ResourceRegistry::AppSettings,
              merge_hash_arrays: true,
              merge_nil_values: true
            )
          else
            ResourceRegistry.const_set('AppSettings', input.to_h)
          end

          Success(input)
        end
      end
    end
  end
end
