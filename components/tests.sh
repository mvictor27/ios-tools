function unit_tests() {
  comp_init 'test'
  if [[ -n $UNIT_TEST_SCHEME ]]; then
    msg 'Running unit tests'
    run_tests "$UNIT_TEST_SCHEME"
  else
    msg 'No UNIT_TEST_SCHEME defined - skipping unit tests'
  fi
  comp_deinit
}

function ui_tests() {
  comp_init 'test'
  if [[ -n $UI_TEST_SCHEME ]]; then

    if [[ $restart_simulator ]]; then
      # Make sure the simulator has hardware keyboard disabled for UI tests and give it time to launch
      msg 'Configuring simulator'
      killall Simulator && sleep 1 || echo "No simulator running" 
      killall "iOS Simulator" && sleep 1 || echo "No iOS Simulator running" 
      defaults write com.apple.iphonesimulator ConnectHardwareKeyboard 0 && sleep 1
      xcrun instruments -w 'iPhone 6s Plus (9.3)' || true && sleep 60
    fi

    msg 'Running UI tests'
    run_tests "$UI_TEST_SCHEME"
  else
    msg 'No UI_TEST_SCHEME defined - skipping UI tests'
  fi
  comp_deinit
}

function run_tests() {
  scheme="$1"

  check_deps 'xcodebuild' 'xcpretty'
  cd "$project_dir"

  if [[ -n $clean ]]; then
    clean_build='clean'
  fi
  if [[ -n $WORKSPACE ]]; then
    workspace="-workspace $WORKSPACE"
  fi

  xcodebuild \
      $workspace \
      -scheme "$scheme" \
      -sdk iphonesimulator \
      -destination "$destination" \
      $clean_build test \
    | bundle exec xcpretty --report junit
}
