import sys
import volcdb

# Check if enough command-line arguments were provided
if len(sys.argv) != 3:
    print("Usage: python name.py <index_to_find> <frame>")
    sys.exit(1)

# Parse command-line arguments
index_to_find = int(sys.argv[1])  # convert from string to int
frame = sys.argv[2]

#frame = "142D_09148_131313"
volcanoes = volcdb.get_volcanoes_in_frame(frame)

#index_to_find = 2229  # dataframe index (not volc_id)

if index_to_find in volcanoes.index:
    volcano_name = volcanoes.loc[index_to_find, 'name']
#    print(f"Volcano name at index {index_to_find} is: {volcano_name}")
    print(f"{volcano_name}")
else:
    print(f"")
