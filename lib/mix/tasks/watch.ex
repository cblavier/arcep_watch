defmodule Mix.Tasks.Arcep.Watch do
  use Mix.Task

  alias ArcepWatch.DataDownload
  alias ArcepWatch.DataLoad
  alias ArcepWatch.Deployment

  def run(["download", year, trimester]) do
    start()
    DataDownload.download!(year, trimester)
  end

  def run(["load", year, trimester]) do
    start()
    DataLoad.load(year, trimester)
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

  def start do
    Logger.remove_backend(:console)
    Application.ensure_all_started(:arcep_watch)
  end

  def run(_) do
    Mix.Shell.IO.error("Unknown command")
    Mix.Shell.IO.info("usage:")
    Mix.Shell.IO.info("- mix arcep.watch download <year> <trimester>")
    Mix.Shell.IO.info("- mix arcep.watch load <year> <trimester>")
    Mix.Shell.IO.info("- mix arcep.watch insights <zip_code> <year> <trimester>")
  end
end
