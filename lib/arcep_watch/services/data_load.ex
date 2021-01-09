defmodule ArcepWatch.DataLoad do
  alias ArcepWatch.{Deployment, Repo}

  import Ecto.Query
  require Logger

  @base_folder "./tmp"

  def load(year, trimester, opts \\ []) do
    zip_col = Keyword.get(opts, :zip_col, 8)
    status_col = Keyword.get(opts, :status_col, 11)

    from(d in Deployment, where: d.year == ^year and d.trimester == ^trimester)
    |> Repo.delete_all()

    folder = "#{@base_folder}/#{year}/#{trimester}"

    streams =
      for file <- File.ls!(folder) do
        File.stream!("#{folder}/#{file}", read_ahead: 100_000)
      end

    streams
    |> Flow.from_enumerables()
    |> Flow.map(fn line ->
      splitted = String.split(line, [",", ";"])
      zip = Enum.at(splitted, zip_col)
      status = splitted |> Enum.at(status_col) |> status()
      {zip, status}
    end)
    |> Flow.partition(key: {:elem, 0})
    |> Flow.reduce(fn -> {%{}, MapSet.new()} end, fn
      {zip, {:error, unknown_status}}, {statuses_by_zip, unknown_statuses} ->
        {
          Map.update(statuses_by_zip, {zip, "unknown_status"}, 1, &(&1 + 1)),
          MapSet.put(unknown_statuses, unknown_status)
        }

      key, {statuses_by_zip, unknown_statuses} ->
        {Map.update(statuses_by_zip, key, 1, &(&1 + 1)), unknown_statuses}
    end)
    |> Flow.on_trigger(fn {statuses_by_zip, unknown_statuses} ->
      Enum.each(statuses_by_zip, fn {{zip, status}, count} ->
        case insert(year, trimester, zip, status, count) do
          {:ok, _} -> :ok
          _ -> :error
        end
      end)

      {[], unknown_statuses}
    end)
    |> Flow.run()
  end

  defp insert(_year, _trimester, _zip, nil, _count), do: :error

  defp insert(year, trimester, zip, status, count) do
    Repo.insert(%Deployment{
      year: String.to_integer(year),
      trimester: String.to_integer(trimester),
      zip: zip,
      status: status,
      count: count
    })
  end

  defp status("deploye"), do: "deployed"
  defp status("raccordable demande"), do: "on_demand"
  defp status("en cours de deploiement"), do: "deploying"
  defp status("signe"), do: "deploying"
  defp status("cible"), do: "target"
  defp status("abandonne"), do: "dropped"
  defp status(unknown_status), do: {:error, unknown_status}
end
