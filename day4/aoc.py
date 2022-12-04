import re


def fullyOverlaps(first, second):
    if(min(first) <= min(second) and max(first) >= max(second)):
        return True
    return False


def anyOverlap(first, second):
    if(min(first) <= max(second) and min(first) >= min(second)):
        return True
    return False


pattern = '(\d+)-(\d+),(\d+)-(\d+)'
count = 0
count2 = 0
with open("input.txt") as file:
    lines = [line.rstrip() for line in file]
    for line in lines:
        matches = re.finditer(pattern, line)
        for match in matches:
            left = (int(match.group(1)), int(match.group(2)))
            right = (int(match.group(3)), int(match.group(4)))
            if(fullyOverlaps(left, right) or fullyOverlaps(right, left)):
                count = count+1
            if(anyOverlap(left, right) or anyOverlap(right, left)):
                count2 = count2+1


print(count)
print(count2)
