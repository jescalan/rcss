## RCSS
# Roots style sheets, an experiment with ruby and css magic

# ----------------------------
# Global Variables
# ----------------------------

$default_indent = nil
$html_elements = [:a, :abbr, :address, :area, :article, :aside, :audio, :b, :base, :bdi, :bdo, :blockquote, :body, :br, :button, :canvas, :caption, :cite, :code, :col, :colgroup, :command, :datalist, :dd, :del, :details, :dfn, :div, :dl, :dt, :em, :embed, :fieldset, :figcaption, :figure, :footer, :form, :h1, :h2, :h3, :h4, :h5, :h6, :head, :header, :hgroup, :hr, :html, :i, :iframe, :img, :input, :ins, :keygen, :kbd, :label, :legend, :li, :link, :map, :mark, :menu, :meta, :meter, :nav, :noscript, :object, :ol, :optgroup, :option, :output, :p, :param, :pre, :progress, :q, :rp, :rt, :ruby, :s, :samp, :script, :section, :select, :small, :source, :span, :strong, :style, :sub, :summary, :sup, :table, :tbody, :td, :textarea, :tfoot, :th, :thead, :time, :title, :tr, :track, :u, :ul, :var, :video, :wbr]
$property_matcher = /([a-zA-Z\-]+):\s*([a-zA-Z0-9#"'\-\(\)\.]+)/
$root = nil
$context = nil
# probably should be an indent matcher here. these could also be global methods that include
# match, like obj.prop_val or obj.indent

# ----------------------------
#### Classes
# ----------------------------

# this is for a css selector, contains one or many prop/val pairs
class Node
  attr_accessor :selector, :parent, :properties, :indent, :children

  # worth thinking about adding line, for debugging during generation

  def initialize(selector, parent = nil)
    @selector = selector.strip # get rid of whitespace and line breaks
    @parent = parent
    @properties = Array.new
    @children = Array.new

    # each line carries a line break which registers as whitespace
    # and must be sanitized before indent detection
    sanitized_selector = selector.gsub("\n", "")

    if sanitized_selector.match(/(\s+)/).nil?
      @indent = 0
    else
      @indent = sanitized_selector.match(/(\s+)/)[1].length/$default_indent
    end

    # ------------------------------------------------------------------------------

  end

  def add_property(prop)
    @properties << Hash[prop[1], prop[2]]
  end

  # adds a new node with itself as the parent, adds to the list of children
  def add_child(line)
    child = Node.new(line, self)
    @children << child

    # testing output
    puts "node added: #{child.selector} with parent #{child.parent.selector if child.parent}"
    # puts "properties: #{child.properties}"

    # context is not getting set correctly! properties are not being added

    return child
  end

end

# Testing classes 
# $default_indent = 2
# node = Node.new("p")
# node.add_property("  color: red")
# node.add_property("  background: blue")
# node2 = Node.new("  .hello", node)
# node2.add_property("    background-image: url('hello.png')\n".match($property_matcher))
# node2.list_properties
# puts node2.indent.inspect

# ----------------------------
# Methods
# ----------------------------

# Most of these are used for indent detection and tokenization

# If the line is empty
def empty_line(line)
  # puts "empty line"
end

### Count Indent
# Returns how many spaces the line has been indented
def count_indent(line)
  line.match(/(\s+)/)[1].length
end

### Count Indent
# Returns the number of times the line has been indented
def indent_level(line)
  count_indent(line)/$default_indent
end

### Set Default Indent
# If no indent has been set already, set the default indent space.
# Only runs on the first indent it encounters
def set_default_indent(line)
  $default_indent = count_indent(line)
end

### Find Context
# One of the most important but logically twisted methods here, this one
# performs a recursive search up the node tree until it finds an appropriate
# parent for a line based on its indent.
def find_context(context, line)
  if context.nil?
    throw "Flagrant code error! Something in the indentation is seriously screwed up"
  elsif context.indent + 1 == indent_level(line)
    return context
  else
    find_context(context.parent, line)
  end
end

## Add selector or property
# Takes a line and figures out if it's a prop/val or selector. If it is
# a prop/val, it is added under the current context. If it's a selector, it's added
# as a child of the current context then sets itself as the new context. If it's not
# read as a selector or prop/val, a syntax error is thrown.
def add_selector_or_property(line, index)
  property = line.match($property_matcher)
  if property && property.length == 3
    $context.add_property(property)
  elsif line.match(/[#|\.]\w+/) || $html_elements.include?(line.match(/\w+/)[0].to_sym)
    $context = $context.add_child(line)
  else
    throw "Flagrant code error! Syntax error on line #{index} - make sure you are writing a valid selector."
  end
end

## Indented?
# Feed it a line, returns true if indented and false if not
def indented?(line)
  line.gsub("\n", "").match(/(\s+)/).nil? ? false : true
end

### Process Line
# This method is super dense, but extremely important to how rcss works.

# First, it checks to see if there is an indent. If not, we're working with a
# root property, which means that it should be added as a child of $root, and
# the context should be switched to it, assuming it's a selector.

# If there is an indent, it needs to be checked and added under the right parent
# selector. If the line's indent is the current context's indent + 1, this is the
# right selector and it is added either as a prop/val or selector by the
# add_selector_or_property function.

# If the line's indent is less than the current context's indent, we need to figure
# out what it's parent is and nest it correctly. The find_context function iterates
# recursively up the node tree until it finds a match. It then sets that match as the
# current context and adds the line as a selector or property under it.

# Finally, an error is thrown if the line was indented too far.
def process_line(line, index)

  if !indented?(line)
    $context = $root
    add_selector_or_property(line, index)
  else

    set_default_indent(line) if $default_indent.nil?

    if indent_level(line) == $context.indent + 1
      add_selector_or_property(line, index)
    elsif indent_level(line) < $context.indent + 1
      $context = find_context($context.parent, line)
      add_selector_or_property(line, index)
    else
      throw "Flagrant code error! You indented line #{index} too far"
    end

  end

end

# ----------------------------
### Main Process
# ----------------------------

file = File.open("example.rcss", "r").readlines

$root = Node.new('root')
$context = $root

file.each_with_index do |line, index|

  if line == "\n" or line.match(/\w/).to_s.empty? # this could be compressed to a single regex
    empty_line(line)
  else
    process_line(line, index)
  end

end



