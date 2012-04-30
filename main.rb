## RCSS
# Roots style sheets, an experiment with ruby and css magic

require './parser.rb'
require './generator.rb'

tree = parse('example.rcss')
generate(tree, "compressed")

## Todo List
# - module that will run and replace variables
# - module that will run and replace mixins (with keyword args)
# - module that recognizes colors, for later.
#    - includes all css colors names, hex, short hex, rgb, hsl.
# - logic module (huge)
# - getting props from parents and generating them
# - media query handling




