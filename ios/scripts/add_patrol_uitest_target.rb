#!/usr/bin/env ruby
# Idempotent script that adds the RunnerUITests UI Testing Bundle target that
# Patrol requires on iOS. Mirrors every build configuration of the Runner
# target (Debug/Release/Profile × 7 flavors) so `patrol build ios --flavor X`
# works for every flavor.
#
# Run from the project root:
#   ruby ios/scripts/add_patrol_uitest_target.rb

require 'xcodeproj'
require 'fileutils'

PROJ_PATH = 'ios/Runner.xcodeproj'
TARGET_NAME = 'RunnerUITests'
TEST_DIR = "ios/#{TARGET_NAME}"
GROUP_PATH = TARGET_NAME

FLAVOR_BUNDLES = {
  'eflux'       => 'com.e-flux.orange',
  'elexon'      => 'com.elexon-charging.ios',
  'opcharge'    => 'com.opcharge.ios',
  'friwigo'     => 'com.friwigo.ios',
  'ezdrive'     => 'fr.ezdrive.ios',
  'ezdriveplus' => 'fr.ezdrive.plus.ios',
  'nxt50five'   => 'nl.nxt50five.ios',
}

FLAVOR_TEAMS = {
  'eflux'       => '56VKX64ZT9',
  'elexon'      => '27D6VMX824',
  'opcharge'    => '6M5X7RA825',
  'friwigo'     => 'T348GSK95P',
  'ezdrive'     => '57QYWMAUTH',
  'ezdriveplus' => 'VF5Y7LW86P',
  'nxt50five'   => '6MRB4UZY74',
}

DEFAULT_FLAVOR = 'eflux'

project = Xcodeproj::Project.open(PROJ_PATH)
runner = project.targets.find { |t| t.name == 'Runner' } or abort 'Runner target not found'

if project.targets.find { |t| t.name == TARGET_NAME }
  warn "Target #{TARGET_NAME} already exists; nothing to do."
  exit 0
end

# 1. Create on-disk sources before referencing them
FileUtils.mkdir_p(TEST_DIR)

m_path = File.join(TEST_DIR, "#{TARGET_NAME}.m")
File.write(m_path, <<~OBJC) unless File.exist?(m_path)
  @import XCTest;
  @import patrol;
  @import ObjectiveC.runtime;

  PATROL_INTEGRATION_TEST_IOS_RUNNER(RunnerUITests)
OBJC

info_path = File.join(TEST_DIR, 'Info.plist')
File.write(info_path, <<~PLIST) unless File.exist?(info_path)
  <?xml version="1.0" encoding="UTF-8"?>
  <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
  <plist version="1.0">
  <dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>$(DEVELOPMENT_LANGUAGE)</string>
    <key>CFBundleExecutable</key>
    <string>$(EXECUTABLE_NAME)</string>
    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$(PRODUCT_NAME)</string>
    <key>CFBundlePackageType</key>
    <string>BNDL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
  </dict>
  </plist>
PLIST

# 2. New target
test_target = project.new(Xcodeproj::Project::Object::PBXNativeTarget)
test_target.name = TARGET_NAME
test_target.product_name = TARGET_NAME
test_target.product_type = 'com.apple.product-type.bundle.ui-testing'
test_target.build_phases << project.new(Xcodeproj::Project::Object::PBXSourcesBuildPhase)
test_target.build_phases << project.new(Xcodeproj::Project::Object::PBXFrameworksBuildPhase)
test_target.build_phases << project.new(Xcodeproj::Project::Object::PBXResourcesBuildPhase)

config_list = project.new(Xcodeproj::Project::Object::XCConfigurationList)
config_list.default_configuration_is_visible = '0'
config_list.default_configuration_name = 'Release'
test_target.build_configuration_list = config_list

runner.build_configurations.each do |runner_config|
  flavor = FLAVOR_BUNDLES.keys.find { |f| runner_config.name.end_with?("-#{f}") } || DEFAULT_FLAVOR
  bundle_base = FLAVOR_BUNDLES[flavor]
  team = FLAVOR_TEAMS[flavor]

  test_config = project.new(Xcodeproj::Project::Object::XCBuildConfiguration)
  test_config.name = runner_config.name
  test_config.build_settings = {
    'CLANG_ENABLE_MODULES'                  => 'YES',
    'CODE_SIGN_STYLE'                       => 'Automatic',
    'CURRENT_PROJECT_VERSION'               => '1',
    'DEVELOPMENT_TEAM'                      => team,
    'GENERATE_INFOPLIST_FILE'               => 'NO',
    'INFOPLIST_FILE'                        => "#{TARGET_NAME}/Info.plist",
    'IPHONEOS_DEPLOYMENT_TARGET'            => '16.2',
    'LD_RUNPATH_SEARCH_PATHS'               => ['$(inherited)', '@executable_path/Frameworks', '@loader_path/Frameworks'],
    'MARKETING_VERSION'                     => '1.0',
    'PRODUCT_BUNDLE_IDENTIFIER'             => "#{bundle_base}.RunnerUITests",
    'PRODUCT_NAME'                          => '$(TARGET_NAME)',
    'SWIFT_VERSION'                         => '5.0',
    'TARGETED_DEVICE_FAMILY'                => '1,2',
    'TEST_TARGET_NAME'                      => 'Runner',
  }
  config_list.build_configurations << test_config
end

project.targets << test_target

# 3. Group + file refs (Xcode shows these under RunnerUITests/)
group = project.main_group[GROUP_PATH] || project.main_group.new_group(TARGET_NAME, TARGET_NAME)
group.set_source_tree('<group>')

m_ref = group.files.find { |f| f.path == "#{TARGET_NAME}.m" } || group.new_reference("#{TARGET_NAME}.m")
info_ref = group.files.find { |f| f.path == 'Info.plist' } || group.new_reference('Info.plist')

sources_phase = test_target.build_phases.find { |bp| bp.is_a?(Xcodeproj::Project::Object::PBXSourcesBuildPhase) }
sources_phase.add_file_reference(m_ref)

# 4. Product reference in the Products group
products_group = project.products_group
product_ref = products_group.new_reference("#{TARGET_NAME}.xctest")
product_ref.include_in_index = '0'
product_ref.set_explicit_file_type('wrapper.cfbundle')
test_target.product_reference = product_ref

# 5. Target dependency on Runner so the app builds before tests
test_target.add_dependency(runner)

project.save
puts "OK — added #{TARGET_NAME} target with #{test_target.build_configurations.size} configurations."
