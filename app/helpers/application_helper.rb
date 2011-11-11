module ApplicationHelper
  def favorite_button(resource)
    opts = {
        :id => dom_id(resource, :favorite),
        :remote => true,
    }

    if resource.favorited?
      opts[:class] = "btn active"
    else
      opts[:class] = "btn"
    end

    link_to("Favorite", [:toggle_favorite, resource], opts)
  end
end