---
copy_path: "_p/olt.md"
date: 2025-06-09
description: "How I used Phoenix to create a live timeline of actions completed by the Oregon legislature as they happen."
lastmod: 2025-06-09
publish: true
slug: "olt"
summary: "I used Phoenix to build a web app that tracks actions being taken in the Oregon Legislature as they happen. I brainstormed the design, how to get the data I wanted, and how to display it. Diving deep into OData, streams, pagination, and concurrency, the end result is a timeline of legislative actions for a more informed state."
tags:
  - coding
  - tech
  - elixir
title: "I made an app that tracks the Oregon legislature"
toc: true
---

I live with a state senator and one of my best friends does media for the legislature so I hear and think about Oregon politics a lot these days. The Oregon State Legislature does a good job of showing the public [what they're up to](https://olis.oregonlegislature.gov/liz/) each day and they also have _all_ of their [data publicly accessible](https://www.oregonlegislature.gov/citizen_engagement/Pages/data.aspx). I've been sitting on what I could do with this data for a while and luckily I've also been learning [Elixir](https://elixir-lang.org/) and [Phoenix](https://www.phoenixframework.org/) to make web apps.

So, I created a [timeline of actions](https://olt.wwinks.com/) completed by the legislature as they happen. Go [check it out](https://olt.wwinks.com), share it with the Oregonians in your life, and don't hesitate to [let me know](/#contact) what you think!

![Screenshot of Oregon Legislature Tracker. Shows two measure actions and a committee agenda item.](/assets/screenshot.webp)

## Brainstorming the design

My idea was to create something that tracks completed actions _as they happen_ in the legislature. For this, I wanted an infinite scroll with all the actions listed in chronological order. But what is worth tracking? Which are actual actions taken? After browsing the [data model (PDF)](https://www.oregonlegislature.gov/citizen_engagement/Documents/OLOData-Model.pdf) for everything that is available, I chose three:

- **Measure history actions.** Actions actually taken in relation to measures. Things like "Governor signed" or "Effective date January 1, 2026."
- **Completed floor agenda items.** Things done on the chamber floor like "Second Reading of House Measures" and "Possible Consideration of House Amendments."
- **Committee agenda items.** Completed agenda items in a specific committee like "Heard and Reported Out with Amendments" in the Joint Committee On Ways and Means.

Here's an initial sketch (disregard the egg on a pedestal from a DnD session and the big red STUCK—that's addressed later):

![Sketch of initial brainstorm for a legislature tracking app](/assets/sketch.webp)

The final version looks pretty much like that. It lists actions taken in the Oregon legislature as they happen for a more informed public. That's the basics for the layperson—I'll get into the nitty-gritty tech stuff here on out.

## Getting the data

The Oregon Legislature allows public access to [its API](https://www.oregonlegislature.gov/citizen_engagement/Pages/data.aspx)[^2] in [OData format](https://www.odata.org/). I've never worked with OData before but it is similar to a regular REST API with better querying abilities. I read the docs and came up with an action plan to efficiently get the data I wanted before rendering it.

In the latest version of OData, you can call an endpoint and get related resources at the same time. I assumed all the actions I wanted to track revolved around measures so my plan was to call the `/Measures` endpoint and get the associated measure actions, committee agenda items, and floor agenda items for each measure all in one go.

I tried something like this: `/Measures?$expand=MeasureHistoryAction($orderby=ActionDate desc)`. This should get _all_ measures and their associated actions sorted by date. Instead, I got an error.

Apparently, nested querying (querying an expanded resource) is only possible in OData 4.0 but the legislature runs the older OData 3.0 that couldn't handle a request like that. This meant that I had to call each endpoint individually for each action type: `/MeasureHistoryActions`, `/CommitteeAgendaItems`, and `/FloorAgendaItems`. From each of these, I _can_ get the associated measure (e.g. by tacking on `?$select=Measure/CatchLine&$expand=Measure`) then combine them all into one big list and render it.

I called each endpoint, selected the attributes I wanted, and tweaked the data to fit into a uniform template. Some events didn't have an actual `ActionDate` tied to them so I used `ModifiedDate` as a proxy—it's probably close enough. Then I concatenated the lists and rendered it. I pulled out the following attributes for each event to fit into a template:

- Measure prefix and number
- Action date and time
- Chamber or committee
- Action taken
- Associated measure catchline
- Optionally, vote text that shows who voted aye and who voted nay

## Pagination and infinite scroll

Here's where things got rocky. Remember, there are three individual API calls that need to be made recursively when you scroll down. My first-pass idea was to get the 10 most recent of each action, add them to the stream, and render them. When you reach the end of the list, it would get 10 more of each action (ordered by date) and add them to the stream.

Let's think about that. Every time you fetch more data, you get the 10 most recent of _each_ action type then the 10 most recent of each type after that, then 10 more of each, and so on. There will be a proportional number of each action type, regardless of the date and time they were actually done. If there were lots of measure actions on one day and just a couple of committee items, you'd see committee items from days ago alongside only very recent measure actions. I could have manually set multipliers for each type (for example, get 5 measure actions, 10 committee actions, and 20 floor items) but they'd still be proportional. That seemed fine to me, at least for a first pass. On each API call, I tacked on `$skip={offset}&$top={offset + limit}` and updated `offset` each pass.

But this had problems. Theoretically, there could be actions added to the stream that occurred later than where you currently are in the list—you'd have to scroll up to see it, even if you knew it got added. I hadn't thought about this until after I solved the second problem.

The other problem (that I _did_ consider) is that, there was **no way to put the actions in chronological order** on the server. You'd have to re-sort all the actions every time you got new data. When using streams in Phoenix, the server adds the data to the stream and unloads it from memory. Once data is added to the stream and rendered, it is completely handed-off to the client-side DOM. I couldn't add events to the stream in order because the server has no memory of what events were previously added.

My solution was to add a JavaScript hook that sorts the events client-side whenever the stream gets updated. Easy enough. I dusted off my JavaScript knowledge and added a hook that sorted events by date whenever it got new data. Then a new problem came up.

When using the `phx-viewport-bottom` binding, it **triggers when the last child has reached the end of the viewport, sends the event, then scrolls the last child into view**. So, you scroll down, more data gets added to the stream, the JavaScript hook re-sorts the data on the client, and the last child before the update gets scrolled into view.

What happens when the last child before the update is still the last child after the update? It scrolls to the bottom, triggers another data fetch, scrolls to the bottom, triggers another data fetch, scrolls to the bottom…an infinite loop.[^1] I banged my head on the desk over this for a while.

Then it struck me. Why don't I just paginate by time? Instead of getting a certain _number_ of actions each time, I'll get _every_ action of each type in the last 24 hours. When you reach the bottom, get data from the last 24 hours before that. Genius! Why didn't I think of that at the beginning? With this new model, the event types aren't necessarily proportional and I can sort the data on the server so no client-side hooks are needed.

I removed the `$skip={offset}&$top={offset + limit}` and used `$filter=ActionDate lt DateTime'#{datetime} and ActionDate gt DateTime'#{shift_date(datetime)}` where `shift_date` … shifts the date you pass it 24 hours in the past. This filters the data to be within `datetime` and 24 hours before `datetime`.

When the LiveView mounts, it assigns the current datetime (`DateTime.now!/0`) to the socket as `datetime` and calls `paginate_events` that looks like this:

```elixir
defp paginate_events(socket, new_datetime) do
	%{datetime: datetime} = socket.assigns

	case Events.get_data(datetime) do

		# in case there isn't any data in that timeframe, paginate again
		[] ->
			socket
			|> assign(:datetime, new_datetime)
			|> paginate_events(Events.shift_date(new_datetime))

		events ->
			socket
			|> assign(:datetime, new_datetime)
			|> stream(:events, events, at: -1)
	end
end

def handle_event("next-page", _params, socket) do
	socket
	|> paginate_events(Events.shift_date(socket.assigns.datetime))}
end
```

## Speeding the thing up with ✨ concurrency ✨

With three individual API calls, it would take a while to get all the data before it could be sent to the client. Instead, I wanted all three to be called at the same time—concurrently. Read any "Why Elixir is Awesome!" blog post and you'll hear about how easy and reliable its concurrency abilities are. I concur.

In just a few lines of code, each endpoint was being called in parallel. This really reduced load time because it now only takes as long as the longest API call (average=0.7576 seconds, SD=0.3478 seconds, n=10). It looked something like this:

```elixir
# create tasks
measure_history_actions_call = 
	Task.async(fn -> fetch_measure_history_action_data(req, datetime) end)
floor_session_agenda_items_call =
	Task.async(fn -> fetch_floor_session_agenda_items(req, datetime) end)
	
# then await each to get the data back
with measure_history_actions_data <- Task.await(measure_history_actions_call),
	floor_session_agenda_items_data <- Task.await(floor_session_agenda_items_call) do
		(measure_history_actions_data ++ 
			floor_session_agenda_items_data)
		|> Enum.sort_by(&(&1["ActionDate"], :desc))
end
```

## Making it look nice

The front-end design was pretty simple. I started with a Tailwind template and tweaked it from there, taking inspiration from the federal [House of Representatives](https://live.house.gov/) and [Mastodon's public roadmap](https://joinmastodon.org/roadmap). The cherry on top is that the little bullet point next to each action pulses if it happened in the last 30 minutes.

I think most programmers agree that dealing with dates, times, and timezones is a pain. Trying to get the date and time to line up across my code was tougher than it should have been. Do your future self a favor and just use [tzdata](https://hexdocs.pm/tzdata/readme.html). It makes working with timezones _way_ easier.

## AI-free

Ready for the real kicker? Not only is this app AI-free but I also **didn't use AI in development**. Crazy, I know. I did this project to learn more about programming and how to use Phoenix and Elixir. Instead of delegating the difficult parts—rewarding things are rarely easy—I actually read the documentation, StackOverflow, and forums to solve my problems. No vibe-coding here. All mistakes, bugs, and errors are entirely my own.

## Next steps

I learned a lot with this project. I learned about OData, the inner workings of `phx-viewport-*` bindings, JavaScript hooks, and concurrency in Elixir. I'll keep an eye on it this week to see what it grabs. If the data I chose to present doesn't make sense, I'll look at the data model again and make changes.

Go [try it out](https://olt.wwinks.com), share it with the Oregonians in your life, and [let me know](/#contact) what you think!

[^1]: Writing this out, I realize this actually can't happen. New actions of every type get added so you are guaranteed to have a different last child each time. I was getting infinite loops when I _reversed_ the order to test that my JavaScript was, in fact, working. Writing _does_ deepen and clarify thoughts!

[^2]: With a generous Acceptable Use Policy: "Clients can execute on-demand queries as needed."
