# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Packaging::GemspecGit, :config do
  let(:message) { RuboCop::Cop::Packaging::GemspecGit::MSG }

  it "registers an offense when using `git` for :files=" do
    expect_offense(<<~RUBY)
      Gem::Specification.new do |spec|
        spec.files = `git ls-files`.split("\\n")
                     ^^^^^^^^^^^^^^ #{message}
      end
    RUBY
  end

  it "registers an offense when using `git ls-files filename` for :files=" do
    expect_offense(<<~RUBY)
      Gem::Specification.new do |s|
        s.files         = `git ls-files LICENSE docs lib`.split("\\n")
                          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
      end
    RUBY
  end

  it "registers an offense when using `git` for :files= but differently" do
    expect_offense(<<~RUBY)
      Gem::Specification.new do |spec|
        spec.files = `git ls-files`.split + %w(
                     ^^^^^^^^^^^^^^ #{message}
                        lib/parser/lexer.rb
                        lib/parser/ruby18.rb
                        lib/parser/ruby19.rb
                        lib/parser/ruby20.rb
                        lib/parser/ruby21.rb
                        lib/parser/ruby22.rb
                        lib/parser/ruby23.rb
                        lib/parser/ruby24.rb
                        lib/parser/ruby25.rb
                        lib/parser/ruby26.rb
                        lib/parser/ruby27.rb
                        lib/parser/ruby28.rb
                        lib/parser/macruby.rb
                        lib/parser/rubymotion.rb
                     )
      end
    RUBY
  end

  it "registers an offense when using `git` for :files= with more stuff" do
    expect_offense(<<~RUBY)
      Gem::Specification.new do |spec|
        spec.files = Dir.chdir(File.expand_path("..", __FILE__)) do
          `git ls-files -z`.split("\\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
          ^^^^^^^^^^^^^^^^^ #{message}
        end
      end
    RUBY
  end

  it "registers an offense when using `git` for :executables=" do
    expect_offense(<<~RUBY)
      Gem::Specification.new do |spec|
        spec.executables = `git ls-files`.split("\\n")
                           ^^^^^^^^^^^^^^ #{message}
      end
    RUBY
  end

  it "does not register an offense when the file just has comments" do
    expect_no_offenses(<<~RUBY)
      # Dummy comments.
      # Blank file.
      # Copyright 2020, Utkarsh Gupta <utkarsh@debian.org>
      # This is an important test.
    RUBY
  end

  it "does not register an offense when the file is empty/blank" do
    expect_no_offenses("")
  end

  it "does not register an offense not in a specification" do
    expect_no_offenses(<<~RUBY)
      spec.files = `git ls-files`
    RUBY
  end

  it "does not register an offense when not using `git` for :files=" do
    expect_no_offenses(<<~RUBY)
      Gem::Specification.new do |spec|
        spec.files = Dir["docs/**/*", "lib/**/*", "LICENSE"].reject { |f| File.directory?(f) }.sort
      end
    RUBY
  end
end
