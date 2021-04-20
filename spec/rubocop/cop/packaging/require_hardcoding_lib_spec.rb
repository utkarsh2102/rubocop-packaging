# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Packaging::RequireHardcodingLib, :config do
  let(:message) { RuboCop::Cop::Packaging::RequireHardcodingLib::MSG }

  let(:project_root) { RuboCop::ConfigLoader.project_root }

  context "when use of File#expand_path method with __FILE__" do
    let(:filename) { "#{project_root}/spec/foo.rb" }
    let(:source) { "File.expand_path('../../lib/foo', __FILE__)" }

    it "registers an offense" do
      expect_offense(<<~RUBY, filename)
        #{source}
        #{"^" * source.length} #{message}
      RUBY

      expect_correction(<<~RUBY)
        require "foo"
      RUBY
    end
  end

  context "when use of File#expand_path method with __dir__" do
    let(:filename) { "#{project_root}/test/foo/bar/qux_spec.rb" }
    let(:source) { "File.expand_path('../../../lib/foo/bar/baz/qux', __dir__)" }

    it "registers an offense" do
      expect_offense(<<~RUBY, filename)
        #{source}
        #{"^" * source.length} #{message}
      RUBY

      expect_correction(<<~RUBY)
        require "foo/bar/baz/qux"
      RUBY
    end
  end

  context "when use of File#dirname method with __FILE__" do
    let(:filename) { "#{project_root}/specs/baz/qux_spec.rb" }
    let(:source) { "File.dirname(__FILE__) + '/../../lib/baz/qux'" }

    it "registers an offense" do
      expect_offense(<<~RUBY, filename)
        #{source}
        #{"^" * source.length} #{message}
      RUBY

      expect_correction(<<~RUBY)
        require "baz/qux"
      RUBY
    end
  end

  context "when use of File#dirname method with __FILE__ with interpolation" do
    let(:filename) { "#{project_root}/specs/baz/qux_spec.rb" }
    let(:source) { '"#{File.dirname(__FILE__)}/../../lib/baz/qux"' } # rubocop:disable Lint/InterpolationCheck

    it "registers an offense" do
      expect_offense(<<~RUBY, filename)
        #{source}
        #{"^" * source.length} #{message}
      RUBY

      expect_correction(<<~RUBY)
        require "baz/qux"
      RUBY
    end
  end

  context "when use of File#dirname method with __dir__" do
    let(:filename) { "#{project_root}/spec/foo.rb" }
    let(:source) { "File.dirname(__dir__) + '/../lib/foo'" }

    it "registers an offense" do
      expect_offense(<<~RUBY, filename)
        #{source}
        #{"^" * source.length} #{message}
      RUBY

      expect_correction(<<~RUBY)
        require "foo"
      RUBY
    end
  end

  context "when use of File#dirname method with __dir__ with interpolation" do
    let(:filename) { "#{project_root}/spec/foo.rb" }
    let(:source) { '"#{File.dirname(__dir__)}/../lib/foo"' } # rubocop:disable Lint/InterpolationCheck

    it "registers an offense" do
      expect_offense(<<~RUBY, filename)
        #{source}
        #{"^" * source.length} #{message}
      RUBY

      expect_correction(<<~RUBY)
        require "foo"
      RUBY
    end
  end

  context "when use of File#expand_path method with __FILE__ but lies inside lib/" do
    let(:filename) { "#{project_root}/lib/foo/bar.rb" }
    let(:source) { "File.expand_path('../../foo', __FILE__)" }

    it "does not register an offense" do
      expect_no_offenses(<<~RUBY, filename)
        #{source}
      RUBY
    end
  end

  context "when use of File#expand_path method with __FILE__ and is made from the gemspec file" do
    let(:filename) { "#{project_root}/bar.gemspec" }
    let(:source) { "File.expand_path('../lib/foo/version', __FILE__)" }

    it "does not register an offense" do
      expect_no_offenses(<<~RUBY, filename)
        #{source}
      RUBY
    end
  end

  context "when use of File#expand_path method with __dir__ but lies inside lib/" do
    let(:filename) { "#{project_root}/lib/foo/bar/baz/qux.rb" }
    let(:source) { "File.expand_path('../../foo', __dir__)" }

    it "does not register an offense" do
      expect_no_offenses(<<~RUBY, filename)
        #{source}
      RUBY
    end
  end

  context "when use of File#expand_path method with __dir__ and is made from the gemspec file" do
    let(:filename) { "#{project_root}/qux.gemspec" }
    let(:source) { "File.expand_path('lib/qux/version', __dir__)" }

    it "does not register an offense" do
      expect_no_offenses(<<~RUBY, filename)
        #{source}
      RUBY
    end
  end

  context "when use of File#dirname with __FILE__ but lies inside tests/" do
    let(:filename) { "#{project_root}/tests/foo/bar_spec.rb" }
    let(:source) { "File.dirname(__FILE__) + '/../lib/bar'" }

    it "does not register an offense" do
      expect_no_offenses(<<~RUBY, filename)
        #{source}
      RUBY
    end
  end

  context "when use of File#dirname with __FILE__ but lies inside lib/" do
    let(:filename) { "#{project_root}/lib/baz/qux.rb" }
    let(:source) { "File.dirname(__FILE__) + '/../baz'" }

    it "does not register an offense" do
      expect_no_offenses(<<~RUBY, filename)
        #{source}
      RUBY
    end
  end

  context "when use of File#dirname with __FILE__ and is made from the gemspec file" do
    let(:filename) { "#{project_root}/bar.gemspec" }
    let(:source) { "File.dirname(__FILE__) + '/../lib/bar/version'" }

    it "does not register an offense" do
      expect_no_offenses(<<~RUBY, filename)
        #{source}
      RUBY
    end
  end

  context "when use of File#dirname with __dir__ but lies inside spec/" do
    let(:filename) { "#{project_root}/spec/foo/bar_spec.rb" }
    let(:source) { "File.dirname(__dir__) + '/../lib/bar'" }

    it "does not register an offense" do
      expect_no_offenses(<<~RUBY, filename)
        #{source}
      RUBY
    end
  end

  context "when use of File#dirname with __dir__ but lies inside lib/" do
    let(:filename) { "#{project_root}/lib/baz/qux.rb" }
    let(:source) { "File.dirname(__dir__) + '/../baz'" }

    it "does not register an offense" do
      expect_no_offenses(<<~RUBY, filename)
        #{source}
      RUBY
    end
  end

  context "when use of File#dirname with __dir__ and is made from the gemspec file" do
    let(:filename) { "#{project_root}/baz.gemspec" }
    let(:source) { "File.dirname(__dir__) + '/lib/baz/version'" }

    it "does not register an offense" do
      expect_no_offenses(<<~RUBY, filename)
        #{source}
      RUBY
    end
  end
end
