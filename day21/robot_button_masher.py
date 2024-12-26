from collections import deque

codes = [
    "140A",
    "143A",
    "349A",
    "582A",
    "964A"
]

numeric_keypad = {"7": (0, 0), "8": (0, 1), "9": (0, 2), "4": (1, 0), "5": (1, 1), "6": (1, 2),
                    "1": (2, 0), "2": (2, 1), "3": (2, 2), "": (3, 0), "0": (3, 1), "A": (3, 2)}
directional_keypad = {"": (0, 0), "^": (0, 1), "A": (0, 2), "<": (1, 0), "v": (1, 1), ">": (1, 2)}

dirctions = ['^', 'v', '<', '>']

#  Eliminates paths that touch the blank spot on the keypad
def remove_impossible_paths(paths, start_pos, is_numeric=True):

    excluded_pos = (3,0) if is_numeric else (0,0)

    i = 0
    while i < len(paths):
        p = list(start_pos)
        for d in paths[i]:

            if d == "^":
                p[0] -= 1
            if d == "v":
                p[0] += 1

            if d == "<":
                p[1] -= 1
            if d == ">":
                p[1] += 1
            
            if tuple(p) == excluded_pos:
                paths.pop(i)
                i -= 1
                break
        i += 1

    return paths

def get_shortest_paths(start_pos, end_pos, is_numeric = True):
    # Generally two paths on the directional keypad -- horizontal first and vertical first
    v_d = "^" if end_pos[0] < start_pos[0] else "v"
    v_q = abs(end_pos[0] - start_pos[0])
    h_d = "<" if end_pos[1] < start_pos[1] else ">"
    h_q = abs(end_pos[1] - start_pos[1])

    return remove_impossible_paths(list(set([v_d * v_q + h_d * h_q, h_d * h_q + v_d * v_q ])), start_pos, is_numeric)

def solve_numeric(num):
    # Start at A
    pos = (3,2)

    sequence = []

    for n in num:
        p = numeric_keypad[n]
        paths = get_shortest_paths(pos, p, is_numeric=True)
        pos = p
        sequence.append(paths)
    
    sequence_parts = []
    for part in sequence:
        tmp = []
        for p in part:
            tmp.append("".join(p) + "A")
        
        sequence_parts.append(tmp)

    return sequence_parts


def solve_directional(seq):
    # Always start at A
    pos = (0,2)

    sequence = []

    for n in seq:
        p = directional_keypad[n]
        paths = get_shortest_paths(pos, p, is_numeric=False)
        pos = p
        sequence.append(paths)
    
    sequence_parts = []
    for part in sequence:
        tmp = []
        for p in part:
            tmp.append("".join(p) + "A")
        
        sequence_parts.append(tmp)

    return sequence_parts


memory = {}

def min_cost(seq, depth):
    if depth == 0:
        return len(seq)
    
    if (seq, depth) in memory:
        return memory[(seq, depth)]
    
    sub_sequences = solve_directional(seq)

    cost = 0
    for part in sub_sequences:
        cost += min([min_cost(seq, depth-1) for seq in part])
    
    memory[(seq, depth)] = cost
    return cost

p1_tot = 0
p2_tot = 0
for num in codes:
    sequence = solve_numeric(num)

    p1_seq_tot = 0
    p2_seq_tot = 0
    for part in sequence:
        p1_seq_tot += min([min_cost(seq, 2) for seq in part])
        p2_seq_tot += min([min_cost(seq, 25) for seq in part])
        

    p1_tot += int(num[:-1]) * p1_seq_tot
    p2_tot += int(num[:-1]) * p2_seq_tot

print(f"Part 1 Result: {p1_tot}")
print(f"Part 2 Result: {p2_tot}")