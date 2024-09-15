---
layout: page
template_engine: erb
title: Posts
---

<%= render Shared::List.new(collection: collections.p) %>
