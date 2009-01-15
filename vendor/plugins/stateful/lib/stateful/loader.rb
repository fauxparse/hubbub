# Loads the rest of Stateful. Nothing more.

module Stateful
  class Loader
    class << self

      def load!

        load_library 'submodules'
        load_library 'hooks'
        load_library 'rules'
        load_library 'state'

        Dir[ "#{load_path}/*.rb" ].sort.each do |library|
          load_library library
        end
      end

      protected

      def load_path
        @@lib_path ||= File.expand_path( File.dirname( __FILE__ ))
      end

      def load_library name
        name = name + '.rb' unless name =~ /\./
        if name == File.basename( name )
          name = "#{File.join( load_path, name )}"
        end
        require name
      end

    end
  end
end
