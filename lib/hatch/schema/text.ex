defmodule Hatch.Schema.Text do
  use Hatch.Schema

  alias Hatch.Schema.Message

  schema "texts" do
    field :unique_id, :string

    field :from, :string
    field :to, :string
    field :body, :string
    field :date, :utc_datetime_usec
    field :type, :string

    belongs_to :message, Message

    # has_many :attachments, Attachment
  end

  def changeset(text \\ %__MODULE__{}, attrs) do
    text
    |> cast(attrs, [:unique_id, :from, :to, :body, :date, :type, :message_id])
    |> validate_required([:from, :to, :body, :date, :type, :message_id])
    |> validate_not_empty([:unique_id, :from, :to])
    |> validate_inclusion(:type, ["sms", "mms"])
    |> foreign_key_constraint(:message_id)
  end
end
