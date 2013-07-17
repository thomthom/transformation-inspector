#-------------------------------------------------------------------------------
#
# Thomas Thomassen
# thomas[at]thomthom[dot]net
#
#-------------------------------------------------------------------------------

require 'sketchup.rb'
require 'extensions.rb'

#-------------------------------------------------------------------------------

module TT
 module Plugins
  module TransformationInspector

  ### CONSTANTS ### ------------------------------------------------------------

  # Plugin information
  PLUGIN_ID       = 'TT_Transformation'.freeze
  PLUGIN_NAME     = 'Transformation Inspector'.freeze
  PLUGIN_VERSION  = '1.1.1'.freeze

  # Resource paths
  FILENAMESPACE = File.basename( __FILE__, '.rb' )
  PATH_ROOT     = File.dirname( __FILE__ ).freeze
  PATH          = File.join( PATH_ROOT, FILENAMESPACE ).freeze
  PATH_UI       = File.join( PATH, 'ui' ).freeze


  ### EXTENSION ### ------------------------------------------------------------

  unless file_loaded?( __FILE__ )
    loader = File.join( PATH, 'core.rb' )
    ex = SketchupExtension.new( PLUGIN_NAME, loader )
    ex.description = 'Inspect and modify the transformation matrix directly.'
    ex.version     = PLUGIN_VERSION
    ex.copyright   = 'Thomas Thomassen © 2012–2013'
    ex.creator     = 'Thomas Thomassen (thomas@thomthom.net)'
    Sketchup.register_extension( ex, true )
  end

  end # module TransformationInspector
 end # module Plugins
end # module TT

#-------------------------------------------------------------------------------

file_loaded( __FILE__ )

#-------------------------------------------------------------------------------