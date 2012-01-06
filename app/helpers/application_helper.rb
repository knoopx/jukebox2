module ApplicationHelper
  def iconic(char)
    content_tag(:span, "&#x#{char};".html_safe, :class => "iconic")
  end

  def favorite_button(resource)
    opts = {
        :id => dom_id(resource, :favorite),
        :remote => true,
    }

    if resource.favorited?
      opts[:class] = "btn danger active"
    else
      opts[:class] = "btn danger"
    end

    link_to(iconic("2764"), [:toggle_favorite, resource], opts)
  end


  def play_button(href, opts = {})
    link_to iconic("e047"), href, opts.merge(:class => "btn success", "data-play" => true)
  end

  def enqueue_button(href, opts = {})
    link_to iconic("2795"), href, opts.merge(:class => "btn success", "data-enqueue" => true)
  end
end