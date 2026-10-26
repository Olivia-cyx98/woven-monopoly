# frozen_string_literal: true

# Absolute path to a file in spec/fixtures/, so specs can load it by name.
module FixtureHelpers
  def fixture(name)
    File.expand_path("../fixtures/#{name}", __dir__)
  end
end
