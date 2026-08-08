# frozen_string_literal: true

RSpec.describe RuboCop::Packaging::LibHelperModule do
  let(:helper) { Object.new.extend(described_class) }
  let(:file_path) { "/workspace/family/gem/exe/tool" }
  let(:project_root) { "/workspace/family" }
  before do
    helper.instance_variable_set(:@file_path, file_path)
    allow(RuboCop::ConfigFinder).to receive(:project_root).and_return(project_root)
    allow(helper).to receive(:gemspec_root_for).and_return(nil)
  end

  it "uses the nearest gemspec root instead of RuboCop's outer workspace root" do
    allow(helper).to receive(:gemspec_root_for).with(file_path).and_return("/workspace/family/gem")

    expect(helper.root_dir).to eq("/workspace/family/gem")
  end

  it "finds a real gemspec while walking upward from the inspected file" do
    package_root = File.expand_path("../../..", __dir__)
    helper.instance_variable_set(:@file_path, File.join(package_root, "lib/foo.rb"))
    allow(helper).to receive(:gemspec_root_for).and_call_original

    expect(helper.root_dir).to eq(package_root)
  end

  it "falls back to RuboCop's project root when no gemspec is found" do
    expect(helper.root_dir).to eq(project_root)
  end

  it "returns nil when neither a gemspec nor a RuboCop project root is found" do
    allow(RuboCop::ConfigFinder).to receive(:project_root).and_return(nil)

    expect(helper.root_dir).to be_nil
  end

  it "resolves the config root once per inspected file" do
    expect(helper).to receive(:gemspec_root_for).with(file_path).once.and_return(nil)

    2.times { helper.root_dir }
  end

  it "refreshes the cached root when the inspected file changes" do
    allow(helper).to receive(:gemspec_root_for).with(file_path).and_return("/workspace/family/gem")
    expect(helper.root_dir).to eq("/workspace/family/gem")

    other_file = "/workspace/family/other/exe/tool"
    helper.instance_variable_set(:@file_path, other_file)
    allow(helper).to receive(:gemspec_root_for).with(other_file).and_return("/workspace/family/other")

    expect(helper.root_dir).to eq("/workspace/family/other")
  end
end
