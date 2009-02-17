module Err 
  module Acts #:nodoc: all
    module Textiled
      include ActionView::Helpers::TagHelper
      include ActionView::Helpers::TextHelper

      def self.included(klass)
        klass.extend ClassMethods
      end

      module ClassMethods
        def acts_as_textiled(*attributes)
          @textiled_attributes = []

          @textiled_unicode = String.new.respond_to? :chars

          ruled = attributes.last.is_a?(Hash) ? attributes.pop : {}
          attributes += ruled.keys

          type_options = %w( plain source )

          attributes.each do |attribute|
            define_method(attribute) do |*type|
              type = type.first

              if type.nil? && self[attribute]
                t = textiled[attribute.to_s]
                if t.nil?
                  t = textiled_version_of self[attribute], Array(ruled[attribute])
                  # preserve whitespace for haml
                  t = t.chomp("\n").gsub(/\n/, '&#x000A;').gsub(/\r/, '')
                  textiled[attribute.to_s] = t
                end
                t
              elsif type.nil? && self[attribute].nil?
                nil
              elsif type_options.include?(type.to_s)
                send("#{attribute}_#{type}")
              else
                raise "I don't understand the `#{type}' option.  Try #{type_options.join(' or ')}."
              end
            end

            define_method("#{attribute}_plain",  proc { strip_redcloth_html(__send__(attribute)) if __send__(attribute) } )
            define_method("#{attribute}_source", proc { __send__("#{attribute}_before_type_cast") } )

            @textiled_attributes << attribute
          end

          include Err::Acts::Textiled::InstanceMethods
        end

        def textiled_attributes
          Array(@textiled_attributes) 
        end
      end

      module InstanceMethods
        def textiled
          textiled? ? (@textiled ||= {}) : @attributes.dup
        end

        def textiled?
          @is_textiled != false
        end

        def textiled=(bool)
          @is_textiled = !!bool
        end

        def textilize
          self.class.textiled_attributes.each { |attr| __send__(attr) }
        end

        def reload(options = nil)
          textiled.clear
          super
        end

        def write_attribute(attr_name, value)
          textiled[attr_name.to_s] = nil
          super
        end
        
        def textiled_version_of(raw, options = {})
          RedCloth.new(raw, options).to_html
        end

      private
        def strip_redcloth_html(html)
          returning html.dup.gsub(html_regexp, '') do |h|
            redcloth_glyphs.each do |(entity, char)|
              sub = [ :gsub!, entity, char ]
              @textiled_unicode ? h.chars.send(*sub) : h.send(*sub)
            end
          end
        end

        def redcloth_glyphs
           [[ '&#x000A;', "\n"],
            [ '&#8217;', "'" ], 
            [ '&#8216;', "'" ],
            [ '&lt;', '<' ], 
            [ '&gt;', '>' ], 
            [ '&#8221;', '"' ],
            [ '&#8220;', '"' ],            
            [ '&#8230;', '...' ],
            [ '\1&#8212;', '--' ], 
            [ ' &rarr; ', '->' ], 
            [ ' &#8211; ', '-' ], 
            [ '&#215;', 'x' ], 
            [ '&#8482;', '(TM)' ], 
            [ '&#174;', '(R)' ],
            [ '&#169;', '(C)' ]]
        end

        def html_regexp
          %r{<(?:[^>"']+|"(?:\\.|[^\\"]+)*"|'(?:\\.|[^\\']+)*')*>}xm
        end
      end
    end
  end
end
