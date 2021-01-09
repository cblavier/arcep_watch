defmodule ArcepWatch.Repo do
  use Ecto.Repo,
    otp_app: :arcep_watch,
    adapter: Ecto.Adapters.Postgres
end
