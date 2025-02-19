defmodule Hatch.Schema.Message do
  use Hatch.Schema

  alias Hatch.Schema.Conversation

  schema "messages" do
    field :type, :string

    field :received_at, :utc_datetime_usec
    field :sent_at, :utc_datetime_usec

    belongs_to :conversation, Conversation
  end

  def changeset(message \\ %__MODULE__{}, attrs) do
    message
    |> cast(attrs, [:type, :received_at, :sent_at, :conversation_id])
    |> validate_required([:type, :conversation_id])
    |> validate_inclusion(:type, ["email", "text"])
    |> foreign_key_constraint(:conversation_id)
    |> put_change(:received_at, DateTime.utc_now())
  end

  def new_email_message(conversation_id, direction)
      when is_binary(conversation_id)
      when direction in [:incoming, :outgoing] do
    %{
      type: "email",
      conversation_id: conversation_id
    }
    |> case do
      res when direction == :incoming ->
        res |> Map.put(:received_at, DateTime.utc_now())

      res ->
        res |> Map.put(:sent_at, DateTime.utc_now())
    end
    |> changeset()
  end

  def new_text_message(conversation_id, direction)
      when is_binary(conversation_id)
      when direction in [:incoming, :outgoing] do
    %{
      type: "text",
      conversation_id: conversation_id
    }
    |> case do
      res when direction == :incoming ->
        res |> Map.put(:received_at, DateTime.utc_now())

      res ->
        res |> Map.put(:sent_at, DateTime.utc_now())
    end
    |> changeset()
  end
end
