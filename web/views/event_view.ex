defmodule FitbitClient.EventView do
  use FitbitClient.Web, :view

  def render("index.json", %{events: events}) do
    events
  end
end
