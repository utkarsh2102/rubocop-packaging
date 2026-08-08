# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Packaging::RequireRelativeHardcodingLib, :config do
  let(:message) { RuboCop::Cop::Packaging::RequireRelativeHardcodingLib::MSG }

  let(:project_root) { RuboCop::ConfigFinder.project_root }

  context "when the inspected project is nested under RuboCop's project root" do
    let(:project_root) { "/workspace/family/gem" }
    let(:filename) { "#{project_root}/exe/tool" }
    let(:source) { "require_relative '../lib/foo'" }

    before do
      allow(RuboCop::ConfigFinder).to receive(:project_root).and_return("/workspace/family")
      allow_any_instance_of(described_class).to receive(:gemspec_root_for).with(filename).and_return(project_root)
    end

    it "uses the nested project's config root" do
      expect_offense(<<~RUBY, filename)
        #{source}
        #{"^" * source.length} #{message}
      RUBY

      expect_correction(<<~RUBY)
        require "foo"
      RUBY
    end
  end

  context "when `require_relative` call lies outside spec/" do
    let(:filename) { "#{project_root}/spec/foo_spec.rb" }
    let(:source) { "require_relative '../lib/foo.rb'" }

    it "registers an offense" do
      expect_offense(<<~RUBY, filename)
        #{source}
        #{"^" * source.length} #{message}
      RUBY

      expect_correction(<<~RUBY)
        require "foo.rb"
      RUBY
    end
  end

  context "when `require_relative` call with nested path lies outside test/" do
    let(:filename) { "#{project_root}/test/rubocop/cop/bar_spec.rb" }
    let(:source) { "require_relative '../../../lib/bar'" }

    it "registers an offense" do
      expect_offense(<<~RUBY, filename)
        #{source}
        #{"^" * source.length} #{message}
      RUBY

      expect_correction(<<~RUBY)
        require "bar"
      RUBY
    end
  end

  context "when one `require_relative` call lies outside specs/" do
    let(:filename) { "#{project_root}/specs/baz_spec.rb" }
    let(:source) { <<~RUBY.chomp }
      require_relative "spec_helper"
      require_relative "../lib/rubocop/baz"
    RUBY

    it "registers an offense" do
      expect_offense(<<~RUBY, filename)
        #{source}
        #{"^" * 37} #{message}
      RUBY

      expect_correction(<<~RUBY)
        require_relative "spec_helper"
        require "rubocop/baz"
      RUBY
    end
  end

  context "when `require_relative` call with `unshift` lies outside tests/" do
    let(:filename) { "#{project_root}/tests/qux_spec.rb" }
    let(:source) { <<~RUBY.chomp }
      $:.unshift("../lib")
      require_relative "../lib/qux"
    RUBY

    it "registers an offense" do
      expect_offense(<<~RUBY, filename)
        #{source}
        #{"^" * 29} #{message}
      RUBY

      expect_correction(<<~RUBY)
        $:.unshift("../lib")
        require "qux"
      RUBY
    end
  end

  context "when `require_relative` call is made from inside lib/" do
    let(:filename) { "#{project_root}/lib/foo.rb" }
    let(:source) { "require_relative '../lib/bar'" }

    it "does not register an offense" do
      expect_no_offenses(<<~RUBY, filename)
        #{source}
      RUBY
    end
  end

  context "when `require_relative` call is made from the gemspec file" do
    let(:filename) { "#{project_root}/foo.gemspec" }
    let(:source) { "require_relative 'lib/foo/version'" }

    it "does not register an offense" do
      expect_no_offenses(<<~RUBY, filename)
        #{source}
      RUBY
    end
  end

  context "when `require_relative` calls are made from inside lib/" do
    let(:filename) { "#{project_root}/lib/foo/bar.rb" }
    let(:source) { <<~RUBY.chomp }
      require_relative "../baz"
      require_relative "foo/qux"
    RUBY

    it "does not register an offense" do
      expect_no_offenses(<<~RUBY, filename)
        #{source}
      RUBY
    end
  end

  context "when the `require_relative` call to `lib` lies inside spec/" do
    let(:filename) { "#{project_root}/spec/rubocop/cop/foo_spec.rb" }
    let(:source) { "require_relative '../lib/foo'" }

    it "does not register an offense" do
      expect_no_offenses(<<~RUBY, filename)
        #{source}
      RUBY
    end
  end

  context "when the `require_relative` call lies inside tests/" do
    let(:filename) { "#{project_root}/tests/rubocop/cop/bar_spec.rb" }
    let(:source) { "require_relative '../bar'" }

    it "does not register an offense" do
      expect_no_offenses(<<~RUBY, filename)
        #{source}
      RUBY
    end
  end

  context "when the `require_relative` call lies inside test/" do
    let(:filename) { "#{project_root}/test/qux_spec.rb" }
    let(:source) { "require_relative 'spec/rubocop/qux.rb'" }

    it "does not register an offense" do
      expect_no_offenses(<<~RUBY, filename)
        #{source}
      RUBY
    end
  end
end
