#include <godot_cpp/core/class_db.hpp>
#include "interactable.hpp"

using namespace godot;

void Interactable::_bind_methods(){
    ClassDB::bind_method(D_METHOD("get_prompt_text"), &Interactable::get_prompt_text);
    ClassDB::bind_method(D_METHOD("set_prompt_text", "text"), &Interactable::set_prompt_text);
    ADD_PROPERTY(PropertyInfo(Variant::STRING, "prompt_text"), "set_prompt_text", "get_prompt_text");

    ClassDB::bind_method(D_METHOD("get_item_id"), &Interactable::get_item_id);
    ClassDB::bind_method(D_METHOD("set_item_id", "id"), &Interactable::set_item_id);
    ADD_PROPERTY(PropertyInfo(Variant::STRING, "item_id"), "set_item_id", "get_item_id");

    ClassDB::bind_method(D_METHOD("get_is_pickup"), &Interactable::get_is_pickup);
    ClassDB::bind_method(D_METHOD("set_is_pickup", "pick"), &Interactable::set_is_pickup);
    ADD_PROPERTY(PropertyInfo(Variant::BOOL, "is_pickup"), "set_is_pickup", "get_is_pickup");

    ClassDB::bind_method(D_METHOD("interact", "player"), &Interactable::interact);
    ADD_SIGNAL(MethodInfo("interacted", PropertyInfo(Variant::OBJECT, "player")));
}

godot::String Interactable::get_prompt_text() const{
    return prompt_text;
}

void Interactable::set_prompt_text(godot::String text){
    prompt_text = text;
}

godot::String Interactable::get_item_id() const{
    return item_id;
}

void Interactable::set_item_id(godot::String id){
    item_id = id;
}

bool Interactable::get_is_pickup() const{
    return is_pickup;
}

void Interactable::set_is_pickup(bool pick){
    is_pickup = pick;
}

void Interactable::interact(godot::Node *player){
    emit_signal("interacted", player);
}