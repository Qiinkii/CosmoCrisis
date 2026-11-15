#include "eclss_terminal.hpp"
#include "player_controller.hpp"
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/classes/scene_tree.hpp>
#include <godot_cpp/classes/window.hpp>
#include <godot_cpp/classes/tween.hpp>
#include <godot_cpp/classes/property_tweener.hpp>
#include <godot_cpp/classes/callback_tweener.hpp>
#include <godot_cpp/variant/array.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

void EclssTerminal::_bind_methods() {
    ClassDB::bind_method(D_METHOD("set_telemetry_path", "p"), &EclssTerminal::set_telemetry_path);
    ClassDB::bind_method(D_METHOD("get_telemetry_path"), &EclssTerminal::get_telemetry_path);
    ADD_PROPERTY(PropertyInfo(Variant::NODE_PATH, "telemetry_path"), "set_telemetry_path", "get_telemetry_path");

    ClassDB::bind_method(D_METHOD("set_valve_pivot_path", "p"), &EclssTerminal::set_valve_pivot_path);
    ClassDB::bind_method(D_METHOD("get_valve_pivot_path"), &EclssTerminal::get_valve_pivot_path);
    ADD_PROPERTY(PropertyInfo(Variant::NODE_PATH, "valve_pivot_path"), "set_valve_pivot_path", "get_valve_pivot_path");

    ClassDB::bind_method(D_METHOD("set_valve_interactable_path", "p"), &EclssTerminal::set_valve_interactable_path);
    ClassDB::bind_method(D_METHOD("get_valve_interactable_path"), &EclssTerminal::get_valve_interactable_path);
    ADD_PROPERTY(PropertyInfo(Variant::NODE_PATH, "valve_interactable_path"), "set_valve_interactable_path", "get_valve_interactable_path");

    ClassDB::bind_method(D_METHOD("set_lever1_pivot_path", "p"), &EclssTerminal::set_lever1_pivot_path);
    ClassDB::bind_method(D_METHOD("get_lever1_pivot_path"), &EclssTerminal::get_lever1_pivot_path);
    ADD_PROPERTY(PropertyInfo(Variant::NODE_PATH, "lever1_pivot_path"), "set_lever1_pivot_path", "get_lever1_pivot_path");

    ClassDB::bind_method(D_METHOD("set_lever1_interactable_path", "p"), &EclssTerminal::set_lever1_interactable_path);
    ClassDB::bind_method(D_METHOD("get_lever1_interactable_path"), &EclssTerminal::get_lever1_interactable_path);
    ADD_PROPERTY(PropertyInfo(Variant::NODE_PATH, "lever1_interactable_path"), "set_lever1_interactable_path", "get_lever1_interactable_path");

    ClassDB::bind_method(D_METHOD("set_lever2_pivot_path", "p"), &EclssTerminal::set_lever2_pivot_path);
    ClassDB::bind_method(D_METHOD("get_lever2_pivot_path"), &EclssTerminal::get_lever2_pivot_path);
    ADD_PROPERTY(PropertyInfo(Variant::NODE_PATH, "lever2_pivot_path"), "set_lever2_pivot_path", "get_lever2_pivot_path");

    ClassDB::bind_method(D_METHOD("set_lever2_interactable_path", "p"), &EclssTerminal::set_lever2_interactable_path);
    ClassDB::bind_method(D_METHOD("get_lever2_interactable_path"), &EclssTerminal::get_lever2_interactable_path);
    ADD_PROPERTY(PropertyInfo(Variant::NODE_PATH, "lever2_interactable_path"), "set_lever2_interactable_path", "get_lever2_interactable_path");

    ClassDB::bind_method(D_METHOD("set_cartridge_interactable_path", "p"), &EclssTerminal::set_cartridge_interactable_path);
    ClassDB::bind_method(D_METHOD("get_cartridge_interactable_path"), &EclssTerminal::get_cartridge_interactable_path);
    ADD_PROPERTY(PropertyInfo(Variant::NODE_PATH, "cartridge_interactable_path"), "set_cartridge_interactable_path", "get_cartridge_interactable_path");

    ClassDB::bind_method(D_METHOD("set_cartridge_slot_path", "p"), &EclssTerminal::set_cartridge_slot_path);
    ClassDB::bind_method(D_METHOD("get_cartridge_slot_path"), &EclssTerminal::get_cartridge_slot_path);
    ADD_PROPERTY(PropertyInfo(Variant::NODE_PATH, "cartridge_slot_path"), "set_cartridge_slot_path", "get_cartridge_slot_path");

    ClassDB::bind_method(D_METHOD("set_slot_interactable_path", "p"), &EclssTerminal::set_slot_interactable_path);
    ClassDB::bind_method(D_METHOD("get_slot_interactable_path"), &EclssTerminal::get_slot_interactable_path);
    ADD_PROPERTY(PropertyInfo(Variant::NODE_PATH, "slot_interactable_path"), "set_slot_interactable_path", "get_slot_interactable_path");

    ClassDB::bind_method(D_METHOD("set_required_item_id", "id"), &EclssTerminal::set_required_item_id);
    ClassDB::bind_method(D_METHOD("get_required_item_id"), &EclssTerminal::get_required_item_id);
    ADD_PROPERTY(PropertyInfo(Variant::STRING, "required_item_id"), "set_required_item_id", "get_required_item_id");

    ClassDB::bind_method(D_METHOD("set_valve_turn_deg", "deg"), &EclssTerminal::set_valve_turn_deg);
    ClassDB::bind_method(D_METHOD("get_valve_turn_deg"), &EclssTerminal::get_valve_turn_deg);
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "valve_turn_deg"), "set_valve_turn_deg", "get_valve_turn_deg");

    ClassDB::bind_method(D_METHOD("set_lever_pull_deg", "deg"), &EclssTerminal::set_lever_pull_deg);
    ClassDB::bind_method(D_METHOD("get_lever_pull_deg"), &EclssTerminal::get_lever_pull_deg);
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "lever_pull_deg"), "set_lever_pull_deg", "get_lever_pull_deg");

    ClassDB::bind_method(D_METHOD("on_valve_interacted", "player"), &EclssTerminal::on_valve_interacted);
    ClassDB::bind_method(D_METHOD("on_lever1_interacted", "player"), &EclssTerminal::on_lever1_interacted);
    ClassDB::bind_method(D_METHOD("on_lever2_interacted", "player"), &EclssTerminal::on_lever2_interacted);
    ClassDB::bind_method(D_METHOD("on_old_cartridge_interacted", "player"), &EclssTerminal::on_old_cartridge_interacted);
    ClassDB::bind_method(D_METHOD("on_slot_interacted", "player"), &EclssTerminal::on_slot_interacted);
    ClassDB::bind_method(D_METHOD("on_anim_finished"), &EclssTerminal::on_anim_finished);
}

void EclssTerminal::set_interactable_active(Interactable *inter, bool active, bool pickup) {
    if (inter == nullptr) return;
    inter->set_collision_layer(active ? 2 : 0);
    inter->set_monitoring(active);
    inter->set_monitorable(active);
    inter->set_is_pickup(pickup);
}

void EclssTerminal::_ready() {
    if (Engine::get_singleton()->is_editor_hint()) return;

    Node3D *lever1_pivot = Object::cast_to<Node3D>(get_node_or_null(lever1_pivot_path));
    if (lever1_pivot) {
        // Исходное рабочее состояние красного рычага — вниз (+lever_pull_deg)
        Vector3 init_rot = lever1_pivot->get_rotation_degrees();
        init_rot.x += lever_pull_deg;
        lever1_pivot->set_rotation_degrees(init_rot);
    }

    Interactable *valve_inter = Object::cast_to<Interactable>(get_node_or_null(valve_interactable_path));
    Interactable *lever1_inter = Object::cast_to<Interactable>(get_node_or_null(lever1_interactable_path));
    Interactable *lever2_inter = Object::cast_to<Interactable>(get_node_or_null(lever2_interactable_path));
    Interactable *cart_inter = Object::cast_to<Interactable>(get_node_or_null(cartridge_interactable_path));
    Interactable *slot_inter = Object::cast_to<Interactable>(get_node_or_null(slot_interactable_path));

    if (slot_inter == nullptr && !cartridge_slot_path.is_empty()) {
        slot_inter = Object::cast_to<Interactable>(get_node_or_null(String(cartridge_slot_path) + "/Interactable"));
    }

    if (valve_inter) {
        valve_inter->connect("interacted", Callable(this, "on_valve_interacted"));
        valve_inter->set_prompt_text(String::utf8("Перекрыть вентиль"));
        set_interactable_active(valve_inter, true, false);
    }
    if (lever1_inter) {
        lever1_inter->connect("interacted", Callable(this, "on_lever1_interacted"));
        set_interactable_active(lever1_inter, false, false);
    }
    if (lever2_inter) {
        lever2_inter->connect("interacted", Callable(this, "on_lever2_interacted"));
        set_interactable_active(lever2_inter, false, false);
    }
    if (cart_inter) {
        cart_inter->connect("interacted", Callable(this, "on_old_cartridge_interacted"));
        set_interactable_active(cart_inter, false, false);
        old_cart_initial_pos = cart_inter->get_global_position();
    }
    if (slot_inter) {
        slot_inter->connect("interacted", Callable(this, "on_slot_interacted"));
        set_interactable_active(slot_inter, false, false);
    }
}

void EclssTerminal::_process(double delta) {
    if (Engine::get_singleton()->is_editor_hint() || step != 3) return;

    Interactable *cart_inter = Object::cast_to<Interactable>(get_node_or_null(cartridge_interactable_path));
    bool removed = false;
    if (cart_inter == nullptr || !cart_inter->is_inside_tree()) {
        removed = true;
    } else {
        Node3D *cart_body = Object::cast_to<Node3D>(cart_inter->get_parent());
        float dist_inter = cart_inter->get_global_position().distance_to(old_cart_initial_pos);
        float dist_body = cart_body ? cart_body->get_global_position().distance_to(old_cart_initial_pos) : 999.0f;
        if (dist_inter > 0.1f || dist_body > 0.1f || !cart_inter->is_visible_in_tree()) {
            removed = true;
        }
    }

    if (removed) {
        step = 4;
        Interactable *slot_inter = Object::cast_to<Interactable>(get_node_or_null(slot_interactable_path));
        if (slot_inter == nullptr && !cartridge_slot_path.is_empty()) {
            slot_inter = Object::cast_to<Interactable>(get_node_or_null(String(cartridge_slot_path) + "/Interactable"));
        }
        if (slot_inter) {
            slot_inter->set_prompt_text(String::utf8("Установить новый картридж LiOH"));
        }
        set_interactable_active(slot_inter, true, false);
        UtilityFunctions::print(String::utf8("Старый картридж извлечён. Установите новый картридж LiOH."));
    }
}

void EclssTerminal::on_anim_finished() {
    is_animating = false;
}

void EclssTerminal::on_valve_interacted(Node *player) {
    if (is_animating) return;

    Node3D *valve_pivot = Object::cast_to<Node3D>(get_node_or_null(valve_pivot_path));
    Interactable *valve_inter = Object::cast_to<Interactable>(get_node_or_null(valve_interactable_path));
    Interactable *lever1_inter = Object::cast_to<Interactable>(get_node_or_null(lever1_interactable_path));

    if (step == 0) {
        set_interactable_active(valve_inter, false, false);
        step = 1;

        if (valve_pivot) {
            is_animating = true;
            Vector3 target_rot = valve_pivot->get_rotation_degrees();
            target_rot.z += valve_turn_deg;

            Ref<Tween> tw = create_tween();
            tw->tween_property(valve_pivot, "rotation_degrees", target_rot, 0.75)
              ->set_trans(Tween::TRANS_SINE)->set_ease(Tween::EASE_IN_OUT);
            tw->tween_callback(Callable(this, "on_anim_finished"));
        }

        if (lever1_inter) {
            lever1_inter->set_prompt_text(String::utf8("Выключить красный рычаг (вверх)"));
            set_interactable_active(lever1_inter, true, false);
        }
    }
    else if (step == 5) {
        set_interactable_active(valve_inter, false, false);
        step = 6;

        if (valve_pivot) {
            is_animating = true;
            Vector3 target_rot = valve_pivot->get_rotation_degrees();
            target_rot.z -= valve_turn_deg;

            Ref<Tween> tw = create_tween();
            tw->tween_property(valve_pivot, "rotation_degrees", target_rot, 0.75)
              ->set_trans(Tween::TRANS_SINE)->set_ease(Tween::EASE_IN_OUT);
            tw->tween_callback(Callable(this, "on_anim_finished"));
        }

        Node *telemetry = get_node_or_null(telemetry_path);
        if (telemetry == nullptr && get_tree() != nullptr) {
            telemetry = get_tree()->get_first_node_in_group("telemetry");
        }
        if (telemetry == nullptr && get_tree() != nullptr && get_tree()->get_root() != nullptr) {
            Array stack;
            stack.push_back(get_tree()->get_root());
            while (stack.size() > 0) {
                Node *curr = Object::cast_to<Node>(stack.pop_back());
                if (curr == nullptr) continue;
                if (curr->is_class("ShipTelemetry") || curr->has_method("repair_co2_system")) {
                    telemetry = curr;
                    break;
                }
                for (int i = 0; i < curr->get_child_count(); i++) {
                    stack.push_back(curr->get_child(i));
                }
            }
        }

        if (telemetry != nullptr) {
            telemetry->call("repair_co2_system");
            UtilityFunctions::print(String::utf8("РЕГЕНЕРАЦИЯ CO2 ВОССТАНОВЛЕНА!"));
        }
    }
}

void EclssTerminal::on_lever1_interacted(Node *player) {
    if (is_animating || step != 1) return;

    Node3D *lever1_pivot = Object::cast_to<Node3D>(get_node_or_null(lever1_pivot_path));
    Interactable *lever1_inter = Object::cast_to<Interactable>(get_node_or_null(lever1_interactable_path));
    Interactable *lever2_inter = Object::cast_to<Interactable>(get_node_or_null(lever2_interactable_path));

    // Выключаем красный рычаг -> вверх (-lever_pull_deg)
    set_interactable_active(lever1_inter, false, false);
    step = 2;

    if (lever1_pivot) {
        is_animating = true;
        Vector3 target_rot = lever1_pivot->get_rotation_degrees();
        target_rot.x -= lever_pull_deg;

        Ref<Tween> tw = create_tween();
        tw->tween_property(lever1_pivot, "rotation_degrees", target_rot, 0.4)
          ->set_trans(Tween::TRANS_BACK)->set_ease(Tween::EASE_OUT);
        tw->tween_callback(Callable(this, "on_anim_finished"));
    }

    if (lever2_inter) {
        lever2_inter->set_prompt_text(String::utf8("Включить синий рычаг (вниз)"));
        set_interactable_active(lever2_inter, true, false);
    }
}

void EclssTerminal::on_lever2_interacted(Node *player) {
    if (is_animating || step != 2) return;

    Node3D *lever2_pivot = Object::cast_to<Node3D>(get_node_or_null(lever2_pivot_path));
    Interactable *lever2_inter = Object::cast_to<Interactable>(get_node_or_null(lever2_interactable_path));
    Interactable *cart_inter = Object::cast_to<Interactable>(get_node_or_null(cartridge_interactable_path));

    // Включаем синий рычаг -> вниз (+lever_pull_deg)
    set_interactable_active(lever2_inter, false, false);
    step = 3;

    if (lever2_pivot) {
        is_animating = true;
        Vector3 target_rot = lever2_pivot->get_rotation_degrees();
        target_rot.x += lever_pull_deg;

        Ref<Tween> tw = create_tween();
        tw->tween_property(lever2_pivot, "rotation_degrees", target_rot, 0.4)
          ->set_trans(Tween::TRANS_BACK)->set_ease(Tween::EASE_OUT);
        tw->tween_callback(Callable(this, "on_anim_finished"));
    }

    if (cart_inter) {
        old_cart_initial_pos = cart_inter->get_global_position();
        set_interactable_active(cart_inter, true, true);
    }
}

void EclssTerminal::on_old_cartridge_interacted(Node *player) {
    if (step != 3) return;
    step = 4;

    Interactable *slot_inter = Object::cast_to<Interactable>(get_node_or_null(slot_interactable_path));
    if (slot_inter == nullptr && !cartridge_slot_path.is_empty()) {
        slot_inter = Object::cast_to<Interactable>(get_node_or_null(String(cartridge_slot_path) + "/Interactable"));
    }
    if (slot_inter) {
        slot_inter->set_prompt_text(String::utf8("Установить новый картридж LiOH"));
    }
    set_interactable_active(slot_inter, true, false);
}

void EclssTerminal::on_slot_interacted(Node *player) {
    if (step != 4) return;

    PlayerController *pc = Object::cast_to<PlayerController>(player);
    if (pc == nullptr || pc->get_held_item_id() != required_item_id) return;

    Node3D *slot = Object::cast_to<Node3D>(get_node_or_null(cartridge_slot_path));
    if (slot == nullptr || !pc->place_held_item(slot)) return;

    Interactable *slot_inter = Object::cast_to<Interactable>(get_node_or_null(slot_interactable_path));
    if (slot_inter == nullptr && !cartridge_slot_path.is_empty()) {
        slot_inter = Object::cast_to<Interactable>(get_node_or_null(String(cartridge_slot_path) + "/Interactable"));
    }
    set_interactable_active(slot_inter, false, false);

    // Сразу после установки картриджа остаётся только закрыть вентиль
    step = 5;
    Interactable *valve_inter = Object::cast_to<Interactable>(get_node_or_null(valve_interactable_path));
    if (valve_inter) {
        valve_inter->set_prompt_text(String::utf8("Закрыть вентиль"));
        set_interactable_active(valve_inter, true, false);
    }
    UtilityFunctions::print(String::utf8("Новый картридж установлен! Закройте вентиль."));
}

void EclssTerminal::set_telemetry_path(const NodePath &p) { telemetry_path = p; }
NodePath EclssTerminal::get_telemetry_path() const { return telemetry_path; }

void EclssTerminal::set_valve_pivot_path(const NodePath &p) { valve_pivot_path = p; }
NodePath EclssTerminal::get_valve_pivot_path() const { return valve_pivot_path; }
void EclssTerminal::set_valve_interactable_path(const NodePath &p) { valve_interactable_path = p; }
NodePath EclssTerminal::get_valve_interactable_path() const { return valve_interactable_path; }

void EclssTerminal::set_lever1_pivot_path(const NodePath &p) { lever1_pivot_path = p; }
NodePath EclssTerminal::get_lever1_pivot_path() const { return lever1_pivot_path; }
void EclssTerminal::set_lever1_interactable_path(const NodePath &p) { lever1_interactable_path = p; }
NodePath EclssTerminal::get_lever1_interactable_path() const { return lever1_interactable_path; }

void EclssTerminal::set_lever2_pivot_path(const NodePath &p) { lever2_pivot_path = p; }
NodePath EclssTerminal::get_lever2_pivot_path() const { return lever2_pivot_path; }
void EclssTerminal::set_lever2_interactable_path(const NodePath &p) { lever2_interactable_path = p; }
NodePath EclssTerminal::get_lever2_interactable_path() const { return lever2_interactable_path; }

void EclssTerminal::set_cartridge_interactable_path(const NodePath &p) { cartridge_interactable_path = p; }
NodePath EclssTerminal::get_cartridge_interactable_path() const { return cartridge_interactable_path; }

void EclssTerminal::set_cartridge_slot_path(const NodePath &p) { cartridge_slot_path = p; }
NodePath EclssTerminal::get_cartridge_slot_path() const { return cartridge_slot_path; }
void EclssTerminal::set_slot_interactable_path(const NodePath &p) { slot_interactable_path = p; }
NodePath EclssTerminal::get_slot_interactable_path() const { return slot_interactable_path; }

void EclssTerminal::set_required_item_id(const String &id) { required_item_id = id; }
String EclssTerminal::get_required_item_id() const { return required_item_id; }

void EclssTerminal::set_valve_turn_deg(double deg) { valve_turn_deg = deg; }
double EclssTerminal::get_valve_turn_deg() const { return valve_turn_deg; }
void EclssTerminal::set_lever_pull_deg(double deg) { lever_pull_deg = deg; }
double EclssTerminal::get_lever_pull_deg() const { return lever_pull_deg; }