defmodule HatchWeb.WebhookController do
  require Logger
  use HatchWeb, :controller

  def receive(conn, %{"provider" => provider_name}) do
    case provider_name do
      "sms_provider" ->
        # TODO there would be some validation that this request is real here.

        Hatch.Provider.Sms.receive_message(conn.body_params)

        conn |> json(%{status: "ok"})

      _ when provider_name in ["email_provider", "mailplus"] ->
        Hatch.Provider.Email.receive_message(conn.body_params)

        conn |> json(%{status: "ok"})

      provider ->
        Logger.warning("received webhook for unknown provider: #{provider}")

        conn |> send_resp(404, "unknown provider")
    end
  end
end
