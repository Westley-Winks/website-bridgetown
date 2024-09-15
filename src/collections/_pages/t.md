---
layout: page
template_engine: erb
title: Tags
---

<section class="card">
  <h2 class="card__title card__title">All Tags</h2>
  <div class="card__content">
    <div class="tag-container">
      <% site.tags.keys.each do |tag| %>
        <%= link_to tag, "/t/#{tag}" , class: "tag-container__tag tag-container__tag" %>
          <% end %>
    </div>
  </div>
</section>
