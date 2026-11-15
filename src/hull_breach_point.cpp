#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/classes/node3d.hpp>
#include "hull_breach_point.hpp"
#include "player_controller.hpp"
#include "ship_telemetry.hpp"
using namespace godot;

void  HullBreachPoint::_bind_methods(){
    ClassDB::bind_method(D_METHOD("get_location_id"), &HullBreachPoint::get_location_id);
    ClassDB::bind_method(D_METHOD("set_location_id", "val"), &HullBreachPoint::set_location_id);
    ADD_PROPERTY(PropertyInfo(Variant::INT, "location_id"), "set_location_id", "get_location_id");

    ClassDB::bind_method(D_METHOD("get_required_item_id"), &HullBreachPoint::get_required_item_id);
    ClassDB::bind_method(D_METHOD("set_required_item_id", "str"), &HullBreachPoint::set_required_item_id);
    ADD_PROPERTY(PropertyInfo(Variant::STRING, "required_item_id"), "set_required_item_id", "get_required_item_id");

    ClassDB::bind_method(D_METHOD("get_telemetry_path"), &HullBreachPoint::get_telemetry_path);
    ClassDB::bind_method(D_METHOD("set_telemetry_path", "path"), &HullBreachPoint::set_telemetry_path);
    ADD_PROPERTY(PropertyInfo(Variant::NODE_PATH, "telemetry_path"), "set_telemetry_path", "get_telemetry_path");

    ClassDB::bind_method(D_METHOD("on_breach_spawned", "id"), &HullBreachPoint::on_breach_spawned);
}

void  HullBreachPoint::_ready(){
    if(Engine::get_singleton()->is_editor_hint()){
        return;
    }
    if (!is_inside_tree()){    
        return;
    } 

    set_visible(false);
    set_collision_layer(0);

    Node *telemetry = get_node_or_null(telemetry_path);
    if(telemetry != nullptr){
        telemetry->connect("hull_breach_spawned", Callable(this, "on_breach_spawned"));
    }
}

void HullBreachPoint::on_breach_spawned(int id){
    if(id != location_id){
        return;
    }
    set_visible(true);
    set_collision_layer(2);
}

void HullBreachPoint::interact(Node *player){
    Interactable::interact(player);
    PlayerController *pc = Object::cast_to<PlayerController>(player);
    if(pc == nullptr){
        return;
    }
    if (pc->get_held_item_id() != required_item_id){
        return;
    }

    pc->clear_held_item();
    ShipTelemetry *telemetry = Object::cast_to<ShipTelemetry>(get_node_or_null(telemetry_path));
    if(telemetry != nullptr){
        telemetry->repair_hull_breach();
    }
    set_visible(false);
    set_collision_layer(0);
}

void HullBreachPoint::set_telemetry_path(const NodePath &path){
    telemetry_path = path; 
}

NodePath HullBreachPoint::get_telemetry_path() const{
    return telemetry_path; 
}

int HullBreachPoint::get_location_id() const{
    return location_id;
}

void HullBreachPoint::set_location_id(int val){
    location_id = val;
}


godot::String HullBreachPoint::get_required_item_id() const{
    return required_item_id;
}

void HullBreachPoint::set_required_item_id(godot::String str){
    required_item_id = str;
}