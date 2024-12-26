
wire_states = {}
connections = {}

def read_input():
    with open('initial_states.txt', 'r') as file:
        lines = file.readlines()

    with open('wiring_diagram.txt', 'r') as file:
        wiring_lines = file.readlines()
    
    
    for line in lines:
        key, value = line.split(':')
        wire_states[key.strip()] = int(value.strip())
    
    for connection in wiring_lines:
        input_wire, output_wire = connection.split('->')
        inputs = input_wire.strip()
        for op in ['AND', 'XOR', 'OR']:
            if op in inputs:
                input_wire_1, input_wire_2 = inputs.split(op)
                input_wire_1 = input_wire_1.strip()
                input_wire_2 = input_wire_2.strip()
                operator = op
                break
        output_wire = output_wire.strip()
        connections[output_wire] = (input_wire_1, input_wire_2, operator)


read_input()

part1_connections = connections.copy()
connections_left = len(connections)
while connections_left > 0:
    remaining_connections = part1_connections.copy()
    for output_wire, (input_wire_1, input_wire_2, operator) in remaining_connections.items():
        if input_wire_1 in wire_states and input_wire_2 in wire_states:
            if operator == 'AND':
                wire_states[output_wire] = wire_states[input_wire_1] & wire_states[input_wire_2]
            elif operator == 'XOR':
                wire_states[output_wire] = wire_states[input_wire_1] ^ wire_states[input_wire_2]
            elif operator == 'OR':
                wire_states[output_wire] = wire_states[input_wire_1] | wire_states[input_wire_2]
            connections_left -= 1
            del part1_connections[output_wire]
        

zStates = {wire: state for wire, state in wire_states.items() if wire.startswith('z')}
sorted_z = sorted(zStates.items(), key=lambda x: x[0], reverse=True)
binary_string = ''.join(str(state) for wire, state in sorted_z)
result = int(binary_string, 2)
print(result)

# Part 2 - Here we are just trying to find the connections that wouldn't make sense given
# the pattern
highest_z = sorted_z[0][0]
swap_needed = set()
for output_wire, (input_wire_1, input_wire_2, operator) in connections.items():
    if output_wire.startswith("z") and operator != "XOR" and output_wire != highest_z:
        swap_needed.add(output_wire)
    if (
        operator == "XOR"
        and output_wire[0] not in ["x", "y", "z"]
        and input_wire_1[0] not in ["x", "y", "z"]
        and input_wire_2[0] not in ["x", "y", "z"]
    ):
        swap_needed.add(output_wire)
    if operator == "AND" and "x00" not in [input_wire_1, input_wire_2]:
        if any(
            (output_wire == sub_input_wire_1 or output_wire == sub_input_wire_2) and sub_operator != "OR"
            for sub_output_wire, (sub_input_wire_1, sub_input_wire_2, sub_operator) in connections.items()
        ):
            swap_needed.add(output_wire)
    if operator == "XOR":
        if any(
            (output_wire == sub_input_wire_1 or output_wire == sub_input_wire_2) and sub_operator == "OR"
            for sub_output_wire, (sub_input_wire_1, sub_input_wire_2, sub_operator) in connections.items()
        ):
            swap_needed.add(output_wire)

print(",".join(sorted(swap_needed)))



