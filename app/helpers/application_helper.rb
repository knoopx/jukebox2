module ApplicationHelper
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

    link_to("&#10084;".html_safe, [:toggle_favorite, resource], opts)
  end
end