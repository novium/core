defmodule CoreWeb.Guardian do
  use Guardian, otp_app: :core
  @moduledoc """
  Contains the serializer for guardian
  """
  alias Core.Repo

  def subject_for_token(user, _claims) do
    {:ok, to_string(user.oid)}
  end

  def subject_for_token(_, _) do
    {:error, :reason_for_error}
  end

  def resource_from_claims(%{"sub" => oid}) do
    case Repo.get_by!(Core.User, oid: oid) do
      nil -> {:error, :resource_not_found}
      user -> {:ok, user}
    end
  end

  def resource_from_claims(_claims) do
    {:error, :reason_for_error}
  end
end
