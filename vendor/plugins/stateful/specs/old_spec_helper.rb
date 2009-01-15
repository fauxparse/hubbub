
module OldSpecHelper

  def setup_post_lifecycle

    Stateful.specify( Post, :lifecycle ) do

      state :first_draft do |state|
        # if the arity of the block is 0, instance_eval it on the receiver
        state.event :revise, :to => :draft do |event|
          event.execute do |post|
            post.scribble_in_margins()
          end
        end
      end

      state :draft do |s|
        s.event :review, :transitions_to => :reviewed_draft do |e|
          e.execute do |post, user|
            post.reviewers      << user
            user.reviewed_posts << post
          end
        end
      end

      state :reviewed_draft do |s|
        s.event :finalize,           :to => :final_draft
      end

      state :final_draft do |s|
        s.event :publish, :to => :published do |event|
          event.requires :approved_by_supervisor?

          event.execute do |post, publication|
            post.add_to_publication publication
          end
        end
      end

      state :published
      state :forgotten_draft
      state :abandoned_draft

      ## EVERY_STATE

      every_state do |state|

        state.on_entry do |post|
          post.messages << "#{post.to_s} \n is entering #{state.name}"
        end

        state.event( :forget,
                     :transitions_to => :forgotten_draft,

                     :only => [ :first_draft,
                                :draft,
                                :reviewed_draft,
                                :abandoned_draft] )  do |event|

          event.execute do |post|
          end
        end
      end # every_state

      ## EVERY_EVENT

      every_event do |event|

        event.requires( :valid?,
                        :message => lambda { |post| post.errors.full_messages.inspect })

        event.requires( :spelling_correct?,
                        :message => "Can't publish spelling errors",
                        :only  => [:publish] )

        event.requires( :panache,
                        :message => "If it doesn't have panache, it's not final!",
                        :only  => [ :finalize, :publish ] ) do
          post.has_panache?
        end

        event.after do |post|
          post.save!
        end

      end # every_event
    end   # specify
  end     # setup_post_lifecycle

  def setup_event_tester
    Stateful.specify( EventTester, :stateful ) do

      state :new do |state|
        state.on_entry do |t|
          t.obj.messages << :on_entry
        end

        state.event :change, :to => :old do |event|
          event.before do |t|
            t.obj.messages << :before
          end

          event.execute do |t|
            t.obj.messages << :execute
          end

          event.after do |t|
            t.obj.messages << :after
          end
        end

        state.on_exit do |t|
          t.obj.messages << :on_exit
        end
      end

      state :old do |state|
        state.on_entry do |t|
          t.obj.messages << :on_entry
        end

        state.on_exit do |t|
          t.obj.messages << :on_exit
        end
      end

      every_state do |state|
        state.after_entry do |t|
          t.obj.messages << :after_on_entry
        end

        state.after_exit do |t|
          t.obj.messages << :after_on_exit
        end
      end

      every_event do |event|
        event.before_before do |t|
          t.obj.messages << :before_before
        end

        event.before_execute do |t|
          t.obj.messages << :before_execute
        end

        event.before_after do |t|
          t.obj.messages << :before_after
        end
      end # every_event

    end   # specify

  end

  def setup_simple_stateful

    Stateful.specify( :simple, :column_name => 'order_status' ) do

      # default state
      state(:new) do |state|

        state.event( :save_draft,
                     :to => :draft ) do |event|

          event.execute do |post, author|
            post.public = false
            post.author = author
            post.save!
          end
        end
      end # new

      state(:draft) do |state|

        state.event(:scrap, :to => :scrapped ) do |event|

          # event.requires ...

          event.execute do |post, author|
            post.scrapped_at = Time.now
            post.save!
          end

        end
      end # draft

      state(:publish) do |state|
        state.event( :unpublish, :to => lambda { |order| order.previous_state })
      end

      state(:composting) do |state|
        state.event( :uncompost, :to => lambda { |order| order.previous_state })
      end

      state(:scrapped)

      # posts can be published or composted from any state
      every_state do |state|

        state.event( :publish!,
                     :to     => :published,
                     :except => :new ) do |event|

          event.halt_if("Post does not have a title") do |post|
            post.title.blank?
          end

          event.before do |post, author|
            post.permalink = post.generate_permalink
          end

        end

        state.event( :compost,
                     :to     => :composting )

        state.event( :archive,
                     :to     => :composting )

      end # every_state

      every_event do |event|

        event.before do |order, author, *otherargs|
          order.last_updated_by = author
          order.previous_state  = event
        end

        event.requires( :valid?, # name of method to call on post; will be called with no arguments
                        :name    => :validate_post, # identifies this rule for reference by satisfy
                        :message => lambda { |post| post.errors.full_messages } )

        event.requires( :name => :authorization,
                        :message => "I can't do that, Dave.") do |event, author, *otherargs|
          post = event.receiver
          author.send("can_#{event.name}?", post)
        end

        event.satisfy( :meta => {
                         :debug_info => "Superusers can ignore most preconditions"
                       }, :except => :validate_post ) do |event, author, *otherargs|
          author.is_superuser?
        end

        event.after do |event, *args|
          event.save!
        end

      end # every_event

    end # specify
  end   # setup_post_lifecycle

end
