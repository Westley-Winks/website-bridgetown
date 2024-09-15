---
layout: page
template_engine: erb
title: Weeknotes
---

<%= render Shared::List.new(collection: collections.w) %>
