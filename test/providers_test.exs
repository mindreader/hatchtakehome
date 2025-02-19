defmodule Test.ProvidersTest do
  use Hatch.DataCase

  def inbound_sms1 do
    """
    {
      "from": "+18045551234",
      "to": "+12016661234",
      "type": "sms",
      "xillio_id": "message-1",
      "body": "text message",
      "attachments": null,
      "timestamp": "2024-11-01T14:00:00Z"
    }
    """
    |> Jason.decode!()
  end

  def inbound_sms2 do
    """
      {
      "from": "+18045551234",
      "to": "+12016661234",
      "type": "mms",
      "xillio_id": "message-2",
      "body": "text message",
      "attachments": ["attachment-url"],
      "timestamp": "2024-11-01T14:00:00Z"
    }
    """
    |> Jason.decode!()
  end

  def inbound_email do
    """
    {
      "from": "user@usehatchapp.com",
      "to": "contact@gmail.com",
      "xillio_id": "message-2",
      "body": "<html><body>html is <b>allowed</b> here </body></html>",
      "attachments": ["attachment-url"],
      "timestamp": "2024-11-01T14:00:00Z"
    }
    """
    |> Jason.decode!()
  end

  setup do
    %{inboundsms: [inbound_sms1(), inbound_sms2()], inboundemail: [inbound_email()]}
  end

  test "receive inbound sms", %{inboundsms: inboundsms} do
    for message <- inboundsms do
      res = Hatch.Provider.Sms.receive_message(message)

      assert res == :ok
    end
  end

  test "receive inbound email", %{inboundemail: inboundemail} do
    for message <- inboundemail do
      res = Hatch.Provider.Email.receive_message(message)

      assert res == :ok
    end
  end

  test "send outbound email" do
    attachments = [
      "https://example.com/attachment1",
      "https://example.com/attachment2"
    ]

    Hatch.Provider.Email.send_message(
      "user@usehatchapp.com",
      "contact@gmail.com",
      "subject",
      "body",
      attachments: attachments
    )
  end

  test "send outbound sms" do
    attachments = [
      "https://example.com/attachment1",
      "https://example.com/attachment2"
    ]

    Hatch.Provider.Sms.send_message("user@usehatchapp.com", "contact@gmail.com", "body",
      attachments: attachments
    )
  end
end
