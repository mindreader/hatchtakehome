defmodule Hatch.Changeset do
  import Ecto.Changeset

  @doc """
  Validates that the fields are not empty strings. For things like to and from fields.
  """
  def validate_not_empty(%Ecto.Changeset{} = changeset, fields) do
    fields = if is_list(fields), do: fields, else: [fields]

    fields
    |> Enum.reduce(changeset, fn field, acc ->
      if get_field(acc, field) == "" do
        add_error(acc, field, "can't be blank")
      else
        acc
      end
    end)
  end
end
