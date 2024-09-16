---
copy_path: "_p/rebuilt-with-bridgetown.md"
date: 2024-09-16
description: "How I rebuilt my website using Bridgetown."
lastmod: 2024-09-16
publish: true
slug: rebuilt-with-bridgetown
summary: "Yet another website revision, this time with Bridgetown, Ruby, and SCSS. Here's how I added a new style, tag features, new link design, and more to my site. I love my website again."
tags:
  - ruby
  - coding
  - tech
title: How I Rebuilt My Website with Bridgetown
toc: true
---

Just three short months after <%= link_to "rebuilding my website with Astro,", "collections/_p/creating-something.md", class: "internal-link" %> I rebuilt it again. This time, I am using [Bridgetown](https://www.bridgetownrb.com/) as a site generator. It's written in Ruby (which I've been looking for an excuse to learn) and strives to optimize for developer happiness and provide everything needed to build a great website. This is how I built my great website and what I learned.

## Applying a face lift

The visual design is the biggest, most obvious change that I am most excited about. No more monochrome! I was reminded in the last rebuild that I'm not much of a designer. I've always liked and wanted to do a "neobrutalist" site design but quickly got overwhelmed with picking colors, border widths, and box shadow thickness.

To solve this, I used [Open Props](https://open-props.style/) to load in a bunch of useful and well-thought variables. Instead of creating my own CSS variables and design system, I can just write `var(--purple-4)` to get the right shade of purple that I want. If I want it lighter, I lower the number and if I want it darker, I increase the number. As frictionless and simple as that. If I wanted to do the same thing by scratch I'd have to go to some color picker website, hope I choose the right shade of purple that will look good, and paste the hex code into the CSS file.

This same principle applies to font sizes, spacing sizes, borders, and more. It really took the overwhelm of choosing the right variable names and colors out of the equation and let me quickly experiment. It's like [Tailwind](https://tailwindcss.com/) but you don't combine your HTML and CSS. Each short keyword maps to a longer CSS variable:

- `var(--size-px-6)` becomes `28px`
- `var(--font-size-4)` becomes `1.5rem`
- `var(--cyan-8)` becomes `#0c8599`

I combined Open Props with the power of [SCSS](https://sass-lang.com/) to randomly choose some colors. For the landing pages that list content (like [posts](/p/), [weeknotes](/w/), or [book notes](/b/)), each item in the list gets a random color. The following SCSS code colors list items randomly while keeping the tag buttons and title that sit on top of it the same color, just two shades lighter.

```scss
$colors: red, orange, yellow, cyan, indigo, pink;
$repeat: 20;

@for $i from 1 through $repeat {
  $color: nth($colors, random(length($colors)));

  .list-item:nth-child(#{length($colors)}n+#{$i}) {
	background: var(--#{$color}-4);

	.list-item__title {
      background: var(--#{$color}-2);
	}

    .list-item__tag {
      background: var(--#{$color}-2);
    }
  }
}
```

For the cherry on top, I made *heavy* use of `:hover()` and `transform` CSS features so that elements pop out a little when you hover over them. Basically every panel, button, and link do this. It makes the website a bit more [squishy](https://sashachapin.substack.com/p/what-the-humans-like-is-responsiveness) and fun to use.

A huge thank-you goes to [Alessandro Muraro](https://alexmuraro.me/) for the design inspiration. Check out their website, it's a thing of beauty.

## Redesigning the home page

I've never really known what to put on the front page of my website. Taking inspiration from [Alessandro Muraro](https://alexmuraro.me/) again, I have the following sections on my home page, arranged using [CSS grid](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_grid_layout/Basic_concepts_of_grid_layout) which I've never used before as a bit of a [flexbox](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_flexible_box_layout/Basic_concepts_of_flexbox) fanboy:

- **Latest posts.** The last ten things I posted, automatically generated and listed in a long, skinny column.
- **Recent links.** Manually updated list of links and commentary that I thought were worth sharing. Probably going to be updated weekly along with posting my [weeknotes.](/w/) This section creates the bulk of the front page.
- **Elsewhere.** Links to ways to contact me or otherwise find me on the internet.
- **Browse tags.** Bank of links to all available tags on my site, automatically generated from my content.
- **Who am I?** My version of an "About" page with ideas taken from [Simone at Minutes to Midnight.](https://minutestomidnight.co.uk/blog/kafkaesque-digital-relationship-with-ourselves/) I list my core values and how they show up in my life as I think that is a better representation of me than my job title or other superficial points in a typical bio.
- **Colophon.** Credits and gratitude for the tools and people that helped me make my website.

Combined, these sections do a pretty good job of giving the user a good idea about who I am while also letting them immediately start clicking and exploring.

## Creating a tag system

Tags are something I've never really taken advantage of. I prefer folders and collections to group my content, using tags for just a few very specific cases. Now, tags are first-class citizens on my website.

Using tags makes jumping around my website easier and more enjoyable while making the whole thing feel like a more cohesive, interconnected entity. This does require thoughtful and consistent use of tags, though, which I'm not quite good at yet. I'll be thinking about how to do this better in the future.

Each tag has its own page at `/t/<tag-name>/` that lists all posts from across my site that have that tag. These pages are generated automatically via a plugin that was surprisingly easy to write. In just a few lines, I had a plugin that pulls all the tags I've used and generates a page for each of them:

```ruby
all_tags = site.tags
all_tags.each do |tag, resources|
  add_resource :pages, "t/#{tag}.md" do
    layout "page"
    title "tag: #{tag}"
    template_engine "erb"
    content "<%% resources = site.tags['#{tag}'] %>\n<%%= render Shared::List.new(collection: resources) %>"
  end
end
```

## Pulling in content automatically

Bridgetown and Ruby make it really easy to manipulate, gather, add, or convert content. In my [past](https://github.com/Westley-Winks/obsidian-to-hugo) [websites](https://github.com/Westley-Winks/obsidian-to-astro-sync), I've used a script that pulls in notes from my <%= link_to "Obsidian vault", "collections/_p/obsidian-pcv.md", class: "internal-link" %> and converts all the wikilinks to a format specific to the framework.

This time, thanks to Ruby, [Thor,](http://whatisthor.com/) and a simpler algorithm, it was much cleaner. I can definitely see why people who like Ruby *really* like Ruby. I thoroughly enjoyed learning and writing it. Watch out, Python.

My new script walks my Obsidian vault and looks for notes with a tag in the front matter called `copy_path`. If that tag exists, it copies the note to the path given. The title of the note and the path that it was copied to are stored for later when converting the links.

After all notes are copied, the script scans each one and finds wikilinks based on a regex and parses them out into the linked note and the text to display. The linked note gets looked up to check if it was copied over according to the information that was stored earlier. If so, it gets converted end plugged into following helper, specific to Bridgetown: `<%%= link_to "text to display", "linked-note.md" %>` Otherwise, just the text to display is written without a link. This lets me link to anything in Obsidian and only what is published gets linked to in Bridgetown.

Images that are linked are not automatically copied over. The script spits out a list of images that were linked to and asks you to manually copy them over to the `/src/assets/` folder.

Lastly, my Kindle highlights are stored alongside my book notes under a `Highlights` header. The last step of the script is to lop these off so my messy highlights don't get displayed.

## Redesigning the URLs

I've wanted shorter, cleaner links for a while. They are easier to look at, type, copy, write, and say. They weren't really long to begin with but compare these:

- `wwinks.com/writing/wellbeing-tools/` vs. `wwinks.com/p/wellbeing-tools/`
- `wwinks.com/writing/weeknotes-2024w36` vs.`wwinks.com/w/2024w36`

Much cleaner. The `/writing/` path is a vestige from the very beginning when I didn't want to call my blog a blog. Here are all of my current content URLs:

- **Standard [posts:](/p/)** `/p/<title>/` (was `/writing/<title>/`)
- **[Book notes:](/b/)** `/b/<title>/` (was `/books/<title>/`)
- **[Peace Corps](/peace-corps/) posts:** `/peace-corps/<title>` (unchanged)
- **[Tags:](/t/)** `/t/<tag>/` (new)
- **[Weeknotes](/w/)** `/w/<YYYYwWW>/` (new)

Many blogs include the date or year in the link (e.g. `example.com/2024/a-blog-post/`) to make the posting date quickly evident or to avoid naming conflicts from two pages being titled the same thing. I chose not to do that because it lengthens the URL without really adding any value. The posting date and last modified date are in the post itself so it doesn't need to be in the URL too. I'm not worried about naming conflicts; if [Derek Sivers](https://sive.rs/su) who uses just a few characters in his URLs doesn't have that problem, I certainly won't.

Yes, I committed [a cardinal sin](https://www.w3.org/Provider/Style/URI) and broke some links. I think it was worth it, though, to get shorter, more intuitive, and more sustainable URLs. To prevent too much [link rot,](https://en.wikipedia.org/wiki/Link_rot) I switched hosting providers from GitHub Pages to Netlify.

With Netlify, you can specify server-side redirects to redirect users from one URL to another. If someone visits an old link that goes to `wwinks.com/books/upgrade/`, they will now be redirected to `wwinks.com/b/upgrade`. Same with all of the above changes. I will likely change `/peace-corps/` to `/pc/` in the future but wanted to test out the redirect functionality first. These posts are very important to me and I want to guarantee that anyone trying to read them will be able to.

## "Is there some kind of competition or something?"

What's the point? Why did I put in all this time and energy and stay up too late some nights just to make my website look cooler?

Besides learning so much, as that is always worth the effort to me, **I love my website again.**

It makes me smile. I'm proud of my site and I'm excited to show it off. I know exactly what's on every page, yet I still enjoy looking, browsing, and clicking around. I really like the tooling, much more than my last site, and I'm looking forward to the next time I can hack on the underlying code to implement more features. It's *my* site and it represents me well.
