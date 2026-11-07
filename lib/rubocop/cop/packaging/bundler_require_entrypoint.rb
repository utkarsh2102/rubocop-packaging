# frozen_string_literal: true

module RuboCop # :nodoc:
  module Cop # :nodoc:
    module Packaging # :nodoc:
      # This cop flags a gemspec whose gem name has no matching file for
      # `Bundler.require` to load.
      #
      # `Bundler.require` loads each gem in the Gemfile by requiring its name,
      # and when that fails for a name containing a dash, by requiring the name
      # with dashes turned into slashes. If neither file exists, the gem is
      # skipped silently, and every application has to add `require:` to its
      # Gemfile entry or require the gem by hand.
      #
      # Add a file at one of those paths that requires the gem's main file.
      #
      # Gems with native extensions are not checked, since their entrypoint
      # may only exist once the extension is compiled.
      #
      # @example
      #
      #   # bad - foo-bar.gemspec, with only lib/foo_bar.rb
      #   Gem::Specification.new do |spec|
      #     spec.name = "foo-bar"
      #   end
      #
      #   # good - foo-bar.gemspec, with lib/foo/bar.rb
      #   #   require "foo_bar"
      #   Gem::Specification.new do |spec|
      #     spec.name = "foo-bar"
      #   end
      #
      #   # good - foo-bar.gemspec, with lib/foo-bar.rb
      #   Gem::Specification.new do |spec|
      #     spec.name = "foo-bar"
      #   end
      #
      class BundlerRequireEntrypoint < Base
        # This is the message that will be displayed when RuboCop::Packaging
        # finds a gem name that `Bundler.require` cannot load.
        MSG = "`Bundler.require` cannot load this gem: add %<paths>s " \
              "that requires the gem's main file."

        def_node_search :gem_name, <<~PATTERN
          (send _ :name= $(str _))
        PATTERN

        def_node_search :require_paths, <<~PATTERN
          (send _ :require_paths= (array $(str _)+))
        PATTERN

        def_node_search :require_path, <<~PATTERN
          (send _ :require_path= $(str _))
        PATTERN

        def_node_search :extensions?, <<~PATTERN
          (send _ {:extensions= :extensions} ...)
        PATTERN

        # Processing of the AST happens here.
        def on_new_investigation
          return unless (node = checked_gem_name)

          candidates = entrypoints(node.value)
          return if candidates.any? { |path| exist?(path) }

          paths = candidates.map { |path| "`#{path}`" }.join(" or ")
          add_offense(node, message: format(MSG, paths: paths))
        end

        private

        def checked_gem_name
          ast = processed_source.ast
          return if ast.nil? || extensions?(ast)

          gem_name(ast).first
        end

        def exist?(path)
          File.exist?(File.join(File.dirname(processed_source.file_path), path))
        end

        def entrypoints(name)
          names = [name]
          names << name.tr("-", "/") if name.include?("-")

          lib_dirs.product(names).map { |dir, file| "#{dir}/#{file.delete_suffix(".rb")}.rb" }
        end

        def lib_dirs
          ast = processed_source.ast
          paths = require_paths(ast).first || require_path(ast).first(1)
          paths.empty? ? ["lib"] : paths.map(&:value)
        end
      end
    end
  end
end
