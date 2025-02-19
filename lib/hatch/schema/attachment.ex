defmodule Hatch.Schema.Attachment do
  use Hatch.Schema

  alias Hatch.Schema.Message

  schema "attachments" do
    field :url, :string

    belongs_to :message, Message
  end

  def changeset(attachment \\ %__MODULE__{}, attrs) do
    # I assume we trust the provider to give us a valid URL.

    attachment
    |> cast(attrs, [:url, :message_id])
    |> validate_required([:url, :message_id])
    |> foreign_key_constraint(:message_id)
  end
end
