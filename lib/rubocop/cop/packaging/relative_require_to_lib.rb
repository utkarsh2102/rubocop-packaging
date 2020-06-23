# frozen_string_literal: true

module RuboCop # :nodoc:
  module Cop # :nodoc:
    module Packaging # :nodoc:
      # TODO
      # Write about this cop.
      # Write bad and good methods.
      # Help from cop/lint/redundant_require_statement.rb.
      #
      class RelativeRequireToLib < Cop
        # This is the message that will be displayed when RuboCop finds an
        # offense of using `require` with relative path to lib.
        MSG = 'Avoid using `require` with relative path to lib.'

        def_node_matcher :require?, <<~PATTERN
          (send nil? :require
            (str {#starts_with_relative_path?}))
        PATTERN

        # Extended method.
        # TODO: document it.
        def on_send(node)
          return unless require?(node)

          add_offense(node)
        end

        # This method is called from inside `#def_node_search`.
        # It is used to find the strings that uses relative path.
        def starts_with_relative_path?(str)
          str.match?(%r{.*\.\./lib/})
        end
      end
    end
  end
end
