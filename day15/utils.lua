function File_exists(file)
  local f = io.open(file, "rb")
  if f then f:close() end
  return f ~= nil
end

function Lines_from(file)
  if not File_exists(file) then
    os.exit(-1, true)
  end
  local lines = {}
  for line in io.lines(file) do
    if string.len(line) ~= 0 then
      lines[#lines + 1] = line
    end
  end
  return lines
end

function Map(table, f)
  local t = {}
  for k, v in pairs(table) do
    t[k] = f(v)
  end
  return t
end

function Dump(o)
  if type(o) == 'table' then
    local s = '{ '
    for k, v in pairs(o) do
      if type(k) ~= 'number' then k = '"' .. k .. '"' end
      s = s .. '[' .. k .. '] = ' .. Dump(v) .. ','
    end
    return s .. '} '
  else
    return tostring(o)
  end
end
