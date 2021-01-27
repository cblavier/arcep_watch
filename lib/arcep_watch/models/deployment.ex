defmodule ArcepWatch.Deployment do
  use Ecto.Schema

  alias ArcepWatch.{Deployment, Repo}

  import Ecto.Query

  schema "deployments" do
    field :year, :integer
    field :trimester, :integer
    field :zip, :string
    field :status, :string
    field :count, :integer
  end

  def get_by_zip(zip) do
    from(
      d in Deployment,
      where: d.zip == ^zip,
      order_by: [asc: d.year, asc: d.trimester, asc: d.status]
    )
    |> aggregate()
  end

  def get_by_zip(zip, year) do
    from(
      d in Deployment,
      where: d.zip == ^zip and d.year == ^year,
      order_by: [asc: d.year, asc: d.trimester, asc: d.status]
    )
    |> aggregate()
  end

  def get_by_zip(zip, year, trimester) do
    from(
      d in Deployment,
      where: d.zip == ^zip and d.year == ^year and d.trimester == ^trimester,
      order_by: [asc: d.year, asc: d.trimester, asc: d.status]
    )
    |> aggregate()
  end

  defp aggregate(query) do
    query
    |> Repo.all()
    |> Enum.group_by(
      &{&1.year, &1.trimester},
      &{&1.status, &1.count}
    )
    |> Enum.map(fn {key, values} -> {key, add_coverage(values)} end)
    |> Map.new()
  end

  defp add_coverage(count_by_status) do
    count_by_status = Map.new(count_by_status)
    deployed_count = Map.get(count_by_status, "deployed", 0)
    total = count_by_status |> Map.values() |> Enum.sum()

    Map.put(count_by_status, "coverage", Float.round(deployed_count / total, 2))
  end
end
