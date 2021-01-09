defmodule ArcepWatch.DataDownload do
  use Tesla, only: [:get], docs: false

  plug(Tesla.Middleware.BaseUrl, "https://www.data.gouv.fr/fr/datasets/r/")
  plug(Tesla.Middleware.FollowRedirects)

  @base_folder "./tmp"
  @split_size 1_000_000

  def download!(year, trimester) do
    base_filename = "arcep-#{year}-#{trimester}"
    folder = "#{@base_folder}/#{year}/#{trimester}"
    File.rm_rf!(folder)
    File.mkdir_p!(folder)

    unless File.exists?("#{@base_folder}/#{base_filename}.7z") do
      IO.puts("downloading #{base_filename}")
      response = get!(url(year, trimester))
      File.write!("#{@base_folder}/#{base_filename}.7z", response.body)
    end

    IO.puts("extracting #{base_filename}")
    :os.cmd(:"7za x #{@base_folder}/#{base_filename}.7z -so > #{folder}/#{base_filename}.csv")

    IO.puts("splitting #{base_filename}")
    :os.cmd(:"cd #{folder} && split -l #{@split_size} #{base_filename}.csv #{base_filename}.csv.")

    File.rm!("#{folder}/#{base_filename}.csv")

    folder
    |> File.ls!()
    |> Enum.map(&"#{folder}/#{&1}")
  end

  defp url(year, trimester), do: dataset(year, trimester)

  defp dataset(2020, 3), do: "e269640f-15f9-45a2-8483-ac4be82e6436"
  defp dataset(2020, 2), do: "e571def3-b634-45b7-8405-6b97c30dce7e"
  defp dataset(2020, 1), do: "d6525a52-6b1b-401c-ba01-4bbeb6cc174c"
  defp dataset(2019, 4), do: "9357c13f-1eb9-4a18-b894-9916dd5ba0da"
  defp dataset(2019, 3), do: "ecd71e4c-1a3a-4a03-9b3f-0f780a0e30ee"
  defp dataset(2019, 2), do: "03c3ac52-3a90-4802-a0ac-31f78bde7986"
  defp dataset(2019, 1), do: "818059e0-5c48-44fd-bb98-4c241200d405"
  defp dataset(2018, 4), do: "aceb74b8-26d5-4696-a123-152d293429ec"
  defp dataset(2018, 3), do: "5bd4026b-2544-4d43-8cdc-b5571b14bac3"
  defp dataset(2018, 2), do: "2af25f1b-99a6-460d-9044-fca95783d315"
  defp dataset(_, _), do: raise("unknow dataset")
end
