-- Ponto de entrada da tradução PT-BR de FireRed e LeafGreen.
return function(mod)
  local function loadFeature(name)
    local path = "features/" .. name .. ".lua"
    local source = assert(mod:read(path), "Missing feature " .. path)
    local chunk, err = loadstring(source, "@" .. path)
    assert(chunk, tostring(err))
    local initialize = chunk()
    assert(type(initialize) == "function", path .. " must return an initializer")
    initialize(mod)
  end

  loadFeature("dialogue")
  loadFeature("graphics")
end
