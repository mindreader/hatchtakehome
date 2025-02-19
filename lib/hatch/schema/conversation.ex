defmodule Hatch.Schema.Conversation do
  use Hatch.Schema

  alias Hatch.Schema.Message

  schema "conversations" do
    field :email_address, :string
    field :phone_number, :string

    has_many :messages, Message
  end

  def changeset(conversation \\ %__MODULE__{}, attrs) do
    conversation
    |> cast(attrs, [:email_address, :phone_number])
    |> unique_constraint(:email_address)
    |> unique_constraint(:phone_number)
  end

  def new_email_conversation(email_address) when is_binary(email_address) do
    %{
      email_address: email_address
    }
    |> changeset()
  end

  def new_text_conversation(phone_number) when is_binary(phone_number) do
    %{
      phone_number: phone_number
    }
    |> changeset()
  end
end
