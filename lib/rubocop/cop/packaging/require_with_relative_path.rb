# frozen_string_literal: true

module RuboCop # :nodoc:
  module Cop # :nodoc:
    module Packaging # :nodoc:
      # TODO: write documentation later.
      #
      class RequireWithRelativePath < Base
        # TODO: write documentation later.
        #
        MSG = "Avoid using `require` with relative path."

        def_node_matcher :require?, <<~PATTERN
          {(send nil? :require (str #falls_in_lib?))
           (send nil? :require (send (const nil? :File) :expand_path (str #falls_in_lib?) {(str _) (send nil? _)}))
           (send nil? :require (send (send (const nil? :File) :dirname {(str _) (send nil? _)}) :+ (str #falls_in_lib?)))}
        PATTERN

        def on_new_investigation
          @file_path = processed_source.file_path
          @file_directory = File.dirname(@file_path)
        end

        def on_send(node)
          return unless require?(node)

          add_offense(node)
        end

        def root_dir
          RuboCop::ConfigLoader.project_root
        end

        def falls_in_lib?(str)
          str.match?(%r{.*\./lib/})
        end

        def _falls_in_lib?(str)
          target_falls_in_lib?(str) && !inspected_file_falls_in_lib?
        end

        def target_falls_in_lib?(str)
          File.expand_path(str, @file_directory).start_with?("#{root_dir}/lib")
        end

        def inspected_file_falls_in_lib?
          @file_path.start_with?("#{root_dir}/lib")
        end
      end
    end
  end
end
