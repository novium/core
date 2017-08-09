defmodule GuardianSerializer do
  @moduledoc """
  Contains the serializer for guardian
  """
  alias Core.Repo

  def for_token(user = %Core.User{}) do
    {:ok, "#{user.oid}"}
  end

  def from_token(token) do
    {:ok, token}
  end
end
