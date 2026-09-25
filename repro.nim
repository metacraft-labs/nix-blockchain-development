import repro_project_dsl
import repro_dsl_stdlib/foreign_env

package nixblockchaindevelopmentEnvironment:
  devEnv:
    useFlakeDevShell(flakeRef = ".#ci")
