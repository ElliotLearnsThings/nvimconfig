# Season mapping: 0=Winter, 1=Spring, 2=Summer, 3=Autumn
MONTH_TO_SEASON = {
    "january": 0,
    "february": 0,
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

# Season names for readability
SEASONS = {
    0: "",
    1: "this is new",
    2: "this is new",
    3: "this is new"
}

def read_file(filename="data.txt"):
    """
    Read animal data from file.
    Expected format: each line contains animal data separated by '/'
    Returns a list of animal records, where each record is a list of values
    """
    try:
        with open(filename) as f:
            lines = f.readlines()
            
        # Process the data - split each line by '/' and create a list of animal records
        animals = []
        for line in lines[1:]:  # Skip header line
            animal_data = [value.strip() for value in line.split("/")]
            animals.append(animal_data)
            
        return animals
    except FileNotFoundError:
        print(f"Error: File '{filename}' not found.")
        return []
    except Exception as e:
        print(f"Error reading file: {e}")
        return []

def is_time_overlap(visitor_start, visitor_end, animal_start, animal_end):
    """
    Check if the visitor's time overlaps with the animal's active time.
    Returns True if there is an overlap, False otherwise.
    """
    # Check if there's an overlap between the two time ranges
    return max(visitor_start, animal_start) < min(visitor_end, animal_end)

def main():
    """Main function to process user input and display available animals."""
    try:
        # Get user input
        user_input = input("What day will you come? (Format: day month time-range, e.g., '15 june 9-17'): ")
        user_input = user_input.strip().lower()
        
        # Parse input
        parts = user_input.split()
        if len(parts) < 3:
            print("Error: Invalid input format. Please use format 'day month time-range'")
            return
            
        # Extract day, month, and time range
        day = parts[0]
        month = parts[1]
        time_range = parts[2]
        
        # Parse visitor's time range
        try:
            time_parts = time_range.split("-")
            visitor_start_time = int(time_parts[0].strip())
            visitor_end_time = int(time_parts[1].strip())
            
            if visitor_start_time >= visitor_end_time:
                print("Error: Start time must be before end time")
                return
                
            if visitor_start_time < 0 or visitor_end_time > 24:
                print("Error: Time must be between 0 and 24")
                return
        except (ValueError, IndexError):
            print("Error: Invalid time format. Please use format 'start-end' (e.g., '9-17')")
            return
        
        # Get season from month
        try:
            season = MONTH_TO_SEASON[month]
            current_season = SEASONS[season]
            print(f"You're visiting in {current_season} (season {season})")
        except KeyError:
            print(f"Error: Invalid month '{month}'. Please enter a valid month name.")
            return
        
        # Get animal data
        animals = read_file()
        if not animals:
            return
            
        print(f"Animals available during your visit on {day} {month} between {visitor_start_time}-{visitor_end_time}:")
        found_animals = False
        
        # Process each animal
        for animal in animals:
            try:
                # Skip if animal is in hibernation during this season
                animal_hibernation_season = animal[1].lower()
                if animal_hibernation_season == SEASONS[season]:
                    continue
                    
                # Get animal's active hours
                active_hours = animal[3].split("-")
                animal_start_time = int(active_hours[0].strip())
                animal_end_time = int(active_hours[1].strip())
                
                # Check if visitor's time overlaps with animal's active time
                if is_time_overlap(visitor_start_time, visitor_end_time, animal_start_time, animal_end_time):
                    print(f"{animal[0]}: {animal_start_time}-{animal_end_time}")
                    found_animals = True
                    
            except (IndexError, ValueError) as e:
                print(f"Warning: Could not process animal data: {animal}. Error: {e}")
                continue
        
        if not found_animals:
            print("No animals available during your specified time.")
            
    except Exception as e:
        print(f"An unexpected error occurred: {e}")

if __name__ == "__main__":
    main()
