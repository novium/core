defmodule Snowflake  do
  @moduledoc """
  Creates a SnowflakeID
  epoch + micro + counter + pid
  """

  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def generate do
    GenServer.call(__MODULE__, :generate)
  end

  def snowflake(counter) do
    with  epoch <- DateTime.utc_now |> DateTime.to_unix,
          {micro, _} <- DateTime.utc_now.microsecond,
          compile <-
            Integer.digits(epoch)
            ++ Integer.digits(div(micro, 1000))
            ++ Integer.digits(counter)
            ++ (System.get_pid |> String.to_integer |> Integer.digits)
            # It is *highly* unlikely that two processes have the same
            # time, counter and PID, yet this should probably be changed
            # to something more "rigorous" in time. (//TODO)
          do
            (compile |> Integer.undigits)
          end
  end

  # Server
  def init(:ok) do
    {:ok, 0}
  end

  def handle_call(:generate, _from, 255), do: {:reply, snowflake(255), 0}
  def handle_call(:generate, _from, counter), do: {:reply, snowflake(counter), counter + 1}

  def init(args) do
    :ok
  end
end
