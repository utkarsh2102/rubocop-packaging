# frozen_string_literal: true

require "rubocop/packaging/lib_helper_module"

module RuboCop # :nodoc:
  module Cop # :nodoc:
    module Packaging # :nodoc:
      # This cop flags the `require_relative` calls, from anywhere
      # mapping to the "lib" directory, except originating from lib/ or
      # the gemspec file, and suggests to use `require` instead.
      #
      # More information about the RequireRelativeHardcodingLib cop can be found here:
      # https://packaging.rubystyle.guide/#require-relative-hardcoding-lib
      #
      # @example
      #
      #   # bad
      #   require_relative "lib/foo.rb"
      #
      #   # good
      #   require "foo.rb"
      #
      #   # bad
      #   require_relative "../../lib/foo/bar"
      #
      #   # good
      #   require "foo/bar"
      #
      #   # good
      #   require_relative "spec_helper"
      #   require_relative "spec/foo/bar"
      #
      class RequireRelativeHardcodingLib < Base
        include RuboCop::Packaging::LibHelperModule

        # This is the message that will be displayed when RuboCop finds an
        # offense of using `require_relative` with relative path to lib.
        MSG = "Avoid using `require_relative` with relative path to lib. " \
          "Use `require` instead."

        def_node_matcher :require_relative, <<~PATTERN
          (send nil? :require_relative
            (str #falls_in_lib?))
        PATTERN

        # Extended from the Base class.
        # More about the `#on_new_investigation` method can be found here:
        # https://github.com/rubocop-hq/rubocop/blob/343f62e4555be0470326f47af219689e21c61a37/lib/rubocop/cop/base.rb
        #
        # Processing of the AST happens here.
        def on_new_investigation
          @file_path = processed_source.file_path
          @file_directory = File.dirname(@file_path)
        end

        # Extended from AST::Traversal.
        # More about the `#on_send` method can be found here:
        # https://github.com/rubocop-hq/rubocop-ast/blob/08d0f49a47af1e9a30a6d8f67533ba793c843d67/lib/rubocop/ast/traversal.rb#L112
        def on_send(node)
          return unless require_relative(node)

          add_offense(node)
        end

        # This method is called from inside `#def_node_matcher`.
        # It flags an offense if the `require_relative` call is made
        # from anywhere except the "lib" directory.
        def falls_in_lib?(str)
          target_falls_in_lib?(str) && !inspected_file_falls_in_lib? && !inspected_file_is_gemspec?
        end
      end
    end
  end
end
