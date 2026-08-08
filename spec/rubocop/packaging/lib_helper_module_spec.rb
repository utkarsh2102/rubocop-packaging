# frozen_string_literal: true

RSpec.describe RuboCop::Packaging::LibHelperModule do
  let(:helper) { Object.new.extend(described_class) }
  let(:file_path) { "/workspace/family/gem/exe/tool" }
  let(:project_root) { "/workspace/family" }
  let(:config_file) { "/workspace/family/gem/.rubocop.yml" }

  before do
    helper.instance_variable_set(:@file_path, file_path)
    allow(RuboCop::ConfigFinder).to receive(:project_root).and_return(project_root)
    allow(RuboCop::ConfigLoader).to receive(:configuration_file_for).with(file_path)
                                                                    .and_return(config_file)
  end

  it "uses the directory containing a nested project .rubocop.yml" do
    expect(helper.root_dir).to eq("/workspace/family/gem")
  end

  it "uses the project root for a project .config/rubocop/config.yml" do
    xdg_config_file = "/workspace/family/gem/.config/rubocop/config.yml"
    allow(RuboCop::ConfigLoader).to receive(:configuration_file_for).with(file_path).and_return(xdg_config_file)

    expect(helper.root_dir).to eq("/workspace/family/gem")
  end

  it "falls back to RuboCop's project root for a user config" do
    allow(RuboCop::ConfigLoader).to receive(:configuration_file_for).with(file_path)
                                                                    .and_return("/home/user/.rubocop.yml")

    expect(helper.root_dir).to eq(project_root)
  end

  it "falls back to RuboCop's project root for the default config" do
    allow(RuboCop::ConfigLoader).to receive(:configuration_file_for).with(file_path)
                                                                    .and_return(RuboCop::ConfigLoader::DEFAULT_FILE)

    expect(helper.root_dir).to eq(project_root)
  end

  it "does not treat the default config directory as a project root" do
    allow(RuboCop::ConfigFinder).to receive(:project_root).and_return(nil)
    allow(RuboCop::ConfigLoader).to receive(:configuration_file_for).with(file_path).and_return(
      RuboCop::ConfigLoader::DEFAULT_FILE
    )

    expect(helper.root_dir).to be_nil
  end

  it "uses a local config directory when RuboCop cannot infer a project root" do
    allow(RuboCop::ConfigFinder).to receive(:project_root).and_return(nil)

    expect(helper.root_dir).to eq("/workspace/family/gem")
  end

  it "resolves the config root once per inspected file" do
    expect(RuboCop::ConfigLoader).to receive(:configuration_file_for).with(file_path).once
                                                                     .and_return(config_file)

    2.times { helper.root_dir }
  end

  it "refreshes the cached root when the inspected file changes" do
    expect(helper.root_dir).to eq("/workspace/family/gem")

    other_file = "/workspace/family/other/exe/tool"
    helper.instance_variable_set(:@file_path, other_file)
    allow(RuboCop::ConfigLoader).to receive(:configuration_file_for).with(other_file)
                                                                    .and_return("/workspace/family/other/.rubocop.yml")

    expect(helper.root_dir).to eq("/workspace/family/other")
  end
end
