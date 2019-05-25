class RablPresenter
  def self.represent(object, options)
    render_options = {
      :format => options[:env]['api.format'],
      :view_path => Rails.root.join('app/views')
    }
    Rabl::Renderer.new(options[:source], object, render_options).render
  end
end