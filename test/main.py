asdfasdf
MAP = {
    "january": 0,
    "feburary": 0,
    "march": 1,
    "april": 1,
    "may": 1,
    "june": 2,
    "july": 2,
    "august": 2,
    "september": 3,
    "october": 3,
    "november": 3,
    "december": 0,
}

def read_file():

    with open("data.txt") as f:
        data = f.readlines()
        data = [value.strip() for datapoint in data for value in datapoint.split("/")]
        _ = data.pop(0)

    return data

def main():

    s = input("What day will you come?")
    s = s.strip()
    strings = s.split(" ")
    # Get the enter time
    
    enter_times = strings[2].split("-")
    e_start_time = int(enter_times[0].strip())
    e_end_time = int(enter_times[1].strip())

    try:
        season = MAP[strings[1]]
    except Exception:
        print("bad input")
        return
    animals = read_file()
    for animal in animals:
        try:
            # 1 is the hibernation
            if (animal[1] == "winter" and season == 0) or (animal[1] == "spring" and season == 1) or (animal[1] == "summer" and season == 2) or (animal[1] == "autumn" and season == 3):
                continue
            times = animal[3].split("-")
        except Exception:
            continue
        try:
            l_start_time = int(times[0].strip())
            l_end_time = int(times[1].strip())
        except Exception:
            print("bad input")
            return
        if not ((e_end_time > l_start_time) or (e_start_time <= e_end_time)):
            return
        print(f"{animal[0]}: {l_start_time}-{l_end_time}")

main()
