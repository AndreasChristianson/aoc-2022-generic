import { resolveObjectURL } from 'buffer'
import { createReadStream } from 'fs'
import { stdout } from 'process'
import { createInterface } from 'readline'
import util from 'util'

const getData = () => {
  const fileStream = createReadStream('input.txt')

  const stream = createInterface({
    input: fileStream,
    crlfDelay: Infinity
  })
  return stream
}
const values = {}
var childCount=0;
var paths = {}

async function parseToObject() {
  const inputRegex = /(.+) - ([LR]+)/;
  for await (const line of getData()) {
    const match = line.match(inputRegex);
    var cursor = values
    for (const direction of match[2]) {
      if (!cursor[direction]) {
        cursor[direction] = {}
      }
      cursor = cursor[direction]

    };
    cursor.name = match[1]
    cursor.path=match[2]
    childCount++
    paths[match[2]] = match[1]
  }
}

await parseToObject()

// console.log(util.inspect(values, true, null))
console.log("childCount raw: "+childCount)
console.log("childCount deduped: "+Object.keys(paths).length)

var shortest = ""
var stops = Infinity
const recur = (cursor, depth) => {
  if (cursor.name && depth < stops) {
    shortest = cursor.name;
    stops = depth
  }
  if (cursor.L && !cursor.R) {
    recur(cursor.L, depth)
  } else if (!cursor.L && cursor.R) {
    recur(cursor.R, depth)
  } else if (cursor.R && cursor.L) {
    recur(cursor.L, depth + 1)
    recur(cursor.R, depth + 1)
  }
}
recur(values, 0)

console.log(stops)
console.log(shortest)

childCount=0

const traverse = (cursor, partialName) => {
  if (!cursor.R && cursor.L&&!cursor.name) {
    return traverse(cursor.L, partialName + "L")
  }
  if (cursor.R && !cursor.L&&!cursor.name) {
    return traverse(cursor.R, partialName + "R")
  }
  if (cursor.R && cursor.L&&!cursor.name) {
    return {
      child:false,
      name: partialName,
      links: [
        traverse(cursor.L, "L"),
        traverse(cursor.R, "R"),
      ]
    }
  }
  if (cursor.R && cursor.L&&cursor.name) {
    childCount++
    return {
      child:true,
      name: partialName+": "+cursor.name,
      path:cursor.path,
      links: [
        traverse(cursor.L, "L"),
        traverse(cursor.R, "R"),
      ]
    }
  }
  if (!cursor.R && cursor.L&&cursor.name) {
    childCount++
    return {
      child:true,
      name: partialName+": "+cursor.name,
      path:cursor.path,
      links: [
        traverse(cursor.L, "L")
      ]
    }
  }
  if (cursor.R && !cursor.L&&cursor.name) {
    childCount++
    return {
      child:true,
      name: partialName+": "+cursor.name,
      path:cursor.path,
      links: [
        traverse(cursor.R, "R")
      ]
    }
  }
  childCount++

  return {
    child:true,
    path: cursor.path,
    name: partialName + ": " + cursor.name,
    links: [
    ]
  }
}
const graph = traverse(values, "workshop")
console.log("childCount post-traverse: "+childCount)
const buildBackLinks = (node,backLink) => {
  for (const childNode of node.links) {
    buildBackLinks(childNode,node)
  }
  if(backLink!=null){
    node.backLink=backLink
  }
}
buildBackLinks(graph,null)
// console.log(util.inspect(graph, true, null))

const childrenNeedPresents = (node) => {
  if(node.child && ! node.visited){
    return true
  }
  
  for (const childNode of node.links) {
    if(childrenNeedPresents(childNode)){
      return true
    }
  }
}
const findNearestChildDown = (node, distanceSoFar) => {
  if(node.child&&!node.visited){
    return {
      distance:distanceSoFar,
      nodeWithChild: node,
      path: node.path,
      name:node.name
    }
  }
  var found = {distance:Infinity, nodeWithChild:null,path:"x"}
  for (const childNode of node.links) {
    var potential = findNearestChildDown(childNode, distanceSoFar+1)
    if(potential.distance<found.distance ||(potential.distance==found.distance &&potential.path<found.path)){
      if(potential.distance==found.distance){
        // console.log("more than one min distance down")
        // console.log("potential: "+potential.path+"("+potential.name+")")
        // console.log("found: "+found.path+"("+found.name+")")
      }
      found = potential
    }
  }
  return found
}

const findNearestChild = (node, distanceSoFar) => {
  var found = findNearestChildDown(node,distanceSoFar)
  while(node.backLink){
    distanceSoFar++
    node= node.backLink
    var potential = findNearestChildDown(node, distanceSoFar)
    if(potential.distance<found.distance ||(potential.distance==found.distance &&potential.path<found.path)){
      if(potential.distance==found.distance){
        // console.log("more than one min distance up")
        // console.log("potential: "+potential.path+"("+potential.name+")")
        // console.log("found: "+found.path+"("+found.name+")")
      }
      found = potential
    }
  }
  return found
}
var totalStops = 0
var cursor = graph
childCount=0
while (true){
  // console.log("at "+cursor.name)
  // console.log("count "+totalStops)
  const {distance, nodeWithChild}=findNearestChild(cursor,0)
  if(nodeWithChild!=null){
    // console.log("moving "+distance+" to "+nodeWithChild.name)
    childCount++
    totalStops+=distance
    cursor= nodeWithChild
    nodeWithChild.visited=true
  }else{
    break
  }
}

console.log(totalStops)
console.log("childCount new years dawn: "+childCount)
