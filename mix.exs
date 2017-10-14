defmodule Core.Mixfile do
  @moduledoc """
  Mixfile
  """
  use Mix.Project

  def project do
    [app: :core,
     version: "0.0.1",
     elixir: "~> 1.2",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps()]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {Core, []},
     applications: [:phoenix, :phoenix_pubsub, :phoenix_html,
                    :cowboy, :logger, :gettext,
                    :phoenix_ecto, :mariaex,
                    :ueberauth, :ueberauth_identity]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [{:phoenix, "~> 1.2.1"},                                  # Phoenix Defaults
     {:phoenix_pubsub, "~> 1.0"},
     {:phoenix_ecto, "~> 3.0"},
     {:mariaex, "~> 0.8.3"},
     {:phoenix_html, "~> 2.10.4"},
     {:phoenix_live_reload, "~> 1.1.1", only: :dev},
     {:gettext, "~> 0.11"},
     {:cowboy, "~> 1.0"},

     {:ueberauth, "~> 0.4.0"},                                # Authentication
     {:ueberauth_identity, "~> 0.2.3"},
     {:guardian, "~> 0.14.5"},
     {:comeonin, "~> 4.0.2"},
     {:pbkdf2_elixir, "~> 0.12.2"},

     {:email_checker, "~> 0.1.0"},                            # Validation

     {:credo, "~> 0.8.6", only: [:dev, :test], runtime: false}  # Dev
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"],
     "test": ["ecto.create --quiet", "ecto.migrate", "test"]]
  end
end
