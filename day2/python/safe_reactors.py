
def is_safe_reactor(reactor):
    shifted_reactor = reactor[:-1]
    reactor_minus_first_value = reactor[1:]
    deltas = [reactor_minus_first_value[i] - shifted_reactor[i] for i in range(len(reactor) - 1)]
    return (all(delta > 0 for delta in deltas) or all(delta < 0 for delta in deltas)) and all(abs(delta) in range(1, 4) for delta in deltas)

def safe_reactors(rows):
    safe_reactors = 0
    for reactor in rows:
        if is_safe_reactor(reactor):
            safe_reactors += 1
    print(safe_reactors)



def safe_reactors_with_dampener(rows):
    safe_reactors = 0
    for reactor in rows:
        if is_safe_reactor(reactor):
            safe_reactors += 1
            continue
        
        # Try to remove each value from the reactor and check for safety again - brute force
        for i in range(len(reactor)):
            shortened_list = [x for j, x in enumerate(reactor) if j != i]
            if is_safe_reactor(shortened_list):
                safe_reactors += 1
                break
        
    print(safe_reactors)

# Read rows from levels.txt
with open('/Users/carterbradford/tech-stuff/aoc-2024/day2/levels.txt', 'r') as file:
    rows = [[int(value) for value in line.strip().split(' ')] for line in file]

safe_reactors(rows)
safe_reactors_with_dampener(rows)


