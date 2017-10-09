defmodule FitbitClient.EventController do
  use FitbitClient.Web, :controller

  def index(conn, _params) do
    events = [
    %ICalendar.Event{
      url: "https://www.floorhelpt.nl/",
      summary: "Bring some delicious food to Bas Janssen",
      dtstart: [[2017, 10, 9], [8, 00, 00]],
      dtend: [[2017, 10, 10], [11, 30, 00]],
      description: "He has not eaten food in over three days..",
      location: "Nedap, Groenlo. Parallelweg 2"
    },
    %ICalendar.Event{
      url: "https://www.floorhelpt.nl/",
      summary: "Bring some disgusting food to Meg",
      dtstart: [[2017, 10, 9], [13, 00, 00]],
      dtend: [[2017, 10, 10], [14, 30, 00]],
      description: "I don't like her, so let's poision her",
      location: "Leeuwarden, Friesland"
    }]
    render conn, events: events
  end
end
