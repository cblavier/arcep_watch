use Mix.Config

# Configure your database
config :arcep_watch, ArcepWatch.Repo,
  username: "postgres",
  password: "postgres",
  database: "arcep_watch_dev",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10,
  log_level: :warn

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"
