---
copy_path: "_p/suntup-treasure-hunt.md"
date: 2024-10-17
description: "How I solved an online treasure hunt."
lastmod: 2024-10-17
publish: true
slug: suntup-treasure-hunt
summary: "Starting with a shortcut, I pretty quickly found all the pieces of the puzzle. The hard part was unscrambling them. Sometimes the search felt like work but, as they apparently say in Latin, *laborare est orare.*"
tags:
  - puzzle
title: "How I solved an online treasure hunt"
toc: true
---

My friend [foreverliketh.is](https://foreverliketh.is) shared a link to a treasure hunt hosted by Suntup Editions, [a book publishing company.](https://suntup.press/news/suntup-editions-treasure-hunt-contest/) The challenge was to find 16 colored letters scattered across their website. Once you find all the letters, you unscramble them into a three-word Latin phrase. The potential prizes were _awesome._ The grand prize was a custom-bound edition of _Blood Meridian_ by Cormac McCarthy, a piece of art in and of itself.[^1] Even if I didn't win anything, I can't say no to a puzzle. Here's how I solved it.

## Sitemaps helped me find all the letters

I love a good puzzle. I do not love doing busy work. The first thing I needed to do was figure out how to find all the letters without manually clicking through every single possible page.

So, I went to [the sitemaps.](https://suntup.press/sitemap.xml) Sitemaps are very common pages that list every page and its location on a given website. They're made for bots to look at so Google can properly index websites and make all its pages searchable. Suntup's sitemap was conveniently sorted by **last modification date.** It told me the exact pages that were recently changed. I manually clicked through each of these and, sure enough, there were 16 pages and they each had a blue letter. In maybe 10 minutes of work, I found the following, sorted by letter frequency: **R (4), A (3), E (3), O (2), B (1), L (1), S (1), T (1).**

## Searching for Latin phrases was much harder

I don't know any Latin so I couldn't even make a guess at this point. A Google search quickly got me a [list of Latin phrases](https://en.wikipedia.org/wiki/List_of_Latin_phrases) sorted by letter on Wikipedia. I had no idea there were that many common Latin phrases. Again, I don't like busy work so I tried to come up with a smarter way to comb through these lists.

First, I noticed that there weren't actually that many letters available to me: RAEOBLST. That meant I only needed to look at the tables for those eight letters, removing more than half of the possibilities. Then, I manually went through each phrase in each table and looked for these requirements in order:

- Is it exactly three words?
- Does it _only_ have the letters in RAEOBLST?
- Does it have one and only one B? L? S? T?

I went through the relevant lists with this method a couple of times. I didn't find anything. As I was sifting through, I began noting down full words that fit the bill: ARTE, TERRA, LABORE, ASTRA, RES. This turned out to come in handy later.

My next algorithm was technology-assisted. I downloaded each table from Wikipedia and opened them up in Excel. I created a new column that calculated the length of each phrase. The one I was looking for was 18 characters long—16 letters plus two spaces. From those 18-character phrases, I asked my questions from before. Still no luck. The phrase I needed definitely wasn't in these Wikipedia tables.

## Random old website to the rescue

In the "External links" section of the Wikipedia page, I found a [list of notable idioms](http://www.sabi.co.uk/Notes/miscPhrases.html) on an un-notable website. This list was comparatively short so I scanned the whole thing using my questions from above—nothing here either.

I _did_ find more links though. One of them was [Simply Latin,](http://www.sacklunch.net/Latin/index.php) another boring website. It was much more comprehensive and I knew there had to be a smarter way to look through these lists. I started looking for whole words—the same ones that I jotted down while going through the Wikipedia tables earlier. LABORE was calling to me[^2] so I went to the L table. Four entries down, there it was: [LABORARE EST ORARE.](http://www.sacklunch.net/Latin/L/laborareestorare.html)

Work is prayer. What a rush. I checked to make sure it wasn't a mirage: **R (4), A (3), E (3), O (2), B (1), L (1), S (1), T (1).** A perfect match!

I submitted my answer and the drawing took place a few days later. I had the right phrase but it was a random draw and my name didn't get pulled. Even so, this was a fun little challenge that I enjoyed solving. Congratulations to the winners!

[^1]: Or a paid trip to tour their headquarters and go to Disneyland. I probably would have (controversially) taken the book.
[^2]: My thinking here was that the company puts lots of work into their products and value high quality work. Maybe they'd choose a phrase that had something to do with labor.
