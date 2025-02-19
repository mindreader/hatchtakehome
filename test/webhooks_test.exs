defmodule Test.WebhooksTest do
  use HatchWeb.ConnCase

  @endpoint HatchWeb.Endpoint

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

  test "receive inbound sms from sms provider" do
    conn = build_conn() |> put_req_header("content-type", "application/json")
    conn1 = Phoenix.ConnTest.post(conn, "/api/webhooks/sms_provider", inbound_sms1())
    conn2 = Phoenix.ConnTest.post(conn, "/api/webhooks/mailplus", inbound_sms1())
    assert json_response(conn1, 200)
    assert json_response(conn2, 200)
  end

  test "receive inbound email from email provider" do
    conn = build_conn() |> put_req_header("content-type", "application/json")
    conn = Phoenix.ConnTest.post(conn, "/api/webhooks/email_provider", inbound_email())
    assert json_response(conn, 200)
  end

  @tag :capture_log
  test "unknown provider" do
    conn = build_conn() |> put_req_header("content-type", "application/json")
    conn = Phoenix.ConnTest.post(conn, "/api/webhooks/unknown_provider", inbound_email())
    assert conn.status == 404
  end
end
