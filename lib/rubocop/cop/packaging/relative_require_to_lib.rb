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

        def_node_matcher :require_relative, <<~PATTERN
          (send nil? :require_relative
            (str #starts_with_relative_path?))
        PATTERN

        def investigate(processed_source)
          @file_path = processed_source.file_path
          @file_directory = File.dirname(@file_path)
        end

        # Extended method.
        # TODO: document it.
        def on_send(node)
          return unless require_relative(node)

          add_offense(node)
        end

        # This method is called from inside `#def_node_search`.
        # It is used to find the strings that uses relative path.
        def starts_with_relative_path?(str)
          root_dir = get_root
          relative_dir = File.expand_path(str, @file_directory)
          relative_dir.delete_prefix!(root_dir + '/')
          relative_dir.start_with?('lib')
          # str.match?(%r{.*\./lib/})
        end

        def get_root(*)
          # FIXME
          '/some'
        end
      end
    end
  end
end
