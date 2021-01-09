# Arcep Watch

Arcep Watch is a simple Elixir console application meant to get accurate figures about **Optical Fiber deployment** in **France**, per city.

Data are provided by [ARCEP](https://www.arcep.fr) and retried from from [datagouv.fr](https://www.data.gouv.fr/fr/datasets/le-marche-du-haut-et-tres-haut-debit-fixe-deploiements/)

## Setup

- Install latest Elixir and run `mix deps.get` to retrieved dependencies
- Have a local PostgresQL running and set connection info `in dev.exs`
- Run `mix ecto.create` and `mix ecto.migrate` to setup the database

## Running

- Run `mix arcep.watch download 2020 3` to download ARCEP Data, 3rd trimester of 2020 from [datagouv.fr](https://www.data.gouv.fr/fr/datasets/le-marche-du-haut-et-tres-haut-debit-fixe-deploiements/)
- Run `mix arcep.watch load 2020 3` to load data from CSV files to database
- Run `mix arcep.watch insights 44120` to get all insights for 44120 zip code (you can also specify year and even trimester : `mix arcep.watch insights 2020`)