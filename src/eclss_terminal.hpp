#pragma once
#include <godot_cpp/classes/node.hpp>
#include <godot_cpp/classes/node3d.hpp>
#include <godot_cpp/variant/node_path.hpp>
#include <godot_cpp/variant/string.hpp>
#include <godot_cpp/variant/vector3.hpp>
#include "interactable.hpp"

class EclssTerminal : public godot::Node {
    GDCLASS(EclssTerminal, godot::Node);

private:
    godot::NodePath telemetry_path;
    godot::NodePath valve_pivot_path;
    godot::NodePath valve_interactable_path;
    godot::NodePath lever1_pivot_path;
    godot::NodePath lever1_interactable_path;
    godot::NodePath lever2_pivot_path;
    godot::NodePath lever2_interactable_path;
    godot::NodePath cartridge_interactable_path;
    godot::NodePath cartridge_slot_path;
    godot::NodePath slot_interactable_path;

    godot::String required_item_id = "lioh_cartridge";
    double valve_turn_deg = -360.0;
    double lever_pull_deg = 90.0;

    int step = 0;
    bool is_animating = false;
    godot::Vector3 old_cart_initial_pos;

    void set_interactable_active(Interactable *inter, bool active, bool pickup = false);

protected:
    static void _bind_methods();

public:
    void _ready() override;
    void _process(double delta) override;

    void on_valve_interacted(godot::Node *player);
    void on_lever1_interacted(godot::Node *player);
    void on_lever2_interacted(godot::Node *player);
    void on_old_cartridge_interacted(godot::Node *player);
    void on_slot_interacted(godot::Node *player);
    void on_anim_finished();

    void set_telemetry_path(const godot::NodePath &p);
    godot::NodePath get_telemetry_path() const;

    void set_valve_pivot_path(const godot::NodePath &p);
    godot::NodePath get_valve_pivot_path() const;
    void set_valve_interactable_path(const godot::NodePath &p);
    godot::NodePath get_valve_interactable_path() const;

    void set_lever1_pivot_path(const godot::NodePath &p);
    godot::NodePath get_lever1_pivot_path() const;
    void set_lever1_interactable_path(const godot::NodePath &p);
    godot::NodePath get_lever1_interactable_path() const;

    void set_lever2_pivot_path(const godot::NodePath &p);
    godot::NodePath get_lever2_pivot_path() const;
    void set_lever2_interactable_path(const godot::NodePath &p);
    godot::NodePath get_lever2_interactable_path() const;

    void set_cartridge_interactable_path(const godot::NodePath &p);
    godot::NodePath get_cartridge_interactable_path() const;

    void set_cartridge_slot_path(const godot::NodePath &p);
    godot::NodePath get_cartridge_slot_path() const;
    void set_slot_interactable_path(const godot::NodePath &p);
    godot::NodePath get_slot_interactable_path() const;

    void set_required_item_id(const godot::String &id);
    godot::String get_required_item_id() const;

    void set_valve_turn_deg(double deg);
    double get_valve_turn_deg() const;
    void set_lever_pull_deg(double deg);
    double get_lever_pull_deg() const;
};