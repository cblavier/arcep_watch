use Mix.Config

# Configure your database
config :arcep_watch, ArcepWatch.Repo,
  username: "postgres",
  password: "postgres",
  database: "arcep_watch_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# Print only warnings and errors during test
config :logger, level: :warn
