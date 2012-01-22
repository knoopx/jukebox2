module ApplicationHelper
  include Jukebox2::Sorting::Helpers
  include Jukebox2::Filtering::Helpers

  def iconic(char)
    content_tag(:span, "&#x#{char};".html_safe, :class => "iconic")
  end

  def favorite_link(resource, opts = {})
    css_class = opts.fetch(:class, "").split(" ")
    css_class.delete("favorite")
    css_class.delete("unfavorite")
    css_class << (resource.favorited? ? "unfavorite" : "favorite")

    opts.merge! :id => dom_id(resource, :favorite),
                :remote => true,
                :class => css_class.reject(&:blank?).uniq.join(" ")

    link_to(iconic("2764"), polymorphic_path([:toggle_favorite, resource], :options => opts), opts)
  end

  def play_link(href, opts = {})
    link_to iconic("e047"), href, opts.merge(:class => ["play", opts[:class]].reject(&:blank?).join(" "), "data-play" => true)
  end

  def enqueue_link(href, opts = {})
    link_to iconic("2795"), href, opts.merge(:class => ["enqueue", opts[:class]].reject(&:blank?).join(" "), "data-enqueue" => true)
  end

  def formatted_length(seconds)
    seconds = seconds.to_i # todo: just store it as int on database
    hours = seconds/3600
    minutes = (seconds/60 - hours * 60)
    seconds = (seconds - (minutes * 60 + hours * 3600))
    "%02d:%02d" % [minutes, seconds]
  end

  def description(text)
    doc = Nokogiri::HTML(text)
    doc.search("a[href*='http://www.last.fm/music/']").each do |a|
      artist_name = CGI.unescape(a["href"].split("/").last)
      a["href"] = artists_path(:search => {:name_like => artist_name})
    end
    simple_format doc.inner_html
  end
end