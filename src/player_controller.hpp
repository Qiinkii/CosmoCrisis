#pragma once
#include <godot_cpp/classes/character_body3d.hpp>
#include <godot_cpp/classes/node3d.hpp>
#include <godot_cpp/classes/camera3d.hpp>
#include <godot_cpp/classes/ray_cast3d.hpp>
#include <godot_cpp/classes/marker3d.hpp>
#include <godot_cpp/classes/input_event.hpp>
#include <godot_cpp/variant/string.hpp>

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
    double garvity = 9.8;

    godot::String held_item_id = "";
    bool can_move = true;

protected:
    static void _bind_methods();

public: 
    void _ready() override;
    void _input(const godot::Ref<godot::InputEvent> &event) override;
    void _physics_process(double delta);

    godot::String get_held_item_id() const;
    void clear_held_item();
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
};