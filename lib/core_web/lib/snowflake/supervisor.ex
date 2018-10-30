defmodule Snowflake.Supervisor do
  @moduledoc """
  Snowflake generator supervisor
  """

  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      worker(Snowflake, [[name: Snowflake]])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
