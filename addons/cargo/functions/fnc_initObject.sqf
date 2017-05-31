/*
 * Author: Glowbal
 * Initializes variables for loadable objects. Called from init EH.
 *
 * Arguments:
 * 0: Object <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [object] call ace_cargo_fnc_initObject
 *
 * Public: No
 */
#include "script_component.hpp"

params ["_object"];
private _type = typeOf _object;
TRACE_2("params",_object,_type);

if ((_object getVariable [QGVAR(canLoad), getNumber (configFile >> "CfgVehicles" >> _type >> QGVAR(canLoad))]) != 1) exitWith {};

// do nothing if the class is already initialized
if (_type in GVAR(initializedItemClasses)) exitWith {};
GVAR(initializedItemClasses) pushBack _type;

TRACE_1("Adding load cargo action to class", _type);

private _condition = {
    GVAR(enable) &&
    {(_target getVariable [QGVAR(canLoad), getNumber (configFile >> "CfgVehicles" >> (typeOf _target) >> QGVAR(canLoad))]) == 1} &&
    {locked _target < 2} &&
    {alive _target} &&
    {[_player, _target, []] call EFUNC(common,canInteractWith)} &&
    {0 < {
            1 == getNumber (configFile >> "CfgVehicles" >> typeOf _x >> QGVAR(hasCargo)) &&
            {_x != _target}
        } count (nearestObjects [_player, CARGO_VEHICLE_CLASSES, MAX_LOAD_DISTANCE])}
};
private _statement = {
    [_player, _target] call FUNC(startLoadIn);
};
private _text = localize LSTRING(loadObject);
private _icon = QPATHTOF(UI\Icon_load.paa);

private _action = [QGVAR(load), _text, _icon, _statement, _condition, {call FUNC(addCargoVehiclesActions)}] call EFUNC(interact_menu,createAction);
[_type, 0, ["ACE_MainActions"], _action] call EFUNC(interact_menu,addActionToClass);

