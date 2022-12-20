export class Node<T> {
  public next: Node<T> | null = null;
  public prev: Node<T> | null = null;
  constructor(public data: T) {}

  public swapNext(){
    const oldPrev = this.prev!
    const oldNext = this.next!
    const oldNextNext = oldNext.next!
    oldPrev.next = oldNext
    oldNext.prev =  oldPrev

    oldNext.next = this
    this.prev = oldNext

    oldNextNext.prev = this
    this.next = oldNextNext
    // console.log(`swapped ${this.data} with ${oldNext.data}`)
  }

  public swapPrev(){
    const oldPrev = this.prev!
    const oldNext = this.next!
    const oldPrevPrev = oldPrev.prev!
    oldPrev.next = oldNext
    oldNext.prev =  oldPrev

    oldPrev.prev = this
    this.next=oldPrev

    this.prev = oldPrevPrev
    oldPrevPrev.next = this
    // console.log(`swapped ${this.data} with ${oldPrev.data}`)

  }
}