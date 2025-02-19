defmodule Hatch.Schema do
  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      import Ecto.Changeset
      import Hatch.Changeset

      @primary_key {:id, :binary_id, autogenerate: true}
      @foreign_key_type :binary_id

      @timestamp_opts [type: :utc_datetime_usecs]
    end
  end
end
