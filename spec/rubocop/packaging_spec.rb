# frozen_string_literal: true

RSpec.describe RuboCop::Packaging do
  describe 'general structure' do
    it 'has a version number' do
      expect(RuboCop::Packaging::VERSION).not_to be nil
    end
  end

  describe 'default configuration file' do
    subject(:config) { RuboCop::ConfigLoader.load_file('config/default.yml') }

    let(:registry) { RuboCop::Cop::Cop.registry }
    let(:cop_names) do
      registry.with_department(:Packaging).cops.map(&:cop_name)
    end

    let(:configuration_keys) { config.keys }

    it 'has a nicely formatted description for all cops' do
      cop_names.each do |name|
        description = config[name]['Description']
        expect(description.nil?).to be(false)
        expect(description).not_to include("\n")
      end
    end

    it 'requires a nicely formatted `VersionAdded` metadata for all cops' do
      cop_names.each do |name|
        version = config[name]['VersionAdded']
        expect(version.nil?).to(be(false),
                                "VersionAdded is required for #{name}.")
        expect(version).to(match(/\A\d+\.\d+\z/),
                           "#{version} should be format ('X.Y') for #{name}.")
      end
    end

    it 'has a period at EOL of description' do
      cop_names.each do |name|
        description = config[name]['Description']

        expect(description).to match(/\.\z/)
      end
    end

    it 'sorts configuration keys alphabetically' do
      expected = configuration_keys.sort
      configuration_keys.each_with_index do |key, idx|
        expect(key).to eq expected[idx]
      end
    end

    it 'has a SupportedStyles for all EnforcedStyle ' \
      'and EnforcedStyle is valid' do
      errors = []
      cop_names.each do |name|
        enforced_styles = config[name]
                          .select { |key, _| key.start_with?('Enforced') }
        enforced_styles.each do |style_name, style|
          supported_key = RuboCop::Cop::Util.to_supported_styles(style_name)
          valid = config[name][supported_key]
          unless valid
            errors.push("#{supported_key} is missing for #{name}")
            next
          end
          next if valid.include?(style)

          errors.push("invalid #{style_name} '#{style}' for #{name} found")
        end
      end

      raise errors.join("\n") unless errors.empty?
    end

    it 'does not have nay duplication' do
      fname = File.expand_path('../../config/default.yml', __dir__)
      content = File.read(fname)
      RuboCop::YAMLDuplicationChecker.check(content, fname) do |key1, key2|
        raise "#{fname} has duplication of #{key1.value} " \
              "on line #{key1.start_line} and line #{key2.start_line}"
      end
    end
  end
end
