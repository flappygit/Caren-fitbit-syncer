defmodule FitbitClient.EventController do
  use FitbitClient.Web, :controller

  def index(conn, _params) do
    events = [
      %ICalendar.Event{
        url: "https://www.floorhelpt.nl/",
        summary: "Bring some delicious food to Bas Janssen",
        dtstart: {{2017, 10, 09}, {8, 30, 00}},
        dtend:   {{2017, 10, 09}, {8, 45, 00}},
        description: "He has not eaten food in over three days..",
        location: "Nedap, Groenlo. Parallelweg 2"
      },
      %ICalendar.Event{
        url: "https://www.floorhelpt.nl/",
        summary: "Bring some disgusting food to Meg",
        dtstart: {{2017, 10, 11}, {10, 30, 00}},
        dtend:   Timex.shift(Timex.now, hours: 3),
        description: "Not sure why, Meg sounds like a nice name",
        location: "Leeuwarden, Friesland"
      },
      %ICalendar.Event{
        url: "https://www.floorhelpt.nl/",
        summary: "Bring some disgusting food to Steven",
        dtstart: {{2017, 10, 11}, {8, 30, 00}},
        dtend:   {{2017, 10, 11}, {10, 30, 00}},
        description: "Not sure why, Steven sounds like a nice name",
        location: "Leeuwarden, Friesland"
      }
    ]
    ics = %ICalendar{ events: events } |> ICalendar.to_ics
    render conn, events: ics
  end
end
