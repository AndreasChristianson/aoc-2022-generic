import { createReadStream } from 'fs'
import { stdout } from 'process'
import { createInterface } from 'readline'

const getData = () => {
  const fileStream = createReadStream('input.txt')

  const stream = createInterface({
    input: fileStream,
    crlfDelay: Infinity
  })
  return stream
}
const values = []

async function parse() {
  var current = 0
  for await (const line of getData()) {
    if (line.trim().length == 0) {
      values.push(current)
      current = 0
    } else {
      current += parseInt(line)
    }
  }
}

await parse()
values.sort((left,right) => right-left)

stdout.write(values[0] + '\n')
stdout.write(values.slice(0,3).reduce((acc,curr)=>acc+curr,0) + '\n')

