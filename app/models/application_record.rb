# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  class << self
    private

    def find_attr_value(attr, keys)
      case keys
      when Array
        attr.dig(*keys)
      when Symbol, String
        attr[keys]
      end
    end
  end
end
