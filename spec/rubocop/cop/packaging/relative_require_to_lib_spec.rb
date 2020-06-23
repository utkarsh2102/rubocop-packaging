# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Packaging::RelativeRequireToLib do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  let(:message) { RuboCop::Cop::Packaging::RelativeRequireToLib::MSG }

  let(:path) { './../..' }

  it 'registers an offense when using `require` with relative path to rubocop' do
    expect_offense(<<~RUBY)
      require '../lib/rubocop'
      ^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
    RUBY
  end

  it 'registers an offense when using `require_relative` with relative path to rubocop' do
    expect_offense(<<~RUBY)
      require_relative '../lib/rubocop'
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
    RUBY
  end

  it 'registers an offense when using `require` with relative path twice' do
    expect_offense(<<~RUBY)
      require '../lib/rubocop'
      ^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
      require '../lib/rubocop/file'
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
    RUBY
  end

  it 'registers an offense when using `require_relative` with relative path twice' do
    expect_offense(<<~RUBY)
      require_relative '../lib/rubocop'
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
      require_relative '../lib/rubocop/file'
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
    RUBY
  end

  it 'registers an offense when using `require` with (more) relative path to rubocop' do
    expect_offense(<<~RUBY)
      require '../../lib/rubocop'
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
    RUBY
  end

  it 'registers an offense when using `require_relative` with (more) relative path to rubocop' do
    expect_offense(<<~RUBY)
      require_relative '../../lib/rubocop'
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
    RUBY
  end

  it 'registers an offense when using `unshift` and `require` with relative path to file.rb' do
    expect_offense(<<~RUBY)
      $:.unshift('../lib')
      require '../lib/file.rb'
      ^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
    RUBY
  end

  it 'registers an offense when using `unshift` and `require_relative` with relative path to file.rb' do
    expect_offense(<<~RUBY)
      $:.unshift('../lib')
      require_relative '../lib/file.rb'
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
    RUBY
  end

  it 'registers an offense when using `require` with a variable and a relative path' do
    expect_offense(<<~RUBY)
      require "#{path}/../lib/rubocop"
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
    RUBY
  end

  it 'registers an offense when using `require_relative` with a variable and a relative path' do
    expect_offense(<<~RUBY)
      require_relative "#{path}/../lib/rubocop"
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
    RUBY
  end

  it 'registers an offense when using `require` with `File.expand_path` and `__FILE__`' do
    expect_offense(<<~RUBY)
      require File.expand_path('../lib/rubocop', __FILE__)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
    RUBY
  end

  it 'registers an offense when using `require` with `File.expand_path` and `__dir__`' do
    expect_offense(<<~RUBY)
      require File.expand_path('../lib/rubocop', __dir__)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
    RUBY
  end

  it 'registers an offense when using `require` with `File.dirname` and `__FILE__`' do
    expect_offense(<<~RUBY)
      require File.dirname(__FILE__) + '/../lib/rubocop'
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
    RUBY
  end

  it 'registers an offense when using `require` with `File.dirname` and `__dir__`' do
    expect_offense(<<~RUBY)
      require File.dirname(__dir__) + '/../lib/rubocop'
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
    RUBY
  end

  it 'does not register an offense when using `require` with absoulte path to file' do
    expect_no_offenses(<<~RUBY)
      require 'file'
    RUBY
  end

  it 'does not register an offense when using `require_relative` with absoulte path to file' do
    expect_no_offenses(<<~RUBY)
      require_relative 'file'
    RUBY
  end

  it 'does not register an offense when using `require` with absolute path to spec dir' do
    expect_no_offenses(<<~RUBY)
      require 'spec/rubocop/file'
    RUBY
  end

  it 'does not register an offense when using `require_relative` with absolute path to spec dir' do
    expect_no_offenses(<<~RUBY)
      require_relative 'spec/rubocop/file'
    RUBY
  end

  it 'does not register an offense when using `require` with relative path to !lib' do
    expect_no_offenses(<<~RUBY)
      require '../spec/rubocop/file'
    RUBY
  end

  it 'does not register an offense when using `require_relative` with relative path to !lib' do
    expect_no_offenses(<<~RUBY)
      require_relative '../spec/rubocop/file'
    RUBY
  end
end
