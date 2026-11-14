#include "player_controller.hpp"
#include "interactable.hpp"
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/classes/input.hpp>
#include <godot_cpp/classes/input_event_mouse_motion.hpp>

using namespace godot;

void PlayerController::_bind_methods(){
    ClassDB::bind_method(D_METHOD("get_held_item_id"), &PlayerController::get_held_item_id);
    ClassDB::bind_method(D_METHOD("clear_held_item"), &PlayerController::clear_held_item);
    ADD_PROPERTY(PropertyInfo(Variant::STRING, "held_item_id"), "", "get_held_item_id");

    ClassDB::bind_method(D_METHOD("get_can_move"), &PlayerController::get_can_move);
    ClassDB::bind_method(D_METHOD("set_can_move", "move"), &PlayerController::set_can_move);
    ADD_PROPERTY(PropertyInfo(Variant::BOOL, "can_move"), "set_can_move", "get_can_move");

    ClassDB::bind_method(D_METHOD("get_move_speed"), &PlayerController::get_move_speed);
    ClassDB::bind_method(D_METHOD("set_move_speed", "speed"), &PlayerController::set_move_speed);
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "move_speed"), "set_move_speed", "get_move_speed");

    ClassDB::bind_method(D_METHOD("get_acceleration"), &PlayerController::get_acceleration);
    ClassDB::bind_method(D_METHOD("set_acceleration", "val"), &PlayerController::set_acceleration);
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "acceleration"), "set_acceleration", "get_acceleration");

    ClassDB::bind_method(D_METHOD("get_friction"), &PlayerController::get_friction);
    ClassDB::bind_method(D_METHOD("set_friction", "val"), &PlayerController::set_friction);
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "friction"), "set_friction", "get_friction");

    ClassDB::bind_method(D_METHOD("get_mouse_sensitivity"), &PlayerController::get_mouse_sensitivity);
    ClassDB::bind_method(D_METHOD("set_mouse_sensitivity", "val"), &PlayerController::set_mouse_sensitivity);
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "mouse_sensitivity"), "set_mouse_sensitivity", "get_mouse_sensitivity");

    ClassDB::bind_method(D_METHOD("get_garvity"), &PlayerController::get_garvity);
    ClassDB::bind_method(D_METHOD("set_garvity", "val"), &PlayerController::set_garvity);
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "garvity"), "set_garvity", "get_garvity");

    ADD_SIGNAL(MethodInfo("interaction_prompt_changed", PropertyInfo(Variant::BOOL, "visible"), PropertyInfo(Variant::STRING, "text")));
    ADD_SIGNAL(MethodInfo("held_item_changed", PropertyInfo(Variant::STRING, "item_id")));
}

void PlayerController::_ready(){
    if(Engine::get_singleton()->is_editor_hint()){
        return;
    }

    head = get_node<Node3D>("Head");
    camera = get_node<Camera3D>("Head/Camera3D");
    interaction_ray = get_node<RayCast3D>("Head/Camera3D/InteractionRay");
    hand_slot = get_node<Marker3D>("Head/Camera3D/HandSlot");
    Input::get_singleton()->set_mouse_mode(Input::MOUSE_MODE_CAPTURED);
}

void PlayerController::_input(const Ref<InputEvent> &event){
    if(Engine::get_singleton()->is_editor_hint() || !can_move){
        return;
    }

    Ref<InputEventMouseMotion> mouse_event = event;
    if(mouse_event.is_valid()){
        rotate_y(-mouse_event->get_relative().x * mouse_sensitivity);
        Vector3 head_rot = head->get_rotation();
        head_rot.x = Math::clamp(
            (real_t)(head_rot.x - mouse_event->get_relative().y * mouse_sensitivity),
            (real_t)Math::deg_to_rad(-85.0),(real_t)Math::deg_to_rad(85.0));
        head->set_rotation(head_rot);
    }

    if(interaction_ray->is_colliding()){
        Interactable *target = Object::cast_to<Interactable>(interaction_ray->get_collider());
        
    }
}

void PlayerController::_physics_process(double delta){
    if(Engine::get_singleton()->is_editor_hint()){
        return;
    }

    Vector2 input_dir = Input::get_singleton()->get_vector("move_left", "move_right", "move_forward", "move_backward");
    if(!can_move){
        input_dir = Vector2(0,0);
    }

    Vector3 direction = get_global_transform().get_basis().xform(Vector3(input_dir.x, 0, input_dir.y)).normalized();
    Vector3 velocity = get_velocity();
    if(!is_on_floor()){
        velocity.y -= garvity * delta;
    }

    if(direction.length() > 0.0){
        velocity.x = Math::move_toward(velocity.x, (real_t)(direction.x * move_speed), (real_t)(acceleration * delta));
        velocity.z = Math::move_toward(velocity.z, (real_t)(direction.z * move_speed), (real_t)(acceleration * delta));
    }
    else{
        velocity.x = Math::move_toward(velocity.x, (real_t)0.0, (real_t)(friction * delta));
        velocity.z = Math::move_toward(velocity.z, (real_t)0.0, (real_t)(friction * delta));
    }
    set_velocity(velocity);
    move_and_slide();
}

godot::String PlayerController::get_held_item_id() const{
    return held_item_id;
}
void PlayerController::clear_held_item(){
    held_item_id = "";
    emit_signal("held_item_changed", held_item_id);
}
bool PlayerController::get_can_move() const{
    return can_move;
}
void PlayerController::set_can_move(bool move){
    can_move = move;
}
double PlayerController::get_move_speed() const{
    return move_speed;
}
void PlayerController::set_move_speed(double speed){
    move_speed = speed;
}

double PlayerController::get_acceleration() const{
    return acceleration;
}
void PlayerController::set_acceleration(double val){
    acceleration = val;
}
double PlayerController::get_friction() const{
    return friction;
}
void PlayerController::set_friction(double val){
    friction = val;
}
double PlayerController::get_mouse_sensitivity() const{
    return mouse_sensitivity;
}
void PlayerController::set_mouse_sensitivity(double val){
    mouse_sensitivity = val;
}

double PlayerController::get_garvity() const{
    return garvity;
}
void PlayerController::set_garvity(double val){
    garvity = val;
}