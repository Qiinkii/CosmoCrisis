#ifndef ECLSS_TERMINAL_HPP
#define ECLSS_TERMINAL_HPP

#include <godot_cpp/classes/node3d.hpp>
#include <godot_cpp/classes/tween.hpp>
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
    double lever_pull_deg = 145.0;

    int step = 0;
    bool is_animating = false;
    Vector3 old_cart_initial_pos;

    void resolve_default_paths();
    Interactable *get_inter(const NodePath &path) const;
    Interactable *get_slot_inter() const;
    void set_inter_state(Interactable *inter, bool active, const String &prompt = "", bool pickup = false);
    void animate_pivot_to(const NodePath &pivot_path, const Vector3 &target_deg, double duration, Tween::TransitionType trans);
    void animate_pivot_by(const NodePath &pivot_path, const Vector3 &delta_deg, double duration, Tween::TransitionType trans);
    void repair_telemetry();

protected:
    static void _bind_methods();

public:
    EclssTerminal() = default;
    ~EclssTerminal() override = default;

    void _ready() override;
    void _process(double delta) override;

    void on_interacted(Node *player);
    void on_anim_finished();

    void set_telemetry_path(const NodePath &p) { telemetry_path = p; }
    NodePath get_telemetry_path() const { return telemetry_path; }

    void set_valve_pivot_path(const NodePath &p) { valve_pivot_path = p; }
    NodePath get_valve_pivot_path() const { return valve_pivot_path; }
    void set_valve_interactable_path(const NodePath &p) { valve_interactable_path = p; }
    NodePath get_valve_interactable_path() const { return valve_interactable_path; }

    void set_lever1_pivot_path(const NodePath &p) { lever1_pivot_path = p; }
    NodePath get_lever1_pivot_path() const { return lever1_pivot_path; }
    void set_lever1_interactable_path(const NodePath &p) { lever1_interactable_path = p; }
    NodePath get_lever1_interactable_path() const { return lever1_interactable_path; }

    void set_lever2_pivot_path(const NodePath &p) { lever2_pivot_path = p; }
    NodePath get_lever2_pivot_path() const { return lever2_pivot_path; }
    void set_lever2_interactable_path(const NodePath &p) { lever2_interactable_path = p; }
    NodePath get_lever2_interactable_path() const { return lever2_interactable_path; }

    void set_cartridge_interactable_path(const NodePath &p) { cartridge_interactable_path = p; }
    NodePath get_cartridge_interactable_path() const { return cartridge_interactable_path; }

    void set_cartridge_slot_path(const NodePath &p) { cartridge_slot_path = p; }
    NodePath get_cartridge_slot_path() const { return cartridge_slot_path; }
    void set_slot_interactable_path(const NodePath &p) { slot_interactable_path = p; }
    NodePath get_slot_interactable_path() const { return slot_interactable_path; }

    void set_required_item_id(const String &id) { required_item_id = id; }
    String get_required_item_id() const { return required_item_id; }

    void set_valve_turn_deg(double deg) { valve_turn_deg = deg; }
    double get_valve_turn_deg() const { return valve_turn_deg; }
    void set_lever_pull_deg(double deg) { lever_pull_deg = deg; }
    double get_lever_pull_deg() const { return lever_pull_deg; }
};

#endif // ECLSS_TERMINAL_HPP