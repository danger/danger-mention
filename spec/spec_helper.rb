require 'pathname'

ROOT = Pathname.new(File.expand_path('../../', __FILE__))
$LOAD_PATH.unshift((ROOT + 'lib').to_s)
$LOAD_PATH.unshift((ROOT + 'spec').to_s)

RSpec.configure do |config|
  # Use color in STDOUT
  config.color = true
end

require 'danger'
require 'cork'
require 'danger_plugin'

def testing_ui
  Cork::Board.new(silent: true)
end

def testing_env
  {
    'HAS_JOSH_K_SEAL_OF_APPROVAL' => 'true',
    'TRAVIS_PULL_REQUEST' => '1',
    'TRAVIS_REPO_SLUG' => 'test'
  }
end

def testing_dangerfile
  env = Danger::EnvironmentManager.new(testing_env)
  Danger::Dangerfile.new(env, testing_ui)
end
