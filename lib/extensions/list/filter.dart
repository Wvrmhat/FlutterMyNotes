extension Filter<T> on Stream<List<T>> {      //we have stream containting a list of things, now we wanta stream of the list of same things, 
  Stream<List<T>> filter(bool Function(T) where) =>   // we get the thing/item if it passes a specific test or returns as true
   map((items) => items.where(where).toList());       //  "where" parameter is used an accepts of type T
}