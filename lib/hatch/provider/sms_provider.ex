defmodule Hatch.Provider.Sms do
  require Logger

  alias Hatch.Schema.Text
  alias Hatch.Schema.Attachment
  alias Hatch.Schema.Conversation
  alias Hatch.Schema.Message

  @moduledoc """
  This module is responsible for dealing with sms messages via some unnamed sms / mms provider.
  """

  def config do
    Application.get_env(:hatch, __MODULE__)
  end

  def receive_message(msg) when is_map(msg) do
    import Ecto.Query

    # I would normally use an Ecto.Multi here, but sqlite is extremely finicky about upserts
    # and reading back already inserted data on conflict, and I just don't have the time to
    # work around it.
    {:ok, :ok} =
      Hatch.Repo.transaction(fn ->
        Conversation.new_text_conversation(msg["from"])
        |> Hatch.Repo.insert!(on_conflict: :nothing)

        %Conversation{} =
          conversation =
          from(c in Conversation, where: c.phone_number == ^msg["from"])
          |> Hatch.Repo.one!()

        %Message{} =
          message =
          Message.new_text_message(conversation.id, :incoming)
          |> Hatch.Repo.insert!()

        %Text{} =
          parse_sms(msg, message)
          |> Hatch.Repo.insert!()

        {_, _} = Hatch.Repo.insert_all(Attachment, parse_attachments(msg["attachments"], message))

        :ok
      end)

    :ok
  end

  defp parse_sms(msg, %Message{} = message) when is_map(msg) do
    %{
      unique_id: msg["xillio_id"],
      from: msg["from"],
      to: msg["to"],
      body: msg["body"],
      date: msg["timestamp"],
      type: msg["type"],
      message_id: message.id
    }
    |> Text.changeset()
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

  def send_message(from, to, body, opts \\ []) do
    import Ecto.Query

    _attachments = Keyword.get(opts, :attachments, [])

    config = config()
    # HTTPoison.post....
    result =
      Logger.info("sending sms via #{config[:send_url]} to #{to} from #{from} with body #{body}")

    # TODO actually validate type
    type = Keyword.get(opts, :type, "sms")

    case result do
      :ok ->
        # it is possible we have a unique id back from this provider, we could use that.
        {:ok, :ok} =
          Hatch.Repo.transaction(fn ->
            Conversation.new_text_conversation(to)
            |> Hatch.Repo.insert!(on_conflict: :nothing)

            %Conversation{} =
              conversation =
              from(c in Conversation, where: c.phone_number == ^to)
              |> Hatch.Repo.one!()

            %Message{} =
              message =
              Message.new_text_message(conversation.id, :outgoing)
              |> Hatch.Repo.insert!()

            %Text{} =
              %{
                from: from,
                to: to,
                body: body,
                date: DateTime.utc_now(),
                type: type,
                message_id: message.id
              }
              |> Text.changeset()
              |> Hatch.Repo.insert!()

            # TODO attachments - in the interests of time, I'm skipping this.

            :ok
          end)

        :ok
    end
  end
end
