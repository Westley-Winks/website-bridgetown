class Builders::TocInjector < SiteBuilder
  def build
    generator do
      site.resources.each do |resource|
        if resource.data.toc
          resource.content.prepend "- seed\n{:toc}\n"
        end
      end
    end
  end
end
