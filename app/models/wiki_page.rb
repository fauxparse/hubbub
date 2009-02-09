require "erb"

class WikiPage < ActiveRecord::Base
  WIKI_LINK_PATTERN = /\b([A-Z]+[a-z]+[A-Z]\w+)|\[\[(([^\:\]]+)(\:([^\]]+))?)\]\]/

  validates_presence_of :title, :author_id
  validates_uniqueness_of :title, :scope => :company_id
  validates_format_of :title, :with => /^[\w _\/]+$/, :message => "should contain only alphanumeric characters, forward slashes, and spaces"
  belongs_to :author, :class_name => "User"
  belongs_to :company
  
  alias_attribute :to_s, :title

  versioning(:title, :body, :author_id) do |version|
    version.repository = returning File.join(RAILS_ROOT, "wiki.git") do |path|
      unless File.exist? path
        FileUtils.mkdir_p path
        FileUtils.chmod 0755, path
        system "cd #{path} && git init --bare"
      end
    end
    puts version.repository
    version.message = lambda { |page| "Updated by #{page.author}" }
  end

  acts_as_textiled :body

  def self.escape_page_title(title)
    ERB::Util.url_encode(title).gsub("%20", "+").gsub("%2F", "/")
  end

  def to_param
    @param ||= self.class.escape_page_title(title)
  end
  
  def page_title
    File.basename(title)
  end
  
  def textiled_version_of_with_wiki_linking(raw, options = {})
    wiki_links = raw.scan WIKI_LINK_PATTERN
    page_titles = wiki_links.collect { |w| w[0] || w[4] || w[2] }.uniq
    pages = company.wiki_pages.find_all_by_title page_titles
    raw.gsub!(WIKI_LINK_PATTERN) do |match|
       page_title, link_title = $1 || $5 || $3, $1 || $3
       page = pages.detect { |p| p.title == page_title }
       classes = "wiki"
       classes << " missing" unless page
       "<a href=\"/wiki/#{self.class.escape_page_title(page_title)}\" class=\"#{classes}\" title=\"#{link_title}\">#{link_title}</a>"
    end
    textiled_version_of_without_wiki_linking(raw, options)
  end
  alias_method_chain :textiled_version_of, :wiki_linking
end
