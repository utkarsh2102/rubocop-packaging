# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Packaging::RequireRelativeHardcodingLib, :config do
  let(:message) { RuboCop::Cop::Packaging::RequireRelativeHardcodingLib::MSG }

  let(:project_root) { RuboCop::ConfigLoader.project_root }

  context 'when `require_relative` call lies outside spec/' do
    let(:filename) { "#{project_root}/spec/foo_spec.rb" }
    let(:source) { 'require_relative "../lib/foo.rb"' }

    it 'registers an offense' do
      expect_offense(<<~RUBY, filename)
        #{source}
        #{'^' * source.length} #{message}
      RUBY
    end
  end

  context 'when `require_relative` call with nested path lies outside test/' do
    let(:filename) { "#{project_root}/test/rubocop/cop/bar_spec.rb" }
    let(:source) { 'require_relative "../../../lib/bar"' }

    it 'registers an offense' do
      expect_offense(<<~RUBY, filename)
        #{source}
        #{'^' * source.length} #{message}
      RUBY
    end
  end

  context 'when one `require_relative` call lies outside specs/' do
    let(:filename) { "#{project_root}/specs/baz_spec.rb" }
    let(:source) { <<~RUBY.chomp }
      require_relative 'spec_helper'
      require_relative '../lib/rubocop/baz'
    RUBY

    it 'registers an offense' do
      expect_offense(<<~RUBY, filename)
        #{source}
        #{'^' * 37} #{message}
      RUBY
    end
  end

  context 'when `require_relative` call with `unshift` lies outside tests/' do
    let(:filename) { "#{project_root}/tests/qux_spec.rb" }
    let(:source) { <<~RUBY.chomp }
      $:.unshift('../lib')
      require_relative "../lib/qux"
    RUBY

    it 'registers an offense' do
      expect_offense(<<~RUBY, filename)
        #{source}
        #{'^' * 29} #{message}
      RUBY
    end
  end

  context 'when `require_relative` call is made from inside lib/' do
    let(:filename) { "#{project_root}/lib/foo.rb" }
    let(:source) { 'require_relative "../lib/bar"' }

    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY, filename)
        #{source}
      RUBY
    end
  end

  context 'when `require_relative` call is made from the gemspec file' do
    let(:filename) { "#{project_root}/foo.gemspec" }
    let(:source) { 'require_relative "lib/foo/version"' }

    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY, filename)
        #{source}
      RUBY
    end
  end

  context 'when `require_relative` calls are made from inside lib/' do
    let(:filename) { "#{project_root}/lib/foo/bar.rb" }
    let(:source) { <<~RUBY.chomp }
      require_relative '../baz'
      require_relative 'foo/qux'
    RUBY

    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY, filename)
        #{source}
      RUBY
    end
  end

  context 'when the `require_relative` call to `lib` lies inside spec/' do
    let(:filename) { "#{project_root}/spec/rubocop/cop/foo_spec.rb" }
    let(:source) { 'require_relative "../lib/foo"' }

    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY, filename)
        #{source}
      RUBY
    end
  end

  context 'when the `require_relative` call lies inside tests/' do
    let(:filename) { "#{project_root}/tests/rubocop/cop/bar_spec.rb" }
    let(:source) { 'require_relative "../bar"' }

    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY, filename)
        #{source}
      RUBY
    end
  end

  context 'when the `require_relative` call lies inside test/' do
    let(:filename) { "#{project_root}/test/qux_spec.rb" }
    let(:source) { 'require_relative "spec/rubocop/qux.rb"' }

    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY, filename)
        #{source}
      RUBY
    end
  end
end
