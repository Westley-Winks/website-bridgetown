class Builders::Inspectors < SiteBuilder
  def build
    inspect_html do |document|
      toc = document.query_selector "article ul#markdown-toc"
      if toc
        main = document.query_selector "main"
        title = document.query_selector "h1"
        article = document.query_selector "article"
        article.add_previous_sibling toc
        toc.wrap("<nav class='toc'></nav>")
      end
    end
  end
end
