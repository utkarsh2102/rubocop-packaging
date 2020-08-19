# frozen_string_literal: true

require "bump"

namespace :cut_release do
  %w[major minor patch pre].each do |release_type|
    desc "Cut a new #{release_type} release, create release notes " \
         "and update documents."
    task release_type do
      run(release_type)
    end
  end

  def add_header_to_changelog(version)
    changelog = File.read("CHANGELOG.md")
    head, tail = changelog.split("## master (unreleased)\n\n", 2)

    File.open("CHANGELOG.md", "w") do |f|
      f << head
      f << "## master (unreleased)\n\n"
      f << "## #{version} (#{Time.now.strftime("%F")})\n\n"
      f << tail
    end
  end

  def create_release_notes(version)
    release_notes = new_version_changes.strip
    contributor_links = user_links(release_notes)

    File.open("relnotes/v#{version}.md", "w") do |file|
      file << release_notes
      file << "\n\n"
      file << contributor_links
      file << "\n"
    end
  end

  def new_version_changes
    changelog = File.read("CHANGELOG.md")
    _, _, new_changes, _older_changes = changelog.split(/^## .*$/, 4)
    new_changes
  end

  def user_links(text)
    names = text.scan(/\[@(\S+)\]\[\]/).map(&:first).uniq
    names.map { |name| "[@#{name}]: https://github.com/#{name}" }
         .join("\n")
  end

  def run(release_type)
    old_version = Bump::Bump.current
    Bump::Bump.run(release_type, commit: false, bundle: false, tag: false)
    new_version = Bump::Bump.current

    # add_header_to_changelog(new_version)
    # create_release_notes(new_version)

    puts "Changed version from #{old_version} to #{new_version}."
  end
end
