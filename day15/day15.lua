require "utils"
require "sensors"


local function sensor_to_string(sensor)
  local function point_to_string(point)
    return '(' .. point.x .. ',' .. point.y .. ')'
  end

  return 's:' .. point_to_string(sensor.sensor_location) ..
      ' r:' .. sensor.range ..
      ' b:' .. point_to_string(sensor.beacon_location)
end

local function count_covered(ordered_sensors_at_row)
  local count = 0
  local current_pos = nil
  for i, range in ipairs(ordered_sensors_at_row) do
    if current_pos == nil or current_pos < range.start then
      count = count + range.finish - range.start
      current_pos = range.finish
    elseif current_pos < range.finish then
      count = count + range.finish - current_pos
      current_pos = range.finish
    end
  end
  return count
end

local function first_uncovered(ordered_sensors_at_row, max)
  local current_pos = 0
  for i, range in ipairs(ordered_sensors_at_row) do
    if current_pos > max then
      return nil
    elseif current_pos + 1 == range.start then
      current_pos = range.finish
    elseif current_pos + 1 < range.start then
      return current_pos + 1
    elseif current_pos < range.finish then
      current_pos = range.finish
    end
  end
end

local file = arg[1]
local lines = Lines_from(file)
local sensors = Map(lines, Parse_line)
local row = tonumber(arg[2])
local ordered_sensors_at_row = Get_sensors_for_row(sensors, row)

local covered = count_covered(ordered_sensors_at_row)
print("covered at row " .. row .. ": ", Dump(covered))

local max = tonumber(arg[4])
local min = tonumber(arg[3])
for curr_row = min, max do
  local curr_ordered_sensors_at_row = Get_sensors_for_row(sensors, curr_row)
  local uncovered = first_uncovered(curr_ordered_sensors_at_row, max)
  if uncovered then
    print("found the distress at row " .. curr_row .. ": ", Dump(uncovered))
    break
  end
end
