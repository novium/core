defmodule Auth do
  @moduledoc """
  Login functions
  """
  alias Ueberauth.Auth
  alias Core.Repo
  alias Core.User
  alias Comeonin.Pbkdf2, as: Comeonin

  # Identity provider
  @doc """
  Create new user
  """
  def create(%Auth{provider: :identity} = auth) do
    with :ok <- validate_mail(auth.info),
         :ok <- validate_pass(auth.credentials)
    do
      # Password / Username OK, try to create account
      result = User.changeset(
        %User{},
        %{
          oid: Ecto.UUID.generate(),
          email: auth.info.email,
          password: hash_password(auth.credentials.other.password)
        }
      ) |> Repo.insert

      case result do
        {:ok, user} -> {:ok, user}
        {:error, reason} ->
          {:error, "Did you forget your password? Seems like your email is already registered"}
      end
    else
      {:error, reason} -> {:error, reason}
      _ -> {:error, "Unknown"}
    end
  end

  @doc """
  Find user
  """
  def find(%Auth{provider: :identity} = auth) do
    with email <- auth.info.email,
         :ok <- validate_mail(auth.info),
         :ok <- validate_pass(auth.credentials),
         user <- Repo.get_by(Core.User, email: email),
         false <- is_nil(user),
         true <- check_password(auth.credentials.other.password, user.password)
    do
      {:ok, user}
    else
      {:error, reason} -> {:error, reason}
      _ -> {:error, "Something isn't right"}
    end
  end

  @doc """
  Simple password validation
  """
  def validate_pass(%{other: %{password: nil}}), do: {:error, "Password required"}
  def validate_pass(%{other: %{password: pw}}) do
    if String.length(pw) <= 8 do
      {:error, "Password is too short"}
    else
      :ok
    end
  end

  def validate_mail(%{email: nil}), do: {:error, "Enter an email"}
  def validate_mail(%{email: email}) do
    case EmailChecker.valid?(email, [EmailChecker.Check.Format]) do
      true -> :ok
      false -> {:error, "Your email seems to be invalid"}
    end
  end

  @doc """
  Takes password, returns hash
  """
  @spec hash_password(String.T) :: String.T
  def hash_password(pw), do: Comeonin.hashpwsalt(pw)

  @doc """
  Takes password and hash, returns true if they match, otherwise false
  """
  @spec check_password(String.T, String.T) :: Boolean
  def check_password(password, hash), do: Comeonin.checkpw(password, hash)
end
