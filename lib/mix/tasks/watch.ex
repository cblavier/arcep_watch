defmodule Mix.Tasks.Arcep.Watch do
  use Mix.Task

  alias ArcepWatch.DataDownload
  alias ArcepWatch.DataLoad
  alias ArcepWatch.Deployment

  @load_options %{
    {2018, 2} => [zip_col: 8, status_col: 10],
    {2018, 3} => [zip_col: 8, status_col: 10],
    {2018, 4} => [zip_col: 8, status_col: 10],
    {2019, 1} => [zip_col: 8, status_col: 10],
    {2019, 2} => [zip_col: 8, status_col: 10],
    {2019, 3} => [zip_col: 8, status_col: 10],
    {2019, 4} => [zip_col: 8, status_col: 10],
    {2020, 1} => [zip_col: 8, status_col: 11],
    {2020, 2} => [zip_col: 8, status_col: 11],
    {2020, 3} => [zip_col: 8, status_col: 11]
  }

  def run(["download", "all"]) do
    start()

    do_all(fn year, trimester, _opts ->
      DataDownload.download!(year, trimester)
    end)
  end

  def run(["download", year, trimester]) do
    start()
    DataDownload.download!(String.to_integer(year), String.to_integer(trimester))
  end

  def run(["load", "all"]) do
    start()
    do_all(&DataLoad.load/3)
  end

  def run(["load", year, trimester]) do
    start()
    {year, trimester} = {String.to_integer(year), String.to_integer(trimester)}
    opts = Map.get(@load_options, {year, trimester}, [])
    DataLoad.load(year, trimester, opts)
  end

  def run(["insights", zip_code, year, trimester]) do
    start()
    IO.inspect(Deployment.get_by_zip(zip_code, year, trimester))
  end

  def run(["insights", zip_code, year]) do
    start()
    IO.inspect(Deployment.get_by_zip(zip_code, year))
  end

  def run(["insights", zip_code]) do
    start()
    IO.inspect(Deployment.get_by_zip(zip_code))
  end

  def run(_) do
    Mix.Shell.IO.error("Unknown command")
    Mix.Shell.IO.info("usage:")
    Mix.Shell.IO.info("- mix arcep.watch download <year> <trimester>")
    Mix.Shell.IO.info("- mix arcep.watch download all")
    Mix.Shell.IO.info("- mix arcep.watch load <year> <trimester>")
    Mix.Shell.IO.info("- mix arcep.watch load all")
    Mix.Shell.IO.info("- mix arcep.watch insights <zip_code> <year> <trimester>")
  end

  defp start do
    Logger.remove_backend(:console)
    Application.ensure_all_started(:arcep_watch)
  end

  defp do_all(fun) do
    for {{year, trimester}, opts} <- @load_options,
        do: fun.(year, trimester, opts)
  end
end
