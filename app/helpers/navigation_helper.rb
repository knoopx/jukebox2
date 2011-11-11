module NavigationHelper
  class Navigation
    def initialize(context, namespace, options = {}, &block)
      @namespace = namespace
      @context = context
    end

    def current_tab?(tab)
      @context.current_tab?(tab, @namespace)
    end

    def method_missing(name, *args, &block)
      if block_given?
        render_content(name, @context.capture(&block), *args)
      else
        render_content(name, *args)
      end
    end

    def render_content(name, content, options = {})
      @context.concat @context.content_tag(:li, content, tag_options(name, options))
    end

    def tag_options(name, options)
      options ||= {}
      classes = options.include?(:class) ? options[:class].split(/\s+/) : []
      classes << "active" if current_tab?(name)
      options[:class] = classes.join(' ') if classes.any?
      options
    end
  end

  def navigation(options = {}, &block)
    raise LocalJumpError, "no block given" unless block_given?
    namespace = options.delete(:namespace) || :default
    navigation = Navigation.new(self, namespace, options)
    html = content_tag("ul", options) do
      yield navigation
    end
    html
  end

  def main_navigation(*controllers)
    navigation do |n|
      controllers.each do |controller|
        n.send(controller, link_to(controller.to_s.humanize, send("#{controller}_path")))
      end
    end
  end
end