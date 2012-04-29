## RCSS
# Roots style sheets, an experiment with ruby and css magic

require './parser.rb'

tree = parse('example.rcss')
puts tree.children.inspect



