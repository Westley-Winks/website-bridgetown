class Builders::TagPageGenerator < SiteBuilder
  def build
    hook :site, :post_read do
      all_tags = site.tags

      all_tags.each do |tag, resources|
        add_resource :pages, "t/#{tag}.md" do
          layout "page"
          title "tag: #{tag}"
          template_engine "erb"
          content "<% resources = site.tags['#{tag}'] %>\n<%= render Shared::List.new(collection: resources) %>"
        end
      end
    end
  end
end
