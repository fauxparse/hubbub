class WikiSweeper < ActionController::Caching::Sweeper
  observe WikiPage

  def after_save(record)
    expire_fragment :controller => "wiki", :action => "show", :id => record.to_param
    expire_fragment :controller => "wiki", :list => "categories"
  end
end
