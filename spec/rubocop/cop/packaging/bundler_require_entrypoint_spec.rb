# frozen_string_literal: true

require "fileutils"
require "tmpdir"

RSpec.describe RuboCop::Cop::Packaging::BundlerRequireEntrypoint, :config do
  around do |example|
    Dir.mktmpdir do |dir|
      @gem_dir = dir
      example.run
    end
  end

  let(:gemspec) { File.join(@gem_dir, "foo-bar.gemspec") }

  def create_file(path)
    full_path = File.join(@gem_dir, path)
    FileUtils.mkdir_p(File.dirname(full_path))
    File.write(full_path, "")
  end

  context "when the gem name has a dash" do
    it "registers an offense when neither entrypoint exists" do
      create_file("lib/foo_bar.rb")

      expect_offense(<<~RUBY, gemspec)
        Gem::Specification.new do |spec|
          spec.name = "foo-bar"
                      ^^^^^^^^^ `Bundler.require` cannot load this gem: add `lib/foo-bar.rb` or `lib/foo/bar.rb` that requires the gem's main file.
        end
      RUBY
    end

    it "does not register an offense when the namespaced entrypoint exists" do
      create_file("lib/foo/bar.rb")

      expect_no_offenses(<<~RUBY, gemspec)
        Gem::Specification.new do |spec|
          spec.name = "foo-bar"
        end
      RUBY
    end

    it "does not register an offense when the dashed entrypoint exists" do
      create_file("lib/foo-bar.rb")

      expect_no_offenses(<<~RUBY, gemspec)
        Gem::Specification.new do |spec|
          spec.name = "foo-bar"
        end
      RUBY
    end
  end

  context "when the gem name has no dash" do
    let(:gemspec) { File.join(@gem_dir, "foo_bar.gemspec") }

    it "registers an offense when the entrypoint does not exist" do
      create_file("lib/foo/bar.rb")

      expect_offense(<<~RUBY, gemspec)
        Gem::Specification.new do |spec|
          spec.name = "foo_bar"
                      ^^^^^^^^^ `Bundler.require` cannot load this gem: add `lib/foo_bar.rb` that requires the gem's main file.
        end
      RUBY
    end

    it "does not register an offense when the entrypoint exists" do
      create_file("lib/foo_bar.rb")

      expect_no_offenses(<<~RUBY, gemspec)
        Gem::Specification.new do |spec|
          spec.name = "foo_bar"
        end
      RUBY
    end
  end

  context "with custom require paths" do
    it "looks in every directory from `require_paths`" do
      create_file("ext/foo/bar.rb")

      expect_no_offenses(<<~RUBY, gemspec)
        Gem::Specification.new do |spec|
          spec.name = "foo-bar"
          spec.require_paths = ["lib", "ext"]
        end
      RUBY
    end

    it "lists the entrypoints for every directory from `require_paths`" do
      expect_offense(<<~RUBY, gemspec)
        Gem::Specification.new do |spec|
          spec.name = "foo-bar"
                      ^^^^^^^^^ `Bundler.require` cannot load this gem: add `lib/foo-bar.rb` or `lib/foo/bar.rb` or `ext/foo-bar.rb` or `ext/foo/bar.rb` that requires the gem's main file.
          spec.require_paths = %w[lib ext]
        end
      RUBY
    end

    it "looks in the directory from `require_path`" do
      create_file("src/foo/bar.rb")

      expect_no_offenses(<<~RUBY, gemspec)
        Gem::Specification.new do |spec|
          spec.name = "foo-bar"
          spec.require_path = "src"
        end
      RUBY
    end

    it "does not look in `lib` when `require_paths` leaves it out" do
      create_file("lib/foo/bar.rb")

      expect_offense(<<~RUBY, gemspec)
        Gem::Specification.new do |spec|
          spec.name = "foo-bar"
                      ^^^^^^^^^ `Bundler.require` cannot load this gem: add `src/foo-bar.rb` or `src/foo/bar.rb` that requires the gem's main file.
          spec.require_paths = ["src"]
        end
      RUBY
    end
  end

  it "does not register an offense for a gem with native extensions" do
    expect_no_offenses(<<~RUBY, gemspec)
      Gem::Specification.new do |spec|
        spec.name = "foo-bar"
        spec.extensions = ["ext/foo_bar/extconf.rb"]
      end
    RUBY
  end

  it "accepts an entrypoint for a gem name ending in `.rb`" do
    create_file("lib/foo.rb")

    expect_no_offenses(<<~RUBY, File.join(@gem_dir, "foo.rb.gemspec"))
      Gem::Specification.new do |spec|
        spec.name = "foo.rb"
      end
    RUBY
  end

  it "does not register an offense when the gem name is not a string literal" do
    expect_no_offenses(<<~RUBY, gemspec)
      Gem::Specification.new do |spec|
        spec.name = Foo::Bar::NAME
      end
    RUBY
  end

  it "does not register an offense for a gemspec without a name" do
    expect_no_offenses(<<~RUBY, gemspec)
      Gem::Specification.new do |spec|
        spec.version = "1.0.0"
      end
    RUBY
  end
end
