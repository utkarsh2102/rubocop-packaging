# frozen_string_literal: true

RSpec.describe RuboCop::Packaging do
  it 'has a version number' do
    expect(RuboCop::Packaging::VERSION).not_to be nil
  end
end
