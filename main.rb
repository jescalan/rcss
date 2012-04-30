## RCSS
# Roots style sheets, an experiment with ruby and css magic

require './parser.rb'
require './generator.rb'

tree = parse('example.rcss')
generate(tree, "debug")

## Todo List
# - generator
# - another module that will run and replace variables
# - another module that will run and replace mixins (with keyword args)
# - a module that recognizes colors, for later.
#    - includes all css colors names, hex, short hex, rgb, hsl.
# - logic module (huge)
# - getting props from parents
# - media query handling




