class Node
  attr_accessor :selector, :parent, :properties, :indent, :children, :line

  def initialize(selector, index = nil, parent = nil)
    @selector = selector.strip # get rid of whitespace and line breaks
    @parent = parent
    @properties = Array.new
    @children = Array.new
    @line = index

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
  def add_child(line, index)
    child = Node.new(line, index, self)
    @children << child

    # nesting debug
    # puts "node added: #{child.selector} with parent #{child.parent.selector if child.parent}"

    return child
  end

end

# ---------------
# Class Tests
# ---------------

# $default_indent = 2
# node = Node.new("p")
# node.add_property("  color: red")
# node.add_property("  background: blue")
# node2 = Node.new("  .hello", node)
# node2.add_property("    background-image: url('hello.png')\n".match($property_matcher))
# node2.list_properties
# puts node2.indent.inspect