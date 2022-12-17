class Producer<T> {
  List<T> list;
  int index = 0;
  Producer(this.list);

  T get() {
    return list[index++ % list.length];
  }
}
