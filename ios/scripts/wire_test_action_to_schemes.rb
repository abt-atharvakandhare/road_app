#!/usr/bin/env ruby
# Adds RunnerUITests as a testable reference to every flavor scheme's
# Test action. Idempotent — safe to re-run after adding new flavors.
#
# Run from the project root:
#   ruby ios/scripts/wire_test_action_to_schemes.rb

require 'xcodeproj'

PROJ_PATH = 'ios/Runner.xcodeproj'
SCHEMES_DIR = File.join(PROJ_PATH, 'xcshareddata/xcschemes')
TEST_TARGET = 'RunnerUITests'

project = Xcodeproj::Project.open(PROJ_PATH)
ui_test_target = project.targets.find { |t| t.name == TEST_TARGET } or
  abort "#{TEST_TARGET} target not found — run add_patrol_uitest_target.rb first"

Dir.glob(File.join(SCHEMES_DIR, '*.xcscheme')).each do |path|
  scheme = Xcodeproj::XCScheme.new(path)

  already_present = scheme.test_action.testables.any? do |t|
    t.buildable_references.any? { |b| b.target_name == TEST_TARGET }
  end
  if already_present
    puts "skip #{File.basename(path)} — already wired"
    next
  end

  testable = Xcodeproj::XCScheme::TestAction::TestableReference.new(ui_test_target)
  scheme.test_action.add_testable(testable)
  scheme.save!
  puts "wired #{File.basename(path)}"
end
