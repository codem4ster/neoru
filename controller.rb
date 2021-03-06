module Neo
  class Controller
    attr_accessor :renderer,:layout


    def render(params={})
      if @layout.blank?
        content = Neo::View.new.render(params)
        Neo::Response.html(content)
      else
        params[:content] =  Neo::View.new.render(params)
        content = Neo::View.new(@layout).render(params)
        Neo::Response.html content
      end
    end

    def redirect(url)
      Neo::Response.redirect url
    end
    alias :redirect_to :redirect

    def path(name, parameters=[])
	    Neo.generate_url name, parameters
    end

    def render_view(view,params)
      content = Neo::View.new(view).render(params)
      Neo::Response.html content
    end
  end
end