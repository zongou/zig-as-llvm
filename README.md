Create wrappers for zig

```sh
mkdir -p bin
for tool in ar cc c++ dlltool lib ranlib objcopy ld.lld; do
	ln -snf ../zig_wrapper.sh "bin/${tool}"
done
```
