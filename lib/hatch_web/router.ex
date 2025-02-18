defmodule HatchWeb.Router do
  use HatchWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", HatchWeb do
    pipe_through :api
  end
end
