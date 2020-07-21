# frozen_string_literal: true

module RuboCop # :nodoc:
  module Cop # :nodoc:
    module Packaging # :nodoc:
      # This cop is used to identify the `require_relative` calls,
      # mapping to the "lib" directory and suggests to use `require`
      # instead.
      #
      # @example
      #
      #   # bad
      #   require_relative 'lib/foo.rb'
      #
      #   # bad
      #   require_relative '../../lib/foo/bar'
      #
      #   # good
      #   require 'foo.rb'
      #
      #   # good
      #   require 'foo/bar'
      #
      #   # good
      #   require_relative 'spec_helper'
      #   require_relative 'foo/bar'
      #
      class RelativeRequireToLib < Base
        # This is the message that will be displayed when RuboCop finds an
        # offense of using `require_relative` with relative path to lib.
        MSG = 'Avoid using `require_relative` with relative path to lib. ' \
          'Use `require` instead.'

        def_node_matcher :require_relative, <<~PATTERN
          (send nil? :require_relative
            (str #starts_with_relative_path?))
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
        # It is used to find paths which starts with "lib".
        def starts_with_relative_path?(str)
          root_dir = RuboCop::ConfigLoader.project_root
          relative_dir = File.expand_path(str, @file_directory)
          relative_dir.delete_prefix!(root_dir + '/')
          relative_dir.start_with?('lib')
        end
      end
    end
  end
end
