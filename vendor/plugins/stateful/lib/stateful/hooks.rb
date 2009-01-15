module Stateful
  module Hooks
    class Base

      class << self
        attr_reader :hook_names
        attr_reader :slot_names
      end

      def self.has *hook_names
        raise ArgumentError, hook_names unless hook_names.all? { |h| Symbol === h }
        @hook_names = hook_names
        @slot_names = @hook_names.map do |hook_name|
          [ :"before_#{hook_name}",
            hook_name,
            :"after_#{hook_name}"
          ]
        end.flatten
        @slot_names.each do |slot|
          attr_reader slot
          define_method "#{slot}=" do |symbol_or_proc|
            add slot, symbol_or_proc
          end
        end

      end

      # eval'ing strings is fucked, but until ruby 1.9
      # this is how it's gotta be

      def self.define_add_hook_method klass, hook_name

        klass.class_eval <<-EOF
          def #{hook_name} symbol = nil, &proc
            hooks.add :#{hook_name}, symbol, &proc
          end
        EOF
      end

      def self.install klass
        @slot_names.each do |s|
          define_add_hook_method klass, s
        end
      end

      def slot_names_from_hook_name hook_name
        h = hook_name.to_s
        ["before_#{h}", h, "after_#{h}"].map &:to_sym
      end

      def add hook_name, symbol_or_proc = nil, &block
        if !self.class.slot_names.include?( hook_name )
          raise( ArgumentError,
                 "Invalid hook: #{hook_name} #{self.class.slot_names.inspect}")
        elsif block_given?
          h = block
        elsif symbol_or_proc.is_a?( Symbol )
          h = symbol_or_proc
        elsif symbol_or_proc.is_a?( Proc   )
          h = symbol_or_proc
        else
          raise ArgumentError, "Need a Proc or Symbol: #{symbol_or_proc}"
        end
        instance_variable_set( "@#{hook_name}", h )
      end

      def remove hook_name
        if !self.class.slot_names.include?( hook_name )
          raise( ArgumentError,
                 "Invalid hook: #{hook_name} #{self.class.slot_names.inspect}")
        end
        instance_variable_set( "@#{hook_name}", nil )
      end

      def run_hook_slot slot_name, t
        case h = send( slot_name )
        when Symbol
          t.receiver.send( h, t)
        when Proc
          h.call( t )
        when nil
          # do nothing
        end
      end

      def run hook_name, t
        if hook_name == :on_exit
          hook_name = :exit
        end
        if hook_name == :on_entry
          hook_name = :entry
        end
        raise ArgumentError, "Invalid hook: #{hook_name}" unless self.class.hook_names.include?( hook_name )
        raise ArgumentError, "Not a transition: #{t}"     unless t.is_a?( Transition )
        slot_names_from_hook_name( hook_name ).each do |slot|
          run_hook_slot( slot, t )
        end
      end
    end

    class EventHooks < Base
      has :before, :during, :execute, :after, :halted
    end

    class StateHooks < Base
      has :entry, :exit

      alias :on_exit  :exit
      alias :on_entry :entry

      alias :on_exit=  :exit=
      alias :on_entry= :entry=


    end

    module StateMethods
      include Hooks

      def self.included klass
        StateHooks.install klass
      end

      def hooks
        @hooks ||= Stateful::Hooks::StateHooks.new( )
      end

    end # StateMethods

    module EventMethods
      include Hooks

      def self.included klass
        EventHooks.install klass
      end

      def hooks
        @hooks ||= Stateful::Hooks::EventHooks.new( )
      end

    end # EventMethods
  end # Hooks
end
