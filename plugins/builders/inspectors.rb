class Builders::Inspectors < SiteBuilder
  def build
    inspect_html do |document|
      toc = document.query_selector "article ul#markdown-toc"
      if toc
        title = document.query_selector "h1"
        article = document.query_selector "article"

        article.add_previous_sibling toc
        toc.wrap("<div class='toc-container'></div>")
        toc.wrap("<nav class='toc card'></nav>")
        toc.prepend_child "<a href='#top'>#{title.content}</a>"
        nav = document.query_selector "main nav"
        nav.add_previous_sibling "<button id='menu-button' aria-expanded='false'>Table Of Contents</button>"
      end
    end
  end
end
