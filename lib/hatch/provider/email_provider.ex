defmodule Hatch.Provider.Email do
  require Logger

  alias Hatch.Schema.Conversation
  alias Hatch.Schema.Email
  alias Hatch.Schema.Attachment
  alias Hatch.Schema.Message

  @moduledoc """
  This module is responsible for dealing with email messages via some unnamed email provider, but
  perhaps named MailPlus.
  """

  def config do
    Application.get_env(:hatch, __MODULE__)
  end

  @doc """
  Receives an email message from some unnamed email provider.
  """
  def receive_message(msg) when is_map(msg) do
    import Ecto.Query

    # I would normally use an Ecto.Multi here, but sqlite is extremely finicky about upserts
    # and reading back already inserted data on conflict, and I just don't have the time to
    # work around it.
    {:ok, :ok} =
      Hatch.Repo.transaction(fn ->
        Conversation.new_email_conversation(msg["from"])
        |> Hatch.Repo.insert!(on_conflict: :nothing)

        %Conversation{} =
          conversation =
          from(c in Conversation, where: c.email_address == ^msg["from"])
          |> Hatch.Repo.one!()

        %Message{} =
          message =
          Message.new_email_message(conversation.id, :incoming)
          |> Hatch.Repo.insert!()

        %Email{} =
          parse_email(msg, message)
          |> Hatch.Repo.insert!()

        {_, _} = Hatch.Repo.insert_all(Attachment, parse_attachments(msg["attachments"], message))

        :ok
      end)

    :ok
  end

  defp parse_email(msg, %Message{} = message) when is_map(msg) do
    %{
      unique_id: msg["xillio_id"],
      from: msg["from"],
      to: msg["to"],
      body: msg["body"],
      date: msg["timestamp"],
      message_id: message.id
    }
    |> Email.changeset()
  end

  defp parse_attachments(attachments, %Message{} = message) do
    (attachments || [])
    |> Enum.map(fn url ->
      %{
        url: url,
        message_id: message.id
      }
    end)
  end

  def send_message(from, to, subject, body, opts \\ []) do
    import Ecto.Query

    _attachments = Keyword.get(opts, :attachments, [])

    config = config()
    # HTTPoison.post....
    result =
      Logger.info(
        "sending email via #{config[:send_url]} to #{to} from #{from} with subject #{subject} and body #{body}"
      )

    # I assume you want to store outgoing messages for display purposes
    case result do
      :ok ->
        {:ok, :ok} =
          Hatch.Repo.transaction(fn ->
            Conversation.new_email_conversation(to)
            |> Hatch.Repo.insert!(on_conflict: :nothing)

            %Conversation{} =
              conversation =
              from(c in Conversation, where: c.email_address == ^to)
              |> Hatch.Repo.one!()

            %Message{} =
              message =
              conversation.id
              |> Message.new_email_message(:outgoing)
              |> Hatch.Repo.insert!()

            %Email{} =
              %{
                from: from,
                to: to,
                date: DateTime.utc_now(),
                body: body,
                message_id: message.id
              }
              |> Email.changeset()
              |> Hatch.Repo.insert!()

            # TODO attachments - in the interests of time, I'm skipping this.

            :ok
          end)

      err ->
        {:error, err}
    end
  end
end
