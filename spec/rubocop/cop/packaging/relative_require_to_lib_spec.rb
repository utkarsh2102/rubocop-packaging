# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Packaging::RelativeRequireToLib do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  let(:message) { RuboCop::Cop::Packaging::RelativeRequireToLib::MSG }

  let(:processed_source) { parse_source(source) }

  before do
    allow(processed_source.buffer)
      .to receive(:name).and_return(filename)
    _investigate(cop, processed_source)
  end

  context 'when `require_relative` call lies outside spec/' do
    let(:filename) { '/some/spec/foo_spec.rb' }
    let(:source) { 'require_relative "../lib/foo.rb"' }

    it 'registers an offense' do
      expect_offense(<<~RUBY)
        #{source}
        #{'^' * source.length} #{message}
      RUBY
    end
  end

  context 'when `require_relative` call with nested path lies outside test/' do
    let(:filename) { '/some/test/rubocop/cop/bar_spec.rb' }
    let(:source) { 'require_relative "../../../lib/bar"' }

    it 'registers an offense' do
      expect_offense(<<~RUBY)
        #{source}
        #{'^' * source.length} #{message}
      RUBY
    end
  end

  context 'when one `require_relative` call lies outside specs/' do
    let(:filename) { '/some/specs/baz_spec.rb' }
    let(:source) { <<~RUBY.chomp }
      require_relative 'spec_helper'
      require_relative '../lib/rubocop/baz'
    RUBY

    it 'registers an offense' do
      expect_offense(<<~RUBY)
        #{source}
        #{'^' * 37} #{message}
      RUBY
    end
  end

  context 'when `require_relative` call with `unshift` lies outside tests/' do
    let(:filename) { '/some/tests/qux_spec.rb' }
    let(:source) { <<~RUBY.chomp }
      $:.unshift('../lib')
      require_relative "../lib/qux"
    RUBY

    it 'registers an offense' do
      expect_offense(<<~RUBY)
        #{source}
        #{'^' * 29} #{message}
      RUBY
    end
  end

  context 'when the `require_relative` call to `lib` lies inside spec/' do
    let(:filename) { '/some/spec/rubocop/cop/foo_spec.rb' }
    let(:source) { 'require_relative "../lib/foo"' }

    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        #{source}
      RUBY
    end
  end

  context 'when the `require_relative` call lies inside tests/' do
    let(:filename) { '/some/tests/rubocop/cop/bar_spec.rb' }
    let(:source) { 'require_relative "../bar"' }

    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        #{source}
      RUBY
    end
  end

  context 'when the `require_relative` call lies inside test/' do
    let(:filename) { '/some/test/qux_spec.rb' }
    let(:source) { 'require_relative "spec/rubocop/qux.rb"' }

    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        #{source}
      RUBY
    end
  end
end
