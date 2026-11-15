#include "eclss_terminal.hpp"
#include "player_controller.hpp"
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/classes/scene_tree.hpp>
#include <godot_cpp/classes/window.hpp>
#include <godot_cpp/classes/property_tweener.hpp>
#include <godot_cpp/classes/callback_tweener.hpp>
#include <godot_cpp/variant/array.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

#define BIND_PATH_PROP(prop_name, setter, getter) \
    ClassDB::bind_method(D_METHOD(#setter, "p"), &EclssTerminal::setter); \
    ClassDB::bind_method(D_METHOD(#getter), &EclssTerminal::getter); \
    ADD_PROPERTY(PropertyInfo(Variant::NODE_PATH, prop_name), #setter, #getter)

void EclssTerminal::_bind_methods() {
    BIND_PATH_PROP("telemetry_path", set_telemetry_path, get_telemetry_path);
    BIND_PATH_PROP("valve_pivot_path", set_valve_pivot_path, get_valve_pivot_path);
    BIND_PATH_PROP("valve_interactable_path", set_valve_interactable_path, get_valve_interactable_path);
    BIND_PATH_PROP("lever1_pivot_path", set_lever1_pivot_path, get_lever1_pivot_path);
    BIND_PATH_PROP("lever1_interactable_path", set_lever1_interactable_path, get_lever1_interactable_path);
    BIND_PATH_PROP("lever2_pivot_path", set_lever2_pivot_path, get_lever2_pivot_path);
    BIND_PATH_PROP("lever2_interactable_path", set_lever2_interactable_path, get_lever2_interactable_path);
    BIND_PATH_PROP("cartridge_interactable_path", set_cartridge_interactable_path, get_cartridge_interactable_path);
    BIND_PATH_PROP("cartridge_slot_path", set_cartridge_slot_path, get_cartridge_slot_path);
    BIND_PATH_PROP("slot_interactable_path", set_slot_interactable_path, get_slot_interactable_path);

    ClassDB::bind_method(D_METHOD("set_required_item_id", "id"), &EclssTerminal::set_required_item_id);
    ClassDB::bind_method(D_METHOD("get_required_item_id"), &EclssTerminal::get_required_item_id);
    ADD_PROPERTY(PropertyInfo(Variant::STRING, "required_item_id"), "set_required_item_id", "get_required_item_id");

    ClassDB::bind_method(D_METHOD("set_valve_turn_deg", "deg"), &EclssTerminal::set_valve_turn_deg);
    ClassDB::bind_method(D_METHOD("get_valve_turn_deg"), &EclssTerminal::get_valve_turn_deg);
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "valve_turn_deg"), "set_valve_turn_deg", "get_valve_turn_deg");

    ClassDB::bind_method(D_METHOD("set_lever_pull_deg", "deg"), &EclssTerminal::set_lever_pull_deg);
    ClassDB::bind_method(D_METHOD("get_lever_pull_deg"), &EclssTerminal::get_lever_pull_deg);
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "lever_pull_deg"), "set_lever_pull_deg", "get_lever_pull_deg");

    ClassDB::bind_method(D_METHOD("on_interacted", "player"), &EclssTerminal::on_interacted);
    ClassDB::bind_method(D_METHOD("on_anim_finished"), &EclssTerminal::on_anim_finished);
}

void EclssTerminal::resolve_default_paths() {
    if (valve_pivot_path.is_empty()) valve_pivot_path = NodePath("ECLSS_isolation_valve_002");
    if (valve_interactable_path.is_empty()) valve_interactable_path = NodePath("ECLSS_isolation_valve_002/Interactable");
    if (lever1_pivot_path.is_empty()) lever1_pivot_path = NodePath("ECLSS_flow_lever_0_002/Flow_lever_pivot_0_002");
    if (lever1_interactable_path.is_empty()) lever1_interactable_path = NodePath("ECLSS_flow_lever_0_002/Flow_lever_pivot_0_002/Interactable");
    if (lever2_pivot_path.is_empty()) lever2_pivot_path = NodePath("ECLSS_flow_lever_1_002/Flow_lever_pivot_1_002");
    if (lever2_interactable_path.is_empty()) lever2_interactable_path = NodePath("ECLSS_flow_lever_1_002/Flow_lever_pivot_1_002/Interactable");
    if (cartridge_interactable_path.is_empty()) cartridge_interactable_path = NodePath("ECLSS_Filter_Cartridge_002/Interactable");
    if (cartridge_slot_path.is_empty()) cartridge_slot_path = NodePath("CartridgeSlot");
    if (slot_interactable_path.is_empty()) slot_interactable_path = NodePath("CartridgeSlot/Interactable");
}

Interactable *EclssTerminal::get_inter(const NodePath &path) const {
    return Object::cast_to<Interactable>(get_node_or_null(path));
}

Interactable *EclssTerminal::get_slot_inter() const {
    Interactable *inter = get_inter(slot_interactable_path);
    if (inter == nullptr && !cartridge_slot_path.is_empty()) {
        inter = Object::cast_to<Interactable>(get_node_or_null(String(cartridge_slot_path) + "/Interactable"));
    }
    return inter;
}

void EclssTerminal::set_inter_state(Interactable *inter, bool active, const String &prompt, bool pickup) {
    if (inter == nullptr) return;
    if (!prompt.is_empty()) {
        inter->set_prompt_text(prompt);
    }
    inter->set_collision_layer(active ? 2 : 0);
    inter->set_monitoring(active);
    inter->set_monitorable(active);
    inter->set_is_pickup(pickup);
}

void EclssTerminal::animate_pivot_to(const NodePath &pivot_path, const Vector3 &target_deg, double duration, Tween::TransitionType trans) {
    Node3D *pivot = Object::cast_to<Node3D>(get_node_or_null(pivot_path));
    if (pivot == nullptr) return;

    is_animating = true;
    Ref<Tween> tw = create_tween();
    tw->tween_property(pivot, "rotation_degrees", target_deg, duration)
      ->set_trans(trans)->set_ease(Tween::EASE_OUT);
    tw->tween_callback(Callable(this, "on_anim_finished"));
}

void EclssTerminal::animate_pivot_by(const NodePath &pivot_path, const Vector3 &delta_deg, double duration, Tween::TransitionType trans) {
    Node3D *pivot = Object::cast_to<Node3D>(get_node_or_null(pivot_path));
    if (pivot == nullptr) return;
    animate_pivot_to(pivot_path, pivot->get_rotation_degrees() + delta_deg, duration, trans);
}

void EclssTerminal::on_anim_finished() {
    is_animating = false;
}

void EclssTerminal::_ready() {
    if (Engine::get_singleton()->is_editor_hint()) return;

    resolve_default_paths();

    const real_t down_x = (real_t)lever_pull_deg;

    // На старте красный рычаг (lever1) опущен МАКСИМАЛЬНО ВНИЗ вперёд: X = +145°
    if (Node3D *lever1 = Object::cast_to<Node3D>(get_node_or_null(lever1_pivot_path))) {
        Vector3 rot = lever1->get_rotation_degrees();
        rot.x = down_x;
        lever1->set_rotation_degrees(rot);
    }

    // На старте синий рычаг (lever2) закрыт ВВЕРХУ: X = 0.0°
    if (Node3D *lever2 = Object::cast_to<Node3D>(get_node_or_null(lever2_pivot_path))) {
        Vector3 rot = lever2->get_rotation_degrees();
        rot.x = 0.0f;
        lever2->set_rotation_degrees(rot);
    }

    Interactable *all_inters[] = {
        get_inter(valve_interactable_path),
        get_inter(lever1_interactable_path),
        get_inter(lever2_interactable_path),
        get_inter(cartridge_interactable_path),
        get_slot_inter()
    };

    for (Interactable *inter : all_inters) {
        if (inter != nullptr) {
            Callable cb = Callable(this, "on_interacted");
            if (!inter->is_connected("interacted", cb)) {
                inter->connect("interacted", cb);
            }
            set_inter_state(inter, false);
        }
    }

    set_inter_state(all_inters[0], true, String::utf8("Close the valve"));
}

void EclssTerminal::_process(double delta) {
    if (Engine::get_singleton()->is_editor_hint() || step != 3) return;

    Interactable *cart_inter = get_inter(cartridge_interactable_path);
    Node3D *cart_body = cart_inter ? Object::cast_to<Node3D>(cart_inter->get_parent()) : nullptr;

    bool removed = (cart_inter == nullptr || !cart_inter->is_inside_tree() || !cart_inter->is_visible_in_tree());
    if (!removed) {
        float dist = cart_body ? cart_body->get_global_position().distance_to(old_cart_initial_pos)
                               : cart_inter->get_global_position().distance_to(old_cart_initial_pos);
        removed = (dist > 0.05f);
    }

    if (removed) {
        step = 4;
        set_inter_state(cart_inter, false);
        set_inter_state(get_slot_inter(), true, String::utf8("Install a new LiOH cartridge"));
    }
}

void EclssTerminal::on_interacted(Node *player) {
    if (is_animating) return;

    const real_t down_x = (real_t)lever_pull_deg;

    switch (step) {
        case 0: // 1. Перекрываем вентиль -> активируем красный рычаг
            set_inter_state(get_inter(valve_interactable_path), false);
            animate_pivot_by(valve_pivot_path, Vector3(0, 0, valve_turn_deg), 0.75, Tween::TRANS_SINE);
            set_inter_state(get_inter(lever1_interactable_path), true, String::utf8("Push the red lever up"));
            step = 1;
            break;

        case 1: // 2. Поднимаем красный рычаг ВВЕРХ (X = 0) -> активируем синий рычаг
            set_inter_state(get_inter(lever1_interactable_path), false);
            if (Node3D *l1 = Object::cast_to<Node3D>(get_node_or_null(lever1_pivot_path))) {
                Vector3 target = l1->get_rotation_degrees();
                target.x = 0.0f;
                animate_pivot_to(lever1_pivot_path, target, 0.4, Tween::TRANS_BACK);
            }
            set_inter_state(get_inter(lever2_interactable_path), true, String::utf8("Flip the blue lever (down)"));
            step = 2;
            break;

        case 2: // 3. Опускаем синий рычаг МАКСИМАЛЬНО ВНИЗ вперёд (X = +145°) -> разрешаем достать старый картридж
            set_inter_state(get_inter(lever2_interactable_path), false);
            if (Node3D *l2 = Object::cast_to<Node3D>(get_node_or_null(lever2_pivot_path))) {
                Vector3 target = l2->get_rotation_degrees();
                target.x = down_x;
                animate_pivot_to(lever2_pivot_path, target, 0.4, Tween::TRANS_BACK);
            }
            if (Interactable *cart = get_inter(cartridge_interactable_path)) {
                Node3D *cart_body = Object::cast_to<Node3D>(cart->get_parent());
                old_cart_initial_pos = cart_body ? cart_body->get_global_position() : cart->get_global_position();
                set_inter_state(cart, true, String::utf8("Remove the used cartridge"), true);
            }
            step = 3;
            break;

        case 3: // Игрок забрал старый картридж -> открываем слот для нового
            set_inter_state(get_inter(cartridge_interactable_path), false);
            set_inter_state(get_slot_inter(), true, String::utf8("Install a new LiOH cartridge"));
            step = 4;
            break;

        case 4: { // 4. Ставим новый картридж в слот -> активируем вентиль
            PlayerController *pc = Object::cast_to<PlayerController>(player);
            Node3D *slot = Object::cast_to<Node3D>(get_node_or_null(cartridge_slot_path));
            if (pc == nullptr || slot == nullptr || pc->get_held_item_id() != required_item_id) return;
            if (!pc->place_held_item(slot)) return;

            set_inter_state(get_slot_inter(), false);
            set_inter_state(get_inter(valve_interactable_path), true, String::utf8("Close the valve"));
            step = 5;
            break;
        }

        case 5: // 5. Закрываем вентиль -> чиним систему CO2
            set_inter_state(get_inter(valve_interactable_path), false);
            animate_pivot_by(valve_pivot_path, Vector3(0, 0, -valve_turn_deg), 0.75, Tween::TRANS_SINE);
            repair_telemetry();
            step = 6;
            break;
    }
}

void EclssTerminal::repair_telemetry() {
    Node *telemetry = get_node_or_null(telemetry_path);
    if (telemetry == nullptr && get_tree() != nullptr && get_tree()->get_root() != nullptr) {
        Array stack;
        stack.push_back(get_tree()->get_root());
        while (stack.size() > 0) {
            Node *curr = Object::cast_to<Node>(stack.pop_back());
            if (curr && (curr->is_class("ShipTelemetry") || curr->has_method("repair_co2_system"))) {
                telemetry = curr;
                break;
            }
            for (int i = 0; curr && i < curr->get_child_count(); i++) {
                stack.push_back(curr->get_child(i));
            }
        }
    }
    if (telemetry != nullptr) {
        telemetry->call("repair_co2_system");
        UtilityFunctions::print(String::utf8("CO2 REGENERATION HAS BEEN RESTORED!"));
    }
}