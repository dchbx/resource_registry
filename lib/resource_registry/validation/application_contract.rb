require 'dry/validation'

module ResourceRegistry
  module Validation
    class ApplicationContract < Dry::Validation::Contract
      config.messages.default_locale = :en
      # config.messages.backend = :i18n

# config.messages.default_locale - default I18n-compatible locale identifier
# config.messages.backend - the localization backend to use. Supported values are: :yaml and :i18n
# config.messages.load_paths - an array of files paths that are used to load messages
# config.messages.top_namespace - the key in the locale files under which messages are defined, by default it’s dry_validation
# config.messages.namespace - custom messages namespace for a contract class. Use this to differentiate common messages

      # Define a macro for all subclasse that checks an email string format
      # Reference it in contract: rule(:email).validate(:email_format)
      register_macro(:email_format) do
        unless /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i.match?(value)
          key.failure('not a valid email format')
        end
      end

      StrictSymbolizingHash = Types::Hash.schema({}).strict.with_key_transform(&:to_sym)

    end
  end
end