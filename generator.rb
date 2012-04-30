## Generator
# Generates pure css output. Takes the following options for the generation styles

# - minified
# - compressed
# - default
# - debug

$result = []

# ----------------------------
# Internal Functions
# ----------------------------

# you forgot about pseudo-selectors son
# this should go back after generation and remove the space
# before any selector that starts with a colon. easiest that way
def generate_selector(node, full_selector)
  full_selector << node.selector
  unless node.parent.selector == 'root'
    generate_selector(node.parent, full_selector)
  end
  return full_selector
end

def add_selector(node, style)
  full_selector = []
  full_selector = generate_selector(node, full_selector)
  case style
  when 'minified'
    $result << "#{full_selector.reverse.join(" ")}{"
  when 'default'
    $result << "#{full_selector.reverse.join(" ")} {\n"
  when 'compressed'
    $result << "#{full_selector.reverse.join(" ")} { "
  when 'debug'
    $result << "/* line #{node.line}: */\n#{full_selector.reverse.join(" ")} {\n"
  else
    throw "Flagrant Error! You must choose a generation style: 'minified', 'compressed', 'default', or 'debug'"
  end
end

def add_properties(sel, style)
  case style
  when 'minified'
    sel.properties.each { |prop| $result << "#{prop.keys.first}:#{prop.values.first};" }
    $result << "}"
  when 'default'
    sel.properties.each { |prop| $result << "  #{prop.keys.first}: #{prop.values.first};\n" }
    $result << "}\n"
  when 'compressed'
    sel.properties.each { |prop| $result << "#{prop.keys.first}: #{prop.values.first}; " }
    $result << "}\n"
  when 'debug'
    sel.properties.each { |prop| $result << "  #{prop.keys.first}: #{prop.values.first};\n" }
    $result << "}\n"
  else
    throw "Flagrant Error! You must choose a generation style: 'minified', 'compressed', 'default', or 'debug'"
  end
end

def generate_tree(node, style)

  node.children.each do |sel|
    add_selector(sel, style)
    add_properties(sel, style)
    generate_tree(sel, style)
  end

end

# ----------------------------
# Main Function (external)
# ----------------------------

def generate(root, style)
  generate_tree(root, style)
  puts $result.join()
end