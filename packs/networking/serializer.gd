class_name Serializer

# NOTE(calco): 

static func Serialize(object: Object) -> PackedByteArray:
	var bytes = PackedByteArray()
	bytes.resize(ComputeByteSize(object))
	var c_offset: int = 0
	for property_dict in object.get_property_list():
		c_offset += _serialize_property(object, property_dict, bytes, c_offset)
	return bytes

static func Deserialize(bytes: PackedByteArray, type: Object) -> Variant:
	var object: Object = null
	if "default" in type:
		object = type.default()
	elif DummyPlayer.new.get_argument_count() == 0:
		object = type.new()
	else:
		# TODO(calco): Handle this better
		print(type)
		push_error("FATAL ERROR: Tried deserializing a type which has no `default` method, and overrides `_init`!")
	
	var c_offset: int = 0
	for property_dict in object.get_property_list():
		c_offset += _deserialize_property(object, property_dict, bytes, c_offset)
	return object

static func ComputeByteSize(object: Object) -> int:
	var c_offset: int = 0
	for property_dict in object.get_property_list():
		c_offset += _compute_byte_size(object, property_dict, c_offset)
	return c_offset
	
# Returns number of bytes read
static func _deserialize_property(object: Object, prop: Dictionary, bytes: PackedByteArray, c_offset: int) -> int:
	var name = prop["name"]
	if name == "script":
		return c_offset
	var type = prop["type"]
	var value
	match type:
		TYPE_NIL:
			return c_offset
		TYPE_BOOL:
			value = bytes.decode_u8(c_offset)
			c_offset += 1
		TYPE_INT:
			value = bytes.decode_s64(c_offset)
			c_offset += 8
		TYPE_FLOAT:
			value = bytes.decode_double(c_offset)
			c_offset += 8
		TYPE_STRING:
			var str_len = bytes.decode_s64(c_offset)
			c_offset += 8
			value = bytes.slice(c_offset, c_offset + str_len).get_string_from_utf8()
			c_offset += str_len
		TYPE_VECTOR2:
			var x = bytes.decode_double(c_offset)
			c_offset += 8
			var y = bytes.decode_double(c_offset)
			c_offset += 8
			value = Vector2(x, y)
		TYPE_VECTOR2I:
			var x = bytes.decode_s64(c_offset)
			c_offset += 8
			var y = bytes.decode_s64(c_offset)
			c_offset += 8
			value = Vector2i(x, y)
		# TYPE_RECT2:
		# TYPE_RECT2I:
		TYPE_VECTOR3:
			var x = bytes.decode_double(c_offset)
			c_offset += 8
			var y = bytes.decode_double(c_offset)
			c_offset += 8
			var z = bytes.decode_double(c_offset)
			c_offset += 8
			value = Vector3(x, y, z)
		TYPE_VECTOR3I:
			var x = bytes.decode_s64(c_offset)
			c_offset += 8
			var y = bytes.decode_s64(c_offset)
			c_offset += 8
			var z = bytes.decode_s64(c_offset)
			c_offset += 8
			value = Vector3i(x, y, z)
		# TYPE_TRANSFORM2D:
		# TYPE_VECTOR4:
		# TYPE_VECTOR4I:
		# TYPE_PLANE:
		# TYPE_QUATERNION:
		# TYPE_AABB:
		# TYPE_BASIS:
		# TYPE_TRANSFORM3D:
		# TYPE_PROJECTION:
		TYPE_COLOR:
			var r = bytes.decode_s64(c_offset)
			c_offset += 8
			var g = bytes.decode_s64(c_offset)
			c_offset += 8
			var b = bytes.decode_s64(c_offset)
			c_offset += 8
			var a = bytes.decode_s64(c_offset)
			c_offset += 8
			value = Color(r, g, b, a)
		# TYPE_STRING_NAME:
		# TYPE_NODE_PATH:
		# TYPE_RID:
		TYPE_OBJECT:
			c_offset += _deserialize_property(object, prop, bytes, c_offset)
		# TYPE_CALLABLE:
		# TYPE_SIGNAL:

		# TODO(calco): Actually implement serialization / deserialization for these bad boys
		# TYPE_DICTIONARY:
		# TYPE_ARRAY:
	
		TYPE_PACKED_BYTE_ARRAY:
			# bytes.append_array(value)
			# c_offset += value.size()
			var bytes_len = bytes.decode_s64(c_offset)
			c_offset += 8
			value = bytes.slice(c_offset, c_offset + bytes_len)
			c_offset += bytes_len
		# TYPE_PACKED_INT32_ARRAY:
		# TYPE_PACKED_INT64_ARRAY:
		# TYPE_PACKED_FLOAT32_ARRAY:
		# TYPE_PACKED_FLOAT64_ARRAY:
		# TYPE_PACKED_STRING_ARRAY:
		# TYPE_PACKED_VECTOR2_ARRAY:
		# TYPE_PACKED_VECTOR3_ARRAY:
		# TYPE_PACKED_COLOR_ARRAY:
		# TYPE_PACKED_VECTOR4_ARRAY:
		_:
			# TODO(calco): Better error information handling
			print(prop)
			push_error("FATAL ERROR: Tried deserializing an unsupported datatype!\n ", prop)
	object.set(name, value)
	return c_offset

# Returns number of bytes written
static func _serialize_property(object: Object, prop: Dictionary, bytes: PackedByteArray, c_offset: int) -> int:
	var name = prop["name"]
	if name == "script":
		return c_offset
	var type = prop["type"]
	var value = object.get(name)
	match type:
		TYPE_NIL:
			return c_offset
		TYPE_BOOL:
			bytes.encode_u8(c_offset, value)
			c_offset += 1
		TYPE_INT:
			bytes.encode_s64(c_offset, value)
			c_offset += 8
		TYPE_FLOAT:
			bytes.encode_double(c_offset, value)
			c_offset += 8
		TYPE_STRING:
			var arr = value.to_utf8_buffer()
			var size = arr.size()
			bytes.encode_s64(c_offset, size)
			c_offset += 8
			# TODO(calco): if only memset() existed in gdscript...
			# bytes.append_array(arr)
			var idx: int = 0
			while idx < size:
				bytes[c_offset + idx] = arr[idx]
				idx += 1
			c_offset += size
		TYPE_VECTOR2:
			bytes.encode_double(c_offset, value.x)
			c_offset += 8
			bytes.encode_double(c_offset, value.y)
			c_offset += 8
		TYPE_VECTOR2I:
			bytes.encode_s64(c_offset, value.x)
			c_offset += 8
			bytes.encode_s64(c_offset, value.y)
			c_offset += 8
		# TYPE_RECT2:
		# TYPE_RECT2I:
		TYPE_VECTOR3:
			bytes.encode_double(c_offset, value.x)
			c_offset += 8
			bytes.encode_double(c_offset, value.y)
			c_offset += 8
			bytes.encode_double(c_offset, value.z)
			c_offset += 8
		TYPE_VECTOR3I:
			bytes.encode_s64(c_offset, value.x)
			c_offset += 8
			bytes.encode_s64(c_offset, value.y)
			c_offset += 8
			bytes.encode_s64(c_offset, value.z)
			c_offset += 8
		# TYPE_TRANSFORM2D:
		# TYPE_VECTOR4:
		# TYPE_VECTOR4I:
		# TYPE_PLANE:
		# TYPE_QUATERNION:
		# TYPE_AABB:
		# TYPE_BASIS:
		# TYPE_TRANSFORM3D:
		# TYPE_PROJECTION:
		TYPE_COLOR:
			bytes.encode_double(c_offset, value.r)
			c_offset += 8
			bytes.encode_double(c_offset, value.g)
			c_offset += 8
			bytes.encode_double(c_offset, value.b)
			c_offset += 8
			bytes.encode_double(c_offset, value.a)
			c_offset += 8
		# TYPE_STRING_NAME:
		# TYPE_NODE_PATH:
		# TYPE_RID:
		TYPE_OBJECT:
			c_offset += _serialize_property(object, prop, bytes, c_offset)
		# TYPE_CALLABLE:
		# TYPE_SIGNAL:

		# TODO(calco): Actually implement serialization / deserialization for these bad boys
		# TYPE_DICTIONARY:
		# TYPE_ARRAY:
	
		TYPE_PACKED_BYTE_ARRAY:
			var size = value.size()
			bytes.encode_s64(c_offset, size)
			c_offset += 8
			# bytes.append_array(value)
			var idx: int = 0
			while idx < size:
				bytes[c_offset + idx] = value[idx]
				idx += 1
			c_offset += value.size()
		# TYPE_PACKED_INT32_ARRAY:
		# TYPE_PACKED_INT64_ARRAY:
		# TYPE_PACKED_FLOAT32_ARRAY:
		# TYPE_PACKED_FLOAT64_ARRAY:
		# TYPE_PACKED_STRING_ARRAY:
		# TYPE_PACKED_VECTOR2_ARRAY:
		# TYPE_PACKED_VECTOR3_ARRAY:
		# TYPE_PACKED_COLOR_ARRAY:
		# TYPE_PACKED_VECTOR4_ARRAY:
		_:
			# TODO(calco): Better error information handling
			print(prop)
			push_error("FATAL ERROR: Tried serializing an unsupported datatype!\n ", prop)
	return c_offset

static func _compute_byte_size(object: Object, prop: Dictionary, c_offset: int) -> int:
	var name = prop["name"]
	if name == "script":
		return c_offset
	var type = prop["type"]
	var value = object.get(name)
	match type:
		TYPE_NIL:
			return c_offset
		TYPE_BOOL:
			c_offset += 1
		TYPE_INT:
			c_offset += 8
		TYPE_FLOAT:
			c_offset += 8
		TYPE_STRING:
			var arr = value.to_utf8_buffer()
			var size = arr.size()
			c_offset += 8
			c_offset += size
		TYPE_VECTOR2:
			c_offset += 8
			c_offset += 8
		TYPE_VECTOR2I:
			c_offset += 8
			c_offset += 8
		# TYPE_RECT2:
		# TYPE_RECT2I:
		TYPE_VECTOR3:
			c_offset += 8
			c_offset += 8
			c_offset += 8
		TYPE_VECTOR3I:
			c_offset += 8
			c_offset += 8
			c_offset += 8
		# TYPE_TRANSFORM2D:
		# TYPE_VECTOR4:
		# TYPE_VECTOR4I:
		# TYPE_PLANE:
		# TYPE_QUATERNION:
		# TYPE_AABB:
		# TYPE_BASIS:
		# TYPE_TRANSFORM3D:
		# TYPE_PROJECTION:
		TYPE_COLOR:
			c_offset += 8
			c_offset += 8
			c_offset += 8
			c_offset += 8
		# TYPE_STRING_NAME:
		# TYPE_NODE_PATH:
		# TYPE_RID:
		TYPE_OBJECT:
			c_offset += _compute_byte_size(object, prop, c_offset)
		# TYPE_CALLABLE:
		# TYPE_SIGNAL:

		# TODO(calco): Actually implement serialization / deserialization for these bad boys
		# TYPE_DICTIONARY:
		# TYPE_ARRAY:
	
		TYPE_PACKED_BYTE_ARRAY:
			var size = value.size()
			c_offset += 8
			c_offset += value.size()
		# TYPE_PACKED_INT32_ARRAY:
		# TYPE_PACKED_INT64_ARRAY:
		# TYPE_PACKED_FLOAT32_ARRAY:
		# TYPE_PACKED_FLOAT64_ARRAY:
		# TYPE_PACKED_STRING_ARRAY:
		# TYPE_PACKED_VECTOR2_ARRAY:
		# TYPE_PACKED_VECTOR3_ARRAY:
		# TYPE_PACKED_COLOR_ARRAY:
		# TYPE_PACKED_VECTOR4_ARRAY:
		_:
			# TODO(calco): Better error information handling
			print(prop)
			push_error("FATAL ERROR: Tried serializing an unsupported datatype!\n ", prop)
	return c_offset
