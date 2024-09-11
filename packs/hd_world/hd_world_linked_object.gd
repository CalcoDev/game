class_name HDWorldLinkedObject

var linked_to: Object = null

func sync_with_linked() -> void:
    print(hash(self), " | ", hash(linked_to))
    # for prop in linked_to.get_property_list():
    #     var prop_name = prop["name"]
    #     var value = linked_to.get(prop_name)
    #     set(prop_name, value)
