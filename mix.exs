defmodule Libu.MixProject do
  use Mix.Project

  def project do
    [
      app: :libu,
      version: "0.1.0",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Libu.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.4.2"},
      {:phoenix_pubsub, "~> 1.1"},
      {:phoenix_ecto, "~> 4.0"},
      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.13"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:plug, "~> 1.7"},
      {:phoenix_live_view, "0.1.0"},
      # {:phoenix_live_view,
      #   github: "phoenixframework/phoenix_live_view",
      #   override: true},
      {:calendar, "~> 0.17.4"},
      {:uuid, "~> 1.1"},
      {:veritaserum, "~> 0.2.1"},
      {:flow, "~> 0.14.3"},
      {:broadway, "~> 0.4.0"},
      {:essence, "~> 0.2.0"},
      {:oauth2, "~> 1.0"},
      {:commanded, github: "commanded/commanded"},
      {:eventstore, github: "zblanco/eventstore", branch: "backward-streaming", override: true},
      {:commanded_eventstore_adapter, github: "commanded/commanded-eventstore-adapter"},
      {:telemetry, "~> 0.4.0"},
      {:telemetry_metrics, "~> 0.3.0"},
      {:ex2ms, "~> 1.0"},
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
