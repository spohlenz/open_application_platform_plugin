module OpenApplicationPlatform::Rails::ViewExtensions
  def link_to_with_canvas_support(name, options={}, html_options=nil)
    link_to_without_canvas_support name, url_for(options), html_options
  end
  
  def url_for_with_canvas_support(*args)
    returning url_for_without_canvas_support(*args) do |url|
      url.gsub!(/^\//, canvas_path) if in_canvas? && url !~ /^#{controller.canvas_path}/
    end
  end
  
  def self.included(base)
    base.class_eval do
      alias_method_chain :link_to, :canvas_support
      alias_method_chain :url_for, :canvas_support
    end
  end
end
