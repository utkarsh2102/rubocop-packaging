# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Packaging::BundlerSetupInTests, :config do
  let(:message) { RuboCop::Cop::Packaging::BundlerSetupInTests::MSG }

  let(:project_root) { RuboCop::ConfigLoader.project_root }

  context "when `require bundler/setup` is used in specs/" do
    let(:filename) { "#{project_root}/spec/spec_helper.rb" }
    let(:source) { "require 'bundler/setup'" }

    it "registers an offense" do
      expect_offense(<<~RUBY, filename)
        #{source}
        #{"^" * source.length} #{message}
      RUBY

      expect_correction("")
    end
  end

  context "when `require bundler/setup` is used in test/foo" do
    let(:filename) { "#{project_root}/tests/foo/test_bar.rb" }
    let(:source) { "require 'bundler/setup'" }

    it "registers an offense" do
      expect_offense(<<~RUBY, filename)
        #{source}
        #{"^" * source.length} #{message}
      RUBY

      expect_correction("")
    end
  end

  context "when `require bundler/setup` is used in a Rakefile" do
    let(:filename) { "#{project_root}/Rakefile" }
    let(:source) { "require 'bundler/setup'" }

    it "does not register an offense" do
      expect_no_offenses(<<~RUBY, filename)
        #{source}
      RUBY
    end
  end

  context "when `require bundler/setup` is used in bin/console" do
    let(:filename) { "#{project_root}/bin/console" }
    let(:source) { "require 'bundler/setup'" }

    it "does not register an offense" do
      expect_no_offenses(<<~RUBY, filename)
        #{source}
      RUBY
    end
  end
end
