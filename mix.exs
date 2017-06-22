defmodule PrxAuth.Mixfile do
  use Mix.Project

  def project do
    [app: :prx_auth,
     version: "0.0.1",
     elixir: "~> 1.2",
     elixirc_paths: elixirc_paths(Mix.env),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description(),
     package: package(),
     deps: deps(),
     name: "PrxAuth",
     source_url: "https://github.com/PRX/prx_auth-elixir",
     docs: docs()]
  end

  def application do
    [mod: {PrxAuth, []},
     applications: [:plug, :jose, :httpoison],
     extra_applications: [:logger]]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  defp deps do
    [{:plug, "~> 1.3"},
     {:poison, "~> 2.2"},
     {:jose, "~> 1.8"},
     {:httpoison, "~> 0.11"},
     {:ex_doc, "~> 0.14", only: :dev, runtime: false},
     {:mock, "~> 0.2.0", only: :test},
     {:uuid, "~> 1.1", only: :test}]
  end

  defp description do
    """
    Plug to verify PRX-issued JWT
    """
  end

  defp package do
    [contributors: ["Ryan Cavis"],
     maintainers: ["Ryan Cavis"],
     licenses: ["MIT"],
     links: %{github: "https://github.com/PRX/prx_auth-elixir"},
     files: ~w(lib LICENSE mix.exs README.md)]
  end

  defp docs do
    [main: "readme",
     extras: ["README.md"]]
  end
end
