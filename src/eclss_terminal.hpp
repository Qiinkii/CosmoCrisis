#ifndef ECLSS_TERMINAL_HPP
#define ECLSS_TERMINAL_HPP

#include <godot_cpp/classes/node3d.hpp>
#include <godot_cpp/variant/node_path.hpp>
#include <godot_cpp/variant/string.hpp>
#include <godot_cpp/variant/vector3.hpp>
#include "interactable.hpp"

using namespace godot;

class EclssTerminal : public Node3D {
    GDCLASS(EclssTerminal, Node3D)

private:
    NodePath telemetry_path;

    NodePath valve_pivot_path;
    NodePath valve_interactable_path;

    NodePath lever1_pivot_path;
    NodePath lever1_interactable_path;

    NodePath lever2_pivot_path;
    NodePath lever2_interactable_path;

    NodePath cartridge_interactable_path;

    NodePath cartridge_slot_path;
    NodePath slot_interactable_path;

    String required_item_id = "lioh_cartridge";

    double valve_turn_deg = 180.0;
    double lever_pull_deg = 45.0;

    int step = 0;
    bool is_animating = false;
    Vector3 old_cart_initial_pos;

    void set_interactable_active(Interactable *inter, bool active, bool pickup = false);

protected:
    static void _bind_methods();

public:
    EclssTerminal() = default;
    ~EclssTerminal() override = default;

    void _ready() override;
    void _process(double delta) override;

    void on_valve_interacted(Node *player);
    void on_lever1_interacted(Node *player);
    void on_lever2_interacted(Node *player);
    void on_old_cartridge_interacted(Node *player);
    void on_slot_interacted(Node *player);
    void on_anim_finished();

    void set_telemetry_path(const NodePath &p);
    NodePath get_telemetry_path() const;

    void set_valve_pivot_path(const NodePath &p);
    NodePath get_valve_pivot_path() const;
    void set_valve_interactable_path(const NodePath &p);
    NodePath get_valve_interactable_path() const;

    void set_lever1_pivot_path(const NodePath &p);
    NodePath get_lever1_pivot_path() const;
    void set_lever1_interactable_path(const NodePath &p);
    NodePath get_lever1_interactable_path() const;

    void set_lever2_pivot_path(const NodePath &p);
    NodePath get_lever2_pivot_path() const;
    void set_lever2_interactable_path(const NodePath &p);
    NodePath get_lever2_interactable_path() const;

    void set_cartridge_interactable_path(const NodePath &p);
    NodePath get_cartridge_interactable_path() const;

    void set_cartridge_slot_path(const NodePath &p);
    NodePath get_cartridge_slot_path() const;
    void set_slot_interactable_path(const NodePath &p);
    NodePath get_slot_interactable_path() const;

    void set_required_item_id(const String &id);
    String get_required_item_id() const;

    void set_valve_turn_deg(double deg);
    double get_valve_turn_deg() const;
    void set_lever_pull_deg(double deg);
    double get_lever_pull_deg() const;
};

#endif // ECLSS_TERMINAL_HPP