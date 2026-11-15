#pragma once
#include <godot_cpp/classes/character_body3d.hpp>
#include <godot_cpp/classes/node3d.hpp>
#include <godot_cpp/classes/camera3d.hpp>
#include <godot_cpp/classes/ray_cast3d.hpp>
#include <godot_cpp/classes/marker3d.hpp>
#include <godot_cpp/classes/input_event.hpp>
#include <godot_cpp/variant/string.hpp>
#include <godot_cpp/classes/collision_shape3d.hpp>
#include <godot_cpp/classes/box_shape3d.hpp>

class PlayerController: public godot::CharacterBody3D{
    GDCLASS(PlayerController, godot::CharacterBody3D);

private:
    godot::Node3D *head = nullptr;
    godot::Camera3D *camera = nullptr;
    godot::RayCast3D *interaction_ray = nullptr;
    godot::Marker3D *hand_slot = nullptr;

    double move_speed = 4.0;
    double acceleration = 12.0;
    double friction = 10.0;
    double mouse_sensitivity = 0.002;
    double garvity = 3;
    double jump_velocity = 4;

    // У приватній секції player_controller.hpp:
    double crouch_speed = 2.0;
    double standing_height = 2.0;
    double crouching_height = 1.0;
    bool is_crouching = false;

    godot::CollisionShape3D *collision_shape = nullptr;

    godot::String held_item_id = "";
    bool can_move = true;
    uint64_t charging_target_id = 0;
    double interaction_hold_progress = 0.0;

protected:
    static void _bind_methods();

public: 
    void _ready() override;
    void _input(const godot::Ref<godot::InputEvent> &event) override;
    void _physics_process(double delta);

    godot::String get_held_item_id() const;
    void set_held_item_id(const godot::String &id);
    bool place_held_item(godot::Node3D *target_slot);
    void clear_held_item();
    godot::Node3D *take_held_item();
    bool get_can_move() const;
    void set_can_move(bool move);
    double get_move_speed() const;
    void set_move_speed(double speed);
    double get_acceleration() const;
    void set_acceleration(double val);
    double get_friction() const;
    void set_friction(double val);
    double get_mouse_sensitivity() const;
    void set_mouse_sensitivity(double val);
    double get_garvity() const;
    void set_garvity(double val);
    double get_jump_velocity() const;
    void set_jump_velocity(double val);
};
