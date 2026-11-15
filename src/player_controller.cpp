#include "player_controller.hpp"
#include "interactable.hpp"
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/classes/input.hpp>
#include <godot_cpp/classes/input_event_mouse_motion.hpp>
#include <godot_cpp/classes/scene_tree.hpp>
#include <godot_cpp/classes/rigid_body3d.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

void PlayerController::_bind_methods(){
    ClassDB::bind_method(D_METHOD("get_held_item_id"), &PlayerController::get_held_item_id);
    ClassDB::bind_method(D_METHOD("clear_held_item"), &PlayerController::clear_held_item);
    ClassDB::bind_method(D_METHOD("take_held_item"), &PlayerController::take_held_item);
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
    if (interaction_ray != nullptr) {
    interaction_ray->add_exception(this);
}
    hand_slot = get_node<Marker3D>("Head/Camera3D/HandSlot");
    Input::get_singleton()->set_mouse_mode(Input::MOUSE_MODE_CAPTURED);
}

void PlayerController::_input(const Ref<InputEvent> &event){
    if(Engine::get_singleton()->is_editor_hint() || !can_move){
        return;
    }

    // ui unblock
    if(event->is_action_pressed("ui_cancel")){
        Input *input = Input::get_singleton();
        if(input->get_mouse_mode() == Input::MOUSE_MODE_CAPTURED){
            input->set_mouse_mode(Input::MOUSE_MODE_VISIBLE);
        } else {
            input->set_mouse_mode(Input::MOUSE_MODE_CAPTURED);
        }
        return;
    }

    if(!can_move || Input::get_singleton()->get_mouse_mode() != Input::MOUSE_MODE_CAPTURED){
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

    // 1. Обновление подсказки при наведении луча
    if (interaction_ray != nullptr && interaction_ray->is_colliding()) {
        Interactable *target = Object::cast_to<Interactable>(interaction_ray->get_collider());
        if (target != nullptr) {
            bool show = !target->get_is_pickup() || held_item_id.is_empty();
            emit_signal("interaction_prompt_changed", show, target->get_prompt_text());
        } else {
            emit_signal("interaction_prompt_changed", false, "");
        }
    } else {
        emit_signal("interaction_prompt_changed", false, "");
    }

    // 2. Взаимодействие при нажатии E ("interact")
  if (Input::get_singleton()->is_action_just_pressed("interact")) {
        UtilityFunctions::print("E pressed | colliding: ", interaction_ray != nullptr && interaction_ray->is_colliding());
        if (interaction_ray != nullptr && interaction_ray->is_colliding()) {
            Object *col = interaction_ray->get_collider();
            UtilityFunctions::print("Ray hit: ", col, " | as Interactable: ", Object::cast_to<Interactable>(col));
            Interactable *target = Object::cast_to<Interactable>(col);
            if (target != nullptr) {
                if (target->get_is_pickup()) {
                    if (held_item_id.is_empty() && hand_slot != nullptr && hand_slot->get_child_count() == 0) {
                        RigidBody3D *rb = Object::cast_to<RigidBody3D>(target->get_parent());
                        if (rb != nullptr) {
                            held_item_id = target->get_item_id();

                            rb->set_freeze_enabled(true);
                            rb->set_collision_layer(0);
                            rb->set_collision_mask(0);

                            target->set_monitoring(false);
                            target->set_monitorable(false);
                            target->set_collision_layer(0);

                            rb->reparent(hand_slot, false);
                            rb->set_position(Vector3(0, 0, 0));
                            rb->set_rotation(Vector3(0, 0, 0));

                            emit_signal("held_item_changed", held_item_id);
                        }
                    }
                } else {
                    // Взаимодействие со щитком (срабатывает и с кубом в руке, и без него)
                    target->interact(this);
                }
            }
        }
    }

    // 3. Выбрасывание предметов куба
    if(Input::get_singleton()->is_action_just_pressed("drop")){
        if(!held_item_id.is_empty() && hand_slot->get_child_count() > 0){
            Node3D *held_node = Object::cast_to<Node3D>(hand_slot->get_child(0));
            RigidBody3D *rb = Object::cast_to<RigidBody3D>(held_node);
            Vector3 forward = -camera->get_global_transform().basis.get_column(2);

            if(rb != nullptr){
                rb->reparent(get_tree()->get_current_scene(), true);
                rb->set_global_position(camera->get_global_position() + forward * 0.8);
                rb->set_collision_layer(1);
                rb->set_collision_mask(1);
                rb->set_freeze_enabled(false);
                rb->apply_central_impulse(forward * 2.5);

                Interactable *inter = rb->get_node<Interactable>("Interactable");
                if(inter != nullptr){
                    inter->set_monitoring(true);
                    inter->set_monitorable(true);
                    inter->set_collision_layer(2);
                }
            } else {
                Interactable *held_item = Object::cast_to<Interactable>(held_node);
                if(held_item != nullptr){
                    held_item->reparent(get_tree()->get_current_scene(), true);
                    held_item->set_global_position(camera->get_global_position() + forward * 0.8);
                    held_item->set_monitoring(true);
                    held_item->set_monitorable(true);
                    held_item->set_collision_layer(2);
                }
            }

            held_item_id = "";
            emit_signal("held_item_changed", held_item_id);
        }
    }
}

godot::String PlayerController::get_held_item_id() const{
    return held_item_id;
}

void PlayerController::clear_held_item(){
    if (hand_slot != nullptr && hand_slot->get_child_count() > 0) {
        hand_slot->get_child(0)->queue_free();
    }
    held_item_id = "";
    emit_signal("held_item_changed", held_item_id);
}

Node3D *PlayerController::take_held_item() {
    if (hand_slot != nullptr && hand_slot->get_child_count() > 0) {
        Node3D *item = Object::cast_to<Node3D>(hand_slot->get_child(0));
        held_item_id = "";
        emit_signal("held_item_changed", held_item_id);
        return item;
    }
    held_item_id = "";
    emit_signal("held_item_changed", held_item_id);
    return nullptr;
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