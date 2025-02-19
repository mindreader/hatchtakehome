# Hatch Takehome Test

To start

  * If you have nix, run `nix run` or `nix test`. Definitely works on linux, probably not on mac.
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`
  * To run tests `mix test`.

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Notes
  * I assumed that emails and sms would in reality differ a lot (ie. emails have subjects), thus benefit from separate tables.
  * Conversation table assumes everything is short lived and you only need one point of contact of each type at a time.
  * Used a single webhook with a parameter rather than separate webhooks that would have just been enumerated in the router.
  * Performance was not a huge concern, don't just me too harshly on my database layout.
  * Since this runs on sqlite3, and that has a few db features missing, I went with simple transactions rather than Ecto.Multi.
