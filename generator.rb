## Generator
# Generates pure css output. Takes the following options for the generation styles

# - minified
# - compressed
# - default
# - debug

$result = Array.new

# ----------------------------
# Internal Functions
# ----------------------------

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