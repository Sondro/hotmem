package hotmem;

#if (cpp||js||flash||java||cs)

#if java
import hotmem.java.JavaUnsafe;
#end

#if cpp
private typedef ArrayBytesData = cpp.RawPointer<cpp.Char>;
#elseif (js||flash)
private typedef ArrayBytesData = Int;
#elseif java
private typedef ArrayBytesData = Dynamic;
#elseif cs
private typedef ArrayBytesData = cs.system.IntPtr;
#end

@:notNull
@:structAccess
@:unreflective
@:nativeGen
@:dce
abstract ArrayBytes(ArrayBytesData) from ArrayBytesData to ArrayBytesData {

#if cpp
	@:unreflective
	@:generic inline function new<T>(buffer:haxe.io.BytesData) {
		this = untyped __cpp__("{0}->GetBase()", buffer);
	}
#elseif java

	inline function new<T>(buffer:java.NativeArray<T>) {
		this = buffer;
	}
#elseif cs
	inline function new(ptr:cs.system.IntPtr) {
		this = ptr;
	}
#elseif (flash||js)
	inline function new(address:Int) {
		this = address;
	}
#end

::foreach TYPES::
	@:unreflective
	public inline function set::TYPE::(address:Int, value:::TYPE::):Void {
#if (flash || js)
		hotmem.HotMemory.set::TYPE::(this + address, value);
#elseif cpp
		untyped __cpp__("*((::CPP_POINTER_TYPE::)({0} + {1})) = {2}", this, address, value);
#elseif java
		untyped __java__("hotmem.java.JavaUnsafe.UNSAFE.::JAVA_UNSAFE_SET::({0}, hotmem.java.JavaUnsafe.BYTE_ARRAY_BASE_OFFSET + {1}, (::JAVA_LANG_TYPE::){2})", this, address, value);
#elseif cs
		hotmem.cs.UnsafeBytes.pset::TYPE::(this, address, value);
#end
	}

	@:unreflective
	public inline function get::TYPE::(address:Int):::TYPE:: {
#if (flash || js)
		return hotmem.HotMemory.get::TYPE::(this + address);
#elseif cpp
		return untyped __cpp__("*((::CPP_POINTER_TYPE::)({0} + {1}))", this, address);
#elseif java
		return untyped __java__("hotmem.java.JavaUnsafe.UNSAFE.::JAVA_UNSAFE_GET::({0}, hotmem.java.JavaUnsafe.BYTE_ARRAY_BASE_OFFSET + {1})::JAVA_UNSAFE_GET_BIT_AND::", this, address);
#elseif cs
		return hotmem.cs.UnsafeBytes.pget::TYPE::(this, address);
#else
		return 0;
#end
	}
::end::
}

#end