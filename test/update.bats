#!/usr/bin/env bats
load helper

@test "version_gt compares semver" {
  arche_version_gt 0.2.0 0.1.9
  ! arche_version_gt 1.0.0 1.0.0
  arche_version_gt 0.10.0 0.9.0
  ! arche_version_gt 0.1.0 0.2.0
}

@test "version_gt tolerates a leading v" {
  arche_version_gt v0.2.0 v0.1.0
}

@test "should_check is true when there is no stamp" {
  run arche_should_check 1000000000
  [ "$status" -eq 0 ]
}

@test "should_check is false right after a check" {
  printf '1000000000' > "$(arche_check_stamp)"
  run arche_should_check 1000000000
  [ "$status" -ne 0 ]
}

@test "should_check is true again a day later" {
  printf '1000000000' > "$(arche_check_stamp)"
  run arche_should_check 1000090000
  [ "$status" -eq 0 ]
}

@test "local_version reads the VERSION file" {
  run arche_local_version
  [ -n "$output" ]
}
