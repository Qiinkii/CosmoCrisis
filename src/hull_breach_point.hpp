#pragma once
#include "interactable.hpp"
#include <godot_cpp/variant/node_path.hpp>
#include <godot_cpp/variant/string.hpp>
#include <godot_cpp/classes/node3d.hpp>

class HullBreachPoint: public Interactable{
    GDCLASS(HullBreachPoint, Interactable);
private:
    int location_id = 1;
    godot::String required_item_id = "epoxy_patch";
    godot::NodePath telemetry_path;
    godot::Node3D *breach_mesh = nullptr;
    godot::Node3D *patched_mesh = nullptr;
protected:
    static void _bind_methods();
public:
    void _ready() override;
    void on_breach_spawned(int id);
    void interact(godot::Node *player) override;

    int get_location_id() const;
    void set_location_id(int val);

    godot::String get_required_item_id() const;
    void set_required_item_id(godot::String str);

    void set_telemetry_path(const godot::NodePath &path);
    godot::NodePath get_telemetry_path() const;
};