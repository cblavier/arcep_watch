defmodule ArcepWatch.Repo.Migrations.CreateDeployments do
  use Ecto.Migration

  def change do
    create table(:deployments) do
      add :year, :integer, null: false
      add :trimester, :integer, null: false
      add :zip, :string, null: false
      add :status, :string, null: false
      add :count, :integer, null: false
    end

    create index(:deployments, [:year, :trimester])
    create unique_index(:deployments, [:year, :trimester, :zip, :status])
    create index(:deployments, [:zip])
  end
end
