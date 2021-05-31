extends Resource
class_name ItemResource

export var name : String
export var id : int
export var stackable : bool = false
export var max_stack_size : int = 1

enum itemType { Generic, Consumable, Quest, Equipment, CraftingMaterial, Weapon }
export(itemType) var type 
export var texture : Texture
export var mesh : Mesh
export var mesh_texture: Material
