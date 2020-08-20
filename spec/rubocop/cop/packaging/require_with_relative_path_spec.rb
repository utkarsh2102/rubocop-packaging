# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Packaging::RequireWithRelativePath do
  subject(:cop) { described_class.new(config) }
  let(:config) { RuboCop::Config.new }

  let(:message) { RuboCop::Cop::Packaging::RequireWithRelativePath::MSG }

  let(:project_root) { RuboCop::ConfigLoader.project_root }

  let(:project_root) { RuboCop::ConfigLoader.project_root }

  context "when `require_relative` call lies outside spec/" do
    let(:filename) { "#{project_root}/spec/foo_spec.rb" }
    let(:source) { "require '../lib/foo.rb'" }

    it "registers an offense" do
      expect_offense(<<~RUBY, filename)
        #{source}
        #{"^" * source.length} #{message}
      RUBY
    end
  end

  context "when `require_relative` calls are made from inside lib/" do
    let(:filename) { "#{project_root}/spec/foo/bar.rb" }
    let(:source) { <<~RUBY.chomp }
      $:.unshift('../../lib')
      require '../../lib/foo/bar'
    RUBY

    it "registers an offense" do
      expect_offense(<<~RUBY, filename)
        #{source}
        #{"^" * 27} #{message}
      RUBY
    end
  end

  context "when `require_relative` call is made from inside lib/" do
    let(:filename) { "#{project_root}/spec/foo.rb" }
    let(:source) { "require File.expand_path('../lib/foo', __FILE__)" }

    it "registers an offense when using `require` with `File.expand_path` and `__FILE__`" do
      expect_offense(<<~RUBY, filename)
        #{source}
        #{"^" * source.length} #{message}
      RUBY
    end
  end

  context "when `require_relative` call is made from inside lib/" do
    let(:filename) { "#{project_root}/spec/foo/bar.rb" }
    let(:source) { "require File.expand_path('../lib/foo/bar', __dir__)" }

    it "registers an offense when using `require` with `File.expand_path` and `__dir__`" do
      expect_offense(<<~RUBY, filename)
        #{source}
        #{"^" * source.length} #{message}
      RUBY
    end
  end

  context "when `require_relative` call is made from inside lib/" do
    let(:filename) { "#{project_root}/spec/baz/qux_spec.rb" }
    let(:source) { "require File.dirname(__FILE__) + '/../lib/baz/qux'" }

    it "registers an offense when using `require` with `File.dirname` and `__FILE__" do
      expect_offense(<<~RUBY, filename)
        #{source}
        #{"^" * source.length} #{message}
      RUBY
    end
  end

  context "when `require_relative` call is made from inside lib/" do
    let(:filename) { "#{project_root}/spec/foo.rb" }
    let(:source) { "require File.dirname(__dir__) + '/../lib/foo'" }

    it "registers an offense when using `require` with `File.dirname` and `__dir__" do
      expect_offense(<<~RUBY, filename)
        #{source}
        #{"^" * source.length} #{message}
      RUBY
    end
  end

  context "when the `require_relative` call lies inside tests/" do
    let(:filename) { "#{project_root}/spec/bar_spec.rb" }
    let(:source) { "require 'bar'" }

    it "does not register an offense" do
      expect_no_offenses(<<~RUBY, filename)
        #{source}
      RUBY
    end
  end

  context "when the `require_relative` call lies inside tests/" do
    let(:filename) { "#{project_root}/spec/bar/foo_spec.rb" }
    let(:source) { "require '../foo'" }

    it "does not register an offense" do
      expect_no_offenses(<<~RUBY, filename)
        #{source}
      RUBY
    end
  end
end
