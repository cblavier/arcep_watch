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
    |> Enum.map(fn {key, values} -> {key, Map.new(values)} end)
    |> Map.new()
  end
end
