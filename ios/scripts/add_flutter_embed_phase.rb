#!/usr/bin/env ruby
# Adds a Run Script build phase to RunnerUITests that copies Flutter.framework
# from the build directory into the test bundle's Frameworks/, then re-signs
# it. Patrol's iOS test bundle transitively depends on Flutter.framework (via
# integration_test.framework), but Flutter is added by xcode_backend.sh which
# only runs on Runner. Without this step the test bundle fails to load on the
# device with "Library not loaded: @rpath/Flutter.framework/Flutter".
#
# Idempotent — safe to re-run.

# Force UTF-8 throughout so the heredoc below survives nanaimo's writer.
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

require 'xcodeproj'

PROJ_PATH = 'ios/Runner.xcodeproj'
TARGET_NAME = 'RunnerUITests'
PHASE_NAME = 'Embed Flutter Framework'

project = Xcodeproj::Project.open(PROJ_PATH)
target = project.targets.find { |t| t.name == TARGET_NAME } or
  abort "#{TARGET_NAME} target not found"

if target.build_phases.any? { |bp| bp.respond_to?(:name) && bp.name == PHASE_NAME }
  puts "Already present; skipping."
  exit 0
end

phase = target.new_shell_script_build_phase(PHASE_NAME)
phase.shell_path = '/bin/sh'
phase.shell_script = <<~'SCRIPT'
  set -e
  SRC="${BUILT_PRODUCTS_DIR}/Flutter.framework"
  DEST="${TARGET_BUILD_DIR}/${WRAPPER_NAME}/Frameworks/Flutter.framework"
  if [ ! -d "$SRC" ]; then
    echo "Flutter.framework not found at $SRC — Runner build must run first."
    exit 1
  fi
  mkdir -p "${TARGET_BUILD_DIR}/${WRAPPER_NAME}/Frameworks"
  rm -rf "$DEST"
  /usr/bin/rsync -a "$SRC/" "$DEST/"
  if [ -n "${EXPANDED_CODE_SIGN_IDENTITY:-}" ]; then
    /usr/bin/codesign --force --sign "$EXPANDED_CODE_SIGN_IDENTITY" \
      --preserve-metadata=identifier,entitlements --timestamp=none "$DEST"
  fi
SCRIPT

project.save
puts "Added '#{PHASE_NAME}' build phase to #{TARGET_NAME}."
