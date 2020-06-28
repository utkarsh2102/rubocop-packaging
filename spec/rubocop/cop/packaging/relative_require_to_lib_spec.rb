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

  context 'when `require_relative` call with nested path lies outside spec/' do
    let(:filename) { '/some/spec/rubocop/cop/foo_spec.rb' }
    let(:source) { 'require_relative "../../../lib/foo.rb"' }

    it 'registers an offense' do
      expect_offense(<<~RUBY)
        #{source}
        #{'^' * source.length} #{message}
      RUBY
    end
  end

  context 'when one `require_relative` call lies outside spec/' do
    let(:filename) { '/some/spec/foo_spec.rb' }
    let(:source) { <<~RUBY.chomp }
      require_relative 'spec_helper'
      require_relative '../lib/rubocop/file'
    RUBY

    it 'registers an offense' do
      expect_offense(<<~RUBY)
        #{source}
        #{'^' * 38} #{message}
      RUBY
    end
  end

  context 'when `require_relative` call with `unshift` lies outside spec/' do
    let(:filename) { '/some/spec/foo_spec.rb' }
    let(:source) { <<~RUBY.chomp }
      $:.unshift('../lib')
      require_relative "../lib/file"
    RUBY

    it 'registers an offense' do
      expect_offense(<<~RUBY)
        #{source}
        #{'^' * 30} #{message}
      RUBY
    end
  end

  context 'when the `require_relative` call to `lib` lies inside spec/' do
    let(:filename) { '/some/specs/rubocop/cop/foo_spec.rb' }
    let(:source) { 'require_relative "../lib/foo.rb"' }

    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        #{source}
      RUBY
    end
  end

  context 'when the `require_relative` call lies inside spec/' do
    let(:filename) { '/some/specs/rubocop/cop/foo_spec.rb' }
    let(:source) { 'require_relative "../foo.rb"' }

    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        #{source}
      RUBY
    end
  end

  context 'when the `require_relative` call lies inside spec/' do
    let(:filename) { '/some/specs/foo_spec.rb' }
    let(:source) { 'require_relative "spec/rubocop/bar"' }

    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        #{source}
      RUBY
    end
  end
end
