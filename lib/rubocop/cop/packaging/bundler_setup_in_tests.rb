# frozen_string_literal: true

require "rubocop/packaging/lib_helper_module"

module RuboCop
  module Cop
    module Packaging
      # TODO: Write cop description and example of bad / good code.
      #
      class BundlerSetupInTests < Base
        include RuboCop::Packaging::LibHelperModule

        # TODO: Write documentation.
        MSG = "Avoid using `bundler/setup` in your tests."

        def_node_matcher :bundler_setup?, <<~PATTERN
          (send nil? :require
            (str #bundler_setup_in_test_dir?))
        PATTERN

        def on_new_investigation
          @file_path = processed_source.file_path
          @file_directory = File.dirname(@file_path)
        end

        def on_send(node)
          return unless bundler_setup?(node)

          add_offense(node)
        end

        def bundler_setup_in_test_dir?(str)
          str.eql?("bundler/setup") && falls_in_test_dir?
        end

        def falls_in_test_dir?
          %w[spec specs test tests].any? { |dir| File.expand_path(@file_directory).start_with?("#{root_dir}/#{dir}") }
        end
      end
    end
  end
end
