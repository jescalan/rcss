## Parser.rb
# Parses a rcss file and converts it into an abstract syntax tree represented by Nodes.

require './node.rb'

# ----------------------------
# Global Variables
# ----------------------------

$default_indent = nil
$html_elements = [:a, :abbr, :address, :area, :article, :aside, :audio, :b, :base, :bdi, :bdo, :blockquote, :body, :br, :button, :canvas, :caption, :cite, :code, :col, :colgroup, :command, :datalist, :dd, :del, :details, :dfn, :div, :dl, :dt, :em, :embed, :fieldset, :figcaption, :figure, :footer, :form, :h1, :h2, :h3, :h4, :h5, :h6, :head, :header, :hgroup, :hr, :html, :i, :iframe, :img, :input, :ins, :keygen, :kbd, :label, :legend, :li, :link, :map, :mark, :menu, :meta, :meter, :nav, :noscript, :object, :ol, :optgroup, :option, :output, :p, :param, :pre, :progress, :q, :rp, :rt, :ruby, :s, :samp, :script, :section, :select, :small, :source, :span, :strong, :style, :sub, :summary, :sup, :table, :tbody, :td, :textarea, :tfoot, :th, :thead, :time, :title, :tr, :track, :u, :ul, :var, :video, :wbr]
$property_matcher = /([a-zA-Z\-]+):\s*([a-zA-Z0-9#"'\-\(\)\. ]+)/
$root = nil
$context = nil

# ----------------------------
# Main Function (External)
# ----------------------------

## Parse
# Opens the file, creates the root context, and goes through each line of the file
# ignoring empty lines and processing lines with text. Returns the entire AST when finished.
def parse(filename)
  file = File.open(filename, "r").readlines

  $root = Node.new('root')
  $context = $root

  file.each_with_index do |line, index|
    process_line(line, index) if line.match(/\S/)
  end

  return $root

end

# ----------------------------
# Internal Methods
# ----------------------------

### Count Indent
# Returns how many spaces the line has been indented
def count_indent(line)
  line.match(/(\s+)/)[1].length
end

### Count Indent
# Returns the number of times the line has been indented per the default indent
def indent_level(line)
  count_indent(line)/$default_indent
end

### Set Default Indent
# If no indent has been set already, set the default indent level.
# Only runs on the first indent it encounters
def set_default_indent(line)
  $default_indent = count_indent(line)
end

## Indented?
# Feed it a line, returns true if the line is indented and false if not
def indented?(line)
  line.gsub("\n", "").match(/(\s+)/).nil? ? false : true
end

### Find Context
# Performs a recursive search up the node tree until it finds an appropriate
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

    # this is where I need to look for variables, colors, and functions
    # add property should be split out to its own sub-method that detects these things

    $context.add_property(property)
  elsif line.match(/[#|\.]\w+/) || $html_elements.include?(line.match(/\w+/)[0].to_sym)

    # before immediately adding a child, need to check name against the mixin index and see
    # if it matches a mixin

    $context = $context.add_child(line, index)

    # there needs to be an else here that looks for traditional() mixin syntax
    # and another like that looks for @directives
    # - @media, @font-face, @keyframes, @extend
    # really some of these should only be allowed at root level

  else
    throw "Flagrant code error! Syntax error on line #{index} - make sure you are writing a valid selector."
  end
end

### Process Line
# This method is super dense, but is the core of the nesting functionality.

# First, it checks to see if there is an indent. If not, we're working with a
# root property, which means that it should be added as a child of $root, and
# the context should be switched to it, assuming it's a selector.

# If there is an indent, it needs to be checked and added under the right parent
# selector. If the line's indent is the current context's indent + 1, we are in the
# right context and it is added under the current context either as a prop/val or 
# selector by the add_selector_or_property() function.

# If the line's indent is less than the current context's indent, we need to figure
# out what it's parent is and nest it correctly. The find_context() function is called 
# and iterates recursively up the node tree until it finds a match. It then sets 
# that match as the current context and adds the line as a selector or property under it.

# Finally, an error is thrown if the line was indented too far.
def process_line(line, index)

  # there should be a check for interpolation here, and just run a simple replace for each line

  if !indented?(line)
    $context = $root
    add_selector_or_property(line, index)
    # check here for @import, @font-face, and @keyframes
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