# mangareader

https://blog.codemagic.io/flutter-state-management-with-riverpod/

> when we talk about managing state, we are referring to the data you need in order to rebuild your UI at any moment in time. 

> The state that is local to any widget is known as ephemeral state (sometimes also called UI state). As the state is contained within a single widget, there is no need for any complex state management techniques – just using a simple StatefulWidget to rebuild the UI is enough.

> The state that is shared across different widgets is known as the app state (sometimes also called shared state). This is where state management solutions help a lot.


https://github.com/Baseflow/flutter_cached_network_image

`Image(image: CachedNetworkImageProvider(url))`


## Isar vs Hive

https://crates.io/crates/sled
https://github.com/hivedb/hive/issues/246#issuecomment-756608325

> There are loads of existing database implementations in Rust that are far more advanced

I thought the same thing but the list of candidates is short. In fact, I didn't find a single database that is suitable for mobile devices and our requirements.

Also, to my knowledge, there is no database that is built as a counterpart to IndexedDB. It is not trivial to write a database that works exactly the same in the browser. IndexedDB is very different from most other databases.

As I said, I don't think there exists a single cross-platform database that also works in the browser and I don't think existing databases can be easily used with Dart and still have great performance. Realm, for example, will never work with Dart because it relies on proxy objects.

So I'm writing basically writing an abstraction around IndexedDB and LMDB in Rust which can be compiled to a binary or WASM.

And then there will be the Dart wrapper around this "backend".

`flutter pub run build_runner build`
ws://192.168.1.12:41000/auth-code/ws=

## Getting Started

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)
