---
layout: page
template_engine: erb
title: Books
---

<%= render Shared::List.new(collection: collections.b) %>
