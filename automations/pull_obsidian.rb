=begin
This automation pulls files from an Obsidian vault. It copies files over if there is a `copy_path` key in the frontmatter of the note. Wikilinks get converted to Bridgetown links (via the `link_to` helper) if the linked note is published. Images must be manually copied over to the `/assets` folder.

Inspiration and regex come from this project.
https://github.com/onurozer/bridgetown-obsidian/blob/main/lib/bridgetown_obsidian/builder.rb
=end

OBSIDIAN_VAULT_PATH = Dir.home() + '/jd_wiki'
REGEX_WIKILINK = /(?<!!)\[\[([^\]]+?)(?:\|([^\]]+))?\]\]/
REGEX_IMAGES = /(?<!!)!\[\[([^\]]+?)(?:\|([^\]]+))?\]\]/
# REGEX_IMAGES = /!\[\[(.+?)\]\]/

def copy_notes
  bt_front_matter_loader = Bridgetown::FrontMatter::Loaders::YAML
  all_md_file_paths = Dir["#{OBSIDIAN_VAULT_PATH}/**/*.md"]

  say "Copying notes from Obsidian vault at #{OBSIDIAN_VAULT_PATH}"

  path_map = {}

  all_md_file_paths.each do |note_path|
    vault_title = File.basename note_path, ".*"
    if bt_front_matter_loader.header? note_path
      note_content = File.read(note_path)
      note = bt_front_matter_loader.new("")
      note = note.read(note_content)
      if note.front_matter.key? "copy_path"
        copy_path = "collections/#{note.front_matter["copy_path"]}"
        path_map[vault_title] = copy_path
        copy_file note_path, "src/#{copy_path}"
        say_status "copy", "#{vault_title} => src/#{copy_path}"
      end
    end
  end
  return path_map
end

def convert_wikilinks(bt_note_path)
  bt_note_content = File.read(bt_note_path)
  bt_note_content.gsub!(REGEX_WIKILINK) do |match|
    wikilink = Regexp.last_match(1)
    wikilink_title = Regexp.last_match(2) || wikilink
    if $path_map.key? wikilink
      wikilink = $path_map[wikilink]
      "<%= link_to \"#{wikilink_title}\", \"#{wikilink}\", class: \"internal-link\" %>"
    else
      "#{wikilink_title}"
    end
  end

  bt_note_content.gsub!(REGEX_IMAGES) do |match|
    image = Regexp.last_match(1)
    alt_text = Regexp.last_match(2) || image
    say_status "manual copy", image, :red
    "![#{alt_text}](/assets/#{image})"
  end

  bt_note_content = bt_note_content.split(/## Highlights/)[0]

  File.write bt_note_path, bt_note_content
end

def remove_kindle_highlights(note_content)
end

def self.source_root
  File.dirname(__FILE__)
end

$path_map = copy_notes
$path_map.each_value do |bt_note_path|
  convert_wikilinks("src/#{bt_note_path}")
end
