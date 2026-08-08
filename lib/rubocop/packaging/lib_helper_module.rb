# frozen_string_literal: true

module RuboCop # :nodoc:
  module Packaging # :nodoc:
    # This helper module extracts the methods which can be used
    # in other cop classes.
    module LibHelperModule
      # For determining the root directory of the project.
      def root_dir
        return @root_dir if @root_dir_for == @file_path

        @root_dir_for = @file_path
        @root_dir = root_dir_from_config
      end

      private

      def root_dir_from_config
        config_file = RuboCop::ConfigLoader.configuration_file_for(@file_path)
        project_root = RuboCop::ConfigFinder.project_root
        return project_root if config_file == RuboCop::ConfigLoader::DEFAULT_FILE
        return project_root unless project_config_file?(config_file, project_root)

        config_path = File.expand_path(config_file)
        return File.dirname(config_path) unless config_path.end_with?("/.config/rubocop/config.yml")

        File.expand_path("../..", File.dirname(config_path))
      end

      def project_config_file?(config_file, project_root)
        return false unless config_file
        return true unless project_root

        config_path = File.expand_path(config_file)
        project_path = File.expand_path(project_root)
        config_path == project_path || config_path.start_with?("#{project_path}/")
      end

      public

      # This method determines if the calls are made to the "lib" directory.
      def target_falls_in_lib?(str)
        File.expand_path(str, @file_directory).start_with?("#{root_dir}/lib")
      end

      # This method determines if the calls (using the __FILE__ argument)
      # are made to the "lib" directory.
      def target_falls_in_lib_using_file?(str)
        File.expand_path(str, @file_path).start_with?("#{root_dir}/lib")
      end

      # This method determines if that call is made *from* the "lib" directory.
      def inspected_file_falls_in_lib?
        @file_path.start_with?("#{root_dir}/lib")
      end

      # This method determines if that call is made *from* the "gemspec" file.
      def inspected_file_is_gemspec?
        @file_path.end_with?("gemspec")
      end

      # This method determines if the inspected file is not in lib/ or
      # isn't a gemspec file.
      def inspected_file_is_not_in_lib_or_gemspec?
        !inspected_file_falls_in_lib? && !inspected_file_is_gemspec?
      end
    end
  end
end
