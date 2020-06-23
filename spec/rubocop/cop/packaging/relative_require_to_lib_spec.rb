# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Packaging::RelativeRequireToLib do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  let(:message) { RuboCop::Cop::Packaging::RelativeRequireToLib::MSG }

  it 'registers an offense when using `require` with relative path to lib/whatever' do
    expect_offense(<<~RUBY)
      require '../lib/whatever'
      ^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
    RUBY
  end

  it 'registers an offense when using `require` with relative path to lib/whatever/file' do
    expect_offense(<<~RUBY)
      require '../lib/whatever/file'
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
    RUBY
  end

  it 'registers an offense when using `require` with relative path to lib/*' do
    expect_offense(<<~RUBY)
      require '../lib/*'
      ^^^^^^^^^^^^^^^^^^ #{message}
    RUBY
  end

  it 'does not register an offense when using `require` with absoulte path to lib' do
    expect_no_offenses(<<~RUBY)
      require 'whatever/file'
    RUBY
  end

  it 'does not register an offense when using `require` with relative path to something else' do
    expect_no_offenses(<<~RUBY)
      require '../spec/whatever/file'
    RUBY
  end
end
