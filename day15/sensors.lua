function Parse_line(line)
  local sensor = {
    x = 0,
    y = 0,
    range = 0
  }
  local regex = "Sensor at x=(-?%d+), y=(-?%d+): closest beacon is at x=(-?%d+), y=(-?%d+)"
  local x1s, y1s, x2s, y2s = string.match(line, regex)

  local x1 = tonumber(x1s)
  local y1 = tonumber(y1s)
  local x2 = tonumber(x2s)
  local y2 = tonumber(y2s)


  return {
    sensor_location = {
      x = x1,
      y = y1,
    },
    range = math.abs(x1 - x2) + math.abs(y1 - y2),
    beacon_location = {
      x = x2,
      y = y2,
    },
  }
end

local function get_row_intersect(sensor, row)
  local range = {}
  local distance = math.abs(sensor.sensor_location.y - row)
  local leftover = sensor.range - distance
  if leftover < 0 then
    return nil
  end
  range.start = sensor.sensor_location.x - leftover
  range.finish = sensor.sensor_location.x + leftover
  return range
end

function Get_sensors_for_row(sensors, row)
  local ranges = {}
  for i, sensor in ipairs(sensors) do
    local row_intersect_range = get_row_intersect(sensor, row)
    if row_intersect_range then
      ranges[#ranges + 1] = row_intersect_range
    end
  end
  table.sort(ranges, function(left, right)
    return left.start < right.start
  end)
  return ranges
end
