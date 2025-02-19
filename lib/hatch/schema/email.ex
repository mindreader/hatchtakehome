defmodule Hatch.Schema.Email do
  use Hatch.Schema

  alias Hatch.Schema.Message

  schema "emails" do
    field :unique_id, :string

    field :from, :string
    field :to, :string
    field :body, :string

    # date in email, not when it was received
    field :date, :utc_datetime_usec

    belongs_to :message, Message
    has_one :conversation, through: [:message, :conversation]
  end

  def changeset(email \\ %__MODULE__{}, attrs) do
    email
    |> cast(attrs, [:unique_id, :from, :to, :body, :date, :message_id])
    |> validate_required([:from, :to, :body, :date, :message_id])
    |> validate_not_empty([:from, :to])
    |> foreign_key_constraint(:message_id)
  end
end
