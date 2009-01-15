## Models
require 'active_record'
module SpecModel
  def messages
    @messages ||= []
  end
end

class ModelWithStateful < ActiveRecord::Base
  include SpecModel
  include Stateful
  set_table_name "spec_models"
end

class Post < ActiveRecord::Base
end

class Posty < ActiveRecord::Base
  set_table_name "posts"
  include SpecModel
  include Stateful

  # helper methods for state
  attr_accessor :scribbles, :published_in

  def scribbles
    @scribbles ||=[]
  end

  def scribble_in_margins
    scribbles << 'wibble'
  end

  def add_to_publication pub
    @published_in << pub
  end
end

class EventTester < ActiveRecord::Base
  include SpecModel
  include Stateful

end     # EventTester
