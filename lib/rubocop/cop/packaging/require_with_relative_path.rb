# frozen_string_literal: true

require "rubocop/packaging/lib_helper_module"

module RuboCop # :nodoc:
  module Cop # :nodoc:
    module Packaging # :nodoc:
      # TODO: write documentation later.
      #
      class RequireWithRelativePath < Base
        include RuboCop::Packaging::LibHelperModule

        # This is the message that will be displayed when RuboCop::Packaging
        # finds an offense of using `require` with relative path to lib.
        MSG = "Avoid using `require` with relative path to `lib/`."

        def_node_matcher :require?, <<~PATTERN
          {(send nil? :require (str #falls_in_lib?))
           (send nil? :require (send (const nil? :File) :expand_path (str #falls_in_lib?) (send nil? :__dir__)))
           (send nil? :require (send (const nil? :File) :expand_path (str #falls_in_lib_using_file?) (str _)))
           (send nil? :require (send (send (const nil? :File) :dirname {(str _) (send nil? _)}) :+ (str #str_starts_with_slash)))}
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
          return unless require?(node)

          add_offense(node)
        end

        # This method is called from inside `#def_node_matcher`.
        # It flags an offense if the `require` call is made from
        # anywhere except the "lib" directory.
        def falls_in_lib?(str)
          target_falls_in_lib?(str) && !inspected_file_falls_in_lib?
        end

        # This method is called from inside `#def_node_matcher`.
        # It flags an offense if the `require` call (using the __FILE__
        # arguement) is made from anywhere except the "lib" directory.
        def falls_in_lib_using_file?(str)
          target_falls_in_lib_using_file?(str) && !inspected_file_falls_in_lib?
        end
      end
    end
  end
end
