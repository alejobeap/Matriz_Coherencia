import volcdb

frame = "142D_09148_131313"
volcanoes = volcdb.get_volcanoes_in_frame(frame)

index_to_find = 2229  # dataframe index (not volc_id)

if index_to_find in volcanoes.index:
    volcano_name = volcanoes.loc[index_to_find, 'name']
    print(f"Volcano name at index {index_to_find} is: {volcano_name}")
else:
    print(f"No volcano found with index {index_to_find}")


'''
#!/bin/bash

# Volcano DataFrame index to search for
volc_index=2229

# Run Python script and capture output
volcano_name=$(python3 get_volcano_name.py "$volc_index")

# Check if variable is empty (not found)
if [ -z "$volcano_name" ]; then
  echo "Volcano not found."
  exit 1
fi

echo "Volcano name is: $volcano_name"

# Use $volcano_name in next steps
# Example:
echo "Next steps with volcano $volcano_name"
# ... your commands here ...
'''
