# frozen_string_literal: true

module RuboCop # :nodoc:
  module Packaging # :nodoc:
    # This helper module extracts the methods which can be used
    # in other cop classes.
    module LibHelperModule
      # For determining the root directory of the project.
      def root_dir
        RuboCop::ConfigLoader.project_root
      end

      # This method determines if the `require_relative` call is made
      # to the "lib" directory.
      def target_falls_in_lib?(str)
        File.expand_path(str, @file_directory).start_with?("#{root_dir}/lib")
      end

      # This method determines if that call is made *from* the "lib" directory.
      def inspected_file_falls_in_lib?
        @file_path.start_with?("#{root_dir}/lib")
      end

      # This method determines if that call is made *from* the "gemspec" file.
      def inspected_file_is_gemspec?
        @file_path.end_with?("gemspec")
      end
    end
  end
end
